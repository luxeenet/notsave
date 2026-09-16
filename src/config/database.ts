import mongoose from 'mongoose';
import { env } from './environment.js';
import { logger } from './logger.js';

export async function connectDatabase(): Promise<typeof mongoose> {
  try {
    mongoose.set('strictQuery', true);
    
    mongoose.connection.on('connected', () => {
      logger.info({ event: 'database_connected' }, 'MongoDB connection established successfully');
    });

    mongoose.connection.on('error', (err) => {
      logger.error({ event: 'database_error', err }, 'MongoDB connection error');
    });

    mongoose.connection.on('disconnected', () => {
      logger.warn({ event: 'database_disconnected' }, 'MongoDB connection lost');
    });

    const conn = await mongoose.connect(env.MONGODB_URI, {
      serverSelectionTimeoutMS: 5000,
      autoIndex: true,
    });

    return conn;
  } catch (error) {
    logger.error({ event: 'database_connect_failed', error }, 'Failed to connect to MongoDB during startup');
    throw error;
  }
}

export async function disconnectDatabase(): Promise<void> {
  try {
    await mongoose.disconnect();
    logger.info({ event: 'database_disconnected_cleanly' }, 'MongoDB connection closed gracefully');
  } catch (error) {
    logger.error({ event: 'database_disconnect_error', error }, 'Error disconnecting MongoDB');
  }
}

export function isDatabaseConnected(): boolean {
  return mongoose.connection.readyState === 1;
}
