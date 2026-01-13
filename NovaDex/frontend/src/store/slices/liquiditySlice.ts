import { createSlice, PayloadAction } from '@reduxjs/toolkit'

interface Token {
  address: string
  symbol: string
  decimals: number
  balance: string
}

interface Pool {
  id: string
  token0: Token
  token1: Token
  fee: number
  liquidity: string
  volume24h: string
  sqrtPriceX96: string
  tick: number
}

interface LiquidityState {
  token0: Token
  token1: Token
  amount0: string
  amount1: string
  fee: number
  tickLower: number
  tickUpper: number
  liquidity: string
  isLoading: boolean
  error: string | null
  pools: Pool[]
  selectedPool: Pool | null
}

const initialState: LiquidityState = {
  token0: {
    address: '',
    symbol: 'ETH',
    decimals: 18,
    balance: '0'
  },
  token1: {
    address: '',
    symbol: 'USDC',
    decimals: 6,
    balance: '0'
  },
  amount0: '',
  amount1: '',
  fee: 3000,
  tickLower: 0,
  tickUpper: 0,
  liquidity: '',
  isLoading: false,
  error: null,
  pools: [],
  selectedPool: null
}

const liquiditySlice = createSlice({
  name: 'liquidity',
  initialState,
  reducers: {
    setToken0: (state, action: PayloadAction<Token>) => {
      state.token0 = action.payload
    },
    setToken1: (state, action: PayloadAction<Token>) => {
      state.token1 = action.payload
    },
    setAmount0: (state, action: PayloadAction<string>) => {
      state.amount0 = action.payload
    },
    setAmount1: (state, action: PayloadAction<string>) => {
      state.amount1 = action.payload
    },
    setFee: (state, action: PayloadAction<number>) => {
      state.fee = action.payload
    },
    setTickLower: (state, action: PayloadAction<number>) => {
      state.tickLower = action.payload
    },
    setTickUpper: (state, action: PayloadAction<number>) => {
      state.tickUpper = action.payload
    },
    setLiquidity: (state, action: PayloadAction<string>) => {
      state.liquidity = action.payload
    },
    setIsLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload
    },
    setPools: (state, action: PayloadAction<Pool[]>) => {
      state.pools = action.payload
    },
    setSelectedPool: (state, action: PayloadAction<Pool | null>) => {
      state.selectedPool = action.payload
    },
    resetLiquidity: (state) => {
      state.amount0 = ''
      state.amount1 = ''
      state.liquidity = ''
      state.error = null
    }
  }
})

export const { 
  setToken0, 
  setToken1, 
  setAmount0, 
  setAmount1, 
  setFee, 
  setTickLower, 
  setTickUpper, 
  setLiquidity, 
  setIsLoading, 
  setError, 
  setPools, 
  setSelectedPool, 
  resetLiquidity 
} = liquiditySlice.actions

export default liquiditySlice.reducer