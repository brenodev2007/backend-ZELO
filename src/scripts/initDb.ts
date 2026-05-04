import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
import fs from 'fs';
import path from 'path';

dotenv.config();

async function initializeDatabase() {
  try {
    console.log('🔧 Inicializando banco de dados...');
    
    // Create connection
    const connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASS || '1234',
      port: Number(process.env.DB_PORT) || 3306,
      multipleStatements: true
    });

    console.log('✅ Conectado ao MySQL');

    // Read and execute schema.sql
    const schemaPath = path.join(__dirname, '..', '..', 'schema.sql');
    const schema = fs.readFileSync(schemaPath, 'utf8');
    
    await connection.query(schema);
    
    console.log('✅ Tabelas criadas com sucesso!');
    console.log('📊 Estrutura do banco de dados:');
    console.log('   - users (id, name, email, password, is_active, created_at, updated_at)');
    
    await connection.end();
    console.log('✅ Banco de dados inicializado com sucesso!');
    
  } catch (error: any) {
    console.error('❌ Erro ao inicializar banco de dados:', error.message);
    process.exit(1);
  }
}

initializeDatabase();
