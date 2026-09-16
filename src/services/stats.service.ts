import { NotificationModel } from '../models/Notification.js';
import { NotificationStats } from '../types/notification.types.js';

export class StatsService {
  async getStatistics(): Promise<NotificationStats> {
    const now = new Date();
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    
    const dayOfWeek = now.getDay();
    const distanceToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1;
    const startOfWeek = new Date(now.getFullYear(), now.getMonth(), now.getDate() - distanceToMonday);

    const startOfMonth = new Date(now.getFullYear(), now.getMonth(), 1);

    const [
      totalNotifications,
      notificationsToday,
      notificationsThisWeek,
      notificationsThisMonth,
      notificationsByPackage,
      notificationsByCategory,
      duplicateCountResult,
      failedProcessingCount,
    ] = await Promise.all([
      NotificationModel.countDocuments(),
      NotificationModel.countDocuments({ receivedAt: { $gte: startOfToday } }),
      NotificationModel.countDocuments({ receivedAt: { $gte: startOfWeek } }),
      NotificationModel.countDocuments({ receivedAt: { $gte: startOfMonth } }),
      NotificationModel.aggregate([
        { $group: { _id: '$packageName', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 10 },
      ]),
      NotificationModel.aggregate([
        { $group: { _id: '$category', count: { $sum: 1 } } },
        { $sort: { count: -1 } },
        { $limit: 10 },
      ]),
      NotificationModel.aggregate([
        { $group: { _id: null, totalDuplicates: { $sum: { $subtract: ['$deliveryAttempts', 1] } } } },
      ]),
      NotificationModel.countDocuments({ processingStatus: 'failed' }),
    ]);

    const duplicateDeliveryCount = duplicateCountResult.length > 0 ? duplicateCountResult[0].totalDuplicates : 0;

    // Aggregate hourly notifications for the last 24 hours
    const twentyFourHoursAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
    const notificationsPerHour = await NotificationModel.aggregate([
      { $match: { receivedAt: { $gte: twentyFourHoursAgo } } },
      {
        $group: {
          _id: { $hour: '$receivedAt' },
          count: { $sum: 1 },
        },
      },
      { $sort: { _id: 1 } },
    ]);

    return {
      totalNotifications,
      notificationsToday,
      notificationsThisWeek,
      notificationsThisMonth,
      notificationsByPackage,
      notificationsByCategory,
      notificationsPerHour,
      duplicateDeliveryCount,
      failedProcessingCount,
    };
  }
}
