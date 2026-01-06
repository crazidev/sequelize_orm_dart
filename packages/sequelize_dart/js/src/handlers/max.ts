import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type MaxParams = {
  model: string;
  column: string;
  options?: any;
};

export async function handleMax(params: MaxParams): Promise<any> {
  const sequelize = getSequelize();
  if (!sequelize) {
    throw new Error('Not connected. Call connect first.');
  }

  const modelName = params.model;
  const column = params.column;
  const options = convertQueryOptions(params.options || {});

  const models = getModels();
  const model = models.get(modelName);

  if (!model) {
    throw new Error(`Model "${modelName}" not found. Define it first.`);
  }

  if (!column) {
    throw new Error('Column name is required for max operation');
  }

  const max = await model.max(column, options);
  return max;
}
