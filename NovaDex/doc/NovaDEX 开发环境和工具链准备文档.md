# NovaDEX 开发环境和工具链准备文档

## 1. 文档概述

本文档详细描述了 NovaDEX 项目的开发环境和工具链准备步骤，包括环境安装、项目结构创建、依赖配置和测试环境设置，为开发团队提供明确的开发环境搭建指导。

## 2. 开发环境安装

### 2.1 Node.js 安装

NovaDEX 项目使用 Node.js 作为开发环境，推荐使用 LTS 版本。

#### 2.1.1 Windows 安装

1. 访问 [Node.js 官方网站](https://nodejs.org/)
2. 下载 Windows 安装包（LTS 版本）
3. 运行安装包，按照提示进行安装
4. 安装完成后，打开命令提示符，运行以下命令验证安装：
   ```bash
   node --version
   npm --version
   ```

#### 2.1.2 macOS 安装

1. 访问 [Node.js 官方网站](https://nodejs.org/)
2. 下载 macOS 安装包（LTS 版本）
3. 运行安装包，按照提示进行安装
4. 安装完成后，打开终端，运行以下命令验证安装：
   ```bash
   node --version
   npm --version
   ```

#### 2.1.3 Linux 安装

使用包管理器安装：

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install nodejs npm

# CentOS/Fedora
sudo dnf install nodejs npm

# 验证安装
node --version
npm --version
```

### 2.2 Hardhat 安装

Hardhat 是 NovaDEX 项目的开发框架，用于智能合约的开发、测试和部署。

```bash
# 全局安装 Hardhat
npm install -g hardhat

# 验证安装
hardhat --version
```

### 2.3 Solidity 编译器安装

NovaDEX 项目使用 Solidity 0.8.24 版本，Hardhat 会自动安装相应版本的编译器。

### 2.4 其他工具安装

```bash
# 安装 Ethers.js（用于与以太坊交互）
npm install ethers

# 安装 OpenZeppelin Contracts（用于安全的智能合约库）
npm install @openzeppelin/contracts

# 安装 Mocha 和 Chai（用于测试）
npm install --save-dev mocha chai
```

## 3. 项目结构创建

### 3.1 创建项目目录

```bash
# 创建项目根目录
mkdir -p f:\workspace\solidity\Base2_Solidity_Dex\NovaDex

# 进入项目根目录
cd f:\workspace\solidity\Base2_Solidity_Dex\NovaDex
```

### 3.2 初始化 Hardhat 项目

```bash
# 初始化 Hardhat 项目
hardhat init
```

选择 "Create a JavaScript project" 或 "Create a TypeScript project"，根据团队偏好选择。

### 3.3 创建合约目录结构

```bash
# 创建合约目录
mkdir -p contracts/NovaDEX/interfaces
mkdir -p contracts/NovaDEX/libraries
mkdir -p contracts/NovaDEX/test-contracts

# 创建测试目录
mkdir -p test/NovaDEX

# 创建部署脚本目录
mkdir -p scripts

# 创建文档目录
mkdir -p doc
```

### 3.4 最终项目结构

```
f:\workspace\solidity\Base2_Solidity_Dex\NovaDex/
├── contracts/
│   ├── NovaDEX/
│   │   ├── interfaces/
│   │   │   ├── IFactory.sol
│   │   │   ├── IPool.sol
│   │   │   ├── IPositionManager.sol
│   │   │   └── ISwapRouter.sol
│   │   ├── libraries/
│   │   │   ├── TickMath.sol
│   │   │   ├── SqrtPriceMath.sol
│   │   │   ├── SwapMath.sol
│   │   │   └── FullMath.sol
│   │   ├── Factory.sol
│   │   ├── Pool.sol
│   │   ├── PositionManager.sol
│   │   ├── SwapRouter.sol
│   │   └── test-contracts/
│   │       ├── TestToken.sol
│   │       └── TestLP.sol
├── test/
│   ├── NovaDEX/
│   │   ├── Factory.test.js
│   │   ├── Pool.test.js
│   │   ├── PositionManager.test.js
│   │   └── SwapRouter.test.js
├── scripts/
│   └── deploy.js
├── doc/
│   ├── NovaDEX_Technical_Design_Document.md
│   ├── NovaDEX_Requirements_Document.md
│   ├── NovaDEX_Interface_Definitions.md
│   ├── NovaDEX_Math_Model_Verification.md
│   ├── NovaDEX_Security_Design_Strategy.md
│   ├── NovaDEX_Development_Plan.md
│   └── NovaDEX_Development_Environment_Setup.md
├── hardhat.config.js
├── package.json
└── README.md
```

## 4. 项目配置

### 4.1 Hardhat 配置

编辑 `hardhat.config.js` 文件，添加以下配置：

```javascript
require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-etherscan");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    ropsten: {
      url: process.env.ROPSTEN_URL || "https://ropsten.infura.io/v3/",
      accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : []
    }
  },
  etherscan: {
    apiKey: process.env.ETHERSCAN_API_KEY
  }
};
```

### 4.2 package.json 配置

编辑 `package.json` 文件，添加以下脚本：

```json
{
  "name": "novadex",
  "version": "1.0.0",
  "description": "NovaDEX Decentralized Exchange",
  "scripts": {
    "compile": "npx hardhat compile",
    "test": "npx hardhat test",
    "test:gas": "REPORT_GAS=true npx hardhat test",
    "node": "npx hardhat node",
    "deploy": "npx hardhat run scripts/deploy.js",
    "deploy:ropsten": "npx hardhat run scripts/deploy.js --network ropsten",
    "verify": "npx hardhat verify",
    "lint": "npx eslint . --ext .js,.ts",
    "lint:fix": "npx eslint . --ext .js,.ts --fix"
  },
  "dependencies": {
    "@openzeppelin/contracts": "^4.8.0",
    "ethers": "^5.7.0"
  },
  "devDependencies": {
    "@nomicfoundation/hardhat-toolbox": "^2.0.0",
    "@nomiclabs/hardhat-etherscan": "^3.0.0",
    "chai": "^4.3.6",
    "eslint": "^8.34.0",
    "eslint-config-standard": "^17.0.0",
    "eslint-plugin-import": "^2.27.5",
    "eslint-plugin-node": "^11.1.0",
    "eslint-plugin-promise": "^6.1.1",
    "hardhat": "^2.12.7",
    "mocha": "^10.2.0"
  }
}
```

## 5. 依赖库安装

运行以下命令安装项目依赖：

```bash
# 安装生产依赖
npm install

