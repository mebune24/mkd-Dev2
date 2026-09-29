import { Router } from 'express';
import { requireAuth, requireRole } from '../middleware/authMiddleware';
import { getLandlordWallet, withdrawLandlordWallet } from '../controllers/landlordWalletController';

const router = Router();

router.use(requireAuth, requireRole(['landlord', 'admin']));

router.get('/', getLandlordWallet);
router.post('/withdraw', withdrawLandlordWallet);

export default router;
