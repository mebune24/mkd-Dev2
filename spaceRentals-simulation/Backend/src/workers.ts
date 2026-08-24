import cron from 'node-cron';
import { prisma } from './lib/prisma';

export const startBackgroundWorkers = () => {
  // Run every day at midnight to check for stale properties
  cron.schedule('0 0 * * *', async () => {
    console.log('[Worker] Running property freshness check...');
    try {
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

      const result = await prisma.property.updateMany({
        where: {
          status: 'available',
          lastConfirmedAvailableAt: { lt: thirtyDaysAgo },
        },
        data: {
          status: 'auto_unpublished',
        },
      });

      console.log(`[Worker] Auto-unpublished ${result.count} stale properties.`);
    } catch (error) {
      console.error('[Worker] Failed property freshness check:', error);
    }
  });
};
