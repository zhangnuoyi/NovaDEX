import { createSlice, PayloadAction } from '@reduxjs/toolkit'

interface WalletState {
  isConnected: boolean
  address: string | null
  chainId: number | null
  balance: string | null
}

const initialState: WalletState = {
  isConnected: false,
  address: null,
  chainId: null,
  balance: null,
}

const walletSlice = createSlice({
  name: 'wallet',
  initialState,
  reducers: {
    connectWallet: (state, action: PayloadAction<{
      address: string
      chainId: number
      balance: string
    }>) => {
      state.isConnected = true
      state.address = action.payload.address
      state.chainId = action.payload.chainId
      state.balance = action.payload.balance
    },
    disconnectWallet: (state) => {
      state.isConnected = false
      state.address = null
      state.chainId = null
      state.balance = null
    },
    updateBalance: (state, action: PayloadAction<string>) => {
      state.balance = action.payload
    },
    updateChainId: (state, action: PayloadAction<number>) => {
      state.chainId = action.payload
    },
  },
})

export const { connectWallet, disconnectWallet, updateBalance, updateChainId } = walletSlice.actions
export default walletSlice.reducer