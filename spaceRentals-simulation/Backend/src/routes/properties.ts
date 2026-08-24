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
} from '../controllers/propertyController';
import { validateRequest } from '../middleware/validateMiddleware';
import { createPropertySchema } from '../utils/schemas';

const router = Router();

// Public
router.get('/', getProperties);
router.get('/nearby', getNearbyProperties);
router.get('/:id', getPropertyById);

// Protected
router.get('/my/listings', authenticate, getMyProperties);
router.post('/', authenticate, requireLandlord, validateRequest(createPropertySchema), createProperty);
router.patch('/:id', authenticate, requireLandlord, updateProperty);
router.delete('/:id', authenticate, requireLandlord, deleteProperty);

export default router;
