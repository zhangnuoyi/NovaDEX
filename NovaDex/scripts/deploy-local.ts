import { ethers, hardhatArguments } from "hardhat";

async function main() {
  console.log("开始部署NovaDEX智能合约...");

  // 部署Factory合约
  const Factory = await ethers.getContractFactory("Factory");
  const factory = await Factory.deploy();
  await factory.waitForDeployment();
  const factoryAddress = await factory.getAddress();
  console.log("Factory合约部署成功：", factoryAddress);

  // 部署PositionManager合约
  const PositionManager = await ethers.getContractFactory("PositionManager");
  const positionManager = await PositionManager.deploy(factoryAddress);
  await positionManager.waitForDeployment();
  const positionManagerAddress = await positionManager.getAddress();
  console.log("PositionManager合约部署成功：", positionManagerAddress);

  // 部署SwapRouter合约
  const SwapRouter = await ethers.getContractFactory("SwapRouter");
  const swapRouter = await SwapRouter.deploy(factoryAddress);
  await swapRouter.waitForDeployment();
  const swapRouterAddress = await swapRouter.getAddress();
  console.log("SwapRouter合约部署成功：", swapRouterAddress);

  console.log("\n所有合约部署完成！");
  console.log("\n合约地址：");
  console.log(`Factory: ${factoryAddress}`);
  console.log(`PositionManager: ${positionManagerAddress}`);
  console.log(`SwapRouter: ${swapRouterAddress}`);

  // 创建一个简单的池（ETH-USDC）作为测试
  console.log("\n创建测试池（ETH-USDC）...");
  
  // 假设的代币地址（在真实环境中需要先部署ERC20代币）
  const token0 = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2"; // WETH
  const token1 = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48"; // USDC
  const fee = 3000; // 0.3%
  const tickLower = -887272; // 最低价格
  const tickUpper = 887272; // 最高价格

  try {
    const poolTx = await factory.createPool(token0, token1, tickLower, tickUpper, fee);
    await poolTx.wait();
    console.log("测试池创建成功");
  } catch (error) {
    console.log("创建测试池时出错：", error instanceof Error ? error.message : String(error));
    console.log("注意：在本地测试中，您需要先部署ERC20代币合约");
  }

  console.log("\n部署完成！可以开始前后端联调测试。");
  console.log("\n测试账户信息：");
  console.log("账户0: 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266");
  console.log("私钥: 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80");
  console.log("\n请使用此私钥在MetaMask中添加账户，连接到本地网络（http://127.0.0.1:8545）");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
