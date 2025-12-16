const { convertAttributes } = require('../utils/dataTypeConverter');
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

  const models = getModels();
  const model = sequelize.define(name, sequelizeAttributes, options || {});
  models.set(name, model);

  return { defined: true };
}

module.exports = {
  handleDefineModel,
};

