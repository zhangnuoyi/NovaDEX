import { Link, useLocation } from 'react-router-dom'

interface SidebarProps {
  isOpen: boolean
  onClose: () => void
}

const Sidebar: React.FC<SidebarProps> = ({ isOpen, onClose }) => {
  const location = useLocation()

  const navItems = [
    { path: '/', label: '交易', icon: '📊' },
    { path: '/liquidity', label: '流动性', icon: '💧' },
    { path: '/positions', label: '头寸', icon: '📈' },
    { path: '/pool-explorer', label: '池浏览器', icon: '🏊' },
    { path: '/profile', label: '个人中心', icon: '👤' },
  ]

  return (
    <>
      {/* 移动端遮罩 */}
      {isOpen && (
        <div 
          className="fixed inset-0 bg-black bg-opacity-50 z-40 md:hidden"
          onClick={onClose}
        ></div>
      )}

      {/* 侧边栏 */}
      <aside 
        className={`fixed top-0 left-0 h-full w-64 bg-card border-r border-border z-50 transform transition-transform duration-300 ease-in-out
          ${isOpen ? 'translate-x-0' : '-translate-x-full'} md:translate-x-0`}
      >
        {/* 侧边栏头部 */}
        <div className="px-6 py-4 border-b border-border">
          <div className="flex items-center">
            <div className="w-10 h-10 bg-primary rounded-full flex items-center justify-center">
              <span className="text-white font-bold text-lg">ND</span>
            </div>
            <span className="ml-2 text-xl font-bold text-white">NovaDEX</span>
          </div>
        </div>

        {/* 导航菜单 */}
        <nav className="p-4">
          <ul className="space-y-2">
            {navItems.map((item) => (
              <li key={item.path}>
                <Link 
                  to={item.path}
                  onClick={onClose}
                  className={`flex items-center space-x-3 px-4 py-3 rounded-lg text-lg font-medium transition-colors
                    ${location.pathname === item.path 
                      ? 'bg-primary/20 text-secondary' 
                      : 'text-text-secondary hover:text-text hover:bg-card/80'}`}
                >
                  <span className="text-xl">{item.icon}</span>
                  <span>{item.label}</span>
                </Link>
              </li>
            ))}
          </ul>
        </nav>

        {/* 侧边栏底部 */}
        <div className="absolute bottom-0 left-0 right-0 p-4 border-t border-border">
          <div className="text-center text-sm text-text-secondary">
            <p>v1.0.0</p>
            <p className="mt-1">NovaDEX © 2026</p>
          </div>
        </div>
      </aside>
    </>
  )
}

export default Sidebar