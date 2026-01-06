import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type DecrementParams = {
  model: string;
  fields: Record<string, number>;
  query?: any;
};

export async function handleDecrement(params: DecrementParams): Promise<any> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const fields = params.fields;
  const options = convertQueryOptions(params.query || {});

  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  if (!fields || Object.keys(fields).length === 0) {
    throw new Error('Fields are required for decrement operation');
  }

  const result = await model.decrement(fields, options);
  return result[0][0];
}
