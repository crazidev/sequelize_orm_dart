import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize, sendNotification } from '../utils/state';

type IncrementParams = {
  model: string;
  fields: Record<string, number>;
  query?: any;
};

export async function handleIncrement(params: IncrementParams): Promise<any> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const fields = params.fields;
  const options = convertQueryOptions(params.query || {});

  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);
  sendNotification({
    notification: "sql_log",
    sql: "Testing notification",
  });

  if (!fields || Object.keys(fields).length === 0) {
    throw new Error('Fields are required for increment operation');
  }

  const result = await model.increment(fields, options);
  return result[0][0];
}

