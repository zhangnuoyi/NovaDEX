# MetaNodeSwap DEX 功能设计文档

## 1. 项目概述

MetaNodeSwap 是一个基于以太坊的去中心化交易所（DEX），采用了类似 Uniswap V3 的集中流动性机制，允许流动性提供者（LP）在特定价格区间内提供流动性，从而提高资金利用率。

### 1.1 核心价值主张
- **集中流动性**：LP 可以在特定价格区间内提供流动性，提高资金效率
- **多费率支持**：支持不同交易费率的流动性池
- **高效交易**：基于数学模型的价格计算和流动性分配
- **安全可靠**：完全去中心化的智能合约实现

### 1.2 目标用户
- 加密货币交易者
- 流动性提供者
- DeFi 应用开发者

## 2. 系统架构

MetaNodeSwap 采用模块化架构设计，主要包含以下核心合约：

### 2.1 核心合约结构

| 合约名称 | 主要功能 | 接口 |
|---------|---------|------|
| Factory | 流动性池工厂，用于创建和管理池 | IFactory |
| Pool | 核心交易合约，处理流动性和交易 | IPool |
| PoolManager | 池管理器，提供池创建和初始化的便捷接口 | IPoolManager |
| PositionManager | 流动性位置管理器，使用 ERC721 管理 LP 头寸 | IPositionManager |
| SwapRouter | 交易路由器，提供统一的交易接口 | ISwapRouter |

### 2.2 数据流图

```
用户 -> SwapRouter -> Pool -> 交易执行
用户 -> PositionManager -> Pool -> 流动性管理
工厂 -> Pool -> 池创建与初始化
```

## 3. 核心功能设计

### 3.1 流动性池管理

#### 3.1.1 池创建
- **功能**：允许用户创建新的流动性池
- **参数**：
  - tokenA, tokenB: 交易对代币地址
  - tickLower, tickUpper: 价格区间
  - fee: 交易费率
- **实现**：
  ```solidity
  function createPool(
      address tokenA,
      address tokenB,
      int24 tickLower,
      int24 tickUpper,
      uint24 fee
  ) external returns (address pool);
  ```

#### 3.1.2 池初始化
- **功能**：初始化池的初始价格
- **参数**：
  - sqrtPriceX96: 初始价格的平方根（Q64.96 格式）
- **实现**：
  ```solidity
  function initialize(uint160 sqrtPriceX96) external;
  ```

### 3.2 流动性管理

#### 3.2.1 提供流动性（Mint）
- **功能**：在指定价格区间内提供流动性
- **参数**：
  - recipient: 流动性接收地址
  - amount: 流动性数量
  - data: 回调数据
- **实现**：
  ```solidity
  function mint(
      address recipient,
      uint128 amount,
      bytes calldata data
  ) external returns (uint256 amount0, uint256 amount1);
  ```

#### 3.2.2 提取流动性（Burn）
- **功能**：从池中提取流动性
- **参数**：
  - amount: 要提取的流动性数量
- **实现**：
  ```solidity
  function burn(uint128 amount) external returns (uint256 amount0, uint256 amount1);
  ```

#### 3.2.3 收取手续费（Collect）
- **功能**：收取累积的交易手续费
- **参数**：
  - recipient: 手续费接收地址
  - amount0Requested: 请求的 token0 手续费数量
  - amount1Requested: 请求的 token1 手续费数量
- **实现**：
  ```solidity
  function collect(
      address recipient,
      uint128 amount0Requested,
      uint128 amount1Requested
  ) external returns (uint128 amount0, uint128 amount1);
  ```

### 3.3 交易功能

#### 3.3.1 代币交换（Swap）
- **功能**：在池中进行代币交换
- **参数**：
  - recipient: 接收地址
  - zeroForOne: 交易方向（token0 到 token1 为 true）
  - amountSpecified: 指定的交易数量
  - sqrtPriceLimitX96: 价格限制
  - data: 回调数据
- **实现**：
  ```solidity
  function swap(
      address recipient,
      bool zeroForOne,
      int256 amountSpecified,
      uint160 sqrtPriceLimitX96,
      bytes calldata data
  ) external returns (int256 amount0, int256 amount1);
  ```

