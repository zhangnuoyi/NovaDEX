// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IFactory } from "./interfaces/IFactory.sol";
import { Pool } from "./Pool.sol";

/**
 * @title Factory 合约实现
 * @notice NovaDEX Factory 合约用于创建和管理流动性池
 */
contract Factory is IFactory {
    // 工厂所有者
    address public owner;

    // 池创建代码哈希
    bytes32 public constant POOL_INIT_CODE_HASH = keccak256(type(Pool).creationCode);

    // 代币对到池数组的映射
    mapping(address => mapping(address => address[])) public pools;

    /**
     * @notice 构造函数
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @notice 内部函数：对输入的两个代币地址进行排序
     * @param tokenA 代币A地址
     * @param tokenB 代币B地址
     * @return token0 排序后的第一个代币地址
     * @return token1 排序后的第二个代币地址
     */
    function _sortTokens(
        address tokenA,
        address tokenB
    ) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "Identical tokens");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
    }

    /**
     * @notice 对输入的两个代币地址进行排序
     * @param tokenA 代币A地址
     * @param tokenB 代币B地址
     * @return token0 排序后的第一个代币地址
     * @return token1 排序后的第二个代币地址
     */
    function sortTokens(
        address tokenA,
        address tokenB
    ) external pure override returns (address token0, address token1) {
        return _sortTokens(tokenA, tokenB);
    }

    /**
     * @notice 创建新的流动性池
     * @param tokenA 代币A地址
     * @param tokenB 代币B地址
     * @param tickLower 价格区间下限
     * @param tickUpper 价格区间上限
     * @param fee 交易费率
     * @return pool 创建的池合约地址
     */
    function createPool(
        address tokenA,
        address tokenB,
        int24 tickLower,
        int24 tickUpper,
        uint24 fee
    ) external override returns (address pool) {
        // 参数验证
        require(tokenA != address(0), "Invalid tokenA");
        require(tokenB != address(0), "Invalid tokenB");
        require(tokenA != tokenB, "Identical tokens");
        require(fee > 0 && fee <= 1000000, "Invalid fee");
        require(tickLower < tickUpper, "Invalid tick range");

        // 对代币进行排序
        (address token0, address token1) = _sortTokens(tokenA, tokenB);

        // 计算CREATE2盐值
        bytes32 salt = keccak256(abi.encode(token0, token1, tickLower, tickUpper, fee));

        // 使用CREATE2创建池合约
        pool = address(new Pool{
            salt: salt
        }(token0, token1, fee, tickLower, tickUpper));

        // 将新池添加到映射中
        pools[token0][token1].push(pool);
        pools[token1][token0].push(pool);

        // 发出池创建事件
        emit PoolCreated(token0, token1, pool, fee);
    }

    /**
     * @notice 根据代币地址和索引查询池地址
     * @param tokenA 代币A地址
     * @param tokenB 代币B地址
     * @param index 池索引
     * @return pool 池合约地址
     */
    function getPool(
        address tokenA,
        address tokenB,
        uint256 index
    ) external view override returns (address pool) {
        // 对代币进行排序
        (address token0, address token1) = _sortTokens(tokenA, tokenB);

        // 检查索引是否有效
        require(index < pools[token0][token1].length, "Invalid index");

        return pools[token0][token1][index];
    }
}
