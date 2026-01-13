// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ------------------------------ 核心依赖导入 ------------------------------
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";                    // ERC20代币标准接口
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";           // 安全ERC20操作工具
import "@openzeppelin/contracts/utils/Address.sol";                        // 地址安全操作工具
import "@openzeppelin/contracts/utils/math/Math.sol";                      // 数学工具函数

// ------------------------------ 可升级合约依赖 ------------------------------
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";        // 初始化合约基类
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";       // UUPS代理升级模式
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";  // 角色权限控制
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";        // 紧急暂停功能

/**
 * @title MetaNodeStake
 * @dev 基于 UUPS 模式的可升级质押挖矿合约，支持多资产池质押和 MetaNode 奖励分配
 * 主要功能包括：ETH/ERC20 多池质押、动态奖励计算、解质押锁定机制、紧急暂停功能
 * 采用累积奖励率模型，确保奖励计算的准确性和高效性
 */
contract MetaNodeStake is
    Initializable,        // 可升级合约初始化基类
    UUPSUpgradeable,      // UUPS代理升级模式实现
    PausableUpgradeable,  // 紧急暂停功能实现
    AccessControlUpgradeable  // 角色权限控制系统
{
    // ------------------------------ 库函数导入 ------------------------------
    using SafeERC20 for IERC20;  // 为IERC20添加安全操作方法
    using Address for address;    // 为address类型添加安全操作方法
    using Math for uint256;       // 为uint256类型添加数学操作方法

    // ------------------------------ 常量定义 ------------------------------
    
    // 管理员角色 - 拥有合约的大部分管理权限
    bytes32 public constant ADMIN_ROLE = keccak256("admin_role");
    // 升级角色 - 仅负责合约升级操作的权限
    bytes32 public constant UPGRADE_ROLE = keccak256("upgrade_role");

    // ETH资金池ID - 系统默认第一个资金池为ETH池
    uint256 public constant ETH_PID = 0;

    // ------------------------------ 数据结构 ------------------------------
    /*
    奖励计算基本原理：在任何时间点，用户有权获得但尚未分配的 MetaNode 数量为：

    待领取 MetaNode = (用户质押量 × 资金池累积奖励率) - 用户已领取奖励 + 待处理奖励

    当用户在资金池存入或取出质押代币时，发生以下操作：
    1. 更新资金池的累积奖励率 (accMetaNodePerST) 和上次奖励区块 (lastRewardBlock)
    2. 计算并累积用户的待领取 MetaNode 奖励
    3. 更新用户的质押数量 (stAmount)
    4. 更新用户的已领取奖励基准点 (finishedMetaNode)
    */
    
    /**
     * @dev 资金池结构体
     * 存储单个质押池的所有相关信息
     */
    struct Pool {
        // 质押代币的地址（ETH资金池为 address(0x0)）
        address stTokenAddress;
        // 不同资金池所占的权重，用于分配区块奖励
        uint256 poolWeight;
        // 资金池上次计算奖励的区块高度
        uint256 lastRewardBlock;
        // 每单位质押代币累积的 MetaNode 奖励 (带 18 位小数精度)
        uint256 accMetaNodePerST;
        // 资金池中的总质押代币数量
        uint256 stTokenAmount;
        // 最小质押数量
        uint256 minDepositAmount;
        // 解质押锁定的区块高度数
        uint256 unstakeLockedBlocks;
    }

    /**
     * @dev 解质押请求结构体
     * 记录用户的解质押请求信息
     */
    struct UnstakeRequest {
        // 用户申请解质押的代币数量
        uint256 amount;
        // 解质押请求可以释放的区块高度
        uint256 unlockBlocks;
    }

    /**
     * @dev 用户数据结构体
     * 记录用户在每个资金池中的质押和奖励信息
     */
    struct User {
        // 用户在当前资金池质押的代币数量
        uint256 stAmount;
        // 用户在当前资金池已经领取的 MetaNode 数量（奖励计算基准点）
        uint256 finishedMetaNode;
        // 用户在当前资金池当前可领取的 MetaNode 数量
        uint256 pendingMetaNode;
        // 用户在当前资金池的解质押请求列表
        UnstakeRequest[] requests;
    }

    // ------------------------------ 状态变量 ------------------------------
    // 质押挖矿开始的区块高度
    uint256 public startBlock;
    // 质押挖矿结束的区块高度
    uint256 public endBlock;
    // 每个区块高度产生的 MetaNode 奖励数量
    uint256 public MetaNodePerBlock;

    // 是否暂停提现功能
    bool public withdrawPaused;
    // 是否暂停领取奖励功能
    bool public claimPaused;

    // MetaNode 代币合约实例
    IERC20 public MetaNode;

    // 所有资金池的权重总和，用于计算各池奖励分配比例
    uint256 public totalPoolWeight;
    // 资金池列表，存储所有质押池信息
    Pool[] public pool;

    // 资金池 ID => 用户地址 => 用户信息映射，记录每个用户在各个池的质押信息
    mapping(uint256 => mapping(address => User)) public user;

    // ------------------------------ 事件定义 ------------------------------

    // 设置 MetaNode 代币地址事件
    event SetMetaNode(IERC20 indexed MetaNode);

    // 暂停提现事件
    event PauseWithdraw();

    // 恢复提现事件
    event UnpauseWithdraw();

    // 暂停领取奖励事件
    event PauseClaim();

    // 恢复领取奖励事件
    event UnpauseClaim();

    // 设置质押开始区块事件
    event SetStartBlock(uint256 indexed startBlock);

    // 设置质押结束区块事件
    event SetEndBlock(uint256 indexed endBlock);

    // 设置每个区块奖励数量事件
    event SetMetaNodePerBlock(uint256 indexed MetaNodePerBlock);

    // 添加资金池事件
    event AddPool(
        address indexed stTokenAddress,    // 质押代币地址
        uint256 indexed poolWeight,        // 资金池权重
        uint256 indexed lastRewardBlock,   // 上次奖励区块
        uint256 minDepositAmount,          // 最小质押数量
        uint256 unstakeLockedBlocks        // 解质押锁定区块数
    );

    // 更新资金池信息事件
    event UpdatePoolInfo(
        uint256 indexed poolId,            // 资金池ID
        uint256 indexed minDepositAmount,  // 最小质押数量
        uint256 indexed unstakeLockedBlocks // 解质押锁定区块数
    );

    // 设置资金池权重事件
    event SetPoolWeight(
        uint256 indexed poolId,            // 资金池ID
        uint256 indexed poolWeight,        // 新的资金池权重
        uint256 totalPoolWeight            // 更新后的总权重
    );

    // 更新资金池奖励事件
    event UpdatePool(
        uint256 indexed poolId,            // 资金池ID
        uint256 indexed lastRewardBlock,   // 上次奖励区块
        uint256 totalMetaNode              // 该区块产生的总奖励
    );

    // 质押事件
    event Deposit(address indexed user, uint256 indexed poolId, uint256 amount);

    // 申请解质押事件
    event RequestUnstake(
        address indexed user,              // 用户地址
        uint256 indexed poolId,            // 资金池ID
        uint256 amount                     // 解质押数量
    );

    // 提现事件
    event Withdraw(
        address indexed user,              // 用户地址
        uint256 indexed poolId,            // 资金池ID
        uint256 amount,                    // 提现数量
        uint256 indexed blockNumber        // 提现区块高度
    );

    // 领取奖励事件
    event Claim(
        address indexed user,              // 用户地址
        uint256 indexed poolId,            // 资金池ID
        uint256 MetaNodeReward             // 领取的奖励数量
    );

    // ************************************** 修饰符 **************************************

    /**
     * @dev 检查资金池 ID 是否有效
     * @param _pid 资金池 ID
     */
    modifier checkPid(uint256 _pid) {
        require(_pid < pool.length, "invalid pid");
        _;
    }

    /**
     * @dev 检查领取奖励功能是否未暂停
     */
    modifier whenNotClaimPaused() {
        require(!claimPaused, "claim is paused");
        _;
    }

    /**
     * @dev 检查提现功能是否未暂停
     */
    modifier whenNotWithdrawPaused() {
        require(!withdrawPaused, "withdraw is paused");
        _;
    }

    /**
     * @notice 合约初始化函数
     * @dev 仅在合约部署时调用一次，初始化基本参数和角色权限
     * @param _MetaNode MetaNode 代币合约地址
     * @param _startBlock 质押挖矿开始区块高度
     * @param _endBlock 质押挖矿结束区块高度
     * @param _MetaNodePerBlock 每个区块的 MetaNode 奖励数量
     */
    function initialize(
        IERC20 _MetaNode,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _MetaNodePerBlock
    ) public initializer {
        require(
            _startBlock <= _endBlock && _MetaNodePerBlock > 0,
            "invalid parameters"
        );

        __AccessControl_init();
        __UUPSUpgradeable_init();
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(UPGRADE_ROLE, msg.sender);
        _grantRole(ADMIN_ROLE, msg.sender);

        setMetaNode(_MetaNode);

        startBlock = _startBlock;
        endBlock = _endBlock;
        MetaNodePerBlock = _MetaNodePerBlock;
    }

    /**
     * @dev UUPS 升级授权函数
     * @param newImplementation 新的合约实现地址
     */
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(UPGRADE_ROLE) {}

    // ************************************** 管理员函数 **************************************

    /**
     * @notice 设置 MetaNode 代币地址
     * @dev 仅管理员可调用
     * @param _MetaNode MetaNode 代币合约地址
     */
    function setMetaNode(IERC20 _MetaNode) public onlyRole(ADMIN_ROLE) {
        MetaNode = _MetaNode;

        emit SetMetaNode(MetaNode);
    }

    /**
     * @notice 暂停提现功能
     * @dev 仅管理员可调用，用于应对紧急情况
     */
    function pauseWithdraw() public onlyRole(ADMIN_ROLE) {
        require(!withdrawPaused, "withdraw has been already paused");

        withdrawPaused = true;

        emit PauseWithdraw();
    }

    /**
     * @notice 恢复提现功能
     * @dev 仅管理员可调用
     */
    function unpauseWithdraw() public onlyRole(ADMIN_ROLE) {
        require(withdrawPaused, "withdraw has been already unpaused");

        withdrawPaused = false;

        emit UnpauseWithdraw();
    }

    /**
     * @notice 暂停领取奖励功能
     * @dev 仅管理员可调用，用于应对紧急情况
     */
    function pauseClaim() public onlyRole(ADMIN_ROLE) {
        require(!claimPaused, "claim has been already paused");

        claimPaused = true;

        emit PauseClaim();
    }

    /**
     * @notice 恢复领取奖励功能
     * @dev 仅管理员可调用
     */
    function unpauseClaim() public onlyRole(ADMIN_ROLE) {
        require(claimPaused, "claim has been already unpaused");

        claimPaused = false;

        emit UnpauseClaim();
    }

    /**
     * @notice 更新质押挖矿开始区块高度
     * @dev 仅管理员可调用，用于调整挖矿开始时间
     * @param _startBlock 新的开始区块高度
     */
    function setStartBlock(uint256 _startBlock) public onlyRole(ADMIN_ROLE) {
        // 验证新的开始区块必须小于等于结束区块
        require(
            _startBlock <= endBlock,
            "start block must be smaller than end block"
        );

        startBlock = _startBlock;

        emit SetStartBlock(_startBlock);
    }

    /**
     * @notice 更新质押挖矿结束区块高度
     * @dev 仅管理员可调用
     * @param _endBlock 新的结束区块高度
     */
    function setEndBlock(uint256 _endBlock) public onlyRole(ADMIN_ROLE) {
        require(
            startBlock <= _endBlock,
            "start block must be smaller than end block"
        );

        endBlock = _endBlock;

        emit SetEndBlock(_endBlock);
    }

    /**
     * @notice 更新每个区块的 MetaNode 奖励数量
     * @dev 仅管理员可调用
     * @param _MetaNodePerBlock 新的每区块奖励数量
     */
    function setMetaNodePerBlock(
        uint256 _MetaNodePerBlock
    ) public onlyRole(ADMIN_ROLE) {
        require(_MetaNodePerBlock > 0, "invalid parameter");

        MetaNodePerBlock = _MetaNodePerBlock;

        emit SetMetaNodePerBlock(_MetaNodePerBlock);
    }

    /**
     * @notice 添加新的质押资金池
     * @dev 仅管理员可调用，请勿重复添加相同的质押代币
     * @param _stTokenAddress 质押代币地址（ETH 池为 address(0)）
     * @param _poolWeight 资金池权重
     * @param _minDepositAmount 最小质押数量
     * @param _unstakeLockedBlocks 解质押锁定区块数
     * @param _withUpdate 是否先更新所有资金池
     */
    function addPool(
        address _stTokenAddress,
        uint256 _poolWeight,
        uint256 _minDepositAmount,
        uint256 _unstakeLockedBlocks,
        bool _withUpdate
    ) public onlyRole(ADMIN_ROLE) {
        // 默认第一个池为 ETH 池，因此第一个池必须使用 address(0x0) 添加
        if (pool.length > 0) {
            require(
                _stTokenAddress != address(0x0),
                "invalid staking token address"
            );
        } else {
            require(
                _stTokenAddress == address(0x0),
                "invalid staking token address"
            );
        }
        // 允许最小质押量为 0
        //require(_minDepositAmount > 0, "invalid min deposit amount");
        require(_unstakeLockedBlocks > 0, "invalid withdraw locked blocks");
        require(block.number < endBlock, "Already ended");

        if (_withUpdate) {
            massUpdatePools();
        }

        uint256 lastRewardBlock = block.number > startBlock
            ? block.number
            : startBlock;
        totalPoolWeight = totalPoolWeight + _poolWeight;

        pool.push(
            Pool({
                stTokenAddress: _stTokenAddress,
                poolWeight: _poolWeight,
                lastRewardBlock: lastRewardBlock,
                accMetaNodePerST: 0,
                stTokenAmount: 0,
                minDepositAmount: _minDepositAmount,
                unstakeLockedBlocks: _unstakeLockedBlocks
            })
        );

        emit AddPool(
            _stTokenAddress,
            _poolWeight,
            lastRewardBlock,
            _minDepositAmount,
            _unstakeLockedBlocks
        );
    }

    /**
     * @notice 更新资金池信息
     * @dev 仅管理员可调用，用于更新资金池的最小质押量和解质押锁定区块数
     * @param _pid 资金池 ID
     * @param _minDepositAmount 最小质押数量
     * @param _unstakeLockedBlocks 解质押锁定区块数
     */
    function updatePool(
        uint256 _pid,
        uint256 _minDepositAmount,
        uint256 _unstakeLockedBlocks
    ) public onlyRole(ADMIN_ROLE) checkPid(_pid) {
        pool[_pid].minDepositAmount = _minDepositAmount;
        pool[_pid].unstakeLockedBlocks = _unstakeLockedBlocks;

        emit UpdatePoolInfo(_pid, _minDepositAmount, _unstakeLockedBlocks);
    }

    /**
     * @notice 更新资金池权重
     * @dev 仅管理员可调用，用于调整各资金池的奖励分配比例
     * @param _pid 资金池 ID
     * @param _poolWeight 新的资金池权重
     * @param _withUpdate 是否先更新所有资金池
     */
    function setPoolWeight(
        uint256 _pid,
        uint256 _poolWeight,
        bool _withUpdate
    ) public onlyRole(ADMIN_ROLE) checkPid(_pid) {
        require(_poolWeight > 0, "invalid pool weight");

        if (_withUpdate) {
            massUpdatePools();
        }

        totalPoolWeight = totalPoolWeight - pool[_pid].poolWeight + _poolWeight;
        pool[_pid].poolWeight = _poolWeight;

        emit SetPoolWeight(_pid, _poolWeight, totalPoolWeight);
    }

    // ************************************** 查询函数 **************************************

    /**
     * @notice 获取资金池总数
     * @return 资金池数量
     */
    function poolLength() external view returns (uint256) {
        return pool.length;
    }

    /**
     * @notice 计算指定区块范围的奖励乘数
     * @dev 乘数计算公式: (结束区块 - 开始区块) * 每区块奖励数量
     * @param _from 开始区块高度（包含）
     * @param _to 结束区块高度（不包含）
     * @return multiplier 奖励乘数
     */
    function getMultiplier(
        uint256 _from,
        uint256 _to
    ) public view returns (uint256 multiplier) {
        require(_from <= _to, "区块范围无效");
        if (_from < startBlock) {
            _from = startBlock; // 确保从挖矿开始区块计算
        }
        if (_to > endBlock) {
            _to = endBlock; // 确保不超过挖矿结束区块
        }
        require(_from <= _to, "结束区块必须大于等于开始区块");
        bool success;
        (success, multiplier) = (_to - _from).tryMul(MetaNodePerBlock);
        require(success, "乘数计算溢出");
    }

    /**
     * @notice 获取用户在指定资金池的待领取 MetaNode 奖励数量
     * @param _pid 资金池 ID
     * @param _user 用户地址
     * @return 待领取的 MetaNode 奖励数量
     */
    function pendingMetaNode(
        uint256 _pid,
        address _user
    ) external view checkPid(_pid) returns (uint256) {
        return pendingMetaNodeByBlockNumber(_pid, _user, block.number);
    }

    /**
     * @notice 根据指定区块高度获取用户在资金池的待领取 MetaNode 奖励数量
     * @dev 计算公式: (用户质押量 * 当前累积奖励率) - 已领取奖励 + 待处理奖励
     * @param _pid 资金池 ID
     * @param _user 用户地址
     * @param _blockNumber 目标区块高度
     * @return 待领取的 MetaNode 奖励数量
     */
    function pendingMetaNodeByBlockNumber(
        uint256 _pid,
        address _user,
        uint256 _blockNumber
    ) public view checkPid(_pid) returns (uint256) {
        Pool storage pool_ = pool[_pid];
        User storage user_ = user[_pid][_user];
        uint256 accMetaNodePerST = pool_.accMetaNodePerST;
        uint256 stSupply = pool_.stTokenAmount;

        // 如果指定区块大于上次奖励计算区块且有质押量，则计算新的累积奖励率
        if (_blockNumber > pool_.lastRewardBlock && stSupply != 0) {
            uint256 multiplier = getMultiplier(
                pool_.lastRewardBlock,
                _blockNumber
            );
            // 根据资金池权重计算该池应得的奖励
            uint256 MetaNodeForPool = (multiplier * pool_.poolWeight) /
                totalPoolWeight;
            // 更新累积奖励率 (1 ether 用于精度转换)
            accMetaNodePerST = 
                accMetaNodePerST +
                (MetaNodeForPool * (1 ether)) /
                stSupply;
        }

        // 计算用户待领取奖励
        return
            (user_.stAmount * accMetaNodePerST) /
            (1 ether) -
            user_.finishedMetaNode +
            user_.pendingMetaNode;
    }

    /**
     * @notice 获取用户在指定资金池的质押数量
     * @param _pid 资金池 ID
     * @param _user 用户地址
     * @return 用户质押的代币数量
     */
    function stakingBalance(
        uint256 _pid,
        address _user
    ) external view checkPid(_pid) returns (uint256) {
        return user[_pid][_user].stAmount;
    }

    /**
     * @notice 获取用户的解质押请求信息
     * @dev 返回总解质押请求数量和当前可提取数量
     * @param _pid 资金池 ID
     * @param _user 用户地址
     * @return requestAmount 总解质押请求数量
     * @return pendingWithdrawAmount 当前可提取的解质押数量
     */
    function withdrawAmount(
        uint256 _pid,
        address _user
    )
        public
        view
        checkPid(_pid)
        returns (uint256 requestAmount, uint256 pendingWithdrawAmount)
    {
        User storage user_ = user[_pid][_user];

        // 遍历用户的所有解质押请求
        for (uint256 i = 0; i < user_.requests.length; i++) {
            if (user_.requests[i].unlockBlocks <= block.number) {
                // 如果已过解锁时间，累加可提取数量
                pendingWithdrawAmount = 
                    pendingWithdrawAmount +
                    user_.requests[i].amount;
            }
            // 累加总请求数量
            requestAmount = requestAmount + user_.requests[i].amount;
        }
    }

    // ************************************** PUBLIC FUNCTION **************************************

    /**
     * @notice Update reward variables of the given pool to be up-to-date.
     */
    function updatePool(uint256 _pid) public checkPid(_pid) {
        Pool storage pool_ = pool[_pid];

        if (block.number <= pool_.lastRewardBlock) {
            return;
        }

        (bool success1, uint256 totalMetaNode) = getMultiplier(
            pool_.lastRewardBlock,
            block.number
        ).tryMul(pool_.poolWeight);
        require(success1, "overflow");

        (success1, totalMetaNode) = totalMetaNode.tryDiv(totalPoolWeight);
        require(success1, "overflow");

        uint256 stSupply = pool_.stTokenAmount;
        if (stSupply > 0) {
            (bool success2, uint256 totalMetaNode_) = totalMetaNode.tryMul(
                1 ether
            );
            require(success2, "overflow");

            (success2, totalMetaNode_) = totalMetaNode_.tryDiv(stSupply);
            require(success2, "overflow");

            (bool success3, uint256 accMetaNodePerST) = pool_
                .accMetaNodePerST
                .tryAdd(totalMetaNode_);
            require(success3, "overflow");
            pool_.accMetaNodePerST = accMetaNodePerST;
        }

        pool_.lastRewardBlock = block.number;

        emit UpdatePool(_pid, pool_.lastRewardBlock, totalMetaNode);
    }

    /**
     * @notice Update reward variables for all pools. Be careful of gas spending!
     */
    function massUpdatePools() public {
        uint256 length = pool.length;
        for (uint256 pid = 0; pid < length; pid++) {
            updatePool(pid);
        }
    }

    /**
     * @notice Deposit staking ETH for MetaNode rewards
     */
    function depositETH() public payable whenNotPaused {
        Pool storage pool_ = pool[ETH_PID];
        require(
            pool_.stTokenAddress == address(0x0),
            "invalid staking token address"
        );

        uint256 _amount = msg.value;
        require(
            _amount >= pool_.minDepositAmount,
            "deposit amount is too small"
        );

        _deposit(ETH_PID, _amount);
    }

    /**
     * @notice Deposit staking token for MetaNode rewards
     * Before depositing, user needs approve this contract to be able to spend or transfer their staking tokens
     *
     * @param _pid       Id of the pool to be deposited to
     * @param _amount    Amount of staking tokens to be deposited
     */
    function deposit(
        uint256 _pid,
        uint256 _amount
    ) public whenNotPaused checkPid(_pid) {
        require(_pid != 0, "deposit not support ETH staking");
        Pool storage pool_ = pool[_pid];
        require(
            _amount > pool_.minDepositAmount,
            "deposit amount is too small"
        );

        if (_amount > 0) {
            IERC20(pool_.stTokenAddress).safeTransferFrom(
                msg.sender,
                address(this),
                _amount
            );
        }

        _deposit(_pid, _amount);
    }

    /**
     * @notice Unstake staking tokens
     *
     * @param _pid       Id of the pool to be withdrawn from
     * @param _amount    amount of staking tokens to be withdrawn
     */
    function unstake(
        uint256 _pid,
        uint256 _amount
    ) public whenNotPaused checkPid(_pid) whenNotWithdrawPaused {
        Pool storage pool_ = pool[_pid];
        User storage user_ = user[_pid][msg.sender];

        require(user_.stAmount >= _amount, "Not enough staking token balance");

        updatePool(_pid);

        uint256 pendingMetaNode_ = (user_.stAmount * pool_.accMetaNodePerST) /
            (1 ether) -
            user_.finishedMetaNode;

        if (pendingMetaNode_ > 0) {
            user_.pendingMetaNode = user_.pendingMetaNode + pendingMetaNode_;
        }

        if (_amount > 0) {
            user_.stAmount = user_.stAmount - _amount;
            user_.requests.push(
                UnstakeRequest({
                    amount: _amount,
                    unlockBlocks: block.number + pool_.unstakeLockedBlocks
                })
            );
        }

        pool_.stTokenAmount = pool_.stTokenAmount - _amount;
        user_.finishedMetaNode =
            (user_.stAmount * pool_.accMetaNodePerST) /
            (1 ether);

        emit RequestUnstake(msg.sender, _pid, _amount);
    }

    /**
     * @notice Withdraw the unlock unstake amount
     *
     * @param _pid       Id of the pool to be withdrawn from
     */
    function withdraw(
        uint256 _pid
    ) public whenNotPaused checkPid(_pid) whenNotWithdrawPaused {
        Pool storage pool_ = pool[_pid];
        User storage user_ = user[_pid][msg.sender];

        uint256 pendingWithdraw_;
        uint256 popNum_;
        for (uint256 i = 0; i < user_.requests.length; i++) {
            if (user_.requests[i].unlockBlocks > block.number) {
                break;
            }
            pendingWithdraw_ = pendingWithdraw_ + user_.requests[i].amount;
            popNum_++;
        }

        for (uint256 i = 0; i < user_.requests.length - popNum_; i++) {
            user_.requests[i] = user_.requests[i + popNum_];
        }

        for (uint256 i = 0; i < popNum_; i++) {
            user_.requests.pop();
        }

        if (pendingWithdraw_ > 0) {
            if (pool_.stTokenAddress == address(0x0)) {
                _safeETHTransfer(msg.sender, pendingWithdraw_);
            } else {
                IERC20(pool_.stTokenAddress).safeTransfer(
                    msg.sender,
                    pendingWithdraw_
                );
            }
        }

        emit Withdraw(msg.sender, _pid, pendingWithdraw_, block.number);
    }

    /**
     * @notice Claim MetaNode tokens reward
     *
     * @param _pid       Id of the pool to be claimed from
     */
    function claim(
        uint256 _pid
    ) public whenNotPaused checkPid(_pid) whenNotClaimPaused {
        Pool storage pool_ = pool[_pid];
        User storage user_ = user[_pid][msg.sender];

        updatePool(_pid);

        uint256 pendingMetaNode_ = (user_.stAmount * pool_.accMetaNodePerST) /
            (1 ether) -
            user_.finishedMetaNode +
            user_.pendingMetaNode;

        if (pendingMetaNode_ > 0) {
            user_.pendingMetaNode = 0;
            _safeMetaNodeTransfer(msg.sender, pendingMetaNode_);
        }

        user_.finishedMetaNode =
            (user_.stAmount * pool_.accMetaNodePerST) /
            (1 ether);

        emit Claim(msg.sender, _pid, pendingMetaNode_);
    }

    // ************************************** INTERNAL FUNCTION **************************************

    /**
     * @notice Deposit staking token for MetaNode rewards
     *
     * @param _pid       Id of the pool to be deposited to
     * @param _amount    Amount of staking tokens to be deposited
     */
    function _deposit(uint256 _pid, uint256 _amount) internal {
        Pool storage pool_ = pool[_pid];
        User storage user_ = user[_pid][msg.sender];

        updatePool(_pid);

        if (user_.stAmount > 0) {
            // uint256 accST = user_.stAmount.mulDiv(pool_.accMetaNodePerST, 1 ether);
            (bool success1, uint256 accST) = user_.stAmount.tryMul(
                pool_.accMetaNodePerST
            );
            require(success1, "user stAmount mul accMetaNodePerST overflow");
            (success1, accST) = accST.tryDiv(1 ether);
            require(success1, "accST div 1 ether overflow");

            (bool success2, uint256 pendingMetaNode_) = accST.trySub(
                user_.finishedMetaNode
            );
            require(success2, "accST sub finishedMetaNode overflow");

            if (pendingMetaNode_ > 0) {
                (bool success3, uint256 _pendingMetaNode) = user_
                    .pendingMetaNode
                    .tryAdd(pendingMetaNode_);
                require(success3, "user pendingMetaNode overflow");
                user_.pendingMetaNode = _pendingMetaNode;
            }
        }

        if (_amount > 0) {
            (bool success4, uint256 stAmount) = user_.stAmount.tryAdd(_amount);
            require(success4, "user stAmount overflow");
            user_.stAmount = stAmount;
        }

        (bool success5, uint256 stTokenAmount) = pool_.stTokenAmount.tryAdd(
            _amount
        );
        require(success5, "pool stTokenAmount overflow");
        pool_.stTokenAmount = stTokenAmount;

        // user_.finishedMetaNode = user_.stAmount.mulDiv(pool_.accMetaNodePerST, 1 ether);
        (bool success6, uint256 finishedMetaNode) = user_.stAmount.tryMul(
            pool_.accMetaNodePerST
        );
        require(success6, "user stAmount mul accMetaNodePerST overflow");

        (success6, finishedMetaNode) = finishedMetaNode.tryDiv(1 ether);
        require(success6, "finishedMetaNode div 1 ether overflow");

        user_.finishedMetaNode = finishedMetaNode;

        emit Deposit(msg.sender, _pid, _amount);
    }

    /**
     * @notice Safe MetaNode transfer function, just in case if rounding error causes pool to not have enough MetaNodes
     *
     * @param _to        Address to get transferred MetaNodes
     * @param _amount    Amount of MetaNode to be transferred
     */
    function _safeMetaNodeTransfer(address _to, uint256 _amount) internal {
        uint256 MetaNodeBal = MetaNode.balanceOf(address(this));

        if (_amount > MetaNodeBal) {
            MetaNode.transfer(_to, MetaNodeBal);
        } else {
            MetaNode.transfer(_to, _amount);
        }
    }

    /**
     * @notice Safe ETH transfer function
     *
     * @param _to        Address to get transferred ETH
     * @param _amount    Amount of ETH to be transferred
     */
    function _safeETHTransfer(address _to, uint256 _amount) internal {
        (bool success, bytes memory data) = address(_to).call{value: _amount}(
            ""
        );

        require(success, "ETH transfer call failed");
        if (data.length > 0) {
            require(
                abi.decode(data, (bool)),
                "ETH transfer operation did not succeed"
            );
        }
    }
}