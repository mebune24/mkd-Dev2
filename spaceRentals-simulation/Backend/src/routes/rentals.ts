import { Router } from 'express';
import { authenticate, requireAdmin, requireLandlordVerificationIfApplicable, requireVerifiedLandlord } from '../middleware/authMiddleware';
import { getAllRentals, getTenantRentals, getLandlordRentals, getRentalById, endRental } from '../controllers/rentalController';

const router = Router();
router.use(authenticate, requireLandlordVerificationIfApplicable);

router.get('/',            requireAdmin, getAllRentals);
router.get('/tenant',      getTenantRentals);
router.get('/landlord',    requireVerifiedLandlord, getLandlordRentals);
router.get('/:id',         getRentalById);
router.patch('/:id/end',   requireVerifiedLandlord, endRental);

export default router;
