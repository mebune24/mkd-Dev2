import { createClient } from 'redis';

const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';

export const redisClient = createClient({ url: redisUrl });

let redisAvailable = false;

/** Returns true only when Redis is connected and accepting commands */
export function isRedisAvailable(): boolean {
  return redisAvailable;
}

redisClient.on('error', (_err) => {
  // Redis is optional — the API continues to work without caching
  if (redisAvailable) {
    console.warn('[Redis] Connection lost — operating without cache.');
    redisAvailable = false;
  }
});
redisClient.on('connect', () => {
  console.log('[Redis] Connected ✓');
  redisAvailable = true;
});

// Attempt connection — failures are non-fatal
redisClient.connect().catch(() => {
  console.warn('[Redis] Not available — caching disabled. Start Redis for better performance.');
});

/**
 * Get a cached value. Returns null if Redis is unavailable.
 */
export async function cacheGet(key: string): Promise<string | null> {
  if (!redisAvailable) return null;
  try { return await redisClient.get(key); }
  catch { return null; }
}

/**
 * Set a cached value with TTL in seconds. No-op if Redis is unavailable.
 */
export async function cacheSet(key: string, value: string, ttlSeconds: number): Promise<void> {
  if (!redisAvailable) return;
  try { await redisClient.setEx(key, ttlSeconds, value); }
  catch { /* ignore */ }
}

/**
 * Delete keys matching a glob pattern. Safe for production (uses SCAN not KEYS).
 */
export async function clearCacheByPattern(pattern: string): Promise<void> {
  if (!redisAvailable) return;
  try {
    const keysToDelete: string[] = [];
    for await (const keys of redisClient.scanIterator({ MATCH: pattern, COUNT: 100 })) {
      keysToDelete.push(...(Array.isArray(keys) ? keys : [keys]));
    }
    if (keysToDelete.length > 0) {
      await redisClient.del(keysToDelete);
    }
  } catch (error) {
    console.warn(`[Redis] Failed to clear cache for pattern "${pattern}":`, error);
  }
}
