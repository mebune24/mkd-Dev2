import { Router } from 'express';
import { authenticate, requireAdmin } from '../middleware/authMiddleware';
import { getAllRentals, getTenantRentals, getLandlordRentals, getRentalById, endRental } from '../controllers/rentalController';

const router = Router();

router.get('/',            authenticate, requireAdmin, getAllRentals);
router.get('/tenant',      authenticate, getTenantRentals);
router.get('/landlord',    authenticate, getLandlordRentals);
router.get('/:id',         authenticate, getRentalById);
router.patch('/:id/end',   authenticate, endRental);

export default router;
