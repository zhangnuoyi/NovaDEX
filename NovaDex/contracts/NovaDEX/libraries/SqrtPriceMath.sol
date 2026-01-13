// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./FullMath.sol";

/// @title SqrtPriceMath 库 - 提供价格表示相关的数学计算
/// @notice 实现价格与sqrtPriceX96之间的转换和流动性计算
library SqrtPriceMath {
    /// @notice Q64.96格式的缩放因子（2^96）
    uint160 internal constant Q96 = 0x1000000000000000000000000; // 2^96

    /// @notice 将价格转换为Q64.96格式的平方根价格
    /// @param price 实际价格（token1/token0）
    /// @return sqrtPriceX96 Q64.96格式的平方根价格
    function priceToSqrtPriceX96(uint256 price) internal pure returns (uint160 sqrtPriceX96) {
        // 计算价格的平方根
        uint256 sqrtPrice = sqrt(price);
        // 转换为Q64.96格式
        sqrtPriceX96 = uint160((sqrtPrice << 96) / 1e18);
    }

    /// @notice 将Q64.96格式的平方根价格转换为实际价格
    /// @param sqrtPriceX96 Q64.96格式的平方根价格
    /// @return price 实际价格（token1/token0）
    function sqrtPriceX96ToPrice(uint160 sqrtPriceX96) internal pure returns (uint256 price) {
        // 将Q64.96格式转换为普通uint256
        uint256 sqrtPrice = uint256(sqrtPriceX96) * 1e18;
        // 计算价格（平方根的平方）
        price = (sqrtPrice * sqrtPrice) / (1 << 192);
    }

    /// @notice 计算给定流动性在价格区间内对应的token0数量
    /// @param liquidity 流动性数量
    /// @param sqrtPriceUpperX96 价格区间上限的Q64.96格式平方根价格
    /// @param sqrtPriceLowerX96 价格区间下限的Q64.96格式平方根价格
    /// @param roundUp 是否向上取整
    /// @return amount0 对应的token0数量
    function getAmount0ForLiquidity(
        uint160 sqrtPriceX96,
        uint160 sqrtPriceUpperX96,
        uint160 sqrtPriceLowerX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount0) {
        // 确保价格顺序正确
        require(sqrtPriceLowerX96 < sqrtPriceUpperX96, "SqrtPriceMath: INVALID_PRICE_RANGE");
        require(sqrtPriceX96 >= sqrtPriceLowerX96 && sqrtPriceX96 <= sqrtPriceUpperX96, "SqrtPriceMath: PRICE_OUT_OF_RANGE");

        // 计算分子和分母
        uint256 numerator0 = uint256(liquidity) * uint256(sqrtPriceUpperX96 - sqrtPriceX96);
        uint256 denominator0 = uint256(sqrtPriceUpperX96) * uint256(sqrtPriceX96);

        // 计算amount0
        amount0 = numerator0 * Q96 / denominator0;

        // 如果需要向上取整，则加1
        if (roundUp && amount0 * denominator0 < numerator0 * Q96) {
            amount0++;
        }
    }

    /// @notice 计算给定流动性在价格区间内对应的token1数量
    /// @param liquidity 流动性数量
    /// @param sqrtPriceUpperX96 价格区间上限的Q64.96格式平方根价格
    /// @param sqrtPriceLowerX96 价格区间下限的Q64.96格式平方根价格
    /// @param roundUp 是否向上取整
    /// @return amount1 对应的token1数量
    function getAmount1ForLiquidity(
        uint160 sqrtPriceX96,
        uint160 sqrtPriceUpperX96,
        uint160 sqrtPriceLowerX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount1) {
        // 确保价格顺序正确
        require(sqrtPriceLowerX96 < sqrtPriceUpperX96, "SqrtPriceMath: INVALID_PRICE_RANGE");
        require(sqrtPriceX96 >= sqrtPriceLowerX96 && sqrtPriceX96 <= sqrtPriceUpperX96, "SqrtPriceMath: PRICE_OUT_OF_RANGE");

        // 计算分子
        uint256 numerator1 = uint256(liquidity) * uint256(sqrtPriceX96 - sqrtPriceLowerX96);

        // 计算amount1
        amount1 = numerator1 / Q96;

        // 如果需要向上取整，则加1
        if (roundUp && amount1 * Q96 < numerator1) {
            amount1++;
        }
    }

    /// @notice 计算给定流动性在价格区间内对应的token0和token1数量
    /// @param liquidity 流动性数量
    /// @param sqrtPriceUpperX96 价格区间上限的Q64.96格式平方根价格
    /// @param sqrtPriceLowerX96 价格区间下限的Q64.96格式平方根价格
    /// @param roundUp 是否向上取整
    /// @return amount0 对应的token0数量
    /// @return amount1 对应的token1数量
    function getAmountsForLiquidity(
        uint160 sqrtPriceX96,
        uint160 sqrtPriceUpperX96,
        uint160 sqrtPriceLowerX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        amount0 = getAmount0ForLiquidity(sqrtPriceX96, sqrtPriceUpperX96, sqrtPriceLowerX96, liquidity, roundUp);
        amount1 = getAmount1ForLiquidity(sqrtPriceX96, sqrtPriceUpperX96, sqrtPriceLowerX96, liquidity, roundUp);
    }

    /// @notice 根据给定的token0数量计算所需的流动性
    /// @param amount0 token0数量
    /// @param sqrtPriceUpperX96 价格区间上限的Q64.96格式平方根价格
    /// @param sqrtPriceLowerX96 价格区间下限的Q64.96格式平方根价格
    /// @return liquidity 所需的流动性数量
    function getLiquidityForAmount0(
        uint160 sqrtPriceX96,
        uint160 sqrtPriceUpperX96,
        uint160 sqrtPriceLowerX96,
        uint256 amount0
    ) internal pure returns (uint128 liquidity) {
        // 确保价格顺序正确
        require(sqrtPriceLowerX96 < sqrtPriceUpperX96, "SqrtPriceMath: INVALID_PRICE_RANGE");
        require(sqrtPriceX96 >= sqrtPriceLowerX96 && sqrtPriceX96 <= sqrtPriceUpperX96, "SqrtPriceMath: PRICE_OUT_OF_RANGE");

        // 计算分母和分子
        uint256 denominator0 = uint256(sqrtPriceUpperX96 - sqrtPriceX96) * Q96;
        uint256 numerator0 = uint256(amount0) * uint256(sqrtPriceUpperX96) * uint256(sqrtPriceX96);

        // 计算流动性
        liquidity = denominator0 > 0 ? uint128(numerator0 / denominator0) : type(uint128).max;
    }

    /// @notice 根据给定的token1数量计算所需的流动性
    /// @param amount1 token1数量
    /// @param sqrtPriceUpperX96 价格区间上限的Q64.96格式平方根价格
    /// @param sqrtPriceLowerX96 价格区间下限的Q64.96格式平方根价格
    /// @return liquidity 所需的流动性数量
    function getLiquidityForAmount1(
        uint160 sqrtPriceX96,
        uint160 sqrtPriceUpperX96,
        uint160 sqrtPriceLowerX96,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        // 确保价格顺序正确
        require(sqrtPriceLowerX96 < sqrtPriceUpperX96, "SqrtPriceMath: INVALID_PRICE_RANGE");
        require(sqrtPriceX96 >= sqrtPriceLowerX96 && sqrtPriceX96 <= sqrtPriceUpperX96, "SqrtPriceMath: PRICE_OUT_OF_RANGE");

        // 计算分母和分子
        uint256 denominator1 = uint256(sqrtPriceX96 - sqrtPriceLowerX96);
        uint256 numerator1 = uint256(amount1) * Q96;

        // 计算流动性
        liquidity = denominator1 > 0 ? uint128(numerator1 / denominator1) : type(uint128).max;
    }

    /// @notice 根据给定的token0和token1数量计算所需的流动性
    /// @param amount0 token0数量
    /// @param amount1 token1数量
    /// @param sqrtPriceUpperX96 价格区间上限的Q64.96格式平方根价格
    /// @param sqrtPriceLowerX96 价格区间下限的Q64.96格式平方根价格
    /// @return liquidity 所需的流动性数量
    function getLiquidityForAmounts(
        uint160 sqrtPriceX96,
        uint160 sqrtPriceUpperX96,
        uint160 sqrtPriceLowerX96,
        uint256 amount0,
        uint256 amount1
    ) internal pure returns (uint128 liquidity) {
        uint128 liquidity0 = getLiquidityForAmount0(sqrtPriceX96, sqrtPriceUpperX96, sqrtPriceLowerX96, amount0);
        uint128 liquidity1 = getLiquidityForAmount1(sqrtPriceX96, sqrtPriceUpperX96, sqrtPriceLowerX96, amount1);
        // 取较小的流动性值
        liquidity = liquidity0 < liquidity1 ? liquidity0 : liquidity1;
    }

    /// @notice 计算价格变化对应的token数量
    /// @param sqrtPriceX96 初始Q64.96格式的平方根价格
    /// @param sqrtPriceNextX96 最终Q64.96格式的平方根价格
    /// @param liquidity 流动性数量
    /// @param zeroForOne 交易方向（token0→token1为true，token1→token0为false）
    /// @return amount0 token0的变化量
    /// @return amount1 token1的变化量
    function getAmountsForPriceImpact(
        uint160 sqrtPriceX96,
        uint160 sqrtPriceNextX96,
        uint128 liquidity,
        bool zeroForOne
    ) internal pure returns (uint256 amount0, uint256 amount1) {
        if (zeroForOne) {
            // token0→token1: 价格下降
            require(sqrtPriceNextX96 <= sqrtPriceX96, "SqrtPriceMath: INVALID_PRICE_IMPACT");
            amount0 = getAmount0ForLiquidity(sqrtPriceNextX96, sqrtPriceX96, sqrtPriceNextX96, liquidity, false);
            amount1 = getAmount1ForLiquidity(sqrtPriceX96, sqrtPriceX96, sqrtPriceNextX96, liquidity, false);
        } else {
            // token1→token0: 价格上升
            require(sqrtPriceNextX96 >= sqrtPriceX96, "SqrtPriceMath: INVALID_PRICE_IMPACT");
            amount0 = getAmount0ForLiquidity(sqrtPriceX96, sqrtPriceNextX96, sqrtPriceX96, liquidity, false);
            amount1 = getAmount1ForLiquidity(sqrtPriceNextX96, sqrtPriceNextX96, sqrtPriceX96, liquidity, false);
        }
    }

    /// @dev 使用FullMath库计算一个数的平方根
    function sqrt(uint256 x) internal pure returns (uint256) {
        return FullMath.sqrt(x);
    }
}