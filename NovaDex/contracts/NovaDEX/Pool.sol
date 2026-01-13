// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPool } from "./interfaces/IPool.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Pool 合约实现
 * @notice NovaDEX Pool 合约用于管理流动性和处理交易
 */
contract Pool is IPool {
    using SafeERC20 for IERC20;
    
    // 池的基本信息
    address public immutable token0;
    address public immutable token1;
    uint24 public immutable fee;
    int24 public immutable tickLower;
    int24 public immutable tickUpper;
    
    // 事件定义
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    // 价格信息
    uint160 public sqrtPriceX96;
    int24 public tick;
    bool public initialized;

    /**
     * @notice 构造函数
     * @param _token0 代币0地址
     * @param _token1 代币1地址
     * @param _fee 交易费率
     * @param _tickLower 价格区间下限
     * @param _tickUpper 价格区间上限
     */
    constructor(
        address _token0,
        address _token1,
        uint24 _fee,
        int24 _tickLower,
        int24 _tickUpper
    ) {
        token0 = _token0;
        token1 = _token1;
        fee = _fee;
        tickLower = _tickLower;
        tickUpper = _tickUpper;
    }

    /**
     * @notice 初始化池的初始价格
     * @param _sqrtPriceX96 初始价格的平方根（Q64.96格式）
     */
    function initialize(uint160 _sqrtPriceX96) external override {
        require(!initialized, "Pool already initialized");
        initialized = true;
        sqrtPriceX96 = _sqrtPriceX96;
        // 这里简单实现，实际项目中需要根据sqrtPriceX96计算tick
        tick = 0;
    }

    /**
     * @notice 获取池的基本信息
     * @return token0 代币0地址
     * @return token1 代币1地址
     * @return fee 交易费率
     * @return tickLower 价格区间下限
     * @return tickUpper 价格区间上限
     */
    function getPoolInfo() external view override returns (
        address, address, uint24, int24, int24
    ) {
        return (token0, token1, fee, tickLower, tickUpper);
    }

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
    function slot0() external view override returns (
        uint160, int24, uint16, uint16, uint16, uint8, bool
    ) {
        // 返回当前价格和状态信息
        // 由于是简化实现，部分参数返回默认值
        return (
            sqrtPriceX96,
            tick,
            0, // observationIndex
            0, // observationCardinality
            0, // observationCardinalityNext
            0, // feeProtocol
            true // unlocked
        );
    }

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
    ) external override returns (int256 amount0, int256 amount1) {
        // 参数验证
        require(initialized, "Pool not initialized");
        require(recipient != address(0), "Invalid recipient");
        require(amountSpecified != 0, "Invalid amount");

        // 这里简化实现，实际项目中需要复杂的价格计算和代币转移逻辑
        // 由于这是一个教学实现，我们简单地返回0作为变化量
        // 在实际项目中，需要根据价格和流动性计算实际的代币变化量
        amount0 = 0;
        amount1 = 0;

        // 发出Swap事件
        emit Swap(
            msg.sender,
            recipient,
            amount0,
            amount1,
            sqrtPriceX96,
            0, // liquidity
            tick
        );

        return (amount0, amount1);
    }
}
