import { Request, Response, NextFunction } from 'express';
import crypto from 'node:crypto';

export function requestIdMiddleware(req: Request, res: Response, next: NextFunction): void {
  const existingId = req.headers['x-request-id'] as string;
  const requestId = existingId || `req_${crypto.randomBytes(12).toString('hex')}`;
  
  req.id = requestId;
  req.startTime = Date.now();
  res.setHeader('X-Request-ID', requestId);

  next();
}
