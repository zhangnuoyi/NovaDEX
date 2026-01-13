import { useSelector, useDispatch } from 'react-redux'
import { RootState } from '../../store'
import { connectWallet, disconnectWallet } from '../../store/slices/walletSlice'

interface NavbarProps {
  toggleSidebar: () => void
}

const Navbar: React.FC<NavbarProps> = ({ toggleSidebar }) => {
  const { isConnected, address } = useSelector((state: RootState) => state.wallet)
  const dispatch = useDispatch()

  const handleConnectWallet = () => {
    // 这里应该调用实际的钱包连接逻辑
    // 模拟连接
    dispatch(connectWallet({
      address: '0x742d35Cc6634C0532925a3b816428822c5f7B105',
      chainId: 1,
      balance: '1.234 ETH'
    }))
  }

  const handleDisconnectWallet = () => {
    dispatch(disconnectWallet())
  }

  const truncateAddress = (addr: string) => {
    return `${addr.slice(0, 6)}...${addr.slice(-4)}`
  }

  return (
    <nav className="bg-card border-b border-border px-4 py-3 md:px-6 fixed w-full top-0 z-50">
      <div className="container mx-auto flex justify-between items-center">
        <div className="flex items-center">
          {/* 汉堡菜单按钮（移动端） */}
          <button 
            className="md:hidden mr-4 text-text-secondary hover:text-text transition-colors"
            onClick={toggleSidebar}
          >
            <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h16" />
            </svg>
          </button>

          {/* Logo */}
          <div className="flex items-center">
            <div className="w-10 h-10 bg-primary rounded-full flex items-center justify-center">
              <span className="text-white font-bold text-lg">ND</span>
            </div>
            <span className="ml-2 text-xl font-bold text-white">NovaDEX</span>
          </div>

          {/* 桌面端导航菜单 */}
          <div className="hidden md:flex ml-10 space-x-8">
            <a href="/" className="text-text hover:text-secondary transition-colors font-medium">交易</a>
            <a href="/liquidity" className="text-text-secondary hover:text-text transition-colors font-medium">流动性</a>
            <a href="/positions" className="text-text-secondary hover:text-text transition-colors font-medium">头寸</a>
            <a href="/pool-explorer" className="text-text-secondary hover:text-text transition-colors font-medium">池浏览器</a>
            <a href="/profile" className="text-text-secondary hover:text-text transition-colors font-medium">个人中心</a>
          </div>
        </div>

        {/* 右侧操作区 */}
        <div className="flex items-center space-x-4">
          {/* 连接钱包按钮 */}
          {!isConnected ? (
            <button 
              className="bg-primary hover:bg-primary/90 text-white font-medium py-2 px-6 rounded-lg transition-colors btn"
              onClick={handleConnectWallet}
            >
              连接钱包
            </button>
          ) : (
            <div className="relative group">
              <button className="bg-card border border-border text-white font-medium py-2 px-4 rounded-lg flex items-center space-x-2 hover:bg-card/80 transition-colors">
                <span>{truncateAddress(address!)}</span>
                <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                </svg>
              </button>
              {/* 下拉菜单 */}
              <div className="absolute right-0 mt-2 w-48 bg-card border border-border rounded-lg shadow-lg z-10 opacity-0 invisible group-hover:opacity-100 group-hover:visible transition-all duration-200">
                <div className="px-4 py-2 text-sm text-text-secondary">
                  {truncateAddress(address!)}
                </div>
                <div className="border-t border-border"></div>
                <button 
                  className="w-full text-left px-4 py-2 text-sm text-text hover:bg-primary/20 transition-colors"
                  onClick={handleDisconnectWallet}
                >
                  断开连接
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </nav>
  )
}

export default Navbar