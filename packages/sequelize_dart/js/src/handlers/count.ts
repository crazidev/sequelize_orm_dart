import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type CountParams = {
  model: string;
  options?: any;
};

export async function handleCount(params: CountParams): Promise<number> {
  const sequelize = getSequelize();
  if (!sequelize) {
    throw new Error('Not connected. Call connect first.');
  }

  const modelName = params.model;
  const options = convertQueryOptions(params.options || {});

  const models = getModels();
  const model = models.get(modelName);

  if (!model) {
    throw new Error(`Model "${modelName}" not found. Define it first.`);
  }

  const count = await model.count(options);
  return count;
}
