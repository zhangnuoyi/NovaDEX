// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../../contracts/NovaDEX/Factory.sol";
import "../../contracts/NovaDEX/Pool.sol";

contract FactoryTest is Test {
    Factory public factory;
    address public token0 = 0x1111111111111111111111111111111111111111;
    address public token1 = 0x2222222222222222222222222222222222222222;
    int24 public tickLower = -60;
    int24 public tickUpper = 60;
    uint24 public fee = 3000;

    function setUp() public {
        // 部署Factory合约
        factory = new Factory();
    }

    function testDeployment() public {
        // 验证合约部署成功
        assert(address(factory) != address(0));
    }

    function testTokenSorting() public {
        // 测试代币排序功能
        (address sorted0, address sorted1) = factory.sortTokens(token0, token1);
        assert(sorted0 == token0);
        assert(sorted1 == token1);

        (address sorted2, address sorted3) = factory.sortTokens(token1, token0);
        assert(sorted2 == token0);
        assert(sorted3 == token1);
    }

    function testCreatePool() public {
        // 测试创建池功能
        address pool = factory.createPool(token0, token1, tickLower, tickUpper, fee);
        assert(pool != address(0));

        // 验证池地址可以通过getPool获取（使用索引0）
        address poolFromMapping = factory.getPool(token0, token1, 0);
        assert(poolFromMapping == pool);

        // 验证池的初始化状态
        Pool poolContract = Pool(pool);
        assert(poolContract.token0() == token0);
        assert(poolContract.token1() == token1);
        assert(poolContract.fee() == fee);
        assert(poolContract.tickLower() == tickLower);
        assert(poolContract.tickUpper() == tickUpper);
    }
}