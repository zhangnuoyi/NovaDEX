import { useState } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import { RootState } from '../../store'
import { 
  setAmountIn, 
  setAmountOut, 
  toggleTradeMode, 
  swapTokens, 
  setIsLoading, 
  setError 
} from '../../store/slices/tradeSlice'
import Button from '../../components/Button/Button'
import Input from '../../components/Input/Input'
import Card from '../../components/Card/Card'

const Home: React.FC = () => {
  const { 
    tokenIn, 
    tokenOut, 
    amountIn, 
    amountOut, 
    fee, 
    isExactInput, 
    price, 
    feeAmount, 
    isLoading, 
    error 
  } = useSelector((state: RootState) => state.trade)
  const dispatch = useDispatch()

  const handleAmountInChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    dispatch(setAmountIn(e.target.value))
    // 这里应该调用实际的价格计算逻辑
    // 模拟计算
    dispatch(setAmountOut((parseFloat(e.target.value) * price).toFixed(6)))
  }

  const handleAmountOutChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    dispatch(setAmountOut(e.target.value))
    // 这里应该调用实际的价格计算逻辑
    // 模拟计算
    dispatch(setAmountIn((parseFloat(e.target.value) / price).toFixed(6)))
  }

  const handleSwap = () => {
    dispatch(swapTokens())
    // 重置价格
    dispatch(setAmountOut(''))
    dispatch(setAmountIn(''))
  }

  const handleTrade = () => {
    dispatch(setIsLoading(true))
    dispatch(setError(null))
    
    // 这里应该调用实际的交易逻辑
    // 模拟交易
    setTimeout(() => {
      dispatch(setIsLoading(false))
      dispatch(setError(null))
      alert('交易成功！')
    }, 2000)
  }

  // 模拟市场数据
  const marketData = {
    price: '2450.50',
    change24h: '+2.34%',
    volume24h: '125.43M',
    liquidity: '892.12M',
    high24h: '2500.00',
    low24h: '2400.00'
  }

  // 模拟最近交易
  const recentTrades = [
    { id: 1, type: 'buy', amount: '0.5 ETH', price: '2450.50', time: '2m ago' },
    { id: 2, type: 'sell', amount: '1.2 ETH', price: '2448.20', time: '5m ago' },
    { id: 3, type: 'buy', amount: '0.25 ETH', price: '2449.80', time: '8m ago' },
    { id: 4, type: 'sell', amount: '0.75 ETH', price: '2451.10', time: '12m ago' },
    { id: 5, type: 'buy', amount: '1.5 ETH', price: '2452.30', time: '15m ago' },
  ]

  return (
    <div className="mt-16">
      <h1 className="text-3xl font-bold mb-6">交易</h1>
      
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* 左侧：交易表单 */}
        <div className="lg:col-span-1">
          <Card title="代币交换">
            {/* 交易模式切换 */}
            <div className="flex justify-between mb-4">
              <Button 
                variant={isExactInput ? 'primary' : 'secondary'}
                size="sm"
                className={`rounded-l-lg ${!isExactInput ? 'border-r-0' : ''}`}
                onClick={() => dispatch(toggleTradeMode())}
              >
                精确输入
              </Button>
              <Button 
                variant={!isExactInput ? 'primary' : 'secondary'}
                size="sm"
                className={`rounded-r-lg ${isExactInput ? 'border-l-0' : ''}`}
                onClick={() => dispatch(toggleTradeMode())}
              >
                精确输出
              </Button>
            </div>
            
            {/* 输入代币 */}
            <div className="mb-4">
              <div className="flex justify-between items-center mb-1">
                <label className="text-sm text-text-secondary">{isExactInput ? '输入' : '预计输入'}</label>
                <div className="flex items-center space-x-2">
                  <span className="text-sm text-text-secondary">余额: {tokenIn.balance}</span>
                  <button className="text-sm text-secondary hover:underline">最大</button>
                </div>
              </div>
              <Input 
                type="number" 
                placeholder="0.0" 
                value={amountIn}
                onChange={handleAmountInChange}
                disabled={!isExactInput || isLoading}
                className="text-xl"
                suffix={
                  <Button 
                    variant="primary"
                    size="sm"
                    className="rounded-full"
                  >
                    {tokenIn.symbol}
                  </Button>
                }
              />
            </div>
            
            {/* 交换按钮 */}
            <div className="flex justify-center mb-4">
              <Button 
                variant="primary"
                size="sm"
                className="w-10 h-10 p-0 rounded-full"
                onClick={handleSwap}
                disabled={isLoading}
              >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 16V4m0 0L3 8m4-4l4 4m6 0v12m0 0l4-4m-4 4l-4-4" />
                </svg>
              </Button>
            </div>
            
            {/* 输出代币 */}
            <div className="mb-4">
              <div className="flex justify-between items-center mb-1">
                <label className="text-sm text-text-secondary">{isExactInput ? '预计输出' : '输出'}</label>
                <div className="flex items-center space-x-2">
                  <span className="text-sm text-text-secondary">余额: {tokenOut.balance}</span>
                  {!isExactInput && (
                    <button className="text-sm text-secondary hover:underline">最大</button>
                  )}
                </div>
              </div>
              <Input 
                type="number" 
                placeholder="0.0" 
                value={amountOut}
                onChange={handleAmountOutChange}
                disabled={isExactInput || isLoading}
                className="text-xl"
                suffix={
                  <Button 
                    variant="primary"
                    size="sm"
                    className="rounded-full"
                  >
                    {tokenOut.symbol}
                  </Button>
                }
              />
            </div>
            
            {/* 交易详情 */}
            <div className="bg-background rounded-lg p-4 mb-4">
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm text-text-secondary">价格</span>
                <span className="text-sm text-white">1 {tokenIn.symbol} = {price} {tokenOut.symbol}</span>
              </div>
              <div className="flex justify-between items-center mb-2">
                <span className="text-sm text-text-secondary">手续费</span>
                <span className="text-sm text-white">{feeAmount} {tokenIn.symbol} ({(fee / 10000).toFixed(2)}%)</span>
              </div>
              <div className="flex justify-between items-center">
                <span className="text-sm text-text-secondary">滑点</span>
                <span className="text-sm text-white">0.5%</span>
              </div>
            </div>
            
            {/* 错误信息 */}
            {error && (
              <div className="bg-error/10 border border-error text-error rounded-lg p-3 mb-4 text-sm">
                {error}
              </div>
            )}
            
            {/* 交易按钮 */}
            <Button 
              variant="primary"
              size="lg"
              className="w-full"
              onClick={handleTrade}
              disabled={isLoading || (!amountIn && !amountOut)}
            >
              {isLoading ? '交易中...' : '交换'}
            </Button>
          </Card>
        </div>
        
        {/* 右侧：图表和市场数据 */}
        <div className="lg:col-span-2 space-y-6">
          {/* 价格图表 */}
          <div className="bg-card rounded-xl shadow-card p-6">
            <div className="flex justify-between items-center mb-4">
              <h2 className="text-xl font-semibold">{tokenIn.symbol}/{tokenOut.symbol}</h2>
              <div className="flex space-x-2">
                {['1m', '5m', '15m', '1h', '4h', '1d', '1w', '1M'].map((time) => (
                  <button 
                    key={time} 
                    className="text-sm px-3 py-1 rounded-full transition-colors
                      ${time === '1h' ? 'bg-primary text-white' : 'bg-background text-text-secondary hover:bg-card/80'}"
                  >
                    {time}
                  </button>
                ))}
              </div>
            </div>
            {/* 模拟图表 */}
            <div className="h-64 bg-background rounded-lg flex items-center justify-center">
              <span className="text-text-secondary">价格图表将在此显示</span>
            </div>
          </div>
          
          {/* 市场数据和最近交易 */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* 市场数据 */}
            <div className="bg-card rounded-xl shadow-card p-6">
              <h3 className="text-lg font-semibold mb-4">市场数据</h3>
              <div className="space-y-3">
                <div className="flex justify-between items-center">
                  <span className="text-text-secondary">当前价格</span>
                  <span className="text-xl font-bold">${marketData.price}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-secondary">24小时涨跌幅</span>
                  <span className="text-success">{marketData.change24h}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-secondary">24小时成交量</span>
                  <span className="text-white">${marketData.volume24h}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-secondary">流动性</span>
                  <span className="text-white">${marketData.liquidity}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-secondary">24小时最高价</span>
                  <span className="text-white">${marketData.high24h}</span>
                </div>
                <div className="flex justify-between items-center">
                  <span className="text-text-secondary">24小时最低价</span>
                  <span className="text-white">${marketData.low24h}</span>
                </div>
              </div>
            </div>
            
            {/* 最近交易 */}
            <div className="bg-card rounded-xl shadow-card p-6">
              <h3 className="text-lg font-semibold mb-4">最近交易</h3>
              <div className="space-y-3">
                {recentTrades.map((trade) => (
                  <div key={trade.id} className="flex justify-between items-center p-2 hover:bg-background rounded-lg transition-colors">
                    <div className="flex items-center space-x-3">
                      <div className={`w-2 h-2 rounded-full ${trade.type === 'buy' ? 'bg-success' : 'bg-error'}`}></div>
                      <div>
                        <div className="text-sm text-white">{trade.amount}</div>
                        <div className="text-xs text-text-secondary">{trade.time}</div>
                      </div>
                    </div>
                    <div className={`text-sm font-medium ${trade.type === 'buy' ? 'text-success' : 'text-error'}`}>
                      ${trade.price}
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Home