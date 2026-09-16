import { Request, Response } from 'express';
import { isDatabaseConnected } from '../config/database.js';
import { ApiResponse } from '../types/notification.types.js';

export function getRootHealth(_req: Request, res: Response): void {
  const response: ApiResponse = {
    success: true,
    service: 'android-notification-receiver',
    status: 'online',
  };
  res.status(200).json(response);
}

export function getLiveness(_req: Request, res: Response): void {
  const response: ApiResponse = {
    success: true,
    status: 'alive',
  };
  res.status(200).json(response);
}

export function getReadiness(_req: Request, res: Response): void {
  const connected = isDatabaseConnected();

  if (!connected) {
    res.status(503).json({
      success: false,
      status: 'not_ready',
      database: 'disconnected',
    });
    return;
  }

  res.status(200).json({
    success: true,
    status: 'ready',
    database: 'connected',
  });
}
