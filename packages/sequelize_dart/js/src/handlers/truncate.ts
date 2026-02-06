import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { getModels, getSequelize } from '../utils/state';

type TruncateParams = {
  model: string;
  options?: {
    cascade?: boolean;
    restartIdentity?: boolean;
  };
};

export async function handleTruncate(params: TruncateParams): Promise<void> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  const options = params.options || {};

  // Model.truncate returns void
  await model.truncate(options);
}
