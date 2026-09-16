import http from 'http';
import { createApp } from './app.js';
import { env } from './config/environment.js';
import { logger } from './config/logger.js';
import { connectDatabase, disconnectDatabase } from './config/database.js';

async function startServer() {
  try {
    logger.info({ event: 'server_startup' }, 'Initializing Android Notification Receiver server...');

    // 1. Connect to MongoDB (fail startup cleanly if DB is unreachable)
    await connectDatabase();

    // 2. Instantiate Express application
    const app = createApp();
    const server = http.createServer(app);

    // 3. Start listening for HTTP connections
    server.listen(env.PORT, () => {
      logger.info(
        {
          event: 'server_listening',
          port: env.PORT,
          env: env.NODE_ENV,
        },
        `Android Notification Receiver server is running on port ${env.PORT}`
      );
    });

    // 4. Graceful Shutdown Handlers (SIGTERM & SIGINT)
    const gracefulShutdown = async (signal: string) => {
      logger.info({ event: 'shutdown_initiated', signal }, `Received ${signal}, commencing graceful shutdown...`);

      // Stop accepting new connections
      server.close(async () => {
        logger.info({ event: 'http_server_closed' }, 'HTTP server closed. Flushing database connections...');
        await disconnectDatabase();
        logger.info({ event: 'shutdown_complete' }, 'Shutdown complete. Exiting cleanly.');
        process.exit(0);
      });

      // Forceful shutdown timeout if connections linger
      setTimeout(() => {
        logger.error({ event: 'shutdown_forced' }, 'Forced shutdown after 10s timeout');
        process.exit(1);
      }, 10000).unref();
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

    process.on('unhandledRejection', (reason) => {
      logger.error({ event: 'unhandled_rejection', reason }, 'Unhandled Promise Rejection encountered');
    });

    process.on('uncaughtException', (error) => {
      logger.error({ event: 'uncaught_exception', error }, 'Uncaught Exception encountered');
      process.exit(1);
    });
  } catch (error) {
    logger.fatal({ event: 'startup_failed', error }, 'Server failed to start');
    process.exit(1);
  }
}

startServer();
