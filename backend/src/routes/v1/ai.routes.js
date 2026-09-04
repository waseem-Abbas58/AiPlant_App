const express = require('express');
const asyncHandler = require('../../middleware/asyncHandler');
const uploadImages = require('../../middleware/uploadImages');
const { identify, diagnose, chat } = require('../../controllers/ai.controller');

const router = express.Router();

router.post('/identify', uploadImages, asyncHandler(identify));
router.post('/diagnose', uploadImages, asyncHandler(diagnose));
router.post('/chat', asyncHandler(chat));

module.exports = router;
