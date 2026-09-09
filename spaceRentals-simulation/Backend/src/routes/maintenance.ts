import { Router } from 'express';
import { authenticate, requireLandlordVerificationIfApplicable } from '../middleware/authMiddleware';
import {
  createMaintenanceRequest,
  getMaintenanceRequests,
  getMaintenanceRequestById,
  updateMaintenanceRequest,
} from '../controllers/maintenanceController';

const router = Router();
router.use(authenticate, requireLandlordVerificationIfApplicable);

router.post('/',     createMaintenanceRequest);
router.get('/',      getMaintenanceRequests);
router.get('/:id',   getMaintenanceRequestById);
router.patch('/:id', updateMaintenanceRequest);

export default router;
