const multer = require('multer');
const { ApiError } = require('../utils/apiResponse');

const MAX_BYTES = 8 * 1024 * 1024;
const MAX_FILES = 5;

const isJpeg = (buffer) =>
  buffer.length >= 3 && buffer[0] === 0xff && buffer[1] === 0xd8 && buffer[2] === 0xff;

const isPng = (buffer) =>
  buffer.length >= 4 &&
  buffer[0] === 0x89 &&
  buffer[1] === 0x50 &&
  buffer[2] === 0x4e &&
  buffer[3] === 0x47;

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: MAX_BYTES, files: MAX_FILES },
  fileFilter: (req, file, cb) => {
    const mime = String(file.mimetype || '').toLowerCase();
    if (mime === 'image/jpeg' || mime === 'image/jpg' || mime === 'image/png') {
      cb(null, true);
      return;
    }
    cb(new ApiError(400, 'Only JPEG and PNG images are allowed'));
  },
});

const uploadImages = upload.array('image', MAX_FILES);

const handleUpload = (req, res, next) => {
  uploadImages(req, res, (err) => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        next(new ApiError(400, 'Each image must be 8 MB or smaller'));
        return;
      }
      if (err.code === 'LIMIT_FILE_COUNT') {
        next(new ApiError(400, 'Send at most 5 images'));
        return;
      }
      if (err instanceof ApiError) {
        next(err);
        return;
      }
      next(new ApiError(400, err.message || 'Invalid image upload'));
      return;
    }

    const files = req.files || [];
    if (files.length === 0) {
      next(new ApiError(400, 'At least one image is required (multipart field: image)'));
      return;
    }

    for (const file of files) {
      const buffer = file.buffer;
      if (!buffer || buffer.length === 0) {
        next(new ApiError(400, 'Image file is empty'));
        return;
      }
      if (!isJpeg(buffer) && !isPng(buffer)) {
        next(new ApiError(400, 'Only JPEG and PNG images are allowed'));
        return;
      }
    }

    next();
  });
};

module.exports = handleUpload;
