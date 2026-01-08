import { checkConnection } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type CountParams = {
  model: string;
  options?: any;
};

export async function handleCount(params: CountParams): Promise<number> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const options = convertQueryOptions(params.options || {});

  const models = getModels();
  const model = models.get(modelName);

  const count = await model.count(options);
  if(typeof count === "number") return count;
  return count.at(0).count;
}
