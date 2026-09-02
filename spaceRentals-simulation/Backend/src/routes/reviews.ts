import { Router } from 'express';
import { authenticate } from '../middleware/authMiddleware';
import { createReview, getPropertyReviews, getLandlordReviews } from '../controllers/reviewController';

const router = Router();

router.get('/property/:propertyId', getPropertyReviews);
router.get('/landlord/:landlordId', getLandlordReviews);
router.post('/', authenticate, createReview);

export default router;
