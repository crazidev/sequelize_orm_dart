import { checkConnection } from '../utils/checkUtils';
import { getSequelize, getOptions } from '../utils/state';

type SequelizeTruncateParams = {
  options?: {
    cascade?: boolean;
    restartIdentity?: boolean;
    withoutForeignKeyChecks?: boolean;
  };
};

export async function handleSequelizeTruncate(params: SequelizeTruncateParams): Promise<void> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const options = params.options || {};
  const dialect = getOptions().dialect;

  // MySQL/MariaDB do not support cascade on truncate and require foreign key checks disabled.
  if (dialect === 'mysql' || dialect === 'mariadb') {
    await sequelize.transaction(async (t) => {
      await sequelize.query('SET FOREIGN_KEY_CHECKS = 0', { transaction: t });
      try {
        await sequelize.truncate({ transaction: t });
      } finally {
        await sequelize.query('SET FOREIGN_KEY_CHECKS = 1', { transaction: t });
      }
    });
    return;
  }

  // Sequelize.truncate truncates all models registered in the instance
  await sequelize.truncate(options);
}
