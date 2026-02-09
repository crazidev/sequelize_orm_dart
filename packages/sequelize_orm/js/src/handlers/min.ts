import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type MinParams = {
  model: string;
  column: string;
  options?: any;
};

export async function handleMin(params: MinParams): Promise<any> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const column = params.column;
  const options = convertQueryOptions(params.options || {});

  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  if (!column) {
    throw new Error('Column name is required for min operation');
  }

  const min = await model.min(column, options);
  return min;
}
