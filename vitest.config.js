import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['app/javascript/**/*.{test,spec}.{js,jsx}'],
  },
})
