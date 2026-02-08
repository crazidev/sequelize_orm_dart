import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type RestoreParams = {
  model: string;
  options?: {
    individualHooks?: boolean;
    limit?: number;
    where?: any;
  };
};

export async function handleRestore(params: RestoreParams): Promise<void> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  // Convert options including where clause
  const options = convertQueryOptions(params.options || {});

  // Model.restore returns void
  await model.restore(options);
}
