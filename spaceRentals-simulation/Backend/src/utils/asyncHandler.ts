import { Request, Response, NextFunction } from 'express';

type AsyncController = (req: Request | any, res: Response, next: NextFunction) => Promise<any>;

export const asyncHandler = (fn: AsyncController) => (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};
