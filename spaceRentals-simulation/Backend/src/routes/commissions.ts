import { Router } from "express";
import { commissionWebhook } from "../controllers/commissionController";
import { authenticate } from "../middleware/authMiddleware";

const router = Router();

router.post("/withdraw", authenticate, (_req, res) => {
  res
    .status(410)
    .json({
      message:
        "Agent commission workflows have been removed. This app is for tenants and landlords only.",
    });
});
router.post("/webhook", commissionWebhook); // called by payment provider; no auth header

export default router;
