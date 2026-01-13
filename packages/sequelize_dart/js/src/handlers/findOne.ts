import { Model } from '@sequelize/core';
import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import { toModelResponse, ModelResponse } from '../utils/modelResponse';

type FindOneParams = {
  model: string;
  options?: any;
};

export async function handleFindOne(params: FindOneParams): Promise<ModelResponse | null> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const options = convertQueryOptions(params.options || {});

  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  const result: Model = await model.findOne(options);
  return result ? toModelResponse(result) : null;
}
