import { configureStore } from '@reduxjs/toolkit'
import walletReducer from './slices/walletSlice'
import tradeReducer from './slices/tradeSlice'
import liquidityReducer from './slices/liquiditySlice'
import positionReducer from './slices/positionSlice'

const store = configureStore({
  reducer: {
    wallet: walletReducer,
    trade: tradeReducer,
    liquidity: liquidityReducer,
    position: positionReducer,
  },
})

export type RootState = ReturnType<typeof store.getState>
export type AppDispatch = typeof store.dispatch

export default store