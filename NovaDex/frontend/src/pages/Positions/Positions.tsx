import { useState } from 'react'
import { useSelector, useDispatch } from 'react-redux'
import { RootState } from '../../store'
import {
  setSelectedPosition,
  setIsCollectingFees,
  setIsBurning,
  setError
} from '../../store/slices/positionSlice'
import Button from '../../components/Button/Button'
import Card from '../../components/Card/Card'

const Positions: React.FC = () => {
  const {
    selectedPosition,
    isCollectingFees,
    isBurning
  } = useSelector((state: RootState) => state.position)
  const dispatch = useDispatch()

  const [showDetails, setShowDetails] = useState(false)

  const handleCollectFees = () => {
    if (!selectedPosition) return

    dispatch(setIsCollectingFees(true))
    dispatch(setError(null))

    // 这里应该调用实际的收取手续费逻辑
    // 模拟收取手续费
    setTimeout(() => {
      dispatch(setIsCollectingFees(false))
      dispatch(setError(null))
      alert('手续费收取成功！')
    }, 2000)
  }

  const handleBurnPosition = () => {
    if (!selectedPosition) return

    dispatch(setIsBurning(true))
    dispatch(setError(null))

    // 这里应该调用实际的销毁头寸逻辑
    // 模拟销毁头寸
    setTimeout(() => {
      dispatch(setIsBurning(false))
      dispatch(setError(null))
      alert('头寸销毁成功！')
    }, 2000)
  }

  const handlePositionClick = (position: any) => {
    dispatch(setSelectedPosition(position))
    setShowDetails(true)
  }

  // 模拟头寸数据
  const mockPositions = [
    {
      tokenId: 1,
      owner: '0x742d35Cc6634C0532925a3b816428822c5f7B105',
      token0: { address: '', symbol: 'ETH', decimals: 18 },
      token1: { address: '', symbol: 'USDC', decimals: 6 },
      fee: 3000,
      tickLower: 84984,
      tickUpper: 85384,
      liquidity: '123456789',
      tokensOwed0: '0.001234',
      tokensOwed1: '3.02',
      feeGrowthInside0LastX128: '1234567890',
      feeGrowthInside1LastX128: '1234567890'
    },
    {
      tokenId: 2,
      owner: '0x742d35Cc6634C0532925a3b816428822c5f7B105',
      token0: { address: '', symbol: 'ETH', decimals: 18 },
      token1: { address: '', symbol: 'DAI', decimals: 18 },
      fee: 500,
      tickLower: 84784,
      tickUpper: 85584,
      liquidity: '987654321',
      tokensOwed0: '0.003456',
      tokensOwed1: '8.43',
      feeGrowthInside0LastX128: '9876543210',
      feeGrowthInside1LastX128: '9876543210'
    }
  ]

  return (
    <div className="mt-16">
      <h1 className="text-3xl font-bold mb-6">我的头寸</h1>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* 左侧：头寸列表 */}
        <div className="lg:col-span-1">
          <Card title="头寸列表">
            {mockPositions.length === 0 ? (
              <div className="text-center py-12">
                <div className="text-text-secondary mb-2">您还没有任何头寸</div>
                <button className="text-secondary hover:underline">了解如何创建头寸</button>
              </div>
            ) : (
              <div className="space-y-3">
                {mockPositions.map((position) => (
                  <div
                    key={position.tokenId}
                    className={`bg-background border border-border rounded-lg p-4 cursor-pointer transition-colors
                      ${selectedPosition?.tokenId === position.tokenId ? 'border-secondary' : 'hover:border-primary/50'}`}
                    onClick={() => handlePositionClick(position)}
                  >
                    <div className="flex justify-between items-center mb-2">
                      <div className="text-lg font-semibold">
                        {position.token0.symbol}/{position.token1.symbol}
                      </div>
                      <div className="text-sm text-secondary">
                        #{position.tokenId}
                      </div>
                    </div>
                    <div className="text-sm text-text-secondary mb-2">
                      价格区间: {position.tickLower} - {position.tickUpper} Tick
                    </div>
                    <div className="flex justify-between items-center">
                      <div className="text-sm">
                        流动性: {parseFloat(position.liquidity).toExponential(2)}
                      </div>
                      <div className="text-sm text-success">
                        手续费: {position.tokensOwed0} {position.token0.symbol}
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </Card>
        </div>

        {/* 右侧：头寸详情 */}
        <div className="lg:col-span-2">
          {showDetails && selectedPosition ? (
            <Card title="头寸详情">
              <div className="flex justify-end items-center mb-6">
                <Button
                  variant="secondary"
                  size="sm"
                  className="p-2 rounded-full"
                  onClick={() => setShowDetails(false)}
                >
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
                  </svg>
                </Button>
              </div>

              {/* 头寸基本信息 */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                <div className="bg-background rounded-lg p-4">
                  <div className="text-sm text-text-secondary mb-1">交易对</div>
                  <div className="text-lg font-medium">
                    {selectedPosition.token0.symbol}/{selectedPosition.token1.symbol}
                  </div>
                </div>
                <div className="bg-background rounded-lg p-4">
                  <div className="text-sm text-text-secondary mb-1">头寸ID</div>
                  <div className="text-lg font-medium">#{selectedPosition.tokenId}</div>
                </div>
                <div className="bg-background rounded-lg p-4">
                  <div className="text-sm text-text-secondary mb-1">费率</div>
                  <div className="text-lg font-medium">{(selectedPosition.fee / 10000).toFixed(2)}%</div>
                </div>
                <div className="bg-background rounded-lg p-4">
                  <div className="text-sm text-text-secondary mb-1">流动性</div>
                  <div className="text-lg font-medium">
                    {parseFloat(selectedPosition.liquidity).toExponential(2)}
                  </div>
                </div>
              </div>

              {/* 价格区间 */}
              <div className="bg-background rounded-lg p-4 mb-6">
                <div className="text-sm text-text-secondary mb-2">价格区间</div>
                <div className="flex items-center space-x-4">
                  <div className="bg-primary/20 text-secondary px-4 py-2 rounded-lg">
                    {selectedPosition.tickLower} Tick
                  </div>
                  <div className="text-text-secondary">至</div>
                  <div className="bg-primary/20 text-secondary px-4 py-2 rounded-lg">
                    {selectedPosition.tickUpper} Tick
                  </div>
                </div>
                {/* 模拟价格图表 */}
                <div className="h-32 bg-card rounded mt-4 flex items-center justify-center">
                  <span className="text-text-secondary">价格区间图表</span>
                </div>
              </div>

              {/* 手续费信息 */}
              <div className="bg-background rounded-lg p-4 mb-6">
                <div className="text-sm text-text-secondary mb-2">待收取手续费</div>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <div className="text-sm text-text-secondary">{selectedPosition.token0.symbol}</div>
                    <div className="text-xl font-semibold">{selectedPosition.tokensOwed0}</div>
                  </div>
                  <div>
                    <div className="text-sm text-text-secondary">{selectedPosition.token1.symbol}</div>
                    <div className="text-xl font-semibold">{selectedPosition.tokensOwed1}</div>
                  </div>
                </div>
              </div>

              {/* 操作按钮 */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <Button
                  variant="success"
                  size="lg"
                  className="w-full"
                  onClick={handleCollectFees}
                  disabled={isCollectingFees || (!selectedPosition.tokensOwed0 && !selectedPosition.tokensOwed1)}
                >
                  {isCollectingFees ? '收取中...' : '收取手续费'}
                </Button>
                <Button
                  variant="error"
                  size="lg"
                  className="w-full"
                  onClick={handleBurnPosition}
                  disabled={isBurning}
                >
                  {isBurning ? '销毁中...' : '销毁头寸'}
                </Button>
              </div>
            </Card>
          ) : (
            <Card className="flex items-center justify-center h-96">
              <div className="text-center">
                <div className="text-text-secondary mb-2">选择一个头寸查看详情</div>
                <div className="text-sm text-text-secondary">
                  从左侧列表中选择一个头寸，查看其详细信息和操作选项
                </div>
              </div>
            </Card>
          )}
        </div>
      </div>
    </div>
  )
}

export default Positions