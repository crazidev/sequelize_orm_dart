export function formatError(error: any): any {
  const errorMessage = error?.message || error?.toString?.() || 'Unknown error';
  const errorName = error?.name || error?.constructor?.name || 'Error';
  const errorCode = error?.code || error?.statusCode || -32603;
  const errorStack = error?.stack || '';

  const errorDetails: any = {
    name: errorName,
    message: errorMessage,
    code: errorCode,
    stack: errorStack,
  };

  if (error?.original) {
    errorDetails.original = {
      message: error.original.message || error.original.toString?.(),
      code: error.original.code,
    };
  }

  if (error?.sql) {
    errorDetails.sql = error.sql;
  }

  return errorDetails;
}
