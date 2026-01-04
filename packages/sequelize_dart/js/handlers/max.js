const { convertQueryOptions } = require('../utils/queryConverter');
const { getSequelize, getModels } = require('../utils/state');

/**
 * Handler for 'max' method
 * Finds the maximum value of a column
 */
async function handleMax(params) {
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
    throw new Error('Column name is required for max operation');
  }

  const max = await model.max(column, options);
  return max;
}

module.exports = {
  handleMax,
};
