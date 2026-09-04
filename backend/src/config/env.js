const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

const env = {
  port: Number(process.env.PORT) || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  isProduction: (process.env.NODE_ENV || 'development') === 'production',

  // Placeholders for later phases — not connected in Phase 1
  mongodbUri: process.env.MONGODB_URI || '',
  firebase: {
    projectId: process.env.FIREBASE_PROJECT_ID || '',
    clientEmail: process.env.FIREBASE_CLIENT_EMAIL || '',
    privateKey: process.env.FIREBASE_PRIVATE_KEY || '',
  },
  plantIdApiKey: process.env.PLANT_ID_API_KEY || '',
  geminiApiKey: process.env.GEMINI_API_KEY || '',
};

module.exports = env;
