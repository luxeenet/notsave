import { Request, Response, NextFunction } from 'express';
import { logger } from '../config/logger.js';
import { env } from '../config/environment.js';

export function errorHandler(
  err: Error & { status?: number; statusCode?: number; code?: number },
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction
): void {
  const statusCode = err.status || err.statusCode || 500;

  logger.error({
    event: 'unhandled_error',
    requestId: req.id,
    path: req.path,
    method: req.method,
    statusCode,
    error: {
      message: err.message,
      stack: env.isProduction ? undefined : err.stack,
      name: err.name,
      code: err.code,
    },
  }, 'Unhandled request error occurred');

  res.status(statusCode).json({
    success: false,
    message: statusCode === 500 ? 'Internal server error' : err.message,
    requestId: req.id,
  });
}
