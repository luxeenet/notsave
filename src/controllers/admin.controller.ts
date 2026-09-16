import { Request, Response, NextFunction } from 'express';
import { AdminService } from '../services/admin.service.js';
import { StatsService } from '../services/stats.service.js';

const adminService = new AdminService();
const statsService = new StatsService();

export async function listNotifications(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const page = req.query.page ? parseInt(req.query.page as string, 10) : 1;
    const limit = req.query.limit ? parseInt(req.query.limit as string, 10) : 20;
    const sort = req.query.sort as string;
    const from = req.query.from as string;
    const to = req.query.to as string;
    const packageName = req.query.packageName as string;
    const category = req.query.category as string;
    const search = req.query.search as string;

    const result = await adminService.getNotifications({
      page,
      limit,
      sort,
      from,
      to,
      packageName,
      category,
      search,
    });

    res.status(200).json({
      success: true,
      message: 'Notifications retrieved successfully',
      data: result,
      requestId: req.id,
    });
  } catch (error) {
    next(error);
  }
}

export async function getNotificationById(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const idParam = req.params.id;
    const id = Array.isArray(idParam) ? idParam[0] : idParam;
    const notification = await adminService.getNotificationById(id);

    if (!notification) {
      res.status(404).json({
        success: false,
        message: 'Notification not found',
        requestId: req.id,
      });
      return;
    }

    res.status(200).json({
      success: true,
      data: notification,
      requestId: req.id,
    });
  } catch (error) {
    next(error);
  }
}

export async function getStatistics(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const stats = await statsService.getStatistics();

    res.status(200).json({
      success: true,
      data: stats,
      requestId: req.id,
    });
  } catch (error) {
    next(error);
  }
}
