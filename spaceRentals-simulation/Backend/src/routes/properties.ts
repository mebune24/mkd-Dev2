import { Router } from 'express';
import { authenticate, requireLandlord } from '../middleware/authMiddleware';
import {
  getProperties,
  getMyProperties,
  getPropertyById,
  createProperty,
  updateProperty,
  deleteProperty,
  getNearbyProperties,
  publishProperty,
  unpublishProperty,
  confirmAvailability,
  searchProperties,
} from '../controllers/propertyController';
import { validateRequest } from '../middleware/validateMiddleware';
import { createPropertySchema } from '../utils/schemas';
import { cacheResponse } from '../middleware/cacheMiddleware';

const router = Router();

// Public
router.get('/search',  cacheResponse(300), searchProperties);
router.get('/nearby',  cacheResponse(300), getNearbyProperties);
router.get('/',        cacheResponse(300), getProperties);
router.get('/:id',     getPropertyById);

// Protected — Landlord
router.get('/my/listings', authenticate, getMyProperties);
router.post('/', authenticate, requireLandlord, validateRequest(createPropertySchema), createProperty);
router.patch('/:id',                      authenticate, requireLandlord, updateProperty);
router.delete('/:id',                     authenticate, requireLandlord, deleteProperty);
router.patch('/:id/publish',              authenticate, requireLandlord, publishProperty);
router.patch('/:id/unpublish',            authenticate, requireLandlord, unpublishProperty);
router.patch('/:id/confirm-availability', authenticate, requireLandlord, confirmAvailability);

export default router;
