import { Response, NextFunction } from 'express';
import { AuthRequest } from './authMiddleware';
import { redisClient } from '../config/redis';

/**
 * Creates a rate limiter based on the authenticated user's ID.
 * Falls back to IP address if the user is not authenticated.
 * 
 * @param windowMs Time window in milliseconds
 * @param maxRequests Maximum number of requests allowed in the time window
 * @param prefix Redis key prefix
 */
export function createUserRateLimiter(windowMs: number, maxRequests: number, prefix: string = 'rate-limit') {
  return async (req: AuthRequest, res: Response, next: NextFunction) => {
    try {
      // Use userId if authenticated, fallback to IP address
      const identifier = req.user?.userId || req.ip || 'unknown-ip';
      const key = `${prefix}:${identifier}`;

      // Increment the counter for this identifier
      const current = await redisClient.incr(key);

      // If this is the first request in the window, set the expiry
      if (current === 1) {
        await redisClient.pExpire(key, windowMs);
      }

      // Add standard rate limit headers
      const ttl = await redisClient.pTTL(key);
      res.setHeader('X-RateLimit-Limit', maxRequests);
      res.setHeader('X-RateLimit-Remaining', Math.max(0, maxRequests - current));
      res.setHeader('X-RateLimit-Reset', new Date(Date.now() + (ttl > 0 ? ttl : 0)).toISOString());

      if (current > maxRequests) {
        return res.status(429).json({ 
          message: 'Too many requests, please slow down.',
          retryAfter: Math.ceil((ttl > 0 ? ttl : 0) / 1000)
        });
      }

      next();
    } catch (err) {
      console.error('[RateLimiter] Error:', err);
      // Fail open to avoid blocking valid traffic if Redis goes down temporarily
      next();
    }
  };
}
