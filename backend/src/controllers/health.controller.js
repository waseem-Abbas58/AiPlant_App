const env = require('../config/env');
const { sendSuccess } = require('../utils/apiResponse');

const getHealth = (req, res) => {
  return sendSuccess(res, {
    message: 'AI PlantApp backend is running',
    data: {
      status: 'ok',
      service: 'ai-plant-app-backend',
      version: 'v1',
      environment: env.nodeEnv,
      plantIdConfigured: Boolean(String(env.plantIdApiKey || '').trim()),
      geminiConfigured: Boolean(String(env.geminiApiKey || '').trim()),
      timestamp: new Date().toISOString(),
    },
  });
};

module.exports = { getHealth };
