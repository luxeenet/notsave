import { z } from 'zod';

export const notificationPayloadSchema = z.object({
  id: z.string().max(256).optional(),
  packageName: z.string({
    required_error: 'packageName is required',
  }).min(1, 'packageName cannot be empty').max(256),
  key: z.string().max(512).optional().nullable(),
  title: z.string().max(4096).optional().nullable(),
  text: z.string().max(16384).optional().nullable(),
  subText: z.string().max(4096).optional().nullable(),
  bigText: z.string().max(65536).optional().nullable(),
  category: z.string().max(128).optional().nullable(),
  time: z.union([
    z.number().positive(),
    z.string().regex(/^\d+$/).transform(Number),
  ], {
    invalid_type_error: 'time must be a valid numeric timestamp',
  }),
});

export type ValidatedNotificationPayload = z.infer<typeof notificationPayloadSchema>;
