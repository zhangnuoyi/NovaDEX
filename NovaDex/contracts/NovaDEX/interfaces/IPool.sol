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
}
