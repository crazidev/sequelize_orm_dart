import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type UpdateParams = {
  model: string;
  data: Record<string, any>;
  query?: any;
};

export async function handleUpdate(params: UpdateParams): Promise<number> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const data = params.data;
  const options = convertQueryOptions(params.query || {});

  if (!data || Object.keys(data).length === 0) {
    throw new Error('Data is required for update operation');
  }

  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  // Sequelize update returns [affectedCount, affectedRows]
  // affectedCount is the number of rows affected
  const result = await model.update(data, options);
  const affectedCount = result[0];

  if (typeof affectedCount === 'number') {
    return affectedCount;
  }

  // Fallback if result format is unexpected
  return 0;
}
