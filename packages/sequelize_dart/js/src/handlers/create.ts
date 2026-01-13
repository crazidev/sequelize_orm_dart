import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import {
  toModelResponse,
  toModelResponseArray,
  ModelResponse,
} from '../utils/modelResponse';
import { Model } from '@sequelize/core';

type CreateParams = {
  model: string;
  data?: Record<string, any> | Record<string, any>[];
  options?: any;
};

export async function handleCreate(
  params: CreateParams,
): Promise<ModelResponse | ModelResponse[]> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const data = params.data || {};
  const options = convertQueryOptions(params.options || {});

  const model = getModels().get(modelName);
  checkModelDefinition(model, modelName);

  // Support bulk create (array of data)
  if (Array.isArray(data)) {
    if (data.length === 0) {
      throw new Error('Cannot create: data array is empty');
    }

    // bulkCreate returns an array of instances
    const results: Model[] = await model.bulkCreate(data, options);
    return toModelResponseArray(results);
  }

  // Single create
  const result = await model.create(data, options);
  return toModelResponse(result);
}
