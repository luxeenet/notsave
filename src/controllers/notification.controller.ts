import { Request, Response, NextFunction } from 'express';
import { NotificationService } from '../services/notification.service.js';
import { ValidatedNotificationPayload } from '../validators/notification.validator.js';
import { ApiResponse } from '../types/notification.types.js';

const notificationService = new NotificationService();

export async function receiveNotification(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const payload = req.body as ValidatedNotificationPayload;
    const rawPayload = req.body;
    const requestId = String(req.id || 'unknown');
    const ipAddress = req.ip;
    const userAgent = req.headers['user-agent'];

    const result = await notificationService.processNotification(
      payload,
      rawPayload,
      requestId,
      ipAddress,
      userAgent
    );

    const response: ApiResponse = {
      success: true,
      message: result.duplicate ? 'Notification already received' : 'Notification received',
      notificationId: result.notificationId,
      requestId,
    };

    if (result.duplicate) {
      response.duplicate = true;
    }

    res.status(200).json(response);
  } catch (error) {
    next(error);
  }
}