# 安装开发依赖
npm install --save-dev
```

## 6. 开发工具配置

### 6.1 VS Code 配置

推荐使用 Visual Studio Code 作为开发工具，并安装以下扩展：

1. **Solidity**：Solidity 语言支持
2. **Hardhat**：Hardhat 集成支持
3. **ESLint**：代码质量检查
4. **Prettier**：代码格式化
5. **GitLens**：Git 集成

### 6.2 Remix IDE 配置

Remix IDE 是一个在线 Solidity 开发环境，用于快速测试和调试智能合约。

1. 访问 [Remix IDE 网站](https://remix.ethereum.org/)
2. 创建新的 Remix 工作区
3. 导入项目合约文件
4. 配置 Solidity 编译器版本为 0.8.24
5. 使用 Remix 的测试功能进行合约测试

## 7. 测试环境设置

### 7.1 本地测试网络

使用 Hardhat 内置的本地测试网络进行开发和测试：

```bash
# 启动本地测试网络
npx hardhat node
```

本地测试网络将在 http://127.0.0.1:8545 上运行，并提供 20 个测试账户。

### 7.2 测试账户配置

编辑 `.env` 文件，添加以下配置：

```bash
# 测试账户私钥（从本地测试网络获取）
PRIVATE_KEY=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# Infura API 密钥（用于测试网部署）
INFURA_API_KEY=your_infura_api_key

