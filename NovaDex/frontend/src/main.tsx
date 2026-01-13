import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.tsx'
import './index.css'
import { Provider } from 'react-redux'
import store from './store'
import { WagmiProvider } from 'wagmi'
import { config } from './config/web3'

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <Provider store={store}>
      <WagmiProvider config={config}>
        <App />
      </WagmiProvider>
    </Provider>
  </React.StrictMode>,
)