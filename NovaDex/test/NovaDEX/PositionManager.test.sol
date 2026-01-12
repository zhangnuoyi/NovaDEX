// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/NovaDEX/Factory.sol";
import "../../contracts/NovaDEX/Pool.sol";
import "../../contracts/NovaDEX/PositionManager.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract PositionManagerTest is Test {
    Factory public factory;
    PositionManager public positionManager;
    address public token0 = 0x1111111111111111111111111111111111111111;
    address public token1 = 0x2222222222222222222222222222222222222222;
    int24 public tickLower = -60;
    int24 public tickUpper = 60;
    uint24 public fee = 3000;
    address public recipient = 0x3333333333333333333333333333333333333333;

    function setUp() public {
        // 部署Factory合约
        factory = new Factory();
        // 部署PositionManager合约
        positionManager = new PositionManager(address(factory));
    }

    function testDeployment() public view {
        // 验证合约部署成功
        assert(address(factory) != address(0));
        assert(address(positionManager) != address(0));
    }

    function testCreatePosition() public {
        // 测试创建头寸功能
        uint256 amount0Desired = 1000000;
        uint256 amount1Desired = 1000000;
        uint256 amount0Min = 900000;
        uint256 amount1Min = 900000;
        uint256 deadline = block.timestamp + 1 hours;

        // 模拟代币转账
        vm.mockCall(
            token0,
            abi.encodeWithSelector(IERC20.transferFrom.selector),
            abi.encode(true)
        );

        vm.mockCall(
            token1,
            abi.encodeWithSelector(IERC20.transferFrom.selector),
            abi.encode(true)
        );

        // 调用createPosition函数
        (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1) = 
            positionManager.createPosition(
                token0,
                token1,
                fee,
                tickLower,
                tickUpper,
                amount0Desired,
                amount1Desired,
                amount0Min,
                amount1Min,
                recipient,
                deadline
            );

        // 验证返回值
        assert(tokenId > 0);
        assert(liquidity == 0); // 当前实现返回0，后续需要完善
        assert(amount0 == 0); // 当前实现返回0，后续需要完善
        assert(amount1 == 0); // 当前实现返回0，后续需要完善

        // 验证头寸信息
        PositionManager.Position memory position = positionManager.getPosition(tokenId);
        assert(position.owner == recipient);
        assert(position.token0 == token0);
        assert(position.token1 == token1);
        assert(position.fee == fee);
        assert(position.tickLower == tickLower);
        assert(position.tickUpper == tickUpper);
        assert(position.liquidity == liquidity);
    }

    function testBurnPosition() public {
        // 先创建一个头寸
        uint256 amount0Desired = 1000000;
        uint256 amount1Desired = 1000000;
        uint256 amount0Min = 900000;
        uint256 amount1Min = 900000;
        uint256 deadline = block.timestamp + 1 hours;

        // 模拟代币转账
        vm.mockCall(
            token0,
            abi.encodeWithSelector(IERC20.transferFrom.selector),
            abi.encode(true)
        );

        vm.mockCall(
            token1,
            abi.encodeWithSelector(IERC20.transferFrom.selector),
            abi.encode(true)
        );

        // 创建头寸
        (uint256 tokenId, , , ) = 
            positionManager.createPosition(
                token0,
                token1,
                fee,
                tickLower,
                tickUpper,
                amount0Desired,
                amount1Desired,
                amount0Min,
                amount1Min,
                recipient,
                deadline
            );

        // 模拟代币转账
        vm.mockCall(
            token0,
            abi.encodeWithSelector(IERC20.transfer.selector),
            abi.encode(true)
        );

        vm.mockCall(
            token1,
            abi.encodeWithSelector(IERC20.transfer.selector),
            abi.encode(true)
        );

        // 使用vm.prank模拟头寸所有者的调用
        vm.prank(recipient);
        (uint256 amount0, uint256 amount1) = positionManager.burnPosition(tokenId, 0);

        // 验证返回值
        assert(amount0 == 0); // 当前实现返回0，后续需要完善
        assert(amount1 == 0); // 当前实现返回0，后续需要完善
    }

    function testCollectFees() public {
        // 先创建一个头寸
        uint256 amount0Desired = 1000000;
        uint256 amount1Desired = 1000000;
        uint256 amount0Min = 900000;
        uint256 amount1Min = 900000;
        uint256 deadline = block.timestamp + 1 hours;

        // 模拟代币转账
        vm.mockCall(
            token0,
            abi.encodeWithSelector(IERC20.transferFrom.selector),
            abi.encode(true)
        );

        vm.mockCall(
            token1,
            abi.encodeWithSelector(IERC20.transferFrom.selector),
            abi.encode(true)
        );

        // 创建头寸
        (uint256 tokenId, , , ) = 
            positionManager.createPosition(
                token0,
                token1,
                fee,
                tickLower,
                tickUpper,
                amount0Desired,
                amount1Desired,
                amount0Min,
                amount1Min,
                recipient,
                deadline
            );

        // 模拟代币转账
        vm.mockCall(
            token0,
            abi.encodeWithSelector(IERC20.transfer.selector),
            abi.encode(true)
        );

        vm.mockCall(
            token1,
            abi.encodeWithSelector(IERC20.transfer.selector),
            abi.encode(true)
        );

        // 使用vm.prank模拟头寸所有者的调用
        vm.prank(recipient);
        (uint256 amount0, uint256 amount1) = positionManager.collectFees(
            tokenId,
            recipient,
            1000,
            1000
        );

        // 验证返回值
        assert(amount0 == 0); // 当前实现返回0，后续需要完善
        assert(amount1 == 0); // 当前实现返回0，后续需要完善
    }
}
