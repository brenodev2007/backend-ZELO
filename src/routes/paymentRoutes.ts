import express from 'express';
import { createPreference, handleWebhook, verifyPayment } from '../controllers/paymentController';

const router = express.Router();

router.post('/create_preference', createPreference);
router.post('/webhook', handleWebhook);
router.get('/verify/:paymentId', verifyPayment);

export default router;
