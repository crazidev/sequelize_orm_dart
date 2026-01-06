import { convertAttributes, extractIndexes } from '../utils/dataTypeConverter';
import { getModels, getSequelize } from '../utils/state';

type DefineModelParams = {
  name: string;
  attributes: Record<string, any>;
  options?: any;
};

export async function handleDefineModel(params: DefineModelParams): Promise<{ defined: true }> {
  const sequelize = getSequelize();
  if (!sequelize) {
    throw new Error('Not connected. Call connect first.');
  }

  const { name, attributes, options } = params;
  const sequelizeAttributes = convertAttributes(attributes);

  const attributeIndexes = extractIndexes(attributes);

  const finalOptions: any = { ...(options || {}) };
  if (attributeIndexes.length > 0) {
    finalOptions.indexes = [...(finalOptions.indexes || []), ...attributeIndexes];
  }

  const models = getModels();
  const model = sequelize.define(name, sequelizeAttributes, finalOptions);
  models.set(name, model);

  return { defined: true };
}
