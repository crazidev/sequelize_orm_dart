#!/usr/bin/env node

// Load environment variables if .env file exists
require('dotenv').config();

const { Sequelize } = require('@sequelize/core');
const { convertAttributes } = require('./utils/dataTypeConverter');
const { convertQueryOptions } = require('./utils/queryConverter');
const { selectDialect } = require('./utils/dialectSelector');
const { formatError } = require('./utils/errorFormatter');

// Global state
let sequelize = null;
const models = new Map();

/**
 * Handle JSON-RPC requests
 */
async function handleRequest(request) {
  const { id, method, params } = request;

  try {
    let result;

    switch (method) {
      case 'ready':
        result = { ready: true };
        break;

      case 'connect':
        const config = params.config;
        const { logging, dialect, pool, ...sequelizeConfig } = config;

        // Build pool configuration (only include defined values)
        const poolConfig = {};
        
        if (pool) {
          // Only include pool options that are explicitly set
          if (pool.max !== undefined && pool.max !== null) poolConfig.max = pool.max;
          if (pool.min !== undefined && pool.min !== null) poolConfig.min = pool.min;
          if (pool.idle !== undefined && pool.idle !== null) poolConfig.idle = pool.idle;
          if (pool.acquire !== undefined && pool.acquire !== null) poolConfig.acquire = pool.acquire;
          if (pool.evict !== undefined && pool.evict !== null) poolConfig.evict = pool.evict;
        }

        const sequelizeOptions = {
          ...sequelizeConfig,
          dialect: selectDialect(dialect),
          logging: logging ? console.error : false, // Use stderr for logging (not stdout)
        };
        
        // Only add pool config if it has values
        if (Object.keys(poolConfig).length > 0) {
          sequelizeOptions.pool = poolConfig;
        }

        sequelize = new Sequelize(sequelizeOptions);

        // Test connection
        await sequelize.authenticate();

        result = { connected: true };
        break;

      case 'defineModel':
        if (!sequelize) {
          throw new Error('Not connected. Call connect first.');
        }

        const { name, attributes, options } = params;
        const sequelizeAttributes = convertAttributes(attributes);

        const model = sequelize.define(name, sequelizeAttributes, options || {});
        models.set(name, model);

        result = { defined: true };
        break;

      case 'findAll':
        if (!sequelize) {
          throw new Error('Not connected. Call connect first.');
        }

        const findAllModelName = params.model;
        const findAllOptions = convertQueryOptions(params.options || {});
        const findAllModel = models.get(findAllModelName);

        if (!findAllModel) {
          throw new Error(`Model "${findAllModelName}" not found. Define it first.`);
        }

        const findAllResults = await findAllModel.findAll(findAllOptions);
        result = findAllResults.map(row => row.toJSON());
        break;

      case 'findOne':
        if (!sequelize) {
          throw new Error('Not connected. Call connect first.');
        }

        const findOneModelName = params.model;
        const findOneOptions = convertQueryOptions(params.options || {});
        const findOneModel = models.get(findOneModelName);

        if (!findOneModel) {
          throw new Error(`Model "${findOneModelName}" not found. Define it first.`);
        }

        const findOneResult = await findOneModel.findOne(findOneOptions);
        result = findOneResult ? findOneResult.toJSON() : null;
        break;

      case 'create':
        if (!sequelize) {
          throw new Error('Not connected. Call connect first.');
        }

        const createModelName = params.model;
        const createData = params.data || {};
        const createModel = models.get(createModelName);

        if (!createModel) {
          throw new Error(`Model "${createModelName}" not found. Define it first.`);
        }

        const createResult = await createModel.create(createData);
        result = createResult.toJSON();
        break;

      case 'close':
        if (sequelize) {
          await sequelize.close();
          sequelize = null;
          models.clear();
        }
        result = { closed: true };
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

process.stdin.on('end', () => {
  // Cleanup on exit
  if (sequelize) {
    sequelize.close();
  }
  process.exit(0);
});

// Handle process termination
process.on('SIGTERM', () => {
  if (sequelize) {
    sequelize.close();
  }
  process.exit(0);
});

process.on('SIGINT', () => {
  if (sequelize) {
    sequelize.close();
  }
  process.exit(0);
});

