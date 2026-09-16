import { NotificationModel } from '../models/Notification.js';
import { NotificationQueryParams, PaginatedResult, INotification } from '../types/notification.types.js';

export class AdminService {
  async getNotifications(params: NotificationQueryParams): Promise<PaginatedResult<INotification>> {
    const page = Math.max(1, params.page || 1);
    const limit = Math.min(100, Math.max(1, params.limit || 20));
    const skip = (page - 1) * limit;

    const query: Record<string, unknown> = {};

    if (params.packageName) {
      query.packageName = params.packageName;
    }

    if (params.category) {
      query.category = params.category;
    }

    if (params.from || params.to) {
      query.receivedAt = {};
      if (params.from) {
        (query.receivedAt as Record<string, unknown>).$gte = new Date(params.from);
      }
      if (params.to) {
        (query.receivedAt as Record<string, unknown>).$lte = new Date(params.to);
      }
    }

    if (params.search) {
      const searchRegex = new RegExp(params.search, 'i');
      query.$or = [
        { packageName: searchRegex },
        { title: searchRegex },
        { text: searchRegex },
        { subText: searchRegex },
        { bigText: searchRegex },
        { category: searchRegex },
        { notificationId: searchRegex },
      ];
    }

    const sortOption = params.sort === 'asc' ? 1 : -1;

    const [items, total] = await Promise.all([
      NotificationModel.find(query)
        .sort({ receivedAt: sortOption })
        .skip(skip)
        .limit(limit)
        .lean(),
      NotificationModel.countDocuments(query),
    ]);

    return {
      items: items as unknown as INotification[],
      total,
      page,
      limit,
      totalPages: Math.ceil(total / limit),
    };
  }

  async getNotificationById(notificationId: string): Promise<INotification | null> {
    const doc = await NotificationModel.findOne({ notificationId }).lean();
    return doc as INotification | null;
  }
}
