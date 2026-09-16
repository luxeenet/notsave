export interface AndroidNotificationPayload {
  id?: string;
  packageName: string;
  key?: string;
  title?: string;
  text?: string;
  subText?: string;
  bigText?: string;
  category?: string;
  time: number;
}

export type ProcessingStatus = 'received' | 'processed' | 'failed';

export interface INotification {
  _id?: string;
  notificationId: string;
  deduplicationHash: string;
  packageName: string;
  key?: string | null;
  title?: string | null;
  text?: string | null;
  subText?: string | null;
  bigText?: string | null;
  category?: string | null;
  deviceTimestamp: Date;
  receivedAt: Date;
  firstReceivedAt: Date;
  lastReceivedAt: Date;
  updatedAt?: Date;
  rawPayload: Record<string, unknown>;
  requestId: string;
  source: string;
  processingStatus: ProcessingStatus;
  deliveryAttempts: number;
  ipHash?: string | null;
  userAgent?: string | null;
}

export interface ApiResponse<T = unknown> {
  success: boolean;
  message?: string;
  requestId?: string;
  data?: T;
  notificationId?: string;
  duplicate?: boolean;
  service?: string;
  status?: string;
  database?: string;
}

export interface AuthenticationResult {
  authenticated: boolean;
  reason?: string;
}

export interface NotificationQueryParams {
  page?: number;
  limit?: number;
  sort?: string;
  from?: string;
  to?: string;
  packageName?: string;
  category?: string;
  search?: string;
}

export interface PaginatedResult<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
  totalPages: number;
}

export interface NotificationStats {
  totalNotifications: number;
  notificationsToday: number;
  notificationsThisWeek: number;
  notificationsThisMonth: number;
  notificationsByPackage: Array<{ _id: string; count: number }>;
  notificationsByCategory: Array<{ _id: string; count: number }>;
  notificationsPerHour: Array<{ _id: number; count: number }>;
  duplicateDeliveryCount: number;
  failedProcessingCount: number;
}
