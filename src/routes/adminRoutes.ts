import express from 'express';
import { getUsers, toggleUserStatus, updateDailyTokens } from '../controllers/adminController';
import authMiddleware from '../middleware/authMiddleware';
import adminMiddleware from '../middleware/adminMiddleware';

const router = express.Router();

// Apply auth and admin middleware to all routes
router.use(authMiddleware);
router.use(adminMiddleware);

router.get('/users', getUsers);
router.patch('/users/:id/active', toggleUserStatus);
router.patch('/users/:id/tokens', updateDailyTokens);

export default router;
