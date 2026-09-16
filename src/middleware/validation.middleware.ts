import { Request, Response, NextFunction } from 'express';
import { ZodSchema, ZodError } from 'zod';
import { logger } from '../config/logger.js';

export function validateBody<T>(schema: ZodSchema<T>) {
  return (req: Request, res: Response, next: NextFunction): void => {
    try {
      req.body = schema.parse(req.body);
      next();
    } catch (error) {
      if (error instanceof ZodError) {
        logger.warn({
          event: 'validation_failed',
          requestId: req.id,
          errors: error.errors,
        }, 'Request payload validation failed');

        res.status(400).json({
          success: false,
          message: 'Invalid request payload',
          errors: error.errors.map((e) => ({
            field: e.path.join('.'),
            message: e.message,
          })),
          requestId: req.id,
        });
        return;
      }

      next(error);
    }
  };
}
