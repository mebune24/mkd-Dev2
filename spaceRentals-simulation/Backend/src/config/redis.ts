import { createClient } from 'redis';

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

export const redisClient = createClient({
  url: redisUrl,
});

redisClient.on('error', (err) => console.log('Redis Client Error', err));
redisClient.on('connect', () => console.log('Redis Client Connected'));

// Connect immediately, or leave it to be connected in index.ts
redisClient.connect().catch(console.error);

/**
 * Helper to delete keys matching a pattern using SCAN (via scanIterator).
 * This is non-blocking and safe for production — avoids the KEYS command
 * which can block Redis on large datasets.
 */
export async function clearCacheByPattern(pattern: string): Promise<void> {
  try {
    const keysToDelete: string[] = [];

    for await (const keys of redisClient.scanIterator({
      MATCH: pattern,
      COUNT: 100,
    })) {
      // scanIterator yields string[] batches
      keysToDelete.push(...(Array.isArray(keys) ? keys : [keys]));
    }

    if (keysToDelete.length > 0) {
      await redisClient.del(keysToDelete);
    }
  } catch (error) {
    console.error(`Failed to clear cache for pattern "${pattern}":`, error);
  }
}
