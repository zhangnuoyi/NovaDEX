// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title Pool 合约接口
 * @notice NovaDEX Pool 合约用于管理流动性和处理交易
 */
interface IPool {
    /**
     * @notice 初始化池的初始价格
     * @param sqrtPriceX96 初始价格的平方根（Q64.96格式）
     */
    function initialize(uint160 sqrtPriceX96) external;

    /**
     * @notice 代币交换函数
     * @param recipient 接收地址
     * @param zeroForOne 交易方向（true表示token0→token1）
     * @param amountSpecified 指定的交易数量
     * @param sqrtPriceLimitX96 价格限制
     * @param data 回调数据
     * @return amount0 token0的变化量
     * @return amount1 token1的变化量
     */
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /**
     * @notice 获取池的基本信息
     * @return token0 代币0地址
     * @return token1 代币1地址
     * @return fee 交易费率
     * @return tickLower 价格区间下限
     * @return tickUpper 价格区间上限
     */
    function getPoolInfo() external view returns (
        address token0,
        address token1,
        uint24 fee,
        int24 tickLower,
        int24 tickUpper
    );

    /**
     * @notice 获取池的slot0信息
     * @return sqrtPriceX96 当前价格的平方根（Q64.96格式）
     * @return tick 当前tick值
     * @return observationIndex 观察索引
     * @return observationCardinality 观察基数
     * @return observationCardinalityNext 下一个观察基数
     * @return feeProtocol 协议费率
     * @return unlocked 是否解锁
     */
    function slot0() external view returns (
        uint160 sqrtPriceX96,
        int24 tick,
        uint16 observationIndex,
        uint16 observationCardinality,
        uint16 observationCardinalityNext,
        uint8 feeProtocol,
        bool unlocked
    );

    /**
     * @notice 添加流动性函数
     * @param amount0Desired 期望的token0数量
     * @param amount1Desired 期望的token1数量
     * @return amount0 实际添加的token0数量
     * @return amount1 实际添加的token1数量
     */
    function mint(uint256 amount0Desired, uint256 amount1Desired) external returns (uint256 amount0, uint256 amount1);
}
