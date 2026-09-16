import { Schema, model, Document } from 'mongoose';

export interface IDeliveryAttempt {
  notificationId: string;
  requestId: string;
  attemptedAt: Date;
  ipHash?: string | null;
  userAgent?: string | null;
  isDuplicate: boolean;
}

export interface IDeliveryAttemptDocument extends IDeliveryAttempt, Document {}

const DeliveryAttemptSchema = new Schema<IDeliveryAttemptDocument>(
  {
    notificationId: {
      type: String,
      required: true,
      index: true,
    },
    requestId: {
      type: String,
      required: true,
    },
    attemptedAt: {
      type: Date,
      default: Date.now,
      index: true,
    },
    ipHash: {
      type: String,
      default: null,
    },
    userAgent: {
      type: String,
      default: null,
    },
    isDuplicate: {
      type: Boolean,
      default: false,
    },
  },
  {
    timestamps: false,
    collection: 'delivery_attempts',
  }
);

export const DeliveryAttemptModel = model<IDeliveryAttemptDocument>('DeliveryAttempt', DeliveryAttemptSchema);
