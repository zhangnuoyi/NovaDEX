// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title SwapRouter 合约接口
 * @notice NovaDEX SwapRouter 合约用于处理代币交换
 */
interface ISwapRouter {
    /**
     * @notice 精确输入交易参数
     * @param tokenIn 输入代币地址
     * @param tokenOut 输出代币地址
     * @param fee 交易费率
     * @param recipient 接收地址
     * @param deadline 交易截止时间
     * @param amountIn 输入代币数量
     * @param amountOutMinimum 最小接受的输出代币数量
     * @param sqrtPriceLimitX96 价格限制
     */
    struct ExactInputParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /**
     * @notice 精确输出交易参数
     * @param tokenIn 输入代币地址
     * @param tokenOut 输出代币地址
     * @param fee 交易费率
     * @param recipient 接收地址
     * @param deadline 交易截止时间
     * @param amountOut 输出代币数量
     * @param amountInMaximum 最大接受的输入代币数量
     * @param sqrtPriceLimitX96 价格限制
     */
    struct ExactOutputParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /**
     * @notice 精确输入报价参数
     * @param tokenIn 输入代币地址
     * @param tokenOut 输出代币地址
     * @param fee 交易费率
     * @param amountIn 输入代币数量
     * @param sqrtPriceLimitX96 价格限制
     */
    struct QuoteExactInputParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        uint256 amountIn;
        uint160 sqrtPriceLimitX96;
    }

    /**
     * @notice 精确输出报价参数
     * @param tokenIn 输入代币地址
     * @param tokenOut 输出代币地址
     * @param fee 交易费率
     * @param amountOut 输出代币数量
     * @param sqrtPriceLimitX96 价格限制
     */
    struct QuoteExactOutputParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        uint256 amountOut;
        uint160 sqrtPriceLimitX96;
    }

    /**
     * @notice 精确输入交易
     * @param params 交易参数
     * @return amountOut 实际输出的代币数量
     */
    function exactInput(
        ExactInputParams calldata params
    ) external returns (uint256 amountOut);

    /**
     * @notice 精确输出交易
     * @param params 交易参数
     * @return amountIn 实际输入的代币数量
     */
    function exactOutput(
        ExactOutputParams calldata params
    ) external returns (uint256 amountIn);

    /**
     * @notice 精确输入报价
     * @param params 报价参数
     * @return amountOut 预期输出的代币数量
     */
    function quoteExactInput(
        QuoteExactInputParams calldata params
    ) external view returns (uint256 amountOut);

    /**
     * @notice 精确输出报价
     * @param params 报价参数
     * @return amountIn 预期输入的代币数量
     */
    function quoteExactOutput(
        QuoteExactOutputParams calldata params
    ) external view returns (uint256 amountIn);
}
