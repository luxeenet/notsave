/**
 * Safely converts Android epoch timestamp in milliseconds to JavaScript Date
 */
export function safeEpochToDate(timestampMs: number): Date {
  if (typeof timestampMs !== 'number' || isNaN(timestampMs) || timestampMs <= 0) {
    return new Date();
  }
  
  // If timestamp was provided in seconds instead of milliseconds (e.g., < 10000000000)
  if (timestampMs < 10000000000) {
    return new Date(timestampMs * 1000);
  }

  const date = new Date(timestampMs);
  if (isNaN(date.getTime())) {
    return new Date();
  }
  return date;
}
