import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type FindOneParams = {
  model: string;
  options?: any;
};

export async function handleFindOne(params: FindOneParams): Promise<any | null> {
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

  const result = await model.findOne(options);
  return result ? result.toJSON() : null;
}
