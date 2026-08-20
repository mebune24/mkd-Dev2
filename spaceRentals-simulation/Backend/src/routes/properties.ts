import { Router } from 'express';
import { getProperties, getPropertyById, createProperty } from '../controllers/propertyController';
import { authenticate } from '../middleware/authMiddleware';

const router = Router();

router.get('/', getProperties);
router.get('/:id', getPropertyById);
router.post('/', authenticate, createProperty);

export default router;
