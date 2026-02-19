import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { getModels, getSequelize, getOptions } from '../utils/state';

type TruncateParams = {
  model: string;
  options?: {
    cascade?: boolean;
    restartIdentity?: boolean;
    withoutForeignKeyChecks?: boolean;
  };
};

export async function handleTruncate(params: TruncateParams): Promise<void> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  const options: any = { ...(params.options || {}) };

  // For PostgreSQL, use raw TRUNCATE query with CASCADE to ensure it works
  // with foreign key constraints. Sequelize's Model.truncate() may not
  // properly pass CASCADE in all v7 versions.
  const dialect = getOptions().dialect;
  if (dialect === 'postgres' && options.cascade) {
    const tableName = model.table?.tableName ?? model.tableName ?? modelName;
    const parts = ['TRUNCATE TABLE', `"${tableName}"`];
    if (options.restartIdentity) parts.push('RESTART IDENTITY');
    parts.push('CASCADE');
    await sequelize.query(parts.join(' '));
    return;
  }

  // For MySQL/MariaDB, TRUNCATE fails if the table is referenced by a foreign key
  // (even when the child table is empty). Always use a transaction so we can run
  // SET FOREIGN_KEY_CHECKS=0, TRUNCATE, SET FOREIGN_KEY_CHECKS=1 on the same connection.
  if (dialect === 'mysql' || dialect === 'mariadb') {
    const tableName = model.table?.tableName ?? model.tableName ?? modelName;
    await sequelize.transaction(async (t) => {
      await sequelize.query('SET FOREIGN_KEY_CHECKS = 0', { transaction: t });
      try {
        await sequelize.query(`TRUNCATE TABLE \`${tableName}\``, { transaction: t });
      } finally {
        await sequelize.query('SET FOREIGN_KEY_CHECKS = 1', { transaction: t });
      }
    });
    return;
  }

  // For other dialects, use Sequelize's Model.truncate with
  // withoutForeignKeyChecks when cascade is requested.
  if (options.cascade && options.withoutForeignKeyChecks === undefined) {
    options.withoutForeignKeyChecks = true;
  }

  await model.truncate(options);
}
