// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";


contract MetaNodeStake is Initializable, UUPSUpgradeable, AccessControlUpgradeable, PausableUpgradeable {
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE"); // 升级合约角色
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE"); // 暂停合约角色
    //ADMIN
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE"); // 管理员角色

    uint256 public constant ETH_PID = 0; // ETH pool ID


    using SafeERC20 for IERC20; // 安全操作ERC20代币
    using Address for address; // 地址操作辅助函数
    using Math for uint256; // 数学操作辅助函数

    //定义pool结构体
    struct Pool {
     //质押代币地址
     address stTokenAddress;
     //pool权重
     uint256 poolWeight;
     //上次奖励块号
     uint256 lastRewardBlock;
     uint256 accMetaNodePerShare; // 每个质押代币的MetNode奖励比例
     uint256 stTokenAmount; // 总质押数量
     uint256 minStTokenAmount; // 最小质押数量
     //解质押区块高度
     uint256 unStakingBlock;
    }

    struct UnstakeRequest {
        uint256 amount; // 解质押数量
        uint256 unstakingBlock; // 解质押区块高度
    }

    struct  User{
        uint256 stAmount; // 质押数量
        uint256 finishedMetaNode; // 已解质押数量
        uint256 pendingMetaNode; // 待解质押数量
        UnstakeRequest[] unstakeRequests; // 解质押请求队列
    }

    //=====状态变量
    uint256 public startBlock; // 合约启动块号
    uint256 public endBlock; // 合约结束块号
    uint256 public MetaNodePreBlock; // 上次奖励块号
    bool public claimPaused; // 是否暂停体现
    bool public withdrawPaused; // 是否暂停领取奖励
    IERC20 public MetNodeToken; // MetNode代币合约地址

    uint256 public totalPoolWeight; // 总pool权重
     Pool[] public pools; // pool数组

     mapping(uint256 =>mapping(address =>User)) public users; // 用户质押信息映射

     //======event

     event SetMetaNode(IERC20 indexed MetNodeToken); // 设置MetNode代币合约地址

     event PauseWithdraw(bool indexed withdrawPaused); // 暂停领取奖励
    event UnpauseWithdraw(bool indexed withdrawPaused); // 取消暂停领取奖励
    event PauseClaim(bool indexed claimPaused); // 暂停体现
    event UnpauseClaim(bool indexed claimPaused); // 取消暂停体现
    event SetStartBlock(uint256 indexed startBlock); // 设置合约启动块号
    event SetEndBlock(uint256 indexed endBlock); // 设置合约结束块号

    event SetMetaNodePreBlock(uint256 indexed MetaNodePreBlock); // 设置上次奖励块号

    event AddPool(
        address indexed stTokenAddress, // 质押代币地址
        uint256 indexed poolWeight, // pool权重
        uint256 indexed lastRewardBlock, // 上次奖励块号
        uint256  minStTokenAmount, // 最小质押数量
        uint256 indexed unStakingBlock // 解质押区块高度
    ); // 添加pool

    event SetPoolWeight(
        uint256 indexed poolId, // pool编号
        uint256 indexed poolWeight, // pool权重
        uint256 totalPoolWeight // 总pool权重
    ); // 设置pool权重
    event UpdatePool(
        uint256 indexed poolId, // pool编号
        uint256 indexed lastRewardBlock, // 上次奖励块号
        uint256 totalMetaNodeAmount, // 总MetNode奖励数量
        uint256 totalStTokenAmount // 总质押数量
    ); // 更新pool
    event Deposit(
        address indexed user, // 用户地址
        uint256 indexed poolId, // pool编号
        uint256 amount // 质押数量
    ); // 质押
    event Withdraw(
        address indexed user, // 用户地址
        uint256 indexed poolId, // pool编号
        uint256 amount // 领取数量
    ); // 领取奖励
    event Claim(
        address indexed user, // 用户地址
        uint256 indexed poolId, // pool编号
        uint256 amount // 体现数量
    ); // 提现

      event RequestUnstake(
        address indexed user,
        uint256 indexed poolId,
        uint256 amount
    ); // 申请解质押
    
    event Unstake(
        address indexed user,
        uint256 indexed poolId,
        uint256 amount,
        uint256 unstakingBlock
    ); // 完成解质押

    // modifier

    modifier checkPid(uint256 _pid){
        require(_pid < pools.length, "MetaNodeStake: pool not exist");
        _;
    }

    modifier whenNotClaimed(){
        require(!claimPaused, "MetaNodeStake: claim paused");
        _;
    }

    modifier whenNotWithdrawPaused(){
        require(!withdrawPaused, "MetaNodeStake: withdraw paused");
        _;
    }


    //方法

    function initialize(
        IERC20 _MetaNodeToken,
        uint256 _startBlock,
        uint256 _endBlock,
        uint256 _MetaNodePreBlock // 上次奖励块号
    )public initializer{
        require(_startBlock < _endBlock, "MetaNodeStake: start block must be less than end block");
        
        // 初始化合约
        __AccessControl_init();
        __Pausable_init();
        __UUPSUpgradeable_init();

        // 授权默认管理员角色、升级合约角色、暂停合约角色、管理员角色
        __grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        __grantRole(UPGRADER_ROLE, msg.sender);
        __grantRole(PAUSER_ROLE, msg.sender);
        __grantRole(ADMIN_ROLE, msg.sender);

        MetNodeToken = _MetaNodeToken;
        startBlock = _startBlock;
        endBlock = _endBlock;
        MetaNodePreBlock = _MetaNodePreBlock;
        claimPaused = false;
        withdrawPaused = false;
    }

    // 授权升级合约角色 
    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyRole(UPGRADER_ROLE)
    {}

    //==================\

    function setMetaNode (IERC20 _MetaNodeToken)
        public
        onlyRole(ADMIN_ROLE)
    {
        MetNodeToken = _MetaNodeToken;
        emit SetMetaNode(_MetaNodeToken);
    }

    function pauseWithdraw() 
        public
        onlyRole(PAUSER_ROLE)
    {
        withdrawPaused = true;
        emit PauseWithdraw(withdrawPaused);
    }

    function unpauseWithdraw() 
        public
        onlyRole(PAUSER_ROLE)
    {
        withdrawPaused = false;
        emit UnpauseWithdraw(withdrawPaused);
    }

    // 暂停体现
    function pauseClaim() 
        public
        onlyRole(PAUSER_ROLE)
    {
        claimPaused = true;
        emit PauseClaim(claimPaused);
    }

    // 取消暂停体现
    function unpauseClaim() 
        public
        onlyRole(PAUSER_ROLE)
    {
        claimPaused = false;
        emit UnpauseClaim(claimPaused);
    }
    
    // 使用PausableUpgradeable的内置pause功能
    function pause() 
        public
        onlyRole(PAUSER_ROLE)
    {
        _pause();
    }
    
    function unpause() 
        public
        onlyRole(PAUSER_ROLE)
    {
        _unpause();
    }

    function setStartBlock(uint256 _startBlock)
        public
        onlyRole(ADMIN_ROLE)
    {
        startBlock = _startBlock;
        emit SetStartBlock(_startBlock);
    }

    function setEndBlock(uint256 _endBlock)
        public
        onlyRole(ADMIN_ROLE)
    {
        endBlock = _endBlock;
        emit SetEndBlock(_endBlock);
    }

    function setMetaNodePreBlock(uint256 _MetaNodePreBlock)
        public
        onlyRole(ADMIN_ROLE)
    {
        MetaNodePreBlock = _MetaNodePreBlock;
        emit SetMetaNodePreBlock(_MetaNodePreBlock);
    }
    function addPool(
        address _stTokenAddress,
        uint256 _poolWeight,
        uint256 _minStTokenAmount,
        uint256 _unStakingBlock,
        bool _poolUpdate

    )public onlyRole(ADMIN_ROLE){

        if(pools.length > 0){
            // Check if token address already exists in other pools
            for (uint256 i = 0; i < pools.length; i++) {
                require(pools[i].stTokenAddress != _stTokenAddress, "MetaNodeStake: pool already exist");
            }
        }else{
              require(
                _stTokenAddress == address(0x0),
                "invalid staking token address"
            );

        }

        require(_unStakingBlock > 0, "MetaNodeStake: unStakingBlock must be greater than 0");

        require(_endBlock > block.number, "MetaNodeStake: endBlock must be greater than current block");
        
        if(_poolUpdate){
            massUpdatePools();
        }
        uint256 lastRewardBlock = block.number > startBlock ? block.number : startBlock;
        totalPoolWeight = totalPoolWeight + _poolWeight; // 更新总pool权重
        pools.push(
            Pool({
                stTokenAddress: _stTokenAddress,
                poolWeight: _poolWeight,
                lastRewardBlock: lastRewardBlock,
                accMetaNodePerShare: 0,
                stTokenAmount: 0,
                minStTokenAmount: _minStTokenAmount,
                unStakingBlock: _unStakingBlock
            })
        );
        emit AddPool(_stTokenAddress, _poolWeight, lastRewardBlock, _minStTokenAmount, _unStakingBlock);


    }
    function updatePool(uint256 _pid) internal {
        Pool storage pool = pools[_pid];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 stTokenAmount = pool.stTokenAmount;
        if (stTokenAmount == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }

        (bool success1, uint256 totalMetaNode) = getMultiplier(
            pool.lastRewardBlock,
            block.number
        ).tryMul(pool.poolWeight);
        require(success1, "MetaNodeStake: calculate totalMetaNode failed");
        (success1, totalMetaNode) = totalMetaNode.tryDiv(totalPoolWeight);
        require(success1, "MetaNodeStake: calculate totalMetaNode failed");

        uint256 stSupply = pool.stTokenAmount;
        if (stSupply > 0) {
            // 计算每个质押代币的MetNode奖励比例
            (bool success2, uint256 totalMetaNode_) = totalMetaNode.tryMul(
                1 ether
            );
            require(success2, "overflow");
            // 每个质押代币的MetNode奖励比例 = 总MetNode奖励数量 / 总质押数量
            (success2, totalMetaNode_) = totalMetaNode_.tryDiv(stSupply);
            require(success2, "overflow");

            // 更新每个质押代币的MetNode奖励比例
            (bool success3, uint256 accMetaNodePerShareNew) = pool.accMetaNodePerShare
                .tryAdd(totalMetaNode_);
            require(success3, "overflow");
            pool.accMetaNodePerShare = accMetaNodePerShareNew;
            pool.lastRewardBlock = block.number;
            emit UpdatePool(_pid, pool.lastRewardBlock, totalMetaNode, stTokenAmount);
        }
      
    }

    function getMultiplier(
        uint256 _startBlock,
        uint256 _endBlock
    ) public view returns (uint256) {
        if(_startBlock < startBlock){
            _startBlock = startBlock;
        }
        if(_endBlock > endBlock){
            _endBlock = endBlock;
        }
        return (_endBlock - _startBlock).mul(MetaNodePreBlock);
    }


    function massUpdatePools() internal {
        for (uint256 pid = 0; pid < pools.length; pid++) {
             updatePool(pid);
        }
    }

    /**
     * @notice Update the given pool's info (minDepositAmount and unstakeLockedBlocks). Can only be called by admin.
     */

    function updatePool(
        uint256 _pid,
        uint256 _minDepositAmount
    ) public onlyRole(ADMIN_ROLE) checkPid(_pid) {
        Pool storage pool = pools[_pid];
        pool.minStTokenAmount = _minDepositAmount;
        emit UpdatePool(_pid, pool.lastRewardBlock, 0, pool.stTokenAmount);
    }

    function setPoolWeight(
        uint256 _pid,
        uint256 _poolWeight
    ) public onlyRole(ADMIN_ROLE) checkPid(_pid) {
        Pool storage pool = pools[_pid];
        totalPoolWeight = totalPoolWeight - pool.poolWeight + _poolWeight; // 更新总pool权重
        pool.poolWeight = _poolWeight;
        emit SetPoolWeight(_pid, _poolWeight, totalPoolWeight);
    }

    function poolLength() public view returns(uint256){
        return pools.length;
    }

    // 获取用户待领取奖励数量
    function pendingMetaNode(
        uint256 _pid,
        address _user
    ) external view checkPid(_pid) returns(uint256){
        return pendingMetaNodeByBlockNumber(_pid, _user, block.number);
    }

    function pendingMetaNodeByBlockNumber(
        uint256 _pid,
        address _user,
        uint256 _blockNumber
    ) public view checkPid(_pid) returns(uint256){
        Pool storage pool = pools[_pid];
        User storage user = users[_pid][_user];
    uint256 accMetaNodePerShare = pool.accMetaNodePerShare;
    uint256 stSupply = pool.stTokenAmount;
    if(stSupply != 0 &&  _blockNumber >pool.lastRewardBlock){

        uint256 multiplier = getMultiplier(
            pool.lastRewardBlock,
            _blockNumber
        );
       uint256 MetaNodeForPool = multiplier*pool.poolWeight/totalPoolWeight; 
       accMetaNodePerShare = accMetaNodePerShare + MetaNodeForPool * (1 ether) / stSupply;
    }

     
        return  (user.stAmount * accMetaNodePerShare) /
            (1 ether) -
            user.finishedMetaNode +
            user.pendingMetaNode;
    }

    function withdrawableAmount(
        uint256 _pid,
        address _user
    ) public view checkPid(_pid) 
    returns(uint256 requestAmount, uint256 pendingWithdrawAmount){
        User storage user_ = users[_pid][_user];
        for(uint256 i = 0; i < user_.unstakeRequests.length; i++){
            UnstakeRequest memory request = user_.unstakeRequests[i];
            if(request.unstakingBlock <= block.number){
                pendingWithdrawAmount = pendingWithdrawAmount + request.amount;
            }else{
                requestAmount = requestAmount + request.amount;
            }
        }

    }
    //质押ETH
    function depositETH(
        
    ) public whenNotPaused {
        Pool storage pool = pools[ETH_PID];
        require(pool.stTokenAddress == address(0x0), "MetaNodeStake: ETH pool not exist");

        uint256 amount = msg.value;
        require(amount >= pool.minStTokenAmount, "MetaNodeStake: amount must be greater than minStTokenAmount");
         _deposit(ETH_PID, amount); 
    }
    
    //领取奖励
    function withdraw(
        uint256 _pid
    ) public whenNotPaused checkPid(_pid) whenNotWithdrawPaused {
        User storage user = users[_pid][msg.sender];
        updatePool(_pid);
        
        uint256 pendingMetaNode_ = (user.stAmount * pools[_pid].accMetaNodePerShare) / 1 ether - user.finishedMetaNode;
        
        if (pendingMetaNode_ > 0) {
            user.pendingMetaNode = user.pendingMetaNode + pendingMetaNode_;
        }
        
        uint256 withdrawAmount = user.pendingMetaNode;
        if (withdrawAmount > 0) {
            user.pendingMetaNode = 0;
            MetNodeToken.safeTransfer(msg.sender, withdrawAmount);
            emit Withdraw(msg.sender, _pid, withdrawAmount);
        }
        
        user.finishedMetaNode = (user.stAmount * pools[_pid].accMetaNodePerShare) / 1 ether;
    }
    
    //完成解质押
    function claim(
        uint256 _pid,
        uint256 _requestIndex
    ) public whenNotPaused checkPid(_pid) whenNotClaimed {
        Pool storage pool = pools[_pid];
        User storage user = users[_pid][msg.sender];
        
        require(_requestIndex < user.unstakeRequests.length, "MetaNodeStake: invalid request index");
        
        UnstakeRequest storage request = user.unstakeRequests[_requestIndex];
        require(block.number >= request.unstakingBlock, "MetaNodeStake: unstake not available yet");
        
        uint256 amount = request.amount;
        require(amount > 0, "MetaNodeStake: amount must be greater than 0");
        
        // Transfer tokens back to user
        if (pool.stTokenAddress == address(0x0)) {
            // ETH pool
            (bool success, ) = msg.sender.call{value: amount}("");
            require(success, "MetaNodeStake: ETH transfer failed");
        } else {
            // ERC20 pool
            IERC20(pool.stTokenAddress).safeTransfer(msg.sender, amount);
        }
        
        // Remove the request by swapping with the last one
        uint256 lastIndex = user.unstakeRequests.length - 1;
        if (_requestIndex != lastIndex) {
            user.unstakeRequests[_requestIndex] = user.unstakeRequests[lastIndex];
        }
        user.unstakeRequests.pop();
        
        emit Claim(msg.sender, _pid, amount);
    }

    function _deposit(uint256 _pid, uint256 _amount) internal {
        Pool storage pool = pools[_pid];
        User storage user = users[_pid][msg.sender];
        updatePool(_pid);
        if(user.stAmount > 0){
                (bool success1, uint256 accST) =   user.stAmount.tryMul(pool.accMetaNodePerShare);
                require(success1, "MetaNodeStake: accMetaNodePerShare overflow");
                (bool success2, uint256 pendingMetaNode_) = accST.tryDiv(1 ether);
                require(success2, "MetaNodeStake: accMetaNodePerShare overflow");
               if (pendingMetaNode_ > 0) {
                (bool success3, uint256 _pendingMetaNode) = user
                    .pendingMetaNode
                    .tryAdd(pendingMetaNode_);
                require(success3, "user pendingMetaNode overflow");
                user.pendingMetaNode = _pendingMetaNode;
            }

        }

        if(_amount >0){
            (bool success4, uint256 _stAmount) = user.stAmount.tryAdd(_amount);
            require(success4, "user stAmount overflow");
            user.stAmount = _stAmount;
        }
         (bool success5, uint256 stTokenAmount) = pool.stTokenAmount.tryAdd(
            _amount
        );
        require(success5, "pool stTokenAmount overflow");
        pool.stTokenAmount = stTokenAmount;

        // user.finishedMetaNode = user.stAmount.mulDiv(pool.accMetaNodePerShare, 1 ether);
        (bool success6, uint256 finishedMetaNode) = user.stAmount.tryMul(
            pool.accMetaNodePerShare
        );
        require(success6, "user stAmount mul accMetaNodePerShare overflow");

        (success6, finishedMetaNode) = finishedMetaNode.tryDiv(1 ether);
        require(success6, "finishedMetaNode div 1 ether overflow");

        user.finishedMetaNode = finishedMetaNode;

        emit Deposit(msg.sender, _pid, _amount);
    
    }

    // 质押代币
    function deposit(
        uint256 _pid,
        uint256 _amount
    ) public whenNotPaused checkPid(_pid) {
        require(_pid != 0, "deposit not support ETH staking");
        Pool storage pool_ = pools[_pid];
        require(
            _amount >= pool_.minStTokenAmount,
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


    function unstake(
        uint256 _pid,
        uint256 _amount
    ) public whenNotPaused checkPid(_pid) whenNotWithdrawPaused {
        Pool storage pool_ = pools[_pid];
        User storage user_ = users[_pid][msg.sender];
        require(user_.stAmount >= _amount, "Not enough staking token balance");

        updatePool(_pid);

        uint256 pendingMetaNode_ = (user_.stAmount * pool_.accMetaNodePerShare) /
        (1 ether) -user_.finishedMetaNode;
        if (pendingMetaNode_ > 0) {
            user_.pendingMetaNode = user_.pendingMetaNode + pendingMetaNode_;
        }
         if (_amount > 0) {
            user_.stAmount = user_.stAmount - _amount;
            user_.unstakeRequests.push(
                UnstakeRequest({
                    amount: _amount,
                    unstakingBlock: block.number + pool_.unStakingBlock
                })
            );
        }
        pool_.stTokenAmount = pool_.stTokenAmount - _amount;
        user_.finishedMetaNode =
            (user_.stAmount * pool_.accMetaNodePerShare) /
            (1 ether);

        emit RequestUnstake(msg.sender, _pid, _amount);
    }

  
}
