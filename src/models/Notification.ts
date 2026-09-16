import { Schema, model, Document } from 'mongoose';
import { INotification } from '../types/notification.types.js';

export interface INotificationDocument extends Omit<INotification, '_id'>, Document {}

const NotificationSchema = new Schema<INotificationDocument>(
  {
    notificationId: {
      type: String,
      required: true,
      unique: true,
      index: true,
      trim: true,
    },
    deduplicationHash: {
      type: String,
      required: true,
      unique: true,
      index: true,
    },
    packageName: {
      type: String,
      required: true,
      index: true,
      trim: true,
    },
    key: {
      type: String,
      default: null,
      trim: true,
    },
    title: {
      type: String,
      default: null,
    },
    text: {
      type: String,
      default: null,
    },
    subText: {
      type: String,
      default: null,
    },
    bigText: {
      type: String,
      default: null,
    },
    category: {
      type: String,
      default: null,
      index: true,
      trim: true,
    },
    deviceTimestamp: {
      type: Date,
      required: true,
    },
    receivedAt: {
      type: Date,
      required: true,
      default: Date.now,
      index: true,
    },
    firstReceivedAt: {
      type: Date,
      required: true,
      default: Date.now,
    },
    lastReceivedAt: {
      type: Date,
      required: true,
      default: Date.now,
    },
    rawPayload: {
      type: Schema.Types.Mixed,
      required: true,
    },
    requestId: {
      type: String,
      required: true,
      index: true,
    },
    source: {
      type: String,
      default: 'android',
    },
    processingStatus: {
      type: String,
      enum: ['received', 'processed', 'failed'],
      default: 'received',
      index: true,
    },
    deliveryAttempts: {
      type: Number,
      default: 1,
      min: 1,
    },
    ipHash: {
      type: String,
      default: null,
    },
    userAgent: {
      type: String,
      default: null,
    },
  },
  {
    timestamps: true,
    collection: 'notifications',
  }
);

// Compound indexes for analytical and search queries
NotificationSchema.index({ packageName: 1, receivedAt: -1 });
NotificationSchema.index({ category: 1, receivedAt: -1 });
NotificationSchema.index({ processingStatus: 1, receivedAt: -1 });

export const NotificationModel = model<INotificationDocument>('Notification', NotificationSchema);
