const { convertAttributes, extractIndexes } = require('../utils/dataTypeConverter');
const { getSequelize, getModels } = require('../utils/state');

/**
 * Handler for 'defineModel' method
 * Defines a Sequelize model
 */
async function handleDefineModel(params) {
  const sequelize = getSequelize();
  if (!sequelize) {
    throw new Error('Not connected. Call connect first.');
  }

  const { name, attributes, options } = params;
  const sequelizeAttributes = convertAttributes(attributes);

  // Extract indexes from attributes
  const attributeIndexes = extractIndexes(attributes);

  // Merge indexes from attributes with options indexes
  const finalOptions = { ...(options || {}) };
  if (attributeIndexes.length > 0) {
    finalOptions.indexes = [
      ...(finalOptions.indexes || []),
      ...attributeIndexes,
    ];
  }

  const models = getModels();
  const model = sequelize.define(name, sequelizeAttributes, finalOptions);
  models.set(name, model);

  return { defined: true };
}

module.exports = {
  handleDefineModel,
};

