import { createSlice, PayloadAction } from '@reduxjs/toolkit'

interface Token {
  address: string
  symbol: string
  decimals: number
  balance: string
}

interface TradeState {
  tokenIn: Token
  tokenOut: Token
  amountIn: string
  amountOut: string
  fee: number
  deadline: number
  isExactInput: boolean
  price: number
  feeAmount: number
  isLoading: boolean
  error: string | null
}

const initialState: TradeState = {
  tokenIn: {
    address: '',
    symbol: 'ETH',
    decimals: 18,
    balance: '0'
  },
  tokenOut: {
    address: '',
    symbol: 'USDC',
    decimals: 6,
    balance: '0'
  },
  amountIn: '',
  amountOut: '',
  fee: 3000,
  deadline: Math.floor(Date.now() / 1000) + 300,
  isExactInput: true,
  price: 2000,
  feeAmount: 0,
  isLoading: false,
  error: null
}

const tradeSlice = createSlice({
  name: 'trade',
  initialState,
  reducers: {
    setTokenIn: (state, action: PayloadAction<Token>) => {
      state.tokenIn = action.payload
    },
    setTokenOut: (state, action: PayloadAction<Token>) => {
      state.tokenOut = action.payload
    },
    swapTokens: (state) => {
      const temp = state.tokenIn
      state.tokenIn = state.tokenOut
      state.tokenOut = temp
      state.amountIn = ''
      state.amountOut = ''
    },
    setAmountIn: (state, action: PayloadAction<string>) => {
      state.amountIn = action.payload
    },
    setAmountOut: (state, action: PayloadAction<string>) => {
      state.amountOut = action.payload
    },
    setFee: (state, action: PayloadAction<number>) => {
      state.fee = action.payload
    },
    setDeadline: (state, action: PayloadAction<number>) => {
      state.deadline = action.payload
    },
    toggleTradeMode: (state) => {
      state.isExactInput = !state.isExactInput
      state.amountIn = ''
      state.amountOut = ''
    },
    setPrice: (state, action: PayloadAction<number>) => {
      state.price = action.payload
    },
    setFeeAmount: (state, action: PayloadAction<number>) => {
      state.feeAmount = action.payload
    },
    setIsLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload
    },
    resetTrade: (state) => {
      state.amountIn = ''
      state.amountOut = ''
      state.error = null
    }
  }
})

export const { 
  setTokenIn, 
  setTokenOut, 
  swapTokens, 
  setAmountIn, 
  setAmountOut, 
  setFee, 
  setDeadline, 
  toggleTradeMode, 
  setPrice, 
  setFeeAmount, 
  setIsLoading, 
  setError, 
  resetTrade 
} = tradeSlice.actions

export default tradeSlice.reducer