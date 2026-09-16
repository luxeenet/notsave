import { NotificationModel, INotificationDocument } from '../models/Notification.js';
import { DeliveryAttemptModel } from '../models/DeliveryAttempt.js';
import { ValidatedNotificationPayload } from '../validators/notification.validator.js';
import { generateDeduplicationHash, createSha256Hash } from '../utils/hash.js';
import { safeEpochToDate } from '../utils/date.js';
import { logger } from '../config/logger.js';
import { env } from '../config/environment.js';

export interface ProcessNotificationResult {
  notificationId: string;
  duplicate: boolean;
  doc: INotificationDocument;
}

export class NotificationService {
  /**
   * Processes and durably persists an incoming Android notification into MongoDB.
   * Handles duplicate delivery safely using unique index constraints.
   */
  async processNotification(
    payload: ValidatedNotificationPayload,
    rawPayload: Record<string, unknown>,
    requestId: string,
    ipAddress?: string,
    userAgent?: string
  ): Promise<ProcessNotificationResult> {
    const deduplicationHash = generateDeduplicationHash({
      packageName: payload.packageName,
      key: payload.key,
      title: payload.title,
      text: payload.text,
      subText: payload.subText,
      bigText: payload.bigText,
      time: payload.time,
    });

    const notificationId = payload.id && payload.id.trim().length > 0 ? payload.id.trim() : deduplicationHash;
    const deviceTimestamp = safeEpochToDate(payload.time);
    const ipHash = ipAddress ? createSha256Hash(ipAddress) : null;
    const now = new Date();

    // Log incoming processing attempt (optionally redacting or showing content)
    logger.info({
      event: 'notification_processing_start',
      requestId,
      notificationId,
      packageName: payload.packageName,
      category: payload.category,
      title: env.LOG_NOTIFICATION_CONTENT ? payload.title : undefined,
    }, 'Processing incoming notification');

    // Check pre-existing notification by notificationId or deduplicationHash
    const existing = await NotificationModel.findOne({
      $or: [{ notificationId }, { deduplicationHash }],
    });

    if (existing) {
      existing.deliveryAttempts += 1;
      existing.lastReceivedAt = now;
      existing.updatedAt = now;
      await existing.save();

      // Record delivery attempt log
      await DeliveryAttemptModel.create({
        notificationId: existing.notificationId,
        requestId,
        attemptedAt: now,
        ipHash,
        userAgent: userAgent || null,
        isDuplicate: true,
      });

      logger.info({
        event: 'notification_duplicate_detected',
        requestId,
        notificationId: existing.notificationId,
        deliveryAttempts: existing.deliveryAttempts,
      }, 'Duplicate notification received and updated delivery count');

      return {
        notificationId: existing.notificationId,
        duplicate: true,
        doc: existing,
      };
    }

    // Try inserting new notification document
    try {
      const newDoc = new NotificationModel({
        notificationId,
        deduplicationHash,
        packageName: payload.packageName,
        key: payload.key || null,
        title: payload.title || null,
        text: payload.text || null,
        subText: payload.subText || null,
        bigText: payload.bigText || null,
        category: payload.category || null,
        deviceTimestamp,
        receivedAt: now,
        firstReceivedAt: now,
        lastReceivedAt: now,
        rawPayload,
        requestId,
        source: 'android',
        processingStatus: 'received',
        deliveryAttempts: 1,
        ipHash,
        userAgent: userAgent || null,
      });

      const savedDoc = await newDoc.save();

      // Record successful delivery attempt
      await DeliveryAttemptModel.create({
        notificationId: savedDoc.notificationId,
        requestId,
        attemptedAt: now,
        ipHash,
        userAgent: userAgent || null,
        isDuplicate: false,
      });

      logger.info({
        event: 'notification_saved_successfully',
        requestId,
        notificationId: savedDoc.notificationId,
        packageName: savedDoc.packageName,
      }, 'Notification successfully saved to MongoDB');

      return {
        notificationId: savedDoc.notificationId,
        duplicate: false,
        doc: savedDoc,
      };
    } catch (error: unknown) {
      // Handle MongoDB duplicate key error (E11000) for concurrency race conditions
      const err = error as { code?: number; keyPattern?: Record<string, unknown> };
      if (err.code === 11000) {
        logger.warn({
          event: 'notification_duplicate_race_condition',
          requestId,
          notificationId,
          keyPattern: err.keyPattern,
        }, 'Race condition duplicate key error caught, resolving duplicate document');

        const raceDoc = await NotificationModel.findOne({
          $or: [{ notificationId }, { deduplicationHash }],
        });

        if (raceDoc) {
          raceDoc.deliveryAttempts += 1;
          raceDoc.lastReceivedAt = now;
          await raceDoc.save();

          return {
            notificationId: raceDoc.notificationId,
            duplicate: true,
            doc: raceDoc,
          };
        }
      }

      logger.error({
        event: 'notification_save_failed',
        requestId,
        notificationId,
        error,
      }, 'Failed to save notification to MongoDB');

      throw error;
    }
  }
}
