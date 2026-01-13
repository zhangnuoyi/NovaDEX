// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.24;

interface IMintCallback{
    function mintCallback(
   
        uint256 amount0Owed,
        uint256 amount1Owed,
 
        bytes  calldata data
    ) external;
}

interface ISwapCallback{
    function swapCallback(
        uint256 amount0Delta, // 0 token 数量
        uint256 amount1Delta, // 1 token 数量
 
        bytes  calldata data 
    ) external;
}

interface IPool{
    function factory () external view returns (address); // 工厂合约地址

    function token0() external view returns (address); // 0 token 地址
    function token1() external view returns (address); // 1 token 地址
    
    function fee() external view returns (uint24); // 手续费
    function tickLower () external view returns (int24); // 下一个tick
    function tickUpper () external view returns (int24); // 上一个tick
    function sqrtPriceX96() external view returns (uint160); // 当前价格
    function tick() external view returns (int24); // 当前tick

    function liquidity() external view returns (uint128); // 流动性

    function feeGrowthGlobal0X128() external view returns (uint256); // 0 token 手续费增长
    function feeGrowthGlobal1X128() external view returns (uint256); // 1 token 手续费增长

    // 持仓量
    function position( address owner) external view returns (
             uint128 _liquidity, // 持仓量
            uint256 feeGrowthInside0LastX128, // 0 token 手续费增长
            uint256 feeGrowthInside1LastX128, // 1 token 手续费增长 

            uint128 tokensOwed0, // 0 token 余额
            uint128 tokensOwed1 // 1 token 余额
        ); // 持仓量
    // 铸造事件
    event Mint(
        address sender,
        address indexed owner,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );
    factory mint(
        address recipient, // 接收者
        uint128 amount, // 持仓量
        bytes calldata data
    ) external returns (
        uint256 amount0,
        uint256 amount1
    );


    event Collect(
        address indexed owner,
        address recipient, // 接收者
        uint128 amount0,
        uint128 amount1
    );

    function collect(
        address recipient, // 接收者
        uint128 amount0, // 0 token 数量
        uint128 amount1 // 1 token 数量
    ) external returns (
        uint256 amount0Owed,
        uint256 amount1Owed
    );

    event Burn(
        address indexed owner,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    function burn(
        uint128 amount, // 持仓量
    ) external returns (
        uint256 amount0,
        uint256 amount1
    );

    event Swap(
        address indexed sender,
        address indexed recipient, // 接收者
        uint256 amount0, // 0 token 数量
        uint256 amount1, // 1 token 数量
        uint160 sqrtPriceX96, // 当前价格
        uint128 liquidity, // 流动性
        int24 tick // 当前tick
    );

    
    function swap(
        address recipient, // 接收者
        bool zeroForOne, // 是否0 token 到 1 token
        int256 amountSpecified, // 交换数量
        uint160 sqrtPriceLimitX96, // 价格限制
        bytes calldata data // 回调数据
    ) external returns (int256 amount0, int256 amount1);
}