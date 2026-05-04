import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import db from './config/db';
import authRoutes from './routes/authRoutes';
import adminRoutes from './routes/adminRoutes';

dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, async () => {
  console.log(`🚀 Servidor rodando na porta ${PORT}`);
  console.log('📝 Configuração do Banco de Dados:', {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT,
    user: process.env.DB_USER
  });
  
  console.log('⏳ Tentando conectar ao banco de dados...');
  try {
    const connection = await db.getConnection();
    console.log('✅ Banco de dados conectado com sucesso!');
    connection.release();
  } catch (err) {
    console.error('Database connection failed:', err);
  }
});
