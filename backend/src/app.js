const express = require('express');
const cors = require('cors');
require('dotenv').config();

const authRoutes = require('./routes/authRoutes');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors({
  origin: ['http://localhost:5555', 'http://localhost:3000', 'http://localhost:3001'],
  credentials: true
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging des requêtes
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  next();
});

// Routes
app.use('/api/auth', authRoutes);

// Route de test
app.get('/api/health', (req, res) => {
  res.json({ 
    success: true, 
    message: '🚀 API EduFlows en ligne!',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV
  });
});

// Route 404
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route non trouvée'
  });
});

// Démarrer le serveur
app.listen(PORT, () => {
  console.log('='.repeat(50));
  console.log('🚀 SERVEUR EDUFLOWS BACKEND');
  console.log('='.repeat(50));
  console.log(`📡 Port: ${PORT}`);
  console.log(`🌍 Environnement: ${process.env.NODE_ENV}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/api/health`);
  console.log(`🔐 Login: POST http://localhost:${PORT}/api/auth/login`);
  console.log('='.repeat(50));
  console.log('📋 Comptes de test:');
  console.log('   Admin: admin@eduflows.com / admin123');
  console.log('   Professeur: prof@eduflows.com / prof123');
  console.log('   Étudiant: etudiant@eduflows.com / etudiant123');
  console.log('='.repeat(50));
});
