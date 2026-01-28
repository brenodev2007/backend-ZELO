import express from 'express';
import { createPreference } from '../controllers/paymentController';

const router = express.Router();

router.post('/create_preference', createPreference);

export default router;
