import { Request, Response } from 'express';
import db from '../config/db';
import { RowDataPacket } from 'mysql2';

export const getUsers = async (req: Request, res: Response) => {
  try {
    const [users] = await db.query<RowDataPacket[]>('SELECT id, name, email, is_active, is_admin, daily_tokens, created_at FROM users ORDER BY id DESC');
    res.json(users);
  } catch (err: any) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

export const toggleUserStatus = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { is_active } = req.body;
  try {
    await db.query('UPDATE users SET is_active = ? WHERE id = ?', [is_active, id]);
    res.json({ msg: 'User status updated successfully' });
  } catch (err: any) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

export const updateDailyTokens = async (req: Request, res: Response) => {
  const { id } = req.params;
  const { daily_tokens } = req.body;
  try {
    await db.query('UPDATE users SET daily_tokens = ? WHERE id = ?', [daily_tokens, id]);
    res.json({ msg: 'User tokens updated successfully' });
  } catch (err: any) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
