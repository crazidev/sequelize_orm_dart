const { convertQueryOptions } = require('../utils/queryConverter');
const { getSequelize, getModels } = require('../utils/state');

/**
 * Handler for 'count' method
 * Counts records matching the query
 */
async function handleCount(params) {
  const sequelize = getSequelize();
  if (!sequelize) {
    throw new Error('Not connected. Call connect first.');
  }

  const modelName = params.model;
  const options = convertQueryOptions(params.options || {});
  const models = getModels();
  const model = models.get(modelName);

  if (!model) {
    throw new Error(`Model "${modelName}" not found. Define it first.`);
  }

  const count = await model.count(options);
  return count;
}

module.exports = {
  handleCount,
};
