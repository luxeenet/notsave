import { Request, Response, NextFunction } from 'express';
import { timingSafeCompare } from '../utils/hash.js';
import { env } from '../config/environment.js';
import { logger } from '../config/logger.js';

export function authenticateBearerToken(req: Request, res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    logger.warn({
      event: 'auth_failed',
      requestId: req.id,
      ip: req.ip,
      reason: 'missing_authorization_header',
    }, 'Authentication failed: Missing Authorization header');

    res.status(401).json({
      success: false,
      message: 'Unauthorized',
      requestId: req.id,
    });
    return;
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0] !== 'Bearer') {
    logger.warn({
      event: 'auth_failed',
      requestId: req.id,
      ip: req.ip,
      reason: 'malformed_authorization_header',
    }, 'Authentication failed: Malformed Authorization header');

    res.status(401).json({
      success: false,
      message: 'Unauthorized',
      requestId: req.id,
    });
    return;
  }

  const token = parts[1];
  const isValid = timingSafeCompare(token, env.BEARER_TOKEN);

  if (!isValid) {
    logger.warn({
      event: 'auth_failed',
      requestId: req.id,
      ip: req.ip,
      reason: 'invalid_token',
    }, 'Authentication failed: Invalid Bearer token');

    res.status(401).json({
      success: false,
      message: 'Unauthorized',
      requestId: req.id,
    });
    return;
  }

  next();
}

export function authenticateAdminKey(req: Request, res: Response, next: NextFunction): void {
  const authHeader = req.headers.authorization || (req.headers['x-api-key'] as string);

  if (!authHeader) {
    res.status(401).json({
      success: false,
      message: 'Unauthorized: Admin authentication required',
      requestId: req.id,
    });
    return;
  }

  let token = authHeader;
  if (authHeader.startsWith('Bearer ')) {
    token = authHeader.split(' ')[1];
  }

  const isValid = timingSafeCompare(token, env.ADMIN_API_KEY);

  if (!isValid) {
    logger.warn({
      event: 'admin_auth_failed',
      requestId: req.id,
      ip: req.ip,
    }, 'Admin authentication failed');

    res.status(401).json({
      success: false,
      message: 'Unauthorized',
      requestId: req.id,
    });
    return;
  }

  next();
}
