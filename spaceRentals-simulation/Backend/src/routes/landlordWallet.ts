import { Router } from 'express';
import { authenticate, requireRole } from '../middleware/authMiddleware';
import { getLandlordWallet, withdrawLandlordWallet } from '../controllers/landlordWalletController';

const router = Router();

router.use(authenticate, requireRole(['landlord', 'admin']));

router.get('/', getLandlordWallet);
router.post('/withdraw', withdrawLandlordWallet);

export default router;
