const app = require('./src/app');
const env = require('./src/config/env');

const server = app.listen(env.port, '0.0.0.0', () => {
  console.log(`AI PlantApp backend running on port ${env.port} [${env.nodeEnv}]`);
  console.log(`Health check: http://localhost:${env.port}/api/v1/health`);
  console.log(`Phone URL: http://192.168.100.7:${env.port}/api/v1/health`);
});

const shutdown = (signal) => {
  console.log(`${signal} received. Shutting down gracefully...`);
  server.close(() => {
    process.exit(0);
  });
};

process.on('SIGINT', () => shutdown('SIGINT'));
process.on('SIGTERM', () => shutdown('SIGTERM'));

process.on('unhandledRejection', (reason) => {
  console.error('Unhandled rejection:', reason);
});

process.on('uncaughtException', (error) => {
  console.error('Uncaught exception:', error);
  shutdown('uncaughtException');
});
