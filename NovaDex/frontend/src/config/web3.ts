import { createConfig, http } from 'wagmi'
import { mainnet, sepolia, hardhat } from 'wagmi/chains'
import { injected, walletConnect } from 'wagmi/connectors'

// 配置Wagmi客户端
export const config = createConfig({
  chains: [mainnet, sepolia, hardhat],
  connectors: [
    injected(),
    walletConnect({
      projectId: 'YOUR_PROJECT_ID', // 需要在WalletConnect上注册获取
    }),
  ],
  transports: {
    [mainnet.id]: http(),
    [sepolia.id]: http(),
    [hardhat.id]: http('http://127.0.0.1:8545'), // 本地Hardhat节点
  },
})

// 智能合约地址配置（将在部署后更新）
export const contractAddresses = {
  factory: '0x0000000000000000000000000000000000000000',
  positionManager: '0x0000000000000000000000000000000000000000',
  swapRouter: '0x0000000000000000000000000000000000000000',
}
