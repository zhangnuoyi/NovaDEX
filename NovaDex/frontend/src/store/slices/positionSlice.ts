import { createSlice, PayloadAction } from '@reduxjs/toolkit'

interface Token {
  address: string
  symbol: string
  decimals: number
}

interface Position {
  tokenId: number
  owner: string
  token0: Token
  token1: Token
  fee: number
  tickLower: number
  tickUpper: number
  liquidity: string
  tokensOwed0: string
  tokensOwed1: string
  feeGrowthInside0LastX128: string
  feeGrowthInside1LastX128: string
}

interface PositionState {
  positions: Position[]
  selectedPosition: Position | null
  isLoading: boolean
  error: string | null
  isCollectingFees: boolean
  isBurning: boolean
}

const initialState: PositionState = {
  positions: [],
  selectedPosition: null,
  isLoading: false,
  error: null,
  isCollectingFees: false,
  isBurning: false
}

const positionSlice = createSlice({
  name: 'position',
  initialState,
  reducers: {
    setPositions: (state, action: PayloadAction<Position[]>) => {
      state.positions = action.payload
    },
    setSelectedPosition: (state, action: PayloadAction<Position | null>) => {
      state.selectedPosition = action.payload
    },
    setIsLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload
    },
    setError: (state, action: PayloadAction<string | null>) => {
      state.error = action.payload
    },
    addPosition: (state, action: PayloadAction<Position>) => {
      state.positions.push(action.payload)
    },
    updatePosition: (state, action: PayloadAction<Position>) => {
      const index = state.positions.findIndex(p => p.tokenId === action.payload.tokenId)
      if (index !== -1) {
        state.positions[index] = action.payload
      }
      if (state.selectedPosition && state.selectedPosition.tokenId === action.payload.tokenId) {
        state.selectedPosition = action.payload
      }
    },
    removePosition: (state, action: PayloadAction<number>) => {
      state.positions = state.positions.filter(p => p.tokenId !== action.payload)
      if (state.selectedPosition && state.selectedPosition.tokenId === action.payload) {
        state.selectedPosition = null
      }
    },
    setIsCollectingFees: (state, action: PayloadAction<boolean>) => {
      state.isCollectingFees = action.payload
    },
    setIsBurning: (state, action: PayloadAction<boolean>) => {
      state.isBurning = action.payload
    },
    collectFeesSuccess: (state, action: PayloadAction<{ tokenId: number, tokensOwed0: string, tokensOwed1: string }>) => {
      const index = state.positions.findIndex(p => p.tokenId === action.payload.tokenId)
      if (index !== -1) {
        state.positions[index].tokensOwed0 = action.payload.tokensOwed0
        state.positions[index].tokensOwed1 = action.payload.tokensOwed1
      }
      if (state.selectedPosition && state.selectedPosition.tokenId === action.payload.tokenId) {
        state.selectedPosition.tokensOwed0 = action.payload.tokensOwed0
        state.selectedPosition.tokensOwed1 = action.payload.tokensOwed1
      }
    },
    burnPositionSuccess: (state, action: PayloadAction<number>) => {
      state.positions = state.positions.filter(p => p.tokenId !== action.payload)
      if (state.selectedPosition && state.selectedPosition.tokenId === action.payload) {
        state.selectedPosition = null
      }
    }
  }
})

export const { 
  setPositions, 
  setSelectedPosition, 
  setIsLoading, 
  setError, 
  addPosition, 
  updatePosition, 
  removePosition, 
  setIsCollectingFees, 
  setIsBurning, 
  collectFeesSuccess, 
  burnPositionSuccess 
} = positionSlice.actions

export default positionSlice.reducer