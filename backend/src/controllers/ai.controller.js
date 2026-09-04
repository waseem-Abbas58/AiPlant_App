const plantId = require('../services/plantIdClient');
const mappers = require('../services/plantIdMappers');
const gemini = require('../services/geminiClient');
const { sendSuccess } = require('../utils/apiResponse');

const identify = async (req, res) => {
  const categoryId = String(req.body.categoryId || 'plant');
  const raw = await plantId.identify(req.files, categoryId);
  return res.status(200).json(mappers.identify(raw, { categoryId }));
};

const diagnose = async (req, res) => {
  const plantName = String(req.body.plantName || '');
  const symptomId = String(req.body.symptomId || '');
  const raw = await plantId.diagnose(req.files);
  return res.status(200).json(mappers.diagnose(raw, { plantName, symptomId }));
};

const chat = async (req, res) => {
  const data = await gemini.chat({
    message: req.body.message,
    plantName: String(req.body.plantName || ''),
    issue: String(req.body.issue || ''),
  });
  return sendSuccess(res, {
    message: 'Ask Botanist reply',
    data,
  });
};

module.exports = { identify, diagnose, chat };
