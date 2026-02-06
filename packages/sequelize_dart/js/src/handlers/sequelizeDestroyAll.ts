import { checkConnection } from '../utils/checkUtils';
import { getSequelize } from '../utils/state';

type SequelizeDestroyAllParams = {
  options?: {
    force?: boolean;
    individualHooks?: boolean;
  };
};

export async function handleSequelizeDestroyAll(params: SequelizeDestroyAllParams): Promise<void> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const options = params.options || {};

  // Sequelize.destroyAll is a slower alternative to truncate that uses DELETE FROM
  await sequelize.destroyAll(options);
}
