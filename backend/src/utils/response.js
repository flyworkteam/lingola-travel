// Standard API Response Utilities

/**
 * Success Response
 */
function successResponse(data) {
  return {
    success: true,
    data: data,
    error: null
  };
}

/**
 * Error Response
 */
function errorResponse(code, message) {
  return {
    success: false,
    data: null,
    error: {
      code: code,
      message: message
    }
  };
}

/**
 * Pagination Metadata
 */
function paginationMeta(currentPage, totalItems, itemsPerPage) {
  const totalPages = Math.ceil(totalItems / itemsPerPage);
  
  return {
    currentPage: parseInt(currentPage),
    totalPages: totalPages,
    totalItems: totalItems,
    itemsPerPage: itemsPerPage
  };
}

/**
 * Error Code Definitions
 */
const ErrorCodes = {
  // Authentication Errors
  INVALID_CREDENTIALS: 'INVALID_CREDENTIALS',
  ACCOUNT_NOT_FOUND: 'ACCOUNT_NOT_FOUND',
  INVALID_TOKEN: 'INVALID_TOKEN',
  TOKEN_NOT_FOUND: 'TOKEN_NOT_FOUND',
  UNAUTHORIZED: 'UNAUTHORIZED',
  FORBIDDEN: 'FORBIDDEN',
  
  // Validation Errors
  VALIDATION_ERROR: 'VALIDATION_ERROR',
  WEAK_PASSWORD: 'WEAK_PASSWORD',
  INVALID_PASSWORD: 'INVALID_PASSWORD',
  
  // Resource Errors
  NOT_FOUND: 'NOT_FOUND',
  DUPLICATE_ENTRY: 'DUPLICATE_ENTRY',
  
  // Rate Limiting
  RATE_LIMIT_EXCEEDED: 'RATE_LIMIT_EXCEEDED',
  
  // Server Errors
  SERVER_ERROR: 'SERVER_ERROR',
  DATABASE_ERROR: 'DATABASE_ERROR'
};

/**
 * User-Friendly Error Messages
 */
const ErrorMessages = {
  [ErrorCodes.INVALID_CREDENTIALS]: 'Email veya şifre hatalı',
  [ErrorCodes.ACCOUNT_NOT_FOUND]: 'Hesap bulunamadı',
  [ErrorCodes.INVALID_TOKEN]: 'Geçersiz veya süresi dolmuş token',
  [ErrorCodes.TOKEN_NOT_FOUND]: 'Token bulunamadı',
  [ErrorCodes.UNAUTHORIZED]: 'Yetkisiz erişim',
  [ErrorCodes.FORBIDDEN]: 'Bu işlem için yetkiniz yok',
  [ErrorCodes.VALIDATION_ERROR]: 'Geçersiz veri',
  [ErrorCodes.WEAK_PASSWORD]: 'Şifre güvenlik gereksinimlerini karşılamıyor',
  [ErrorCodes.INVALID_PASSWORD]: 'Mevcut şifre hatalı',
  [ErrorCodes.NOT_FOUND]: 'Kaynak bulunamadı',
  [ErrorCodes.DUPLICATE_ENTRY]: 'Bu kayıt zaten mevcut',
  [ErrorCodes.RATE_LIMIT_EXCEEDED]: 'Çok fazla istek. Lütfen daha sonra tekrar deneyin.',
  [ErrorCodes.SERVER_ERROR]: 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.',
  [ErrorCodes.DATABASE_ERROR]: 'Veritabanı hatası'
};

/**
 * Get Error Message by Code
 */
function getErrorMessage(code) {
  return ErrorMessages[code] || ErrorMessages[ErrorCodes.SERVER_ERROR];
}

module.exports = {
  successResponse,
  errorResponse,
  paginationMeta,
  ErrorCodes,
  ErrorMessages,
  getErrorMessage
};
