import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import { printLogs } from '../utils/printLogs';
import { Model, Op } from '@sequelize/core';

type FindAllParams = {
  model: string;
  options?: any;
};

export async function handleFindAll(params: FindAllParams): Promise<any[]> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const options = convertQueryOptions(params.options || {});

  const model = getModels().get(modelName);
  checkModelDefinition(model, modelName);

  const results: Model[] = await model.findAll(options);
  return results.map((row: any) => row.toJSON());
}

