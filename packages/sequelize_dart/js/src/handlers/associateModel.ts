import { getModels } from '../utils/state';

type AssociateModelParams = {
  sourceModel: string;
  targetModel: string;
  associationType: string;
  options?: any;
};

export async function handleAssociateModel(
  params: AssociateModelParams,
): Promise<{ associated: true }> {
  const models = getModels();
  const { sourceModel, targetModel, associationType, options } = params;

  const source = models.get(sourceModel);
  const target = models.get(targetModel);

  if (!source) {
    throw new Error(`Source model "${sourceModel}" not found. Define it first.`);
  }

  if (!target) {
    throw new Error(`Target model "${targetModel}" not found. Define it first.`);
  }

  switch (associationType) {
    case 'hasOne':
      source.hasOne(target, options || {});
      break;
    case 'hasMany':
      source.hasMany(target, options || {});
      break;
    case 'belongsTo':
      source.belongsTo(target, options || {});
      break;
    default:
      throw new Error(`Unknown association type: ${associationType}`);
  }

  return { associated: true };
}
