import { Router } from 'express';
import { authenticate, requireVerifiedAgent, requireVerifiedLandlord } from '../middleware/authMiddleware';
import { decideAgreement, listAgreements, requestAgreement } from '../controllers/agentAgreementController';

const router = Router();
router.use(authenticate);
router.get('/', listAgreements);
router.post('/', requireVerifiedLandlord, requestAgreement);
router.patch('/:id/decision', requireVerifiedAgent, decideAgreement);

export default router;
