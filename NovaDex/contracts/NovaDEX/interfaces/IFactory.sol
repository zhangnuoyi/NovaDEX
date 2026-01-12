// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Factory 合约接口
 * @notice NovaDEX Factory 合约用于创建和管理流动性池
 */
interface IFactory {
    /**
     * @notice 创建新的流动性池
     * @param tokenA 代币A地址
     * @param tokenB 代币B地址
     * @param tickLower 价格区间下限
     * @param tickUpper 价格区间上限
     * @param fee 交易费率
     * @return pool 创建的池合约地址
     */
    function createPool(
        address tokenA,
        address tokenB,
        int24 tickLower,
        int24 tickUpper,
        uint24 fee
    ) external returns (address pool);

    /**
     * @notice 根据代币地址和索引查询池地址
     * @param tokenA 代币A地址
     * @param tokenB 代币B地址
     * @param index 池索引
     * @return pool 池合约地址
     */
    function getPool(
        address tokenA,
        address tokenB,
        uint256 index
    ) external view returns (address pool);

    /**
     * @notice 对输入的两个代币地址进行排序
     * @param tokenA 代币A地址
     * @param tokenB 代币B地址
     * @return token0 排序后的第一个代币地址
     * @return token1 排序后的第二个代币地址
     */
    function sortTokens(
        address tokenA,
        address tokenB
    ) external pure returns (address token0, address token1);

    /**
     * @notice 池创建事件
     * @param token0 排序后的第一个代币地址
     * @param token1 排序后的第二个代币地址
     * @param pool 池合约地址
     * @param fee 交易费率
     */
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        address indexed pool,
        uint24 fee
    );
}