#### 3.3.2 交易路由
- **功能**：提供统一的交易接口，支持复杂交易路径
- **实现**：SwapRouter 合约

### 3.4 头寸管理

#### 3.4.1 ERC721 头寸
- **功能**：使用 ERC721 代币表示 LP 头寸
- **特点**：每个头寸对应一个唯一的 NFT

#### 3.4.2 批量操作
- **功能**：支持批量创建、管理和交易头寸

## 4. 技术特点

### 4.1 价格模型

采用 Q64.96 格式的平方根价格表示法，确保高精度计算：

- `sqrtPriceX96`: 当前价格的平方根（Q64.96 格式）
- `tick`: 当前价格对应的整数刻度

### 4.2 流动性模型

集中流动性机制：
- LP 可以在 `[tickLower, tickUpper)` 区间内提供流动性
- 只有当当前价格在该区间内时，流动性才会被使用
- 提高了资金利用率

### 4.3 手续费计算

动态手续费计算：
- 基于交易金额和当前费率
- 手续费累积到全局变量 `feeGrowthGlobal0X128` 和 `feeGrowthGlobal1X128`
- LP 按其流动性比例分配手续费

### 4.4 安全性设计

- **回调机制**：使用 `mintCallback` 和 `swapCallback` 确保资金安全
- **权限控制**：无中心化控制，完全由智能合约规则管理
- **数学验证**：所有价格和流动性计算都经过严格的数学验证

## 5. 合约交互流程

### 5.1 流动性提供流程

1. 用户调用 `PositionManager.mint()` 创建头寸
2. `PositionManager` 调用 `Pool.mint()`
3. `Pool` 计算所需代币数量并调用 `mintCallback`
4. 用户在回调中转移代币到池
5. `Pool` 更新流动性并发出事件

### 5.2 交易流程

1. 用户调用 `SwapRouter.swap()`
2. `SwapRouter` 调用 `Pool.swap()`
3. `Pool` 计算交易价格和数量
4. `Pool` 调用 `swapCallback` 接收输入代币
5. `Pool` 转移输出代币给用户
6. `Pool` 更新价格和流动性并发出事件

## 6. 数据结构

### 6.1 核心数据结构

```solidity
// Factory 参数
struct Parameters {
    address factory;
    address tokenA;
    address tokenB;
    int24 tickLower;
    int24 tickUpper;
    uint24 fee;
}

// 池信息
struct PoolInfo {
    address pool;
    address token0;
    address token1;
    uint32 index;
    uint24 fee;
    uint8 feeProtocol;
    int24 tickLower;
    int24 tickUpper;
    int24 tick;
    uint160 sqrtPriceX96;
    uint128 liquidity;
}

// 头寸信息
struct Position {
    uint128 liquidity;
    uint128 tokensOwed0;
    uint128 tokensOwed1;
    uint256 feeGrowthInside0LastX128;
    uint256 feeGrowthInside1LastX128;
}
```

## 7. 未来扩展计划

- 支持更多 EVM 兼容链
- 实现跨链交易功能
- 支持限价订单
- 集成预言机服务
- 开发治理机制

## 8. 安全考虑

- 智能合约审计
- 形式化验证
- 漏洞赏金计划
- 应急响应机制

## 9. 部署与维护

- 合约升级机制
- 监控与告警
- 文档更新
- 社区支持

# 附录

## A. 术语表

- **DEX**: 去中心化交易所
- **LP**: 流动性提供者
- **tick**: 价格刻度，用于表示价格区间
- **sqrtPriceX96**: Q64.96 格式的平方根价格
- **集中流动性**: 允许 LP 在特定价格区间内提供流动性的机制
- **ERC721**: 非同质化代币标准

## B. 参考资料

- [Uniswap V3 白皮书](https://uniswap.org/whitepaper-v3.pdf)
- [以太坊智能合约开发文档](https://docs.soliditylang.org/)
- [OpenZeppelin 合约库](https://openzeppelin.com/contracts/)
