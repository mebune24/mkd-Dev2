import { Router } from 'express';
import {
  getProperties,
  getPropertyById,
  getMyProperties,
  createProperty,
  updateProperty,
  deleteProperty,
} from '../controllers/propertyController';
import {
  authenticate,
  requireLandlord,
} from '../middleware/authMiddleware';

const router = Router();

router.get('/', getProperties);                            // public
router.get('/mine', authenticate, requireLandlord, getMyProperties); // landlord only
router.get('/:id', getPropertyById);                      // public
router.post('/', authenticate, requireLandlord, createProperty);
router.patch('/:id', authenticate, requireLandlord, updateProperty);
router.delete('/:id', authenticate, requireLandlord, deleteProperty);

export default router;
