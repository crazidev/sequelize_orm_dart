const { convertQueryOptions } = require('../utils/queryConverter');
const { getSequelize, getModels } = require('../utils/state');

/**
 * Handler for 'min' method
 * Finds the minimum value of a column
 */
async function handleMin(params) {
  const sequelize = getSequelize();
  if (!sequelize) {
    throw new Error('Not connected. Call connect first.');
  }

  const modelName = params.model;
  const column = params.column;
  const options = convertQueryOptions(params.options || {});
  const models = getModels();
  const model = models.get(modelName);

  if (!model) {
    throw new Error(`Model "${modelName}" not found. Define it first.`);
  }

  if (!column) {
    throw new Error('Column name is required for min operation');
  }

  const min = await model.min(column, options);
  return min;
}

module.exports = {
  handleMin,
};
