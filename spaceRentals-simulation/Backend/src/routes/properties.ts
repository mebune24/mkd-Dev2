import { Router } from 'express';
import { authenticate, optionalAuthenticate, requireVerifiedLandlord } from '../middleware/authMiddleware';
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
  boostProperty,
  getVideoFeed,
} from '../controllers/propertyController';
import { getComments, addComment } from '../controllers/commentController';
import { validateRequest } from '../middleware/validateMiddleware';
import { createPropertySchema } from '../utils/schemas';
import { cacheResponse } from '../middleware/cacheMiddleware';
import { togglePropertyLike, togglePropertyReshare } from '../controllers/propertyEngagementController';

const router = Router();

// Public
router.get('/search',  cacheResponse(300), searchProperties);
router.get('/nearby',  cacheResponse(300), getNearbyProperties);
router.get('/feed/video', optionalAuthenticate, getVideoFeed);
router.get('/',        cacheResponse(300), getProperties);
router.get('/my/listings', authenticate, getMyProperties);
router.get('/:id/comments', getComments);
router.get('/:id',     getPropertyById);

// Protected — Tenant/Landlord Comments
router.post('/:id/comments', authenticate, addComment);
router.post('/:id/like', authenticate, togglePropertyLike);
router.post('/:id/reshare', authenticate, togglePropertyReshare);

// Protected — Landlord
router.post('/', authenticate, requireVerifiedLandlord, validateRequest(createPropertySchema), createProperty);
router.patch('/:id',                      authenticate, requireVerifiedLandlord, updateProperty);
router.delete('/:id',                     authenticate, requireVerifiedLandlord, deleteProperty);
router.patch('/:id/publish',              authenticate, requireVerifiedLandlord, publishProperty);
router.patch('/:id/unpublish',            authenticate, requireVerifiedLandlord, unpublishProperty);
router.patch('/:id/confirm-availability', authenticate, requireVerifiedLandlord, confirmAvailability);
router.post('/:id/boost',                 authenticate, requireVerifiedLandlord, boostProperty);

export default router;
