class ApiError extends Error {
  constructor(statusCode, message, error = {}) {
    super(message);
    this.statusCode = statusCode;
    this.error = error;
    this.isOperational = true;
    Error.captureStackTrace(this, this.constructor);
  }
}

const sendSuccess = (res, { statusCode = 200, message = 'Success', data = {} } = {}) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

const sendError = (res, { statusCode = 500, message = 'Internal server error', error = {} } = {}) => {
  return res.status(statusCode).json({
    success: false,
    message,
    error,
  });
};

module.exports = {
  ApiError,
  sendSuccess,
  sendError,
};
