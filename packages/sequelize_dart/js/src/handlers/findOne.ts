import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type FindOneParams = {
  model: string;
  options?: any;
};

export async function handleFindOne(params: FindOneParams): Promise<any | null> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const options = convertQueryOptions(params.options || {});

  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  const result = await model.findOne(options);
  return result ? result.toJSON() : null;
}
