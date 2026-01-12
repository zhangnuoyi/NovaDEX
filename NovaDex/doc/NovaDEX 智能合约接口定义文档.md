# NovaDEX 智能合约接口定义文档

## 1. 文档概述

本接口定义文档详细描述了 NovaDEX 智能合约的接口规范，包括数据结构、函数签名和事件定义，为开发团队提供明确的接口开发指导。

## 2. Factory 合约接口

### 2.1 数据结构

```solidity
// 用于创建池的参数
struct Parameters {
    address factory;
    address token0;
    address token1;
    int24 tickLower;
    int24 tickUpper;
    uint24 fee;
}
```

### 2.2 函数签名

#### 2.2.1 池创建函数

```solidity
function createPool(
    address tokenA,
    address tokenB,
    int24 tickLower,
    int24 tickUpper,
    uint24 fee
) external returns (address pool);
```

#### 2.2.2 池查询函数

```solidity
function getPool(
    address tokenA,
    address tokenB,
    uint32 index
) external view returns (address pool);
```

### 2.3 事件定义

```solidity
event PoolCreated(
    address indexed token0,
    address indexed token1,
    uint32 indexed index,
    int24 tickLower,
    int24 tickUpper,
    uint24 fee,
    address pool
);
```

## 3. Pool 合约接口

### 3.1 回调接口

#### 3.1.1 Mint 回调接口

```solidity
interface IMintCallback {
    function mintCallback(
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;
}
```

#### 3.1.2 Swap 回调接口

```solidity
interface ISwapCallback {
    function swapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
```

### 3.2 数据结构

```solidity
// 头寸信息
struct Position {
    uint128 liquidity;
    uint128 tokensOwed0;
    uint128 tokensOwed1;
    uint256 feeGrowthInside0LastX128;
    uint256 feeGrowthInside1LastX128;
}
```

### 3.3 函数签名

#### 3.3.1 池初始化函数

```solidity
function initialize(uint160 sqrtPriceX96) external;
```

#### 3.3.2 流动性提供函数

```solidity
function mint(
    address recipient,
    uint128 amount,
    bytes calldata data
) external returns (uint256 amount0, uint256 amount1);
```

#### 3.3.3 流动性提取函数

```solidity
function burn(
    uint128 amount
) external returns (uint256 amount0, uint256 amount1);
```

#### 3.3.4 手续费收取函数

```solidity
function collect(
    address recipient,
    uint128 amount0Requested,
    uint128 amount1Requested
) external returns (uint128 amount0, uint128 amount1);
```

#### 3.3.5 代币交换函数

```solidity
function swap(
    address recipient,
    bool zeroForOne,
    int256 amountSpecified,
    uint160 sqrtPriceLimitX96,
    bytes calldata data
) external returns (int256 amount0, int256 amount1);
```

### 3.4 事件定义

#### 3.4.1 Mint 事件

```solidity
event Mint(
    address sender,
    address indexed owner,
    uint128 amount,
    uint256 amount0,
    uint256 amount1
);
```

#### 3.4.2 Burn 事件

```solidity
event Burn(
    address indexed owner,
    uint128 amount,
    uint256 amount0,
    uint256 amount1
);
```

#### 3.4.3 Collect 事件

```solidity
event Collect(
    address indexed owner,
    address recipient,
    uint128 amount0,
    uint128 amount1
);
```

#### 3.4.4 Swap 事件

```solidity
event Swap(
    address indexed sender,
    address indexed recipient,
    int256 amount0,
    int256 amount1,
    uint160 sqrtPriceX96,
    uint128 liquidity,
    int24 tick
);
```

## 4. PositionManager 合约接口

### 4.1 数据结构

```solidity
// 头寸信息
struct PositionInfo {
    uint256 id;
    address owner;
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint128 liquidity;
    uint128 tokensOwed0;
    uint128 tokensOwed1;
    uint256 feeGrowthInside0LastX128;
    uint256 feeGrowthInside1LastX128;
}

// 头寸创建参数
struct MintParams {
    address token0;
    address token1;
    uint24 fee;
    int24 tickLower;
    int24 tickUpper;
    uint256 amount0Desired;
    uint256 amount1Desired;
    uint256 amount0Min;
    uint256 amount1Min;
    address recipient;
    uint256 deadline;
}
```

### 4.2 函数签名

#### 4.2.1 头寸创建函数

```solidity
function mint(
    MintParams calldata params
) external returns (
    uint256 tokenId,
    uint128 liquidity,
    uint256 amount0,
    uint256 amount1
);
```

#### 4.2.2 头寸销毁函数

```solidity
function burn(
    uint256 tokenId,
    uint128 amount
) external returns (uint256 amount0, uint256 amount1);
```

#### 4.2.3 头寸手续费收取函数

