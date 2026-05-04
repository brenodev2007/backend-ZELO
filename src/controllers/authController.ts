import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import db from '../config/db';
import { RowDataPacket, ResultSetHeader } from 'mysql2';

export const register = async (req: Request, res: Response) => {
  const { name, email, password, acceptedTerms } = req.body;

  try {
    // Validate terms acceptance
    if (!acceptedTerms) {
      res.status(400).json({ msg: 'Você deve aceitar os Termos de Uso para criar uma conta.' });
      return;
    }

    const [existingUser] = await db.query<RowDataPacket[]>('SELECT * FROM users WHERE email = ?', [email]);
    if (existingUser.length > 0) {
       res.status(400).json({ msg: 'User already exists' });
       return;
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    const [result] = await db.query<ResultSetHeader>('INSERT INTO users (name, email, password) VALUES (?, ?, ?)', [name, email, hashedPassword]);

    const payload = {
      user: {
        id: result.insertId,
      },
    };

    jwt.sign(payload, process.env.JWT_SECRET as string, { expiresIn: '1h' }, (err, token) => {
      if (err) throw err;
      res.json({ token });
    });
  } catch (err: any) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

export const login = async (req: Request, res: Response) => {
  const { email, password } = req.body;

  try {
    const [users] = await db.query<RowDataPacket[]>('SELECT * FROM users WHERE email = ?', [email]);
    if (users.length === 0) {
       res.status(400).json({ msg: 'Invalid Credentials' });
       return;
    }

    const user = users[0];

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
       res.status(400).json({ msg: 'Invalid Credentials' });
       return;
    }

    if (!user.is_active) {
       res.status(403).json({ msg: 'Sua conta foi desativada. Entre em contato com o suporte.' });
       return;
    }

    const payload = {
      user: {
        id: user.id,
      },
    };

    jwt.sign(payload, process.env.JWT_SECRET as string, { expiresIn: '1h' }, (err, token) => {
      if (err) throw err;
      res.json({ token });
    });
  } catch (err: any) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};

export const resetPassword = async (req: Request, res: Response) => {
  const { email, newPassword } = req.body;

  try {
    const [users] = await db.query<RowDataPacket[]>('SELECT * FROM users WHERE email = ?', [email]);
    if (users.length === 0) {
       res.status(404).json({ msg: 'User not found' });
       return;
    }

    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(newPassword, salt);

    await db.query('UPDATE users SET password = ? WHERE email = ?', [hashedPassword, email]);

    res.json({ msg: 'Password updated successfully' });
  } catch (err: any) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};
