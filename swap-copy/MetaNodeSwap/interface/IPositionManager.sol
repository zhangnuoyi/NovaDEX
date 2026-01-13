// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.24;
pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IPositionManager is IERC721 {
    // 持仓信息
    struct PositionInfo{
        uint256 id; // 持仓id
        address owner; // 持仓者
        address token0; // 0 token 地址
        address token1; // 1 token 地址
        uint32 index;
        uint24 fee; // 手续费
        int24 tickLower; // 下一个tick
        int24 tickUpper; // 上一个tick
        uint128 liquidity; // 流动性
        uint128 tokensOwed0; // 0 token 余额
        uint128 tokensOwed1; // 1 token 余额
        uint256 feeGrowthInside0LastX128; // 0 token 手续费增长
        uint256 feeGrowthInside1LastX128; // 1 token 手续费增长
    }

    function getAllPositions() external view returns (PositionInfo[] memory positions);

    struct MintParams{
        address token0; // 0 token 地址
        address token1; // 1 token 地址
        uint32 index;
        uint256 amount0Desired; // 0 token 数量
        uint256 amount1Desired; // 1 token 数量
        address recipient; // 接收者
        uint256 deadline; // 截止时间
    }

    function mint(MintParams calldata params) external returns (
        
        uint256 positionId, // 持仓id
        uint128 liquidity, // 持仓量
        uint256 amount0, // 0 token 数量
        uint256 amount1 // 1 token 数量
        
        );

        function burn(uint256 positionId) external returns (uint256 amount0,uint256 amount1);
        // 收集手续费
        function collect(uint256 positionId, address recipient) external returns (uint256 amount0,uint256 amount1);
        // 铸造回调
        function mintCallback(
            uint256 amount0Owed,
            uint256 amount1Owed,
            bytes calldata data
        ) external;

}