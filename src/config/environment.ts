import dotenv from 'dotenv';

dotenv.config();

function getEnvVariable(key: string, defaultValue?: string): string {
  const value = process.env[key] || defaultValue;
  if (value === undefined) {
    throw new Error(`[Config Error] Missing required environment variable: ${key}`);
  }
  return value;
}

function getEnvNumber(key: string, defaultValue: number): number {
  const value = process.env[key];
  if (!value) return defaultValue;
  const parsed = parseInt(value, 10);
  if (isNaN(parsed)) {
    throw new Error(`[Config Error] Invalid number for environment variable: ${key}`);
  }
  return parsed;
}

function getEnvBoolean(key: string, defaultValue: boolean): boolean {
  const value = process.env[key];
  if (!value) return defaultValue;
  return value.toLowerCase() === 'true' || value === '1';
}

export const env = {
  NODE_ENV: getEnvVariable('NODE_ENV', 'development'),
  PORT: getEnvNumber('PORT', 8080),
  MONGODB_URI: getEnvVariable('MONGODB_URI', 'mongodb://127.0.0.1:27017/android_notifications'),
  BEARER_TOKEN: getEnvVariable('BEARER_TOKEN'),
  ADMIN_API_KEY: getEnvVariable('ADMIN_API_KEY', getEnvVariable('BEARER_TOKEN')),
  TRUST_PROXY: getEnvBoolean('TRUST_PROXY', true),
  CORS_ORIGINS: process.env.CORS_ORIGINS ? process.env.CORS_ORIGINS.split(',').map((s) => s.trim()).filter(Boolean) : [],
  RATE_LIMIT_WINDOW_MS: getEnvNumber('RATE_LIMIT_WINDOW_MS', 60000),
  RATE_LIMIT_MAX: getEnvNumber('RATE_LIMIT_MAX', 300),
  BODY_LIMIT: getEnvVariable('BODY_LIMIT', '1mb'),
  LOG_LEVEL: getEnvVariable('LOG_LEVEL', 'info'),
  LOG_NOTIFICATION_CONTENT: getEnvBoolean('LOG_NOTIFICATION_CONTENT', false),
  isProduction: process.env.NODE_ENV === 'production',
  isTest: process.env.NODE_ENV === 'test',
};
