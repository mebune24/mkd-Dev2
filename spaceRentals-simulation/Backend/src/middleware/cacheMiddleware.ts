import { Request, Response, NextFunction } from 'express';
import { cacheGet, cacheSet } from '../config/redis';

/**
 * Middleware to cache HTTP responses based on the request URL.
 * Automatically serializes response JSON and caches it for the specified TTL.
 * 
 * @param ttlSeconds Time-to-live in seconds
 */
export function cacheResponse(ttlSeconds: number = 300) {
  return async (req: Request, res: Response, next: NextFunction): Promise<void> => {
    // Only cache GET requests
    if (req.method !== 'GET') {
      return next();
    }

    const key = `properties:cache:${req.originalUrl || req.url}`;

    try {
      const cached = await cacheGet(key);
      if (cached) {
        res.setHeader('X-Cache', 'HIT');
        res.json(JSON.parse(cached));
        return;
      }

      // If not cached, patch res.json to capture the response and cache it
      const originalJson = res.json.bind(res);
      res.json = (body: any) => {
        // Only cache successful responses
        if (res.statusCode >= 200 && res.statusCode < 300) {
          cacheSet(key, JSON.stringify(body), ttlSeconds).catch(err => {
            console.error('[Redis] Failed to cache response for', key, err);
          });
        }
        return originalJson(body);
      };

      res.setHeader('X-Cache', 'MISS');
      next();
    } catch (error) {
      console.error('[Redis] Cache middleware error:', error);
      next();
    }
  };
}
