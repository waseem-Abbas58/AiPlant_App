const { sendError } = require('../utils/apiResponse');

const errorHandler = (err, req, res, next) => {
  void next;

  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal server error';
  const error = err.error && typeof err.error === 'object' ? { ...err.error } : {};

  if (process.env.NODE_ENV !== 'production' && statusCode >= 500 && err.stack) {
    error.stack = err.stack;
  }

  return sendError(res, { statusCode, message, error });
};

module.exports = errorHandler;
