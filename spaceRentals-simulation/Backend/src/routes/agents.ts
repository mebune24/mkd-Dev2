import { Router } from "express";
import { authenticate } from "../middleware/authMiddleware";

const router = Router();

router.use(authenticate);

router.get("/", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.get("/profile", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.get("/kyc/me", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.post("/kyc", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.get("/kyc/pending", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.get("/kyc", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.patch("/kyc/:id/approve", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.patch("/kyc/:id/reject", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.get("/wallet", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.post("/wallet/withdraw", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.get("/wallet/withdrawals", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.get("/commissions", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

router.get("/commissions/all", (_req, res) => {
  res.status(410).json({
    message:
      "Agent workflows have been removed. This app is for tenants and landlords only.",
  });
});

export default router;
