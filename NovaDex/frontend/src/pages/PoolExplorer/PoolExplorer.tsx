import { useState } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import { RootState } from '../../store'
import { setSelectedPool } from '../../store/slices/liquiditySlice'
import Button from '../../components/Button/Button'
import Input from '../../components/Input/Input'
import Card from '../../components/Card/Card'

const PoolExplorer: React.FC = () => {
  const { selectedPool, isLoading, error } = useSelector((state: RootState) => state.liquidity)
  const dispatch = useDispatch()

  const [searchTerm, setSearchTerm] = useState('')
  const [sortBy, setSortBy] = useState('liquidity')
  const [sortOrder, setSortOrder] = useState('desc')

  const handleSearchChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchTerm(e.target.value)
  }

  const handleSortChange = (field: string) => {
    if (sortBy === field) {
      setSortOrder(sortOrder === 'asc' ? 'desc' : 'asc')
    } else {
      setSortBy(field)
      setSortOrder('desc')
    }
  }

  const handlePoolClick = (pool: any) => {
    dispatch(setSelectedPool(pool))
  }

  const handleAddLiquidity = () => {
    if (!selectedPool) return
    
    // 这里应该导航到流动性页面并填充所选池的信息
    alert('添加流动性功能将在此实现')
  }

  const handleTrade = () => {
    if (!selectedPool) return
    
    // 这里应该导航到交易页面并填充所选池的信息
    alert('交易功能将在此实现')
  }

  // 模拟池数据
  const mockPools = [
    {
      id: '1',
      token0: { address: '', symbol: 'ETH', decimals: 18, balance: '0' },
      token1: { address: '', symbol: 'USDC', decimals: 6, balance: '0' },
      fee: 3000,
      liquidity: '1234567890',
      volume24h: '543210000',
      sqrtPriceX96: '79228162514264337593543950336',
      tick: 85184
    },
    {
      id: '2',
      token0: { address: '', symbol: 'ETH', decimals: 18, balance: '0' },
      token1: { address: '', symbol: 'DAI', decimals: 18, balance: '0' },
      fee: 500,
      liquidity: '987654321',
      volume24h: '987654000',
      sqrtPriceX96: '79228162514264337593543950336',
      tick: 85184
    },
    {
      id: '3',
      token0: { address: '', symbol: 'BTC', decimals: 18, balance: '0' },
      token1: { address: '', symbol: 'ETH', decimals: 18, balance: '0' },
      fee: 10000,
      liquidity: '567890123',
      volume24h: '234567000',
      sqrtPriceX96: '79228162514264337593543950336',
      tick: 85184
    },
    {
      id: '4',
      token0: { address: '', symbol: 'LINK', decimals: 18, balance: '0' },
      token1: { address: '', symbol: 'USDC', decimals: 6, balance: '0' },
      fee: 3000,
      liquidity: '345678901',
      volume24h: '123456000',
      sqrtPriceX96: '79228162514264337593543950336',
      tick: 85184
    }
  ]

  // 过滤和排序池
  const filteredPools = mockPools.filter(pool => {
    const poolName = `${pool.token0.symbol}/${pool.token1.symbol}`
    return poolName.toLowerCase().includes(searchTerm.toLowerCase())
  })

  const sortedPools = [...filteredPools].sort((a, b) => {
    let aValue, bValue
    
    switch (sortBy) {
      case 'liquidity':
        aValue = parseFloat(a.liquidity)
        bValue = parseFloat(b.liquidity)
        break
      case 'volume24h':
        aValue = parseFloat(a.volume24h)
        bValue = parseFloat(b.volume24h)
        break
      case 'fee':
        aValue = a.fee
        bValue = b.fee
        break
      default:
        aValue = parseFloat(a.liquidity)
        bValue = parseFloat(b.liquidity)
    }
    
    if (sortOrder === 'asc') {
      return aValue - bValue
    } else {
      return bValue - aValue
    }
  })

  return (
    <div className="mt-16">
      <h1 className="text-3xl font-bold mb-6">池浏览器</h1>
      
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* 左侧：搜索和筛选 */}
        <div className="lg:col-span-1">
          <Card title="搜索和筛选">
            {/* 搜索框 */}
            <div className="mb-6">
              <Input 
                type="text" 
                placeholder="搜索交易对..." 
                value={searchTerm}
                onChange={handleSearchChange}
                className="pl-10"
                prepend={
                  <svg className="w-5 h-5 text-text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                  </svg>
                }
              />
            </div>
            
            {/* 手续费筛选 */}
            <div className="mb-6">
              <h3 className="text-sm font-medium mb-3">手续费</h3>
              <div className="space-y-2">
                {[0.01, 0.05, 0.3, 1].map((fee) => (
                  <div key={fee} className="flex items-center">
                    <input 
                      type="checkbox" 
                      id={`fee-${fee}`}
                      className="w-4 h-4 bg-background border border-border rounded text-secondary focus:ring-secondary"
                    />
                    <label htmlFor={`fee-${fee}`} className="ml-2 text-sm text-text-secondary">{fee}%</label>
                  </div>
                ))}
              </div>
            </div>
            
            {/* 排序选项 */}
            <div>
              <h3 className="text-sm font-medium mb-3">排序方式</h3>
              <div className="space-y-2">
                {[
                  { value: 'liquidity', label: '流动性' },
                  { value: 'volume24h', label: '24小时交易量' },
                  { value: 'fee', label: '手续费' }
                ].map((option) => (
                  <div key={option.value} className="flex items-center justify-between">
                    <label className="text-sm text-text-secondary">{option.label}</label>
                    <Button 
                      variant="secondary"
                      size="sm"
                      className="text-sm p-0"
                      onClick={() => handleSortChange(option.value)}
                    >
                      {sortBy === option.value ? (sortOrder === 'asc' ? '↑' : '↓') : ''}
                    </Button>
                  </div>
                ))}
              </div>
            </div>
          </Card>
        </div>
        
        {/* 右侧：池列表和详情 */}
        <div className="lg:col-span-2">
          {/* 池列表 */}
          <Card title="流动性池" className="mb-6">
            
            {isLoading ? (
              <div className="text-center py-12">
                <div className="loading text-text-secondary">加载中...</div>
              </div>
            ) : error ? (
              <div className="bg-error/10 border border-error text-error rounded-lg p-4 text-center">
                {error}
              </div>
            ) : sortedPools.length === 0 ? (
              <div className="text-center py-12">
                <div className="text-text-secondary mb-2">未找到匹配的池</div>
                <button className="text-secondary hover:underline">清除筛选条件</button>
              </div>
            ) : (
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead>
                    <tr className="border-b border-border">
                      <th className="text-left py-3 px-4 text-sm font-semibold text-text-secondary">池</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-text-secondary">费率</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-text-secondary">流动性</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-text-secondary">24小时交易量</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-text-secondary">价格</th>
                      <th className="text-left py-3 px-4 text-sm font-semibold text-text-secondary">操作</th>
                    </tr>
                  </thead>
                  <tbody>
                    {sortedPools.map((pool) => (
                      <tr 
                        key={pool.id} 
                        className={`border-b border-border hover:bg-background transition-colors cursor-pointer
                          ${selectedPool?.id === pool.id ? 'bg-primary/20' : ''}`}
                        onClick={() => handlePoolClick(pool)}
                      >
                        <td className="py-3 px-4">
                          <div className="flex items-center">
                            <div className="bg-primary text-white px-3 py-1 rounded-full text-sm mr-2">
                              {pool.token0.symbol}
                            </div>
                            <span className="text-text-secondary">/</span>
                            <div className="bg-primary text-white px-3 py-1 rounded-full text-sm ml-2">
                              {pool.token1.symbol}
                            </div>
                          </div>
                        </td>
                        <td className="py-3 px-4 text-sm text-white">
                          {(pool.fee / 10000).toFixed(2)}%
                        </td>
                        <td className="py-3 px-4 text-sm text-white">
                          ${parseFloat(pool.liquidity).toLocaleString()}
                        </td>
                        <td className="py-3 px-4 text-sm text-white">
                          ${parseFloat(pool.volume24h).toLocaleString()}
                        </td>
                        <td className="py-3 px-4 text-sm text-white">
                          2450.50
                        </td>
                        <td className="py-3 px-4">
                          <div className="flex space-x-2">
                            <Button 
                              variant="secondary"
                              size="sm"
                              onClick={(e) => {
                                e.stopPropagation()
                                handleTrade()
                              }}
                            >
                              交易
                            </Button>
                            <Button 
                              variant="primary"
                              size="sm"
                              onClick={(e) => {
                                e.stopPropagation()
                                handleAddLiquidity()
                              }}
                            >
                              添加
                            </Button>
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </Card>
          {/* 池详情 */}
          {selectedPool && (
            <Card title="池详情">
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <div className="bg-background rounded-lg p-4">
                  <div className="text-sm text-text-secondary mb-1">交易对</div>
                  <div className="text-xl font-semibold">
                    {selectedPool.token0.symbol}/{selectedPool.token1.symbol}
                  </div>
                </div>
                <div className="bg-background rounded-lg p-4">
                  <div className="text-sm text-text-secondary mb-1">费率</div>
                  <div className="text-xl font-semibold">{(selectedPool.fee / 10000).toFixed(2)}%</div>
                </div>
                <div className="bg-background rounded-lg p-4">
                  <div className="text-sm text-text-secondary mb-1">流动性</div>
                  <div className="text-xl font-semibold">
                    ${parseFloat(selectedPool.liquidity).toLocaleString()}
                  </div>
                </div>
                <div className="bg-background rounded-lg p-4">
                  <div className="text-sm text-text-secondary mb-1">24小时交易量</div>
                  <div className="text-xl font-semibold">
                    ${parseFloat(selectedPool.volume24h).toLocaleString()}
                  </div>
                </div>
              </div>
              
              {/* 价格图表 */}
              <div className="bg-background rounded-lg p-4 mb-6">
                <div className="text-sm text-text-secondary mb-2">价格走势</div>
                <div className="h-64 bg-card rounded flex items-center justify-center">
                  <span className="text-text-secondary">价格图表将在此显示</span>
                </div>
              </div>
              
              {/* 操作按钮 */}
              <div className="flex space-x-4">
                <Button 
                  variant="primary"
                  size="lg"
                  className="flex-1"
                  onClick={handleTrade}
                >
                  开始交易
                </Button>
                <Button 
                  variant="secondary"
                  size="lg"
                  className="flex-1"
                  onClick={handleAddLiquidity}
                >
                  添加流动性
                </Button>
              </div>
            </Card>
          )}
        </div>
      </div>
    </div>
  )
}

export default PoolExplorer