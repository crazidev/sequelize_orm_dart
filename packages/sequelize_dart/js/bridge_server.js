#!/usr/bin/env node

// Load environment variables if .env file exists
require('dotenv').config();

const { formatError } = require('./utils/errorFormatter');
const { getSequelize } = require('./utils/state');

// Import handlers
const { handleReady } = require('./handlers/ready');
const { handleConnect } = require('./handlers/connect');
const { handleDefineModel } = require('./handlers/defineModel');
const { handleAssociateModel } = require('./handlers/associateModel');
const { handleFindAll } = require('./handlers/findAll');
const { handleFindOne } = require('./handlers/findOne');
const { handleCreate } = require('./handlers/create');
const { handleClose } = require('./handlers/close');

/**
 * Handle JSON-RPC requests
 */
async function handleRequest(request) {
  const { id, method, params } = request;

  try {
    let result;

    switch (method) {
      case 'ready':
        result = await handleReady();
        break;

      case 'connect':
        result = await handleConnect(params);
        break;

      case 'defineModel':
        result = await handleDefineModel(params);
        break;

      case 'associateModel':
        result = await handleAssociateModel(params);
        break;

      case 'findAll':
        result = await handleFindAll(params);
        break;

      case 'findOne':
        result = await handleFindOne(params);
        break;

      case 'create':
        result = await handleCreate(params);
        break;

      case 'close':
        result = await handleClose();
        break;

      default:
        throw new Error(`Unknown method: ${method}`);
    }

    // Send success response (use process.stdout.write for better concurrency)
    const response = {
      id,
      result,
    };
    process.stdout.write(JSON.stringify(response) + '\n');
  } catch (error) {
    // Send error response with detailed error information
    const response = {
      id,
      error: formatError(error),
    };
    process.stdout.write(JSON.stringify(response) + '\n');
  }
}

// Send ready signal immediately
process.stdout.write(JSON.stringify({ id: 0, result: { ready: true } }) + '\n');

// Read from stdin line by line
let buffer = '';
process.stdin.setEncoding('utf8');

process.stdin.on('data', (chunk) => {
  buffer += chunk;
  const lines = buffer.split('\n');
  buffer = lines.pop() || ''; // Keep incomplete line in buffer

  for (const line of lines) {
    if (line.trim()) {
      try {
        const request = JSON.parse(line);
        // Process requests concurrently - don't await, let them run in parallel
        handleRequest(request).catch((error) => {
          const errorResponse = {
            id: request.id || null,
            error: formatError(error),
          };
          process.stdout.write(JSON.stringify(errorResponse) + '\n');
        });
      } catch (error) {
        const errorResponse = {
          id: null,
          error: {
            message: `Parse error: ${error.message}`,
            code: -32700,
          },
        };
        process.stdout.write(JSON.stringify(errorResponse) + '\n');
      }
    }
  }
});

process.stdin.on('end', async () => {
  // Cleanup on exit
  const sequelize = getSequelize();
  if (sequelize) {
    await sequelize.close();
  }
  process.exit(0);
});

// Handle process termination
process.on('SIGTERM', async () => {
  const sequelize = getSequelize();
  if (sequelize) {
    await sequelize.close();
  }
  process.exit(0);
});

process.on('SIGINT', async () => {
  const sequelize = getSequelize();
  if (sequelize) {
    await sequelize.close();
  }
  process.exit(0);
});

