const express = require('express');
const healthRoutes = require('./health.routes');
const aiRoutes = require('./ai.routes');

const router = express.Router();

router.use('/health', healthRoutes);
router.use('/ai', aiRoutes);

module.exports = router;
