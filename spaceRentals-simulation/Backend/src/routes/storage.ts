import { Router, Request, Response } from 'express';
import multer from 'multer';
import { authenticate } from '../middleware/authMiddleware';
import { supabaseService } from '../services/SupabaseService';
import { encryptionService } from '../services/encryptionService';
import { prisma } from '../lib/prisma';
import { asyncHandler } from '../utils/asyncHandler';

const router = Router();
const upload = multer({ storage: multer.memoryStorage(), limits: { fileSize: 10 * 1024 * 1024 } }); // 10MB limit

// Require authentication for all storage routes
router.use(authenticate);

// POST /api/storage/upload
// Expects multipart/form-data: `file` and `bucket` (e.g. kyc-documents, property-images)
router.post('/upload', upload.single('file'), asyncHandler(async (req: Request | any, res: Response) => {
  const file = req.file;
  const bucket = req.body.bucket;
  
  if (!file) throw { status: 400, message: 'File is required' };
  if (!bucket) throw { status: 400, message: 'Bucket name is required' };

  // Validate allowed buckets to prevent arbitrary uploads
  const allowedBuckets = ['property-images', 'kyc-documents', 'lease-documents', 'profile-images'];
  if (!allowedBuckets.includes(bucket)) {
    throw { status: 400, message: 'Invalid bucket specified' };
  }

  // The landlord/admin KYC workflow renders documents as images. Restrict the
  // KYC bucket to those formats so a reviewer never receives an opaque or
  // unsupported executable/document type.
  if (bucket === 'kyc-documents' && !['image/jpeg', 'image/png', 'image/webp'].includes(file.mimetype)) {
    throw { status: 400, message: 'KYC documents must be JPEG, PNG, or WebP images.' };
  }

  // Enforce role constraints. Only landlords can upload to property-images, etc.
  if (bucket === 'property-images' && req.user.role !== 'landlord' && req.user.role !== 'admin') {
    throw { status: 403, message: 'Only landlords can upload property images' };
  }
  
  const filename = supabaseService.generateUniqueFileName(file.originalname);
  // Store files inside a user-specific folder for isolation
  const path = `${req.user.userId}/${filename}`;

  let uploadBuffer = file.buffer;
  if (bucket === 'kyc-documents') {
    uploadBuffer = encryptionService.encryptBuffer(file.buffer);
  }

  await supabaseService.uploadFile(bucket, path, uploadBuffer, bucket === 'kyc-documents' ? 'application/octet-stream' : file.mimetype);

  return res.status(201).json({
    message: 'File uploaded successfully',
    path,
    bucket
  });
}));

// DELETE /api/storage/kyc-orphans
// Best-effort rollback for documents uploaded before a KYC submission failed.
// Referenced files are never deleted, making retries after a lost response safe.
router.delete('/kyc-orphans', asyncHandler(async (req: Request | any, res: Response) => {
  const paths = Array.isArray(req.body?.paths) ? req.body.paths.filter((path: unknown) => typeof path === 'string') : [];
  if (paths.length === 0) return res.json({ deleted: 0 });
  if (paths.length > 10) throw { status: 400, message: 'At most 10 KYC files can be cleaned up at once.' };

  const prefix = `${req.user.userId}/`;
  if (paths.some((path: string) => !path.startsWith(prefix) || path.slice(prefix.length).includes('/'))) {
    throw { status: 400, message: 'Invalid KYC document path.' };
  }

  const verification = await prisma.landlordVerification.findUnique({
    where: { landlordId: req.user.userId },
    select: { documents: true },
  });
  let referenced = new Set<string>();
  if (verification?.documents) {
    try {
      referenced = new Set(Object.values(JSON.parse(verification.documents)).filter((path): path is string => typeof path === 'string'));
    } catch { /* Invalid legacy data must never authorize deletion. */
      return res.json({ deleted: 0 });
    }
  }

  const deletable = paths.filter((path: string) => !referenced.has(path));
  await Promise.all(deletable.map((path: string) => supabaseService.deleteFile('kyc-documents', path)));
  return res.json({ deleted: deletable.length });
}));

// GET /api/storage/signed-url
// Query params: bucket, path
router.get('/signed-url', asyncHandler(async (req: Request | any, res: Response) => {
  const bucket = req.query.bucket as string;
  const path = req.query.path as string;

  if (!bucket || !path) {
    throw { status: 400, message: 'Bucket and path query parameters are required' };
  }

  // Basic authorization: path format is usually "userId/filename".
  // Check if the user is requesting their own file or is an admin.
  const pathUserId = path.split('/')[0];
  if (pathUserId !== req.user.userId && req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const signedUrl = await supabaseService.getSignedUrl(bucket, path);
  return res.json({ signedUrl });
}));

// GET /api/storage/download
// Used for decrypting encrypted files on the fly (e.g. KYC docs)
router.get('/download', asyncHandler(async (req: Request | any, res: Response) => {
  const bucket = req.query.bucket as string;
  const path = req.query.path as string;

  if (!bucket || !path) {
    throw { status: 400, message: 'Bucket and path query parameters are required' };
  }

  const pathUserId = path.split('/')[0];
  if (pathUserId !== req.user.userId && req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const encryptedBuffer = await supabaseService.downloadFile(bucket, path);
  let finalBuffer = encryptedBuffer;

  if (bucket === 'kyc-documents') {
    try {
      finalBuffer = encryptionService.decryptBuffer(encryptedBuffer);
    } catch (err) {
      console.error('[Storage] Decryption failed:', err);
      throw { status: 500, message: 'Failed to decrypt file' };
    }
  }

  res.setHeader('Content-Type', 'application/octet-stream');
  res.setHeader('Content-Disposition', `attachment; filename="${path.split('/').pop()}"`);
  return res.send(finalBuffer);
}));

export default router;
