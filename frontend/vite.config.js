import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
    plugins: [react()],
    http: true,
    server: {
        proxy: {
            '/api': {
                target: 'http://109.71.252.147:5000', // Backend URL
                changeOrigin: true,
            },
        },
    },
});
