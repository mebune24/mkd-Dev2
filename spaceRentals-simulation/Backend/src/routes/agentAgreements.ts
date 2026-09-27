import { Router } from "express";
import {
  authenticate,
  requireLandlordVerificationIfApplicable,
} from "../middleware/authMiddleware";

const router = Router();
router.use(authenticate);

router.get("/", (_req, res) => {
  res
    .status(410)
    .json({
      message:
        "Agent workflows have been removed. This app is for tenants and landlords only.",
    });
});
router.post("/", requireLandlordVerificationIfApplicable, (_req, res) => {
  res
    .status(410)
    .json({
      message:
        "Agent workflows have been removed. This app is for tenants and landlords only.",
    });
});
router.patch("/:id/decision", (_req, res) => {
  res
    .status(410)
    .json({
      message:
        "Agent workflows have been removed. This app is for tenants and landlords only.",
    });
});

export default router;
