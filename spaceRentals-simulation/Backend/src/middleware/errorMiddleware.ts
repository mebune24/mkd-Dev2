import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';
import multer from 'multer';

export const globalErrorHandler = (
  err: any,
  req: Request,
  res: Response,
  next: NextFunction
) => {
  console.error('[GlobalError]', err);

  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    // P2002: Unique constraint failed
    if (err.code === 'P2002') {
      return res.status(409).json({ message: 'A record with this value already exists.' });
    }
    // P2025: Record not found
    if (err.code === 'P2025') {
      return res.status(404).json({ message: 'Requested record not found.' });
    }
  }

  if (err instanceof multer.MulterError) {
    if (err.code === 'LIMIT_FILE_SIZE') {
      return res.status(413).json({ message: 'Uploaded file is too large. Maximum size is 50 MB.' });
    }
    return res.status(400).json({ message: `Upload failed: ${err.message}` });
  }

  // Handle our custom thrown errors { status, message }
  if (err.status && err.message) {
    return res.status(err.status).json({ message: err.message });
  }

  return res.status(500).json({ message: 'Internal server error.' });
};
