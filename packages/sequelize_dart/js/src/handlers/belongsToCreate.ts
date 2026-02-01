import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { getModels, getSequelize } from '../utils/state';
import { toModelResponse, ModelResponse } from '../utils/modelResponse';

type BelongsToCreateParams = {
  sourceModel: string;
  primaryKeyValues: Record<string, any>;
  associationName: string;
  data: Record<string, any>;
  options?: any;
};

function capitalize(name: string): string {
  if (!name) return name;
  return name[0].toUpperCase() + name.slice(1);
}

function compactWhere(where: Record<string, any>): Record<string, any> {
  return Object.fromEntries(
    Object.entries(where || {}).filter(([, v]) => v !== undefined && v !== null),
  );
}

export async function handleBelongsToCreate(
  params: BelongsToCreateParams,
): Promise<ModelResponse> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const models = getModels();
  const source = models.get(params.sourceModel);
  checkModelDefinition(source, params.sourceModel);

  const where = compactWhere(params.primaryKeyValues);
  const instance = await source.findOne({ where });
  if (!instance) {
    throw new Error(
      `Cannot create belongsTo association: instance of "${params.sourceModel}" not found for provided primary key values`,
    );
  }

  const methodName = `create${capitalize(params.associationName)}`;
  const fn = (instance as any)[methodName];
  if (typeof fn !== 'function') {
    throw new Error(
      `Association creator "${methodName}" not found on model "${params.sourceModel}"`,
    );
  }

  const result = await fn.call(instance, params.data || {}, params.options || {});
  return toModelResponse(result);
}

