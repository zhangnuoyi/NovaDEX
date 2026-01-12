// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title PositionManager 合约接口
 * @notice NovaDEX PositionManager 合约用于管理流动性头寸
 */
interface IPositionManager is IERC721 {
    /**
     * @notice 头寸创建事件
     * @param tokenId 头寸的NFT ID
     * @param owner 头寸所有者地址
     * @param token0 代币0地址
     * @param token1 代币1地址
     * @param fee 交易费率
     * @param tickLower 价格区间下限
     * @param tickUpper 价格区间上限
     * @param liquidity 创建的流动性数量
     * @param amount0 实际提供的代币0数量
     * @param amount1 实际提供的代币1数量
     */
    event PositionCreated(
        uint256 indexed tokenId,
        address indexed owner,
        address indexed token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    /**
     * @notice 头寸销毁事件
     * @param tokenId 头寸的NFT ID
     * @param owner 头寸所有者地址
     * @param liquidity 销毁的流动性数量
     * @param amount0 提取的代币0数量
     * @param amount1 提取的代币1数量
     */
    event PositionBurned(
        uint256 indexed tokenId,
        address indexed owner,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );

    /**
     * @notice 头寸手续费收取事件
     * @param tokenId 头寸的NFT ID
     * @param recipient 手续费接收地址
     * @param amount0 收取的代币0手续费数量
     * @param amount1 收取的代币1手续费数量
     */
    event FeesCollected(
        uint256 indexed tokenId,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1
    );

    /**
     * @notice 头寸信息结构体
     * @param owner 头寸所有者地址
     * @param token0 代币0地址
     * @param token1 代币1地址
     * @param fee 交易费率
     * @param tickLower 价格区间下限
     * @param tickUpper 价格区间上限
     * @param liquidity 流动性数量
     * @param feeGrowthInside0LastX128 代币0手续费增长
     * @param feeGrowthInside1LastX128 代币1手续费增长
     * @param tokensOwed0 待领取的代币0手续费
     * @param tokensOwed1 待领取的代币1手续费
     */
    struct Position {
        address owner;
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint256 tokensOwed0;
        uint256 tokensOwed1;
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
    ) external returns (
        uint256 tokenId,
        uint128 liquidity,
        uint256 amount0,
        uint256 amount1
    );

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
    ) external returns (
        uint256 amount0,
        uint256 amount1
    );

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
    ) external returns (
        uint256 amount0,
        uint256 amount1
    );

    /**
     * @notice 查询指定头寸的详细信息
     * @param tokenId 头寸的NFT ID
     * @return position 头寸信息结构体
     */
    function getPosition(
        uint256 tokenId
    ) external view returns (
        Position memory position
    );
}