# Etherscan API 密钥（用于合约验证）
ETHERSCAN_API_KEY=your_etherscan_api_key
```

### 7.3 测试脚本创建

创建测试脚本，用于测试合约功能：

```javascript
// test/NovaDEX/Factory.test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Factory Contract", function () {
  let Factory;
  let factory;
  let TokenA;
  let tokenA;
  let TokenB;
  let tokenB;
  let owner;
  let addr1;
  
  beforeEach(async function () {
    // 获取测试账户
    [owner, addr1] = await ethers.getSigners();
    
    // 部署测试代币
    TokenA = await ethers.getContractFactory("TestToken");
    tokenA = await TokenA.deploy("Token A", "TA", ethers.utils.parseEther("1000000"));
    await tokenA.deployed();
    
    TokenB = await ethers.getContractFactory("TestToken");
    tokenB = await TokenB.deploy("Token B", "TB", ethers.utils.parseEther("1000000"));
    await tokenB.deployed();
    
    // 部署 Factory 合约
    Factory = await ethers.getContractFactory("Factory");
    factory = await Factory.deploy();
    await factory.deployed();
  });
  
  describe("Deployment", function () {
    it("Should set the right owner", async function () {
      expect(await factory.owner()).to.equal(owner.address);
    });
  });
  
  describe("Pool Creation", function () {
    it("Should create a new pool", async function () {
      const tickLower = -60;
      const tickUpper = 60;
      const fee = 3000;
      
      await expect(factory.createPool(tokenA.address, tokenB.address, tickLower, tickUpper, fee))
        .to.emit(factory, "PoolCreated");
      
      const pool = await factory.getPool(tokenA.address, tokenB.address, 0);
      expect(pool).to.not.equal(ethers.constants.AddressZero);
    });
  });
});
```

## 8. 安全工具配置

### 8.1 Slither 安装

Slither 是一个 Solidity 静态分析工具，用于检测智能合约漏洞。

```bash
# 安装 Python
# 然后安装 Slither
pip install slither-analyzer

# 运行 Slither 分析
slither .
```

### 8.2 Mythril 安装

Mythril 是一个智能合约安全分析工具，用于检测漏洞。

```bash
# 安装 Mythril
pip install mythril

# 运行 Mythril 分析
myth analyze contracts/NovaDEX/Factory.sol
```

## 9. 代码质量工具配置

### 9.1 ESLint 配置

创建 `.eslintrc.json` 文件，配置 ESLint：

```json
{
  "extends": "standard",
  "rules": {
    "semi": ["error", "always"],
    "quotes": ["error", "double"]
  },
  "env": {
    "node": true,
    "mocha": true
  }
}
```

### 9.2 Prettier 配置

创建 `.prettierrc` 文件，配置 Prettier：

```json
{
  "semi": true,
  "singleQuote": false,
  "printWidth": 80,
  "tabWidth": 2,
  "trailingComma": "es5"
}
```

## 10. Git 配置

### 10.1 Git 初始化

```bash
# 初始化 Git 仓库
git init

# 配置 Git 用户
# git config user.name "Your Name"
# git config user.email "your.email@example.com"
```

### 10.2 .gitignore 配置

创建 `.gitignore` 文件，添加以下配置：

```gitignore
# Dependencies
node_modules/

# Environment variables
.env
.env.local
.env.test
.env.production

# Build artifacts
dist/
build/

# Test coverage
coverage/

# Editor directories and files
.vscode/
.idea/
*.swp
*.swo
*~

# OS files
.DS_Store
Thumbs.db

# Logs
logs/
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*
```

## 11. 开发环境验证

运行以下命令验证开发环境是否配置正确：

```bash
# 编译合约
npx hardhat compile

# 运行测试
npx hardhat test

# 启动本地测试网络
npx hardhat node
```

如果所有命令都能正常运行，说明开发环境配置正确。

## 12. 开发工作流程

1. 创建新的功能分支
2. 编写智能合约代码
3. 运行单元测试
4. 进行代码审查
5. 合并到主分支
6. 进行集成测试
7. 部署到测试网
8. 进行最终测试
9. 部署到主网

## 13. 结论

本开发环境和工具链准备文档详细描述了 NovaDEX 项目的开发环境搭建步骤，包括环境安装、项目结构创建、依赖配置和测试环境设置。开发团队应严格按照本文档进行开发环境搭建，确保开发环境的一致性和稳定性。