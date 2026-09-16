import express, { Express } from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { pinoHttp } from 'pino-http';
import { env } from './config/environment.js';
import { logger } from './config/logger.js';
import { requestIdMiddleware } from './middleware/requestId.middleware.js';
import { errorHandler } from './middleware/error.middleware.js';
import healthRoutes from './routes/health.routes.js';
import notificationRoutes from './routes/notification.routes.js';
import adminRoutes from './routes/admin.routes.js';

export function createApp(): Express {
  const app = express();

  if (env.TRUST_PROXY) {
    app.set('trust proxy', 1);
  }

  // Security HTTP Headers
  app.use(helmet());

  // CORS setup
  const corsOptions = {
    origin: env.CORS_ORIGINS.length > 0 ? env.CORS_ORIGINS : false,
    optionsSuccessStatus: 200,
  };
  app.use(cors(corsOptions));

  // Request ID middleware
  app.use(requestIdMiddleware);

  // Structured HTTP logging
  app.use(
    pinoHttp({
      logger,
      customAttributeKeys: {
        req: 'request',
        res: 'response',
        err: 'error',
      },
      genReqId: (req: express.Request) => req.id || 'unknown',
    })
  );

  // Body parser with payload limit protection
  app.use(express.json({ limit: env.BODY_LIMIT }));
  app.use(express.urlencoded({ extended: true, limit: env.BODY_LIMIT }));

  // Register Routes
  app.use('/', healthRoutes);
  app.use('/api/v1', notificationRoutes);
  app.use('/api/v1/admin', adminRoutes);

  // Handle 404 for unknown endpoints
  app.use((req, res) => {
    res.status(404).json({
      success: false,
      message: `Route ${req.method} ${req.path} not found`,
      requestId: req.id,
    });
  });

  // Central Error Handler
  app.use(errorHandler);

  return app;
}
