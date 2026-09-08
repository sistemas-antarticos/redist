import baseConfig from '/app/vite.config.js';

const hmrHost = process.env.VITE_HMR_HOST || 'localhost';
const appOrigin = new URL(process.env.APP_URL || `http://${hmrHost}:8000`).origin;

export default {
  ...baseConfig,
  server: {
    ...baseConfig.server,
    origin: `http://${hmrHost}:5173`,
    cors: { origin: appOrigin },
    hmr: { host: hmrHost },
    watch: {
      ...baseConfig.server?.watch,
      usePolling: process.env.CHOKIDAR_USEPOLLING === 'true',
    },
  },
};
