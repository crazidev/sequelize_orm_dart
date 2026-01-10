import { Sequelize } from '@sequelize/core';
import { selectDialect } from '../utils/dialectSelector';
import { setOptions, setSequelize, sendNotification } from '../utils/state';

type ConnectParams = {
  config: any;
};

export async function handleConnect(params: ConnectParams): Promise<{ connected: true }> {
  const config = params.config;
  const { logging, dialect, pool, hoistIncludeOptions, ...sequelizeConfig } = config;

  setOptions({ hoistIncludeOptions: !!hoistIncludeOptions });

  const poolConfig: any = {};

  if (pool) {
    if (pool.max !== undefined && pool.max !== null) poolConfig.max = pool.max;
    if (pool.min !== undefined && pool.min !== null) poolConfig.min = pool.min;
    if (pool.idle !== undefined && pool.idle !== null) poolConfig.idle = pool.idle;
    if (pool.acquire !== undefined && pool.acquire !== null) poolConfig.acquire = pool.acquire;
    if (pool.evict !== undefined && pool.evict !== null) poolConfig.evict = pool.evict;
  }

  const loggingFn = logging
    ? (sql: any) => {
        // Send notification via the bridge (works for both stdio and Worker Thread)
        sendNotification({
          notification: 'sql_log',
          sql: typeof sql === 'string' ? sql : String(sql),
        });
      }
    : false;

  const sequelizeOptions: any = {
    ...sequelizeConfig,
    dialect: selectDialect(dialect),
    logging: loggingFn,
  };

  if (Object.keys(poolConfig).length > 0) {
    sequelizeOptions.pool = poolConfig;
  }

  const sequelize = new Sequelize(sequelizeOptions);

  await sequelize.authenticate();

  setSequelize(sequelize);

  return { connected: true };
}
