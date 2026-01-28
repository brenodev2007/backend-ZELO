import express, { Request, Response } from 'express';
import { register, login } from '../controllers/authController';
import authMiddleware from '../middleware/authMiddleware';
import db from '../config/db';
import { RowDataPacket } from 'mysql2';

const router = express.Router();

// Register User
router.post('/register', register);

// Login User
router.post('/login', login);

// Get User (Protected)
interface AuthRequest extends Request {
    user?: any;
}

router.get('/user', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const [user] = await db.query<RowDataPacket[]>('SELECT id, name, email FROM users WHERE id = ?', [req.user.user.id]);
    res.json(user[0]);
  } catch (err: any) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

export default router;
