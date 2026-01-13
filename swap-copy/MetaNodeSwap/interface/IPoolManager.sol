// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.24;
pragma abicoder v2;

import "./IFactory.sol";

interface IPoolManager is IFactory {
 
    struct PoolInfo{
        address pool; // 池合约地址
        address token0; // 0 token 地址
        address token1; // 1 token 地址
        uint32 index;
        uint24 fee; // 手续费
        uint8 feeProtocol; // 手续费协议
        int24 tickLower; // 下一个tick
        int24 tickUpper; // 上一个tick
        uint160 sqrtPriceX96; // 当前价格
        uint128 liquidity; // 流动性
        int24 tick; // 当前tick
    }

    struct Pair {
        address token0; // 0 token 地址
        address token1; // 1 token 地址
    }

    function getPairs() external view returns (Pair[] memory pairs);
    function getAllPoolInfo() external view returns (PoolInfo[] memory poolInfos);

    struct  CreateAndInitializePoolParams{
        address tokenA;
        address tokenB;
        uint32 index;
        int24 tickLower; // 下一个tick
        int24 tickUpper; // 上一个tick
        uint24 fee; // 手续费
    }

    // 创建并初始化池
    function createAndInitializePoolIfNecessary(
        CreateAndInitializePoolParams calldata params
    ) external returns (address pool);
}

