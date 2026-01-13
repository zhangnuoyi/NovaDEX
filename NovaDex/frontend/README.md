# NovaDEX 前端项目

## 项目概述

NovaDEX 前端项目是基于 React + TypeScript + Tailwind CSS 构建的去中心化交易所用户界面，完整支持 NovaDEX 的所有核心功能，包括代币交易、流动性管理和头寸管理等。

## 技术栈

- **框架**: React 18
- **语言**: TypeScript
- **CSS 框架**: Tailwind CSS 3
- **状态管理**: Redux Toolkit
- **Web3 集成**: Ethers.js 6
- **图表库**: Chart.js
- **构建工具**: Vite

## 项目结构

```
frontend/
├── public/              # 静态资源
├── src/
│   ├── assets/         # 图片、图标等资源
│   ├── components/     # 通用组件
│   │   ├── Button/     # 按钮组件
│   │   ├── Card/       # 卡片组件
│   │   ├── Form/       # 表单组件
│   │   ├── Modal/      # 模态框组件
│   │   └── Navbar/     # 导航栏组件
│   ├── pages/          # 页面组件
│   │   ├── Home/       # 首页/交易页面
│   │   ├── Liquidity/  # 流动性管理页面
│   │   ├── Positions/  # 头寸管理页面
│   │   ├── PoolExplorer/ # 池浏览器页面
│   │   └── Profile/    # 个人中心页面
│   ├── services/       # 业务逻辑层
│   │   ├── web3/       # Web3 服务
│   │   ├── api/        # API 服务
│   │   └── contracts/  # 智能合约交互
│   ├── store/          # Redux 状态管理
│   │   ├── slices/     # Redux slices
│   │   └── index.ts    # Redux store
│   ├── types/          # TypeScript 类型定义
│   ├── utils/          # 工具函数
│   ├── App.tsx         # 应用根组件
│   ├── main.tsx        # 应用入口
│   └── index.css       # 全局样式
├── tailwind.config.js  # Tailwind 配置
├── tsconfig.json       # TypeScript 配置
├── vite.config.ts      # Vite 配置
├── package.json        # 项目依赖
└── README.md           # 项目文档
```

## 核心功能实现

### 1. 钱包连接

- 支持 MetaMask、WalletConnect 等主流钱包
- 实时显示钱包余额和网络状态
- 自动检测和提示网络切换

### 2. 代币交易

- 支持精确输入和精确输出交易模式
- 实时价格更新和手续费计算
- 交易确认和状态跟踪
- 历史交易记录查询

### 3. 流动性管理

- 创建和管理流动性头寸
- 实时显示流动性数量和手续费收益
- 添加和移除流动性功能
- 池浏览器功能

### 4. 头寸管理

- 显示所有头寸 NFT
- 头寸详细信息查看
- 手续费收取功能
- NFT 转移功能

## 开发指南

### 安装依赖

```bash
npm install
```

### 开发模式

```bash
npm run dev
```

### 构建生产版本

```bash
npm run build
```

### 代码检查

```bash
npm run lint
```

## UI 设计规范

请参考项目根目录下的 `NovaDEX_UI_Design_Document.md` 文件，严格按照设计规范进行开发。

## 智能合约交互

前端项目通过 Ethers.js 与 NovaDEX 智能合约进行交互，主要交互的合约包括：

- Factory 合约
- Pool 合约
- PositionManager 合约
- SwapRouter 合约

合约 ABIs 和地址配置在 `src/services/contracts/` 目录下。

## 安全注意事项

- 所有合约调用必须经过用户确认
- 敏感信息不得存储在前端
- 定期更新依赖库，修复安全漏洞
- 严格验证用户输入，防止恶意攻击

## 性能优化

- 使用 React.memo 和 useMemo 优化组件渲染
- 实现虚拟列表，优化大数据量展示
- 图片懒加载，提高页面加载速度
- 缓存频繁使用的数据，减少网络请求

## 浏览器兼容性

- Chrome (最新版本)
- Firefox (最新版本)
- Safari (最新版本)
- Edge (最新版本)

## 贡献指南

1. Fork 项目
2. 创建特性分支
3. 提交代码
4. 创建 Pull Request

## 许可证

MIT License