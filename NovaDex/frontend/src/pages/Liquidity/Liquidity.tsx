import { useState } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import { RootState } from '../../store'
import { 
  setAmount0, 
  setAmount1, 
  setIsLoading, 
  setError 
} from '../../store/slices/liquiditySlice'
import Button from '../../components/Button/Button'
import Input from '../../components/Input/Input'
import Card from '../../components/Card/Card'

const Liquidity: React.FC = () => {
  const { 
    token0, 
    token1, 
    amount0, 
    amount1, 
    fee, 
    tickLower, 
    tickUpper, 
    liquidity, 
    isLoading, 
    error, 
    pools 
  } = useSelector((state: RootState) => state.liquidity)
  const dispatch = useDispatch()

  const handleAmount0Change = (e: React.ChangeEvent<HTMLInputElement>) => {
    dispatch(setAmount0(e.target.value))
    // 这里应该调用实际的流动性计算逻辑
    // 模拟计算
    if (e.target.value) {
      dispatch(setAmount1((parseFloat(e.target.value) * 2450).toFixed(2)))
    } else {
      dispatch(setAmount1(''))
    }
  }

  const handleAmount1Change = (e: React.ChangeEvent<HTMLInputElement>) => {
    dispatch(setAmount1(e.target.value))
    // 这里应该调用实际的流动性计算逻辑
    // 模拟计算
    if (e.target.value) {
      dispatch(setAmount0((parseFloat(e.target.value) / 2450).toFixed(6)))
    } else {
      dispatch(setAmount0(''))
    }
  }

  const handleAddLiquidity = () => {
    dispatch(setIsLoading(true))
    dispatch(setError(null))
    
    // 这里应该调用实际的添加流动性逻辑
    // 模拟添加流动性
    setTimeout(() => {
      dispatch(setIsLoading(false))
      dispatch(setError(null))
      alert('流动性添加成功！')
    }, 2000)
  }

  // 模拟流动性池数据
  const mockPools = [
    {
      id: '1',
      token0: { address: '', symbol: 'ETH', decimals: 18, balance: '0' },
      token1: { address: '', symbol: 'USDC', decimals: 6, balance: '0' },
      fee: 3000,
      liquidity: '123456789',
      volume24h: '543210',
      sqrtPriceX96: '79228162514264337593543950336',
      tick: 85184
    },
    {
      id: '2',
      token0: { address: '', symbol: 'ETH', decimals: 18, balance: '0' },
      token1: { address: '', symbol: 'DAI', decimals: 18, balance: '0' },
      fee: 500,
      liquidity: '987654321',
      volume24h: '987654',
      sqrtPriceX96: '79228162514264337593543950336',
      tick: 85184
    }
  ]

  return (
    <div className="mt-16">
      <div className="flex justify-between items-center mb-6">
        <h1 className="text-3xl font-bold">流动性</h1>
        <Button variant="primary" size="md">
          创建池
        </Button>
      </div>
      
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* 左侧：添加流动性表单 */}
        <div className="lg:col-span-1">
          <Card title="添加流动性">
            
            {/* 代币选择 */}
            <div className="space-y-4">
              {/* 代币0 */}
              <div>
                <div className="flex justify-between items-center mb-1">
                  <label className="text-sm text-text-secondary">代币0</label>
                  <div className="flex items-center space-x-2">
                    <span className="text-sm text-text-secondary">余额: {token0.balance}</span>
                    <button className="text-sm text-secondary hover:underline">最大</button>
                  </div>
                </div>
                <Input 
                  type="number" 
                  placeholder="0.0" 
                  value={amount0}
                  onChange={handleAmount0Change}
                  disabled={isLoading}
                  className="text-xl"
                  suffix={
                    <Button 
                      variant="primary"
                      size="sm"
                      className="rounded-full"
                    >
                      {token0.symbol}
                    </Button>
                  }
                />
              </div>
              
              {/* 代币1 */}
              <div>
                <div className="flex justify-between items-center mb-1">
                  <label className="text-sm text-text-secondary">代币1</label>
                  <div className="flex items-center space-x-2">
                    <span className="text-sm text-text-secondary">余额: {token1.balance}</span>
                    <button className="text-sm text-secondary hover:underline">最大</button>
                  </div>
                </div>
                <Input 
                  type="number" 
                  placeholder="0.0" 
                  value={amount1}
                  onChange={handleAmount1Change}
                  disabled={isLoading}
                  className="text-xl"
                  suffix={
                    <Button 
                      variant="primary"
                      size="sm"
                      className="rounded-full"
                    >
                      {token1.symbol}
                    </Button>
                  }
                />
              </div>
            </div>
            
            {/* 价格区间 */}
            <div className="mt-6 space-y-3">
              <div className="flex justify-between items-center">
                <label className="text-sm text-text-secondary">价格区间</label>
              </div>
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <div className="flex justify-between items-center mb-1">
                    <span className="text-sm text-text-secondary">下限</span>
                  </div>
                  <Input 
                    type="number" 
                    placeholder="-120"
                    className="bg-background"
                    suffix={<span className="text-text-secondary">Tick</span>}
                  />
                </div>
                <div>
                  <div className="flex justify-between items-center mb-1">
                    <span className="text-sm text-text-secondary">上限</span>
                  </div>
                  <Input 
                    type="number" 
                    placeholder="120"
                    className="bg-background"
                    suffix={<span className="text-text-secondary">Tick</span>}
                  />
                </div>
              </div>
            </div>
            
            {/* 流动性信息 */}
            <div className="mt-6 bg-background rounded-lg p-4">
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm text-text-secondary">预计流动性</span>
                <span className="text-sm text-white">{liquidity || '0'}</span>
              </div>
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm text-text-secondary">当前价格</span>
                <span className="text-sm text-white">{token0.symbol}/{token1.symbol} = 2450.50</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-text-secondary">费率</span>
                <span className="text-sm text-white">{(fee / 10000).toFixed(2)}%</span>
              </div>
            </div>
            
            {/* 错误信息 */}
            {error && (
              <div className="bg-error/10 border border-error text-error rounded-lg p-3 mt-4 text-sm">
                {error}
              </div>
            )}
            
            {/* 添加流动性按钮 */}
            <Button 
              variant="primary"
              size="lg"
              className="w-full mt-6"
              onClick={handleAddLiquidity}
              disabled={isLoading || (!amount0 && !amount1)}
            >
              {isLoading ? '添加中...' : '添加流动性'}
            </Button>
          </Card>
        </div>
        
        {/* 右侧：我的池 */}
        <div className="lg:col-span-2">
          <Card title="我的池">
            {mockPools.length === 0 ? (
              <div className="text-center py-12">
                <div className="text-text-secondary mb-2">您还没有添加任何流动性</div>
                <button className="text-secondary hover:underline">了解如何添加流动性</button>
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
                    {mockPools.map((pool) => (
                      <tr key={pool.id} className="border-b border-border hover:bg-background transition-colors">
                        <td className="py-3 px-4">
                          <div className="flex items-center">
                            <Button variant="primary" size="sm" className="rounded-full mr-2">
                              {pool.token0.symbol}
                            </Button>
                            <span className="text-text-secondary">/</span>
                            <Button variant="primary" size="sm" className="rounded-full ml-2">
                              {pool.token1.symbol}
                            </Button>
                          </div>
                        </td>
                        <td className="py-3 px-4 text-sm text-white">
                          {(pool.fee / 10000).toFixed(2)}%
                        </td>
                        <td className="py-3 px-4 text-sm text-white">
                          {parseFloat(pool.liquidity).toExponential(2)}
                        </td>
                        <td className="py-3 px-4 text-sm text-white">
                          {pool.volume24h}
                        </td>
                        <td className="py-3 px-4 text-sm text-white">
                          2450.50
                        </td>
                        <td className="py-3 px-4">
                          <div className="flex space-x-2">
                            <Button variant="secondary" size="sm">
                              添加
                            </Button>
                            <Button variant="primary" size="sm">
                              移除
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
        </div>
      </div>
    </div>
  )
}

export default Liquidity