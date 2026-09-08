import { Router } from 'express';
import { authenticate } from '../middleware/authMiddleware';
import { getTenantWallet, applyWalletToRent, withdrawTenantWallet } from '../controllers/tenantWalletController';

const router = Router();
router.use(authenticate);
router.get('/', getTenantWallet);
router.post('/apply-to-rent', applyWalletToRent);
router.post('/withdraw', withdrawTenantWallet);

export default router;
