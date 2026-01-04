const { Sequelize } = require('@sequelize/core');
const { selectDialect } = require('../utils/dialectSelector');
const { setSequelize } = require('../utils/state');

/**
 * Handler for 'connect' method
 * Establishes a connection to the database
 */
async function handleConnect(params) {
  const config = params.config;
  const { logging, dialect, pool, hoistIncludeOptions, ...sequelizeConfig } = config;

  const { setOptions } = require('../utils/state');
  setOptions({ hoistIncludeOptions: !!hoistIncludeOptions });

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

  // Custom logging function that sends SQL to Dart via JSON-RPC notification
  const loggingFn = logging
    ? (sql) => {
        // Send SQL log as JSON-RPC notification to stdout
        const notification = {
          notification: 'sql_log',
          sql: typeof sql === 'string' ? sql : String(sql),
        };
        process.stdout.write(JSON.stringify(notification) + '\n');
        // Also log to stderr for debugging
        console.error(sql);
      }
    : false;

  const sequelizeOptions = {
    ...sequelizeConfig,
    dialect: selectDialect(dialect),
    logging: loggingFn,
  };

  // Only add pool config if it has values
  if (Object.keys(poolConfig).length > 0) {
    sequelizeOptions.pool = poolConfig;
  }

  const sequelize = new Sequelize(sequelizeOptions);

  // Test connection
  await sequelize.authenticate();

  // Store the sequelize instance
  setSequelize(sequelize);

  return { connected: true };
}

module.exports = {
  handleConnect,
};

