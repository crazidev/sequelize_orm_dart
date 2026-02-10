import { Attributes, FindOptions, Model } from '@sequelize/core';
import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize, sendNotification } from '../utils/state';
import { toModelResponse, ModelResponse } from '../utils/modelResponse';
import { printLogs } from '../utils/printLogs';

type FindOneParams = {
  model: string;
  options?: FindOptions<Attributes<any>>;
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
