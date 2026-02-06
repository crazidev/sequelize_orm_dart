import { checkConnection } from '../utils/checkUtils';
import { getSequelize } from '../utils/state';

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

  // Sequelize.truncate truncates all models registered in the instance
  await sequelize.truncate(options);
}
