const { Pool } = require('pg');
require('dotenv').config();

console.log('🔌 Configuration PostgreSQL:');
console.log(`- Host: ${process.env.DB_HOST}`);
console.log(`- Port: ${process.env.DB_PORT}`);
console.log(`- Database: ${process.env.DB_NAME}`);
console.log(`- User: ${process.env.DB_USER}`);

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  database: process.env.DB_NAME || 'eduflows_db',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || undefined, // Changer ceci
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Test de connexion
pool.on('connect', () => {
  console.log('✅ Connecté à PostgreSQL avec succès!');
});

pool.on('error', (err) => {
  console.error('❌ Erreur PostgreSQL:', err.message);
});

// Fonction pour tester la connexion
async function testConnection() {
  try {
    const client = await pool.connect();
    console.log('✅ Test de connexion PostgreSQL réussi!');
    client.release();
  } catch (error) {
    console.error('❌ Erreur de connexion PostgreSQL:', error.message);
  }
}

// Tester la connexion au démarrage
testConnection();

module.exports = {
  query: (text, params) => pool.query(text, params),
  pool
};
