import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type FindAllParams = {
  model: string;
  options?: any;
};

export async function handleFindAll(params: FindAllParams): Promise<any[]> {
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

  const results = await model.findAll(options);
  return results.map((row: any) => row.toJSON());
}
