const { getModels } = require('../utils/state');

/**
 * Handler for 'associateModel' method
 * Sets up associations between Sequelize models (hasOne, hasMany, etc.)
 */
async function handleAssociateModel(params) {
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

  // Set up the association based on type
  switch (associationType) {
    case 'hasOne':
      source.hasOne(target, options || {});
      break;
    case 'hasMany':
      source.hasMany(target, options || {});
      break;
    default:
      throw new Error(`Unknown association type: ${associationType}`);
  }

  // Note: Associations are stored in source.associations with the alias as the key
  // If 'as' is provided, that's the key; otherwise it might be the model name
  // We don't verify here as Sequelize handles the storage internally

  return { associated: true };
}

module.exports = {
  handleAssociateModel,
};
