// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./SqrtPriceMath.sol";
import "./TickMath.sol";
import "./FullMath.sol";

/// @title SwapMath 库 - 提供交易计算相关的数学函数
/// @notice 实现交易步长计算、手续费计算等核心交易逻辑
library SwapMath {
    /// @notice 计算交易步长的核心函数
    /// @param sqrtPriceX96 当前Q64.96格式的平方根价格
    /// @param sqrtPriceTargetX96 目标Q64.96格式的平方根价格
    /// @param liquidity 流动性数量
    /// @param amountRemaining 剩余需要交换的代币数量
    /// @param fee 手续费率（单位：1e6分之一，例如0.3%=3000）
    /// @return sqrtPriceNextX96 交易步长后的Q64.96格式平方根价格
    /// @return amountIn 交易步长中使用的输入代币数量
    /// @return amountOut 交易步长中获得的输出代币数量
    /// @return feeAmount 交易步长中收取的手续费数量
    function computeSwapStep(
        uint160 sqrtPriceX96,
        uint160 sqrtPriceTargetX96,
        uint128 liquidity,
        int256 amountRemaining,
        uint24 fee
    ) internal pure returns (
        uint160 sqrtPriceNextX96,
        uint256 amountIn,
        uint256 amountOut,
        uint256 feeAmount
    ) {
        // 声明局部变量
        uint256 amount0;
        uint256 amount1;
        
        // 确定交易方向和类型
        bool isExactInput = amountRemaining > 0;
        bool zeroForOne = sqrtPriceTargetX96 < sqrtPriceX96;

        // 确保价格顺序正确
        if (zeroForOne) {
            require(sqrtPriceTargetX96 > TickMath.getSqrtPriceAtTick(TickMath.MIN_TICK), "SwapMath: PRICE_TARGET_TOO_LOW");
            require(sqrtPriceX96 > sqrtPriceTargetX96, "SwapMath: INVALID_PRICE_ORDER");
        } else {
            require(sqrtPriceTargetX96 < TickMath.getSqrtPriceAtTick(TickMath.MAX_TICK), "SwapMath: PRICE_TARGET_TOO_HIGH");
            require(sqrtPriceX96 < sqrtPriceTargetX96, "SwapMath: INVALID_PRICE_ORDER");
        }

        if (isExactInput) {
            // 精确输入模式：计算能获得的输出代币数量
            uint256 amountRemainingAbs = uint256(amountRemaining);
            // 计算手续费
            feeAmount = (amountRemainingAbs * fee) / 1e6;
            uint256 amountInWithFee = amountRemainingAbs - feeAmount;

            if (zeroForOne) {
                // token0 → token1
                // 计算能达到的最高价格
                sqrtPriceNextX96 = getNextSqrtPriceFromInput(zeroForOne, sqrtPriceX96, liquidity, amountInWithFee);
                // 计算实际的输入和输出数量
                (amount0, amount1) = SqrtPriceMath.getAmountsForPriceImpact(sqrtPriceX96, sqrtPriceNextX96, liquidity, zeroForOne);
                amountIn = amount0;
                amountOut = amount1;
            } else {
                // token1 → token0
                // 计算能达到的最低价格
                sqrtPriceNextX96 = getNextSqrtPriceFromInput(zeroForOne, sqrtPriceX96, liquidity, amountInWithFee);
                // 计算实际的输入和输出数量
                (amount0, amount1) = SqrtPriceMath.getAmountsForPriceImpact(sqrtPriceX96, sqrtPriceNextX96, liquidity, zeroForOne);
                amountIn = amount1;
                amountOut = amount0;
            }

            // 确保价格不超过目标价格
            if ((zeroForOne && sqrtPriceNextX96 < sqrtPriceTargetX96) || (!zeroForOne && sqrtPriceNextX96 > sqrtPriceTargetX96)) {
                sqrtPriceNextX96 = sqrtPriceTargetX96;
                // 重新计算在目标价格下的输入和输出数量
                (amountIn, amountOut) = zeroForOne 
                    ? SqrtPriceMath.getAmountsForPriceImpact(sqrtPriceX96, sqrtPriceTargetX96, liquidity, zeroForOne)
                    : (amount1, amount0);
                // 调整手续费
                feeAmount = (amountIn * fee) / 1e6;
                // 调整总输入数量
                amountIn = amountIn + feeAmount;
            }
        } else {
            // 精确输出模式：计算需要的输入代币数量
            uint256 amountRemainingAbs = uint256(-amountRemaining);

            if (zeroForOne) {
                // token0 → token1
                // 计算需要达到的价格
                sqrtPriceNextX96 = getNextSqrtPriceFromOutput(zeroForOne, sqrtPriceX96, liquidity, amountRemainingAbs);
                // 计算实际的输入和输出数量
                (amount0, amount1) = SqrtPriceMath.getAmountsForPriceImpact(sqrtPriceX96, sqrtPriceNextX96, liquidity, zeroForOne);
                amountIn = amount0;
                amountOut = amount1;
            } else {
                // token1 → token0
                // 计算需要达到的价格
                sqrtPriceNextX96 = getNextSqrtPriceFromOutput(zeroForOne, sqrtPriceX96, liquidity, amountRemainingAbs);
                // 计算实际的输入和输出数量
                (amount0, amount1) = SqrtPriceMath.getAmountsForPriceImpact(sqrtPriceX96, sqrtPriceNextX96, liquidity, zeroForOne);
                amountIn = amount1;
                amountOut = amount0;
            }

            // 确保价格不超过目标价格
            if ((zeroForOne && sqrtPriceNextX96 < sqrtPriceTargetX96) || (!zeroForOne && sqrtPriceNextX96 > sqrtPriceTargetX96)) {
                sqrtPriceNextX96 = sqrtPriceTargetX96;
                // 重新计算在目标价格下的输入和输出数量
                // 先获取价格影响对应的代币数量
                (amount0, amount1) = SqrtPriceMath.getAmountsForPriceImpact(sqrtPriceX96, sqrtPriceTargetX96, liquidity, zeroForOne);
                // 根据交易方向确定输入和输出数量
                (amountIn, amountOut) = zeroForOne ? (amount0, amount1) : (amount1, amount0);
            }

            // 计算手续费
            feeAmount = (amountIn * fee) / (1e6 - fee);
            // 调整总输入数量
            amountIn = amountIn + feeAmount;
        }

        // 确保价格变化合理
        require(sqrtPriceNextX96 != sqrtPriceX96, "SwapMath: NO_PRICE_CHANGE");
    }

    /// @notice 根据输入代币数量计算新的价格
    /// @param zeroForOne 交易方向（token0→token1为true，token1→token0为false）
    /// @param sqrtPriceX96 当前Q64.96格式的平方根价格
    /// @param liquidity 流动性数量
    /// @param amountIn 输入代币数量
    /// @return sqrtPriceNextX96 新的Q64.96格式平方根价格
    function getNextSqrtPriceFromInput(
        bool zeroForOne,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        uint256 amountIn
    ) internal pure returns (uint160 sqrtPriceNextX96) {
        require(amountIn > 0, "SwapMath: INVALID_AMOUNT_IN");

        if (zeroForOne) {
            // token0 → token1: 价格下降
            // 计算新的价格
            uint256 numerator = uint256(liquidity) << 96;
            uint256 denominator = numerator + (uint256(amountIn) * uint256(sqrtPriceX96));
            sqrtPriceNextX96 = denominator > 0 ? uint160(numerator / denominator) : 0;
        } else {
            // token1 → token0: 价格上升
            // 计算新的价格
            uint256 numerator = (uint256(liquidity) << 96) + (uint256(amountIn) * uint256(sqrtPriceX96));
            uint256 denominator = uint256(liquidity) << 96;
            sqrtPriceNextX96 = denominator > 0 ? uint160(numerator / denominator) : type(uint160).max;
        }

        // 确保价格在有效范围内
        sqrtPriceNextX96 = boundPrice(sqrtPriceNextX96);
    }

    /// @notice 根据输出代币数量计算新的价格
    /// @param zeroForOne 交易方向（token0→token1为true，token1→token0为false）
    /// @param sqrtPriceX96 当前Q64.96格式的平方根价格
    /// @param liquidity 流动性数量
    /// @param amountOut 输出代币数量
    /// @return sqrtPriceNextX96 新的Q64.96格式平方根价格
    function getNextSqrtPriceFromOutput(
        bool zeroForOne,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        uint256 amountOut
    ) internal pure returns (uint160 sqrtPriceNextX96) {
        require(amountOut > 0, "SwapMath: INVALID_AMOUNT_OUT");

        if (zeroForOne) {
            // token0 → token1: 价格下降
            // 计算新的价格
            uint256 numerator = uint256(liquidity) << 96;
            uint256 denominator = uint256(liquidity) << 96 + (uint256(amountOut) * uint256(sqrtPriceX96));
            sqrtPriceNextX96 = denominator > 0 ? uint160(numerator / denominator) : 0;
        } else {
            // token1 → token0: 价格上升
            // 计算新的价格
            uint256 numerator = (uint256(liquidity) << 96) + (uint256(amountOut) * uint256(sqrtPriceX96));
            uint256 denominator = uint256(liquidity) << 96;
            sqrtPriceNextX96 = denominator > 0 ? uint160(numerator / denominator) : type(uint160).max;
        }

        // 确保价格在有效范围内
        sqrtPriceNextX96 = boundPrice(sqrtPriceNextX96);
    }

    /// @notice 将价格限制在有效范围内
    /// @param sqrtPriceX96 需要限制的Q64.96格式平方根价格
    /// @return boundedSqrtPriceX96 限制后的Q64.96格式平方根价格
    function boundPrice(uint160 sqrtPriceX96) internal pure returns (uint160 boundedSqrtPriceX96) {
        uint160 minSqrtPriceX96 = TickMath.getSqrtPriceAtTick(TickMath.MIN_TICK);
        uint160 maxSqrtPriceX96 = TickMath.getSqrtPriceAtTick(TickMath.MAX_TICK);

        if (sqrtPriceX96 < minSqrtPriceX96) {
            boundedSqrtPriceX96 = minSqrtPriceX96;
        } else if (sqrtPriceX96 > maxSqrtPriceX96) {
            boundedSqrtPriceX96 = maxSqrtPriceX96;
        } else {
            boundedSqrtPriceX96 = sqrtPriceX96;
        }
    }

    /// @notice 计算交易所产生的手续费
    /// @param amountIn 输入代币数量
    /// @param fee 手续费率（单位：1e6分之一，例如0.3%=3000）
    /// @return feeAmount 手续费数量
    function computeFeeAmount(uint256 amountIn, uint24 fee) internal pure returns (uint256 feeAmount) {
        require(amountIn > 0, "SwapMath: INVALID_AMOUNT_IN");
        require(fee <= 1e6, "SwapMath: INVALID_FEE");
        feeAmount = FullMath.mulDiv(amountIn, fee, 1e6);
    }

    /// @notice 计算精确输入交易的输出数量和新价格
    /// @param zeroForOne 交易方向（token0→token1为true，token1→token0为false）
    /// @param sqrtPriceX96 当前Q64.96格式的平方根价格
    /// @param liquidity 流动性数量
    /// @param amountIn 输入代币数量
    /// @param fee 手续费率
    /// @return sqrtPriceNextX96 新的Q64.96格式平方根价格
    /// @return amountOut 输出代币数量
    /// @return feeAmount 手续费数量
    function computeExactInput(
        bool zeroForOne,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        uint256 amountIn,
        uint24 fee
    ) internal pure returns (
        uint160 sqrtPriceNextX96,
        uint256 amountOut,
        uint256 feeAmount
    ) {
        // 计算手续费
        feeAmount = computeFeeAmount(amountIn, fee);
        uint256 amountInWithFee = amountIn - feeAmount;

        // 计算新的价格
        sqrtPriceNextX96 = getNextSqrtPriceFromInput(zeroForOne, sqrtPriceX96, liquidity, amountInWithFee);

        // 计算输出数量
        (uint256 amount0, uint256 amount1) = SqrtPriceMath.getAmountsForPriceImpact(sqrtPriceX96, sqrtPriceNextX96, liquidity, zeroForOne);
        amountOut = zeroForOne ? amount1 : amount0;
    }

    /// @notice 计算精确输出交易的输入数量和新价格
    /// @param zeroForOne 交易方向（token0→token1为true，token1→token0为false）
    /// @param sqrtPriceX96 当前Q64.96格式的平方根价格
    /// @param liquidity 流动性数量
    /// @param amountOut 输出代币数量
    /// @param fee 手续费率
    /// @return sqrtPriceNextX96 新的Q64.96格式平方根价格
    /// @return amountIn 输入代币数量
    /// @return feeAmount 手续费数量
    function computeExactOutput(
        bool zeroForOne,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        uint256 amountOut,
        uint24 fee
    ) internal pure returns (
        uint160 sqrtPriceNextX96,
        uint256 amountIn,
        uint256 feeAmount
    ) {
        // 计算新的价格
        sqrtPriceNextX96 = getNextSqrtPriceFromOutput(zeroForOne, sqrtPriceX96, liquidity, amountOut);

        // 计算输入数量
        (uint256 amount0, uint256 amount1) = SqrtPriceMath.getAmountsForPriceImpact(sqrtPriceX96, sqrtPriceNextX96, liquidity, zeroForOne);
        uint256 amountInWithoutFee = zeroForOne ? amount0 : amount1;

        // 计算手续费和总输入数量
        feeAmount = (amountInWithoutFee * fee) / (1e6 - fee);
        amountIn = amountInWithoutFee + feeAmount;
    }
}