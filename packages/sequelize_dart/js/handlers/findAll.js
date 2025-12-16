const { convertQueryOptions } = require('../utils/queryConverter');
const { getSequelize, getModels } = require('../utils/state');

/**
 * Handler for 'findAll' method
 * Finds all records matching the query
 */
async function handleFindAll(params) {
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

  const results = await model.findAll(options);
  return results.map(row => row.toJSON());
}

module.exports = {
  handleFindAll,
};