```solidity
function collect(
    uint256 tokenId,
    address recipient,
    uint128 amount0Requested,
    uint128 amount1Requested
) external returns (uint128 amount0, uint128 amount1);
```

#### 4.2.4 头寸查询函数

```solidity
function getPosition(
    uint256 tokenId
) external view returns (PositionInfo memory position);
```

## 5. SwapRouter 合约接口

### 5.1 数据结构

#### 5.1.1 精确输入交易参数

```solidity
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
```

#### 5.1.2 精确输出交易参数

```solidity
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
```

#### 5.1.3 精确输入报价参数

```solidity
struct QuoteExactInputParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    uint256 amountIn;
    uint160 sqrtPriceLimitX96;
}
```

#### 5.1.4 精确输出报价参数

```solidity
struct QuoteExactOutputParams {
    address tokenIn;
    address tokenOut;
    uint24 fee;
    uint256 amountOut;
    uint160 sqrtPriceLimitX96;
}
```

### 5.2 函数签名

#### 5.2.1 精确输入交易函数

```solidity
function exactInput(
    ExactInputParams calldata params
) external returns (uint256 amountOut);
```

#### 5.2.2 精确输出交易函数

```solidity
function exactOutput(
    ExactOutputParams calldata params
) external returns (uint256 amountIn);
```

#### 5.2.3 精确输入报价函数

```solidity
function quoteExactInput(
    QuoteExactInputParams calldata params
) external view returns (uint256 amountOut);
```

#### 5.2.4 精确输出报价函数

```solidity
function quoteExactOutput(
    QuoteExactOutputParams calldata params
) external view returns (uint256 amountIn);
```

## 6. 数学库接口

### 6.1 TickMath 库

```solidity
function getTickAtSqrtPrice(uint160 sqrtPriceX96) internal pure returns (int24 tick);
function getSqrtPriceAtTick(int24 tick) internal pure returns (uint160 sqrtPriceX96);
```

### 6.2 SqrtPriceMath 库

```solidity
function getAmount0Delta(
    uint160 sqrtPriceAX96,
    uint160 sqrtPriceBX96,
    int128 liquidity
) internal pure returns (int256 amount0);

function getAmount1Delta(
    uint160 sqrtPriceAX96,
    uint160 sqrtPriceBX96,
    int128 liquidity
) internal pure returns (int256 amount1);
```

### 6.3 SwapMath 库

```solidity
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
);
```

## 7. 接口文件结构

```
├── contracts/
│   ├── NovaDEX/
│   │   ├── interfaces/
│   │   │   ├── IFactory.sol
│   │   │   ├── IPool.sol
│   │   │   ├── IPositionManager.sol
│   │   │   └── ISwapRouter.sol
│   │   └── libraries/
│   │       ├── TickMath.sol
│   │       ├── SqrtPriceMath.sol
│   │       └── SwapMath.sol
```

## 8. 接口实现规范

### 8.1 数据类型规范

- 地址类型使用 `address`
- 整数类型使用 `uint256` 或 `int256`，除非有明确的大小限制
- 费率使用 `uint24`，范围 0-1000000（表示 0.0000% 到 100.0000%）
- Tick 值使用 `int24`，范围 -887272 到 887272
- Liquidity 使用 `uint128`

### 8.2 命名规范

- 合约名称使用 PascalCase
- 函数名称使用 camelCase
- 变量名称使用 camelCase
- 常量名称使用 UPPERCASE_SNAKE_CASE
- 事件名称使用 PascalCase
- 结构体名称使用 PascalCase

### 8.3 函数可见性规范

- 外部调用函数使用 `external`
- 内部调用函数使用 `internal`
- 纯函数使用 `pure`
- 视图函数使用 `view`

### 8.4 错误处理规范

- 使用自定义错误类型
- 错误消息清晰明确
- 错误代码具有唯一性

## 9. 接口兼容性

### 9.1 ERC20 兼容性

所有代币操作都必须与 ERC20 标准兼容，包括：
- 转账函数 `transfer`
- 授权函数 `approve`
- 批量转账函数 `transferFrom`

### 9.2 ERC721 兼容性

PositionManager 合约必须实现 ERC721 标准，包括：
- 铸造函数 `_mint`
- 销毁函数 `_burn`
- 转移函数 `transferFrom`
- 所有者查询函数 `ownerOf`
- 元数据函数 `tokenURI`

## 10. 测试接口

所有接口必须有对应的测试用例，包括：
- 单元测试
- 集成测试
- 边界条件测试
- 错误处理测试

## 11. 文档规范

所有接口必须有对应的文档注释，包括：
- 函数功能描述
- 参数说明
- 返回值说明
- 事件说明
- 错误说明

使用 Solidity 的 NatSpec 格式编写文档注释。
