// Main Server Application
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
require('dotenv').config();

const { testConnection } = require('./config/database');
const { apiLimiter } = require('./middleware/rateLimiter');

// Import routes
const routes = require('./routes');

const app = express();
const PORT = process.env.PORT || 3000;
const API_VERSION = process.env.API_VERSION || 'v1';

// ===================================
// Middleware
// ===================================

// Security headers
app.use(helmet());

// CORS configuration
const corsOptions = {
  origin: process.env.CORS_ORIGINS ? process.env.CORS_ORIGINS.split(',') : '*',
  credentials: true,
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));

// Body parsing
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Request logging
if (process.env.ENABLE_REQUEST_LOGGING === 'true') {
  app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));
}

// Rate limiting
app.use(apiLimiter);

// ===================================
// Routes
// ===================================

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    timestamp: new Date().toISOString(),
    version: API_VERSION,
    environment: process.env.NODE_ENV
  });
});

// API routes
app.use(`/api/${API_VERSION}`, routes);

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    data: null,
    error: {
      code: 'NOT_FOUND',
      message: `Route ${req.method} ${req.path} not found`
    }
  });
});

// Global error handler
app.use((err, req, res, next) => {
  console.error('Global error handler:', err);
  
  res.status(err.status || 500).json({
    success: false,
    data: null,
    error: {
      code: 'SERVER_ERROR',
      message: process.env.NODE_ENV === 'production' 
        ? 'Sunucu hatası' 
        : err.message
    }
  });
});

// ===================================
// Server Initialization
// ===================================

async function startServer() {
  try {
    // Test database connection
    const dbConnected = await testConnection();
    
    if (!dbConnected) {
      console.error('⚠️  Database connection failed. Server will not start.');
      console.error('Please check your .env file and ensure MySQL is running.');
      process.exit(1);
    }
    
    // Start server
    app.listen(PORT, () => {
      console.log('\n🚀 Lingola Travel Backend Server');
      console.log('================================');
      console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🌐 Server running on: http://localhost:${PORT}`);
      console.log(`📡 API Base URL: http://localhost:${PORT}/api/${API_VERSION}`);
      console.log(`💚 Health check: http://localhost:${PORT}/health`);
      console.log('================================\n');
    });
  } catch (error) {
    console.error('Server startup failed:', error);
    process.exit(1);
  }
}

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('\nSIGINT signal received: closing HTTP server');
  process.exit(0);
});

// Start the server
startServer();

module.exports = app;
