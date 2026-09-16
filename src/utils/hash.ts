import crypto from 'node:crypto';

/**
 * Creates SHA-256 hash string for deduplication or anonymization
 */
export function createSha256Hash(input: string): string {
  return crypto.createHash('sha256').update(input).digest('hex');
}

/**
 * Creates deterministic deduplication hash from notification payload components
 */
export function generateDeduplicationHash(data: {
  packageName: string;
  key?: string | null;
  title?: string | null;
  text?: string | null;
  subText?: string | null;
  bigText?: string | null;
  time: number;
}): string {
  const parts = [
    data.packageName || '',
    data.key || '',
    data.title || '',
    data.text || '',
    data.subText || '',
    data.bigText || '',
    data.time ? String(data.time) : '',
  ];
  return createSha256Hash(parts.join('||'));
}

/**
 * Timing-safe string comparison using crypto.timingSafeEqual
 */
export function timingSafeCompare(a: string, b: string): boolean {
  try {
    const bufA = Buffer.from(a, 'utf-8');
    const bufB = Buffer.from(b, 'utf-8');

    if (bufA.length !== bufB.length) {
      // Perform a dummy compare against itself to preserve constant time signature
      crypto.timingSafeEqual(bufA, bufA);
      return false;
    }

    return crypto.timingSafeEqual(bufA, bufB);
  } catch {
    return false;
  }
}
