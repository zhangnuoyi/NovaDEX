// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721URIStorage } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import { IPositionManager } from "./interfaces/IPositionManager.sol";
import { IFactory } from "./interfaces/IFactory.sol";
import { IPool } from "./interfaces/IPool.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title PositionManager 合约实现
 * @notice NovaDEX PositionManager 合约用于管理流动性头寸
 */
contract PositionManager is ERC721URIStorage, IPositionManager {
    using SafeERC20 for IERC20;

    // Factory 合约地址
    address public immutable factory;

    // 代币ID计数器
    uint256 private _tokenIdCounter;

    // 头寸信息映射
    mapping(uint256 => Position) private _positions;

    /**
     * @notice 构造函数
     * @param factoryAddress Factory 合约地址
     */
    constructor(address factoryAddress) ERC721("NovaDEX Position", "NDP") {
        require(factoryAddress != address(0), "Invalid factory address");
        factory = factoryAddress;
        _tokenIdCounter = 1;
    }

    /**
     * @notice 创建新的流动性头寸
     * @param token0 代币0地址
     * @param token1 代币1地址
     * @param fee 交易费率
     * @param tickLower 价格区间下限
     * @param tickUpper 价格区间上限
     * @param amount0Desired 期望提供的代币0数量
     * @param amount1Desired 期望提供的代币1数量
     * @param amount0Min 最小接受的代币0数量
     * @param amount1Min 最小接受的代币1数量
     * @param recipient 头寸接收地址
     * @param deadline 交易截止时间
     * @return tokenId 头寸的NFT ID
     * @return liquidity 创建的流动性数量
     * @return amount0 实际提供的代币0数量
     * @return amount1 实际提供的代币1数量
     */
    function createPosition(
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint256 amount0Desired,
        uint256 amount1Desired,
        uint256 amount0Min,
        uint256 amount1Min,
        address recipient,
        uint256 deadline
    ) external override returns (
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    ) {
        // 参数验证
        require(token0 != address(0) && token1 != address(0), "Invalid token addresses");
        require(token0 != token1, "Identical tokens");
        require(fee > 0 && fee <= 1000000, "Invalid fee");
        require(tickLower < tickUpper, "Invalid tick range");
        require(amount0Desired > 0 || amount1Desired > 0, "Insufficient desired amounts");
        require(amount0Min <= amount0Desired && amount1Min <= amount1Desired, "Invalid minimum amounts");
        require(recipient != address(0), "Invalid recipient");
        require(deadline >= block.timestamp, "Transaction expired");

        // 获取或创建池合约
        IFactory factoryContract = IFactory(factory);
        address poolAddress = factoryContract.createPool(token0, token1, tickLower, tickUpper, fee);
        IPool pool = IPool(poolAddress);

        // 检查池是否已初始化
        (uint160 sqrtPriceX96, int24 tick, , , , , ) = pool.slot0();
        // 如果池未初始化，可以直接提供初始流动性
        // 这里简化处理，实际项目中需要更复杂的逻辑

        // 计算流动性并提供流动性
        // 这里简化处理，实际项目中需要更复杂的逻辑
        liquidity = 0;
        amount0 = 0;
        amount1 = 0;

        // 转移代币到池
        if (amount0 > 0) {
            IERC20(token0).safeTransferFrom(msg.sender, address(pool), amount0);
        }
        if (amount1 > 0) {
            IERC20(token1).safeTransferFrom(msg.sender, address(pool), amount1);
        }

        // 创建头寸NFT
        tokenId = _tokenIdCounter++;
        _mint(recipient, tokenId);

        // 保存头寸信息
        _positions[tokenId] = Position({
            owner: recipient,
            token0: token0,
            token1: token1,
            fee: fee,
            tickLower: tickLower,
            tickUpper: tickUpper,
            liquidity: liquidity,
            feeGrowthInside0LastX128: 0,
            feeGrowthInside1LastX128: 0,
            tokensOwed0: 0,
            tokensOwed1: 0
        });

        // 发出头寸创建事件
        emit PositionCreated(
            tokenId,
            recipient,
            token0,
            token1,
            fee,
            tickLower,
            tickUpper,
            liquidity,
            amount0,
            amount1
        );

        return (tokenId, liquidity, amount0, amount1);
    }

    /**
     * @notice 销毁指定的流动性头寸
     * @param tokenId 头寸的NFT ID
     * @param amount 要销毁的流动性数量
     * @return amount0 提取的代币0数量
     * @return amount1 提取的代币1数量
     */
    function burnPosition(
        uint256 tokenId,
        uint128 amount
    ) external override returns (
        uint256 amount0,
        uint256 amount1
    ) {
        // 参数验证
        require(ownerOf(tokenId) == msg.sender, "Not token owner or invalid token");

        // 获取头寸信息
        Position storage position = _positions[tokenId];
        require(amount <= position.liquidity, "Invalid amount");

        // 获取池合约
        IFactory factoryContract = IFactory(factory);
        address poolAddress = factoryContract.getPool(position.token0, position.token1, 0);
        IPool pool = IPool(poolAddress);

        // 销毁流动性
        // 这里简化处理，实际项目中需要更复杂的逻辑
        amount0 = 0;
        amount1 = 0;

        // 更新头寸信息
        position.liquidity -= amount;

        // 如果流动性为0，销毁NFT
        if (position.liquidity == 0) {
            _burn(tokenId);
            // 清除头寸信息
            delete _positions[tokenId];
        }

        // 发出头寸销毁事件
        emit PositionBurned(
            tokenId,
            msg.sender,
            amount,
            amount0,
            amount1
        );

        return (amount0, amount1);
    }

    /**
     * @notice 收取指定头寸的累积手续费
     * @param tokenId 头寸的NFT ID
     * @param recipient 手续费接收地址
     * @param amount0Requested 请求的代币0手续费数量
     * @param amount1Requested 请求的代币1手续费数量
     * @return amount0 实际收取的代币0手续费数量
     * @return amount1 实际收取的代币1手续费数量
     */
    function collectFees(
        uint256 tokenId,
        address recipient,
        uint256 amount0Requested,
        uint256 amount1Requested
    ) external override returns (
        uint256 amount0,
        uint256 amount1
    ) {
        // 参数验证
        require(ownerOf(tokenId) == msg.sender, "Not token owner or invalid token");
        require(recipient != address(0), "Invalid recipient");

        // 获取头寸信息
        Position storage position = _positions[tokenId];

        // 计算累积的手续费
        // 这里简化处理，实际项目中需要更复杂的逻辑
        amount0 = position.tokensOwed0;
        amount1 = position.tokensOwed1;

        // 限制收取的手续费数量
        if (amount0Requested < amount0) {
            amount0 = amount0Requested;
        }
        if (amount1Requested < amount1) {
            amount1 = amount1Requested;
        }

        // 更新头寸信息
        position.tokensOwed0 -= amount0;
        position.tokensOwed1 -= amount1;

        // 转移手续费给接收者
        if (amount0 > 0) {
            IERC20(position.token0).safeTransfer(recipient, amount0);
        }
        if (amount1 > 0) {
            IERC20(position.token1).safeTransfer(recipient, amount1);
        }

        // 发出手续费收取事件
        emit FeesCollected(
            tokenId,
            recipient,
            amount0,
            amount1
        );

        return (amount0, amount1);
    }

    /**
     * @notice 查询指定头寸的详细信息
     * @param tokenId 头寸的NFT ID
     * @return position 头寸信息结构体
     */
    function getPosition(
        uint256 tokenId
    ) external view override returns (
        Position memory position
    ) {
        require(_positions[tokenId].owner != address(0), "Token does not exist");
        return _positions[tokenId];
    }

    /**
     * @notice 重写tokenURI函数，返回头寸的元数据
     * @param tokenId 头寸的NFT ID
     * @return tokenURI 头寸的元数据URI
     */
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        // ownerOf会自动检查代币是否存在
        ownerOf(tokenId);
        // 这里简化处理，实际项目中需要返回真实的元数据URI
        return "https://novadex.io/position/";
    }
}
