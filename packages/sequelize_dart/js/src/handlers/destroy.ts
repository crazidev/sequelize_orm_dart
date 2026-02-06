import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type DestroyParams = {
  model: string;
  options?: {
    force?: boolean;
    limit?: number;
    individualHooks?: boolean;
    where?: any;
  };
};

export async function handleDestroy(params: DestroyParams): Promise<number> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  // Convert options including where clause
  const options = convertQueryOptions(params.options || {});

  // Model.destroy returns the number of destroyed rows
  const destroyedCount = await model.destroy(options);

  if (typeof destroyedCount === 'number') {
    return destroyedCount;
  }

  // Fallback if result format is unexpected
  return 0;
}
