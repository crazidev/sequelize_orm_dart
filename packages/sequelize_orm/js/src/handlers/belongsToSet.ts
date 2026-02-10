import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { getModels, getSequelize } from '../utils/state';

type BelongsToSetParams = {
  sourceModel: string;
  primaryKeyValues: Record<string, any>;
  associationName: string;
  targetOrKey: any;
  save?: boolean;
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

export async function handleBelongsToSet(
  params: BelongsToSetParams,
): Promise<{ set: true }> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const models = getModels();
  const source = models.get(params.sourceModel);
  checkModelDefinition(source, params.sourceModel);

  const where = compactWhere(params.primaryKeyValues);
  const instance = await source.findOne({ where });
  if (!instance) {
    throw new Error(
      `Cannot set belongsTo association: instance of "${params.sourceModel}" not found for provided primary key values`,
    );
  }

  const methodName = `set${capitalize(params.associationName)}`;
  const fn = (instance as any)[methodName];
  if (typeof fn !== 'function') {
    throw new Error(
      `Association setter "${methodName}" not found on model "${params.sourceModel}"`,
    );
  }

  const options = { ...(params.options || {}) };
  if (params.save !== undefined && params.save !== null) {
    options.save = params.save;
  }

  await fn.call(instance, params.targetOrKey, options);
  return { set: true };
}

