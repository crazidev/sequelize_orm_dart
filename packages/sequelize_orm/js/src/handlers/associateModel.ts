import { cleanOptions } from '../utils/cleanOptions';
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
  const { sourceModel, targetModel, associationType } = params;

  const source = models.get(sourceModel);
  const target = models.get(targetModel);

  if (!source) {
    throw new Error(`Source model "${sourceModel}" not found. Define it first.`);
  }

  if (!target) {
    throw new Error(`Target model "${targetModel}" not found. Define it first.`);
  }

  const opts = cleanOptions(params.options);

  // In Sequelize v7, hasOne/hasMany auto-create the inverse belongsTo.
  // Skip if the alias is already registered on the source model.
  const alias = opts.as;
  if (alias && (source as any).associations?.[alias]) {
    return { associated: true };
  }

  switch (associationType) {
    case 'hasOne':
      source.hasOne(target, opts);
      break;
    case 'hasMany':
      source.hasMany(target, opts);
      break;
    case 'belongsTo':
      source.belongsTo(target, opts);
      break;
    default:
      throw new Error(`Unknown association type: ${associationType}`);
  }

  return { associated: true };
}
