import { StatusCodes } from 'http-status-codes';

// eslint-disable-next-line no-unused-vars
export const errorHandler = (err, req, res, next) => {
  const statusCode = err.statusCode || StatusCodes.INTERNAL_SERVER_ERROR;
  const message = err.message || 'Something went wrong';
  res.status(statusCode).json({
    success: false,
    message: message,
    stack: process.env.BUILD_MODE === 'dev' ? err.stack : {},
  });
};
