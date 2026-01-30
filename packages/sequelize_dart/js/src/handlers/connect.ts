import { Sequelize } from '@sequelize/core';
import { selectDialect } from '../utils/dialectSelector';
import { setOptions, setSequelize, sendNotification } from '../utils/state';

type ConnectParams = {
  config: any;
};

export async function handleConnect(params: ConnectParams): Promise<{ connected: true }> {
  const config = params.config;
  const { logging, dialect, pool, hoistIncludeOptions, ...sequelizeConfig } = config;

  const normalizedDialect = typeof dialect === 'string' ? dialect.toLowerCase() : 'postgres';

  setOptions({
    hoistIncludeOptions: !!hoistIncludeOptions,
    dialect: normalizedDialect,
  });

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

  function isUnknownDatabaseError(err: any): boolean {
    const original = err?.original ?? err?.parent ?? err;
    const errno = original?.errno ?? original?.errno;
    const code = original?.code;
    return errno === 1049 || code === 'ER_BAD_DB_ERROR';
  }

  async function tryCreateDatabaseIfMissing(): Promise<boolean> {
    if (normalizedDialect !== 'mysql' && normalizedDialect !== 'mariadb') return false;

    const dbName =
      typeof sequelizeConfig.database === 'string'
        ? sequelizeConfig.database
        : typeof sequelizeConfig.url === 'string'
          ? (() => {
              try {
                const u = new URL(sequelizeConfig.url);
                const name = u.pathname?.replace(/^\//, '') ?? '';
                return name || undefined;
              } catch {
                return undefined;
              }
            })()
          : undefined;

    if (!dbName) return false;

    let adminOptions: any = { ...sequelizeOptions };

    if (typeof sequelizeConfig.url === 'string') {
      try {
        const u = new URL(sequelizeConfig.url);
        u.pathname = '/';
        u.search = '';
        u.hash = '';
        adminOptions = { ...adminOptions, url: u.toString() };
      } catch {
        // fall back to clearing database below
      }
    }

    // If we were using discrete connection params, clear database to connect without selecting one.
    adminOptions.database = undefined;

    const adminSequelize = new Sequelize(adminOptions);
    try {
      await adminSequelize.authenticate();
      // Use identifier quoting to avoid injection/invalid names
      await adminSequelize.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\``);
      return true;
    } finally {
      await adminSequelize.close().catch(() => undefined);
    }
  }

  try {
    await sequelize.authenticate();
  } catch (err: any) {
    if (isUnknownDatabaseError(err)) {
      const created = await tryCreateDatabaseIfMissing();
      if (created) {
        await sequelize.authenticate();
      } else {
        throw err;
      }
    } else {
      throw err;
    }
  }

  setSequelize(sequelize);

  return { connected: true };
}
