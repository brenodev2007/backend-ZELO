import { Request, Response, NextFunction } from 'express';
import db from '../config/db';
import { RowDataPacket } from 'mysql2';

interface AuthRequest extends Request {
  user?: any;
}

const adminMiddleware = async (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const [user] = await db.query<RowDataPacket[]>('SELECT is_admin FROM users WHERE id = ?', [req.user.user.id]);
    
    if (!user.length || !user[0].is_admin) {
      res.status(403).json({ msg: 'Access denied: Admins only' });
      return;
    }

    next();
  } catch (err) {
    res.status(500).json({ msg: 'Server error verifying admin status' });
  }
};

export default adminMiddleware;
