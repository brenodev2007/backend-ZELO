import express, { Request, Response } from 'express';
import { register, login, resetPassword } from '../controllers/authController';
import authMiddleware from '../middleware/authMiddleware';
import db from '../config/db';
import { RowDataPacket } from 'mysql2';

const router = express.Router();

// Register User
router.post('/register', register);

// Login User
router.post('/login', login);

// Reset Password
router.post('/reset-password', resetPassword);

// Get User (Protected)
interface AuthRequest extends Request {
    user?: any;
}

router.get('/user', authMiddleware, async (req: AuthRequest, res: Response) => {
  try {
    const [user] = await db.query<RowDataPacket[]>('SELECT id, name, email, is_active, is_admin, daily_tokens FROM users WHERE id = ?', [req.user.user.id]);
    
    if (!user.length) {
      res.status(404).json({ msg: 'User not found' });
      return;
    }

    if (!user[0].is_active) {
      res.status(403).json({ msg: 'Account deactivated' });
      return;
    }

    res.json({ 
      id: user[0].id, 
      name: user[0].name, 
      email: user[0].email,
      is_admin: Boolean(user[0].is_admin),
      daily_tokens: user[0].daily_tokens
    });
  } catch (err: any) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

export default router;
