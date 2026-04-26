import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { tanstackRouter } from '@tanstack/router-plugin/vite'
import { resolve } from 'node:path'

export default defineConfig({
  plugins: [tanstackRouter({ routesDirectory: './src/app/routes' }), react()],
  resolve: {
    alias: {
      '@': resolve(import.meta.dirname, 'src'),
      'styled-system': resolve(import.meta.dirname, 'styled-system'),
    },
  },
})
