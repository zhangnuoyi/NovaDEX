// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.24;

/**
 * @title IFactory
 * @dev Interface for the factory contract.
 */
interface IFactory {

    struct Parameter {
        address factory;
        address tokenA;
        address tokenB;
        int24 tickLower; // 下一个tick
        int24 tickUpper; // 上一个tick
        uint24 fee; // 手续费
    }


    function parameters() external view returns (Parameter memory);



    event PoolCreated(
        address token0;
        address token1;
        uint32 index;
        int24 tickLower; // 下一个tick
        int24 tickUpper; // 上一个tick
        uint24 fee; // 手续费
        address pool;
    )

    function getPool(
        address tokenA,
        address tokenB,
        uint32 index
    ) external view returns (address pool);


    function createPool(
        address tokenA,
        address tokenB,
        uint32 tickLower,
        uint32 tickUpper,
        uint24 fee
    ) external returns (address pool);
}