import { useState } from 'react'
import { BrowserRouter as Router, Routes, Route, Link } from 'react-router-dom'
import Navbar from './components/Navbar/Navbar'
import Sidebar from './components/Sidebar/Sidebar'
import Home from './pages/Home/Home'
import Liquidity from './pages/Liquidity/Liquidity'
import Positions from './pages/Positions/Positions'
import PoolExplorer from './pages/PoolExplorer/PoolExplorer'
import Profile from './pages/Profile/Profile'

function App() {
  const [isSidebarOpen, setIsSidebarOpen] = useState(false)

  const toggleSidebar = () => {
    setIsSidebarOpen(!isSidebarOpen)
  }

  return (
    <Router>
      <div className="min-h-screen bg-background">
        <Navbar toggleSidebar={toggleSidebar} />
        <div className="flex">
          <Sidebar isOpen={isSidebarOpen} onClose={() => setIsSidebarOpen(false)} />
          <main className="flex-1 p-4 md:p-6 lg:p-8">
            <Routes>
              <Route path="/" element={<Home />} />
              <Route path="/liquidity" element={<Liquidity />} />
              <Route path="/positions" element={<Positions />} />
              <Route path="/pool-explorer" element={<PoolExplorer />} />
              <Route path="/profile" element={<Profile />} />
            </Routes>
          </main>
        </div>
        <footer className="py-4 px-6 bg-card border-t border-border mt-auto">
          <div className="container mx-auto text-center text-text-secondary text-sm">
            © 2026 NovaDEX. All rights reserved.
          </div>
        </footer>
      </div>
    </Router>
  )
}

export default App