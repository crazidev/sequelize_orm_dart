/**
 * Format error for JSON-RPC response
 */
function formatError(error) {
  const errorMessage = error.message || error.toString() || 'Unknown error';
  const errorName = error.name || error.constructor?.name || 'Error';
  const errorCode = error.code || error.statusCode || -32603;
  const errorStack = error.stack || '';
  
  const errorDetails = {
    name: errorName,
    message: errorMessage,
    code: errorCode,
    stack: errorStack,
  };
  
  // Add Sequelize-specific error details if available
  if (error.original) {
    errorDetails.original = {
      message: error.original.message || error.original.toString(),
      code: error.original.code,
    };
  }
  
  // Add SQL error details if available
  if (error.sql) {
    errorDetails.sql = error.sql;
  }
  
  return errorDetails;
}

module.exports = {
  formatError,
};

