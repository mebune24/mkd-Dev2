import { Request, Response, NextFunction } from 'express';
import { Prisma } from '@prisma/client';

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

  // Handle our custom thrown errors { status, message }
  if (err.status && err.message) {
    return res.status(err.status).json({ message: err.message });
  }

  return res.status(500).json({ message: 'Internal server error.' });
};
