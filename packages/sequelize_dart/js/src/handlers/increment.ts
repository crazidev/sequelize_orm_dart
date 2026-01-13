import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import { toModelResponseArray, ModelResponse } from '../utils/modelResponse';

type IncrementParams = {
  model: string;
  fields: Record<string, number>;
  query?: any;
};

export async function handleIncrement(params: IncrementParams): Promise<ModelResponse[]> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const fields = params.fields;
  const options = convertQueryOptions(params.query || {});

  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  if (!fields || Object.keys(fields).length === 0) {
    throw new Error('Fields are required for increment operation');
  }

  const result = await model.increment(fields, options);
  // result[0] is an array of updated instances
  return toModelResponseArray(result[0]);
}

