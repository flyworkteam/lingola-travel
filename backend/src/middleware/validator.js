// Request Validation Middleware
const { validationResult } = require('express-validator');
const { errorResponse, ErrorCodes } = require('../utils/response');

/**
 * Validation Error Handler
 */
function handleValidationErrors(req, res, next) {
  const errors = validationResult(req);
  
  if (!errors.isEmpty()) {
    const errorMessages = errors.array().map(err => `${err.param}: ${err.msg}`);
    
    return res.status(400).json(
      errorResponse(
        ErrorCodes.VALIDATION_ERROR,
        errorMessages.join(', ')
      )
    );
  }
  
  next();
}

module.exports = {
  handleValidationErrors
};
