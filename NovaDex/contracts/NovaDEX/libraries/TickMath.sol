// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FullMath.sol";

/// @title TickMath 库 - 提供Tick系统相关的数学计算
/// @notice 实现Tick与价格、sqrtPriceX96之间的转换，并处理边界条件
library TickMath {
    /// @notice Tick的最小值
    int24 public constant MIN_TICK = -887272;
    /// @notice Tick的最大值
    int24 public constant MAX_TICK = 887272;

    /// @notice 价格步长（1.0001）
    uint160 internal constant Q96 = 0x1000000000000000000000000; // 2^96
    uint256 internal constant ONE = 0x10000000000000000; // 2^64
    uint256 internal constant ONE_MINUS_TWO_POW_NEGATIVE_64 = 0xFFFFFFFFFFFFFFFF;
    uint256 internal constant TWO_POW_64 = 0x10000000000000000;

    /// @notice 计算Tick对应的sqrtPriceX96
    /// @param tick 需要转换的Tick值
    /// @return sqrtPriceX96 对应的Q64.96格式的平方根价格
    function getSqrtPriceAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96) {
        // 检查Tick边界
        require(tick >= MIN_TICK && tick <= MAX_TICK, "TickMath: TICK_OUT_OF_BOUNDS");

        // 使用固定的计算方法来得到sqrtPriceX96
        // 这是一个优化的实现，避免了复杂的浮点数运算
        uint256 absTick = tick < 0 ? uint256(-int256(tick)) : uint256(int256(tick));
        uint256 ratio = absTick & 0x1 != 0 ? 0xfffcb933bd6fad37aa2d162d1a594001 : 0x100000000000000000000000000000000;
        if (absTick & 0x2 != 0) ratio = (ratio * 0xfff97272373d413259a46990580e213a) >> 128;
        if (absTick & 0x4 != 0) ratio = (ratio * 0xfff2e50f5f656932ef12357cf3c7fdcc) >> 128;
        if (absTick & 0x8 != 0) ratio = (ratio * 0xffe5caca7e10e4e61c3624eaa0941cd0) >> 128;
        if (absTick & 0x10 != 0) ratio = (ratio * 0xffcb9843d60f6159c9db58835c926644) >> 128;
        if (absTick & 0x20 != 0) ratio = (ratio * 0xff973b41fa98c081472e6896dfb254c0) >> 128;
        if (absTick & 0x40 != 0) ratio = (ratio * 0xff2ea16466c96a3843ec78b326b52861) >> 128;
        if (absTick & 0x80 != 0) ratio = (ratio * 0xfe5dee046a99a2a811c461f1969c3053) >> 128;
        if (absTick & 0x100 != 0) ratio = (ratio * 0xfcbe86c7900a88aedcffc83b479aa3a4) >> 128;
        if (absTick & 0x200 != 0) ratio = (ratio * 0xf987a7253ac413176f2b074cf7815e54) >> 128;
        if (absTick & 0x400 != 0) ratio = (ratio * 0xf3392b0822b70005940c7a398e4b70f3) >> 128;
        if (absTick & 0x800 != 0) ratio = (ratio * 0xe7159475a2c29b7443b29c7fa6e889d9) >> 128;
        if (absTick & 0x1000 != 0) ratio = (ratio * 0xd097f3bdfd2022b8845ad8f792aa5825) >> 128;
        if (absTick & 0x2000 != 0) ratio = (ratio * 0xa9f746462d870fdf8a65dc1f90e061e5) >> 128;
        if (absTick & 0x4000 != 0) ratio = (ratio * 0x70d869a156d2a1b890bb3df62baf32f7) >> 128;
        if (absTick & 0x8000 != 0) ratio = (ratio * 0x31be135f97d08fd981231505542fcfa6) >> 128;
        if (absTick & 0x10000 != 0) ratio = (ratio * 0x9aa508b5b7a84e1c677de54f3e99bc9);

        if (tick > 0) ratio = ONE / ratio;

        // 将结果转换为Q64.96格式
        sqrtPriceX96 = ratio <= type(uint160).max ? uint160(ratio >> 32) : type(uint160).max;
    }

    /// @notice 计算sqrtPriceX96对应的Tick值
    /// @param sqrtPriceX96 Q64.96格式的平方根价格
    /// @return tick 对应的Tick值
    function getTickAtSqrtPrice(uint160 sqrtPriceX96) internal pure returns (int24 tick) {
        // 计算价格的平方根
        uint256 sqrtPrice = uint256(sqrtPriceX96) << 32;

        // 计算log2(sqrtPrice)
        uint256 r = sqrtPrice > TWO_POW_64 ? sqrtPrice >> 64 : sqrtPrice;
        uint256 msb = 0;
        uint256 x = r;
        if (x >= 0x100000000) { x >>= 32; msb += 32; }
        if (x >= 0x10000) { x >>= 16; msb += 16; }
        if (x >= 0x100) { x >>= 8; msb += 8; }
        if (x >= 0x10) { x >>= 4; msb += 4; }
        if (x >= 0x4) { x >>= 2; msb += 2; }
        if (x >= 0x2) msb += 1;

        uint256 log2 = msb - 64;
        if (r >= TWO_POW_64) {
            r >>= 1;
        }
        r = (r * ONE) >> (63 - log2);
        uint256 log2Mantissa = r - ONE;

        // 计算log10(log2)
        uint256 log10Mantissa = (log2Mantissa * 0x268826a0) >> 64;
        uint256 log10Exponent = log2 * 0x53594D2B941BE599;
        uint256 log10 = log10Exponent + log10Mantissa;

        // 计算log(1.0001)
        uint256 log1p4 = 0x2386f26fc10000; // log(1.0001) * 2^58

        // 计算tick = log10 / log(1.0001)
        uint256 tickUint = (log10 << 26) / log1p4;
        // 确保tick在有效范围内
        require(tickUint <= uint256(uint24(int24(MAX_TICK))), "TickMath: TICK_CALCULATION_OVERFLOW");
        
        // 使用内联汇编安全地将uint256转换为int24
        assembly {
            tick := tickUint
        }

        // 检查并调整tick值以确保准确性
        if (tick < MIN_TICK) tick = MIN_TICK;
        if (tick > MAX_TICK) tick = MAX_TICK;

        // 验证结果是否正确
        uint160 sqrtPriceAtTick = getSqrtPriceAtTick(tick);
        if (sqrtPriceAtTick > sqrtPriceX96) {
            tick--;
        } else {
            uint160 sqrtPriceAtNextTick = getSqrtPriceAtTick(tick + 1);
            if (sqrtPriceAtNextTick <= sqrtPriceX96) {
                tick++;
            }
        }

        // 最终验证
        require(tick >= MIN_TICK && tick <= MAX_TICK, "TickMath: TICK_OUT_OF_BOUNDS");
        require(getSqrtPriceAtTick(tick) <= sqrtPriceX96, "TickMath: INVALID_TICK");
        if (tick < MAX_TICK) {
            require(getSqrtPriceAtTick(tick + 1) > sqrtPriceX96, "TickMath: INVALID_TICK");
        }
    }

    /// @notice 检查Tick是否在有效范围内
    /// @param tick 需要检查的Tick值
    /// @return bool 如果Tick在有效范围内返回true，否则返回false
    function isValidTick(int24 tick) internal pure returns (bool) {
        return tick >= MIN_TICK && tick <= MAX_TICK;
    }

    /// @notice 获取Tick对应的价格
    /// @param tick Tick值
    /// @return price 对应的价格（token1/token0）
    function getPriceAtTick(int24 tick) internal pure returns (uint256 price) {
        uint160 sqrtPriceX96 = getSqrtPriceAtTick(tick);
        price = uint256(sqrtPriceX96) * uint256(sqrtPriceX96);
    }

    /// @notice 将价格转换为Tick
    /// @param price 价格值（token1/token0）
    /// @return tick 对应的Tick值
    function priceToTick(uint256 price) internal pure returns (int24 tick) {
        // 计算价格的平方根
        uint160 sqrtPriceX96 = uint160(sqrt(price) << 96);
        return getTickAtSqrtPrice(sqrtPriceX96);
    }

    /// @dev 使用FullMath库计算一个数的平方根
    function sqrt(uint256 x) internal pure returns (uint256) {
        return FullMath.sqrt(x);
    }
}