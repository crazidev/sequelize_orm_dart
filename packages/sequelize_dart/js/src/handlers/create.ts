import { ModelStatic } from '@sequelize/core';
import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { getModels, getSequelize } from '../utils/state';

type CreateParams = {
  model: string;
  data?: Record<string, any>;
};

export async function handleCreate(params: CreateParams): Promise<any> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const data = params.data || {};

  const model = getModels().get(modelName);
  checkModelDefinition(model, modelName);

  const result = await model.create(data);
  return result.toJSON();
}
