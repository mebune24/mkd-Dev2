import { Router } from 'express';
import { getApplications, createApplication } from '../controllers/applicationController';
import { authenticate } from '../middleware/authMiddleware';

const router = Router();

router.get('/', authenticate, getApplications);
router.post('/', authenticate, createApplication);

export default router;
