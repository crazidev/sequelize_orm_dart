const { getSequelize, getModels } = require('../utils/state');

/**
 * Handler for 'create' method
 * Creates a new record
 */
async function handleCreate(params) {
  const sequelize = getSequelize();
  if (!sequelize) {
    throw new Error('Not connected. Call connect first.');
  }

  const modelName = params.model;
  const data = params.data || {};
  const models = getModels();
  const model = models.get(modelName);

  if (!model) {
    throw new Error(`Model "${modelName}" not found. Define it first.`);
  }

  const result = await model.create(data);
  return result.toJSON();
}

module.exports = {
  handleCreate,
};

