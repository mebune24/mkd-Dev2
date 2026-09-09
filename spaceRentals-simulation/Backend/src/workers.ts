import cron from 'node-cron';
import { prisma } from './lib/prisma';
import { supabaseService } from './services/SupabaseService';

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

  // ─── Worker 3: Remove abandoned landlord-KYC uploads (every hour) ───────
  // Uploads are only retained once referenced by a LandlordVerification row.
  // The one-hour grace period permits a normal multi-file submission/retry.
  cron.schedule('15 * * * *', async () => {
    try {
      const cutoff = new Date(Date.now() - 60 * 60 * 1000);
      const [landlords, verifications] = await Promise.all([
        prisma.user.findMany({ where: { role: 'landlord' }, select: { id: true } }),
        prisma.landlordVerification.findMany({ select: { landlordId: true, documents: true } }),
      ]);
      const referenced = new Set<string>();
      const protectedLandlords = new Set<string>();
      for (const verification of verifications) {
        try {
          for (const path of Object.values(JSON.parse(verification.documents))) {
            if (typeof path === 'string') referenced.add(path);
          }
        } catch {
          // Preserve every file for this landlord when legacy data is malformed.
          protectedLandlords.add(verification.landlordId);
        }
      }

      let deleted = 0;
      for (const landlord of landlords) {
        if (protectedLandlords.has(landlord.id)) continue;
        const files = await supabaseService.listFiles('kyc-documents', landlord.id);
        for (const file of files) {
          const createdAt = new Date(file.created_at ?? file.updated_at ?? Date.now());
          const path = `${landlord.id}/${file.name}`;
          if (createdAt < cutoff && !referenced.has(path)) {
            await supabaseService.deleteFile('kyc-documents', path);
            deleted += 1;
          }
        }
      }
      if (deleted > 0) console.log(`[Worker] Removed ${deleted} abandoned landlord KYC upload(s).`);
    } catch (error) {
      console.error('[Worker] Failed abandoned KYC upload cleanup:', error);
    }
  });

  // ─── Worker 4: Overdue payment reminders (every day at 09:00) ────────────
  cron.schedule('0 9 * * *', async () => {
    console.log('[Worker] Checking for overdue payments...');
    try {
      const overdueRentals = await prisma.rental.findMany({
        where: { status: 'active' },
        include: {
          tenant: { select: { id: true, name: true } },
          property: { select: { title: true } },
        },
      });
      // TODO: For each rental, check last payment date and send notification if overdue.
      // Requires a payment date field on Payment model. Currently just logs count.
      console.log(`[Worker] Checked ${overdueRentals.length} active rentals for overdue payments.`);
    } catch (error) {
      console.error('[Worker] Overdue payment check failed:', error);
    }
  });

  // ─── Worker 5: Lease expiry alerts (every day at 07:00) ─────────────────
  cron.schedule('0 7 * * *', async () => {
    console.log('[Worker] Checking for soon-to-expire rentals...');
    try {
      const thirtyDaysFromNow = new Date();
      thirtyDaysFromNow.setDate(thirtyDaysFromNow.getDate() + 30);
      const expiringRentals = await prisma.rental.findMany({
        where: { status: 'active', activatedAt: { lte: thirtyDaysFromNow } },
        include: {
          tenant: { select: { id: true, name: true } },
          property: { select: { title: true } },
        },
      });
      // TODO: Send renewal notifications via notificationService.sendNotification()
      console.log(`[Worker] Found ${expiringRentals.length} rentals nearing expiry.`);
    } catch (error) {
      console.error('[Worker] Lease expiry check failed:', error);
    }
  });

  console.log('[Workers] All background workers started.');

};
