import cron from 'node-cron';
import { prisma } from './lib/prisma';

export const startBackgroundWorkers = () => {
  // ─── Worker 1: Auto-unpublish stale properties (every day at midnight) ───
  cron.schedule('0 0 * * *', async () => {
    console.log('[Worker] Running property freshness check...');
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
      const result = await prisma.property.updateMany({
        where: { status: 'available', lastConfirmedAvailableAt: { lt: thirtyDaysAgo } },
        data: { status: 'auto_unpublished' },
      });
      console.log(`[Worker] Auto-unpublished ${result.count} stale properties.`);
    } catch (error) {
      console.error('[Worker] Failed property freshness check:', error);
    }
  });

  // ─── Worker 2: Expire old password reset tokens (every hour) ────────────
  cron.schedule('0 * * * *', async () => {
    try {
      const result = await prisma.passwordResetToken.deleteMany({
        where: { expiresAt: { lt: new Date() } },
      }).catch(() => ({ count: 0 })); // Ignore if table doesn't exist yet
      if (result.count > 0) console.log(`[Worker] Expired ${result.count} password reset tokens.`);
    } catch (error) {
      // Silently ignore — table may not exist in all environments
    }
  });

  console.log('[Workers] All background workers started.');
};
