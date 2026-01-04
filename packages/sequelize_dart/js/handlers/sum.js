const { convertQueryOptions } = require('../utils/queryConverter');
const { getSequelize, getModels } = require('../utils/state');

/**
 * Handler for 'sum' method
 * Sums values of a column
 */
async function handleSum(params) {
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
    throw new Error('Column name is required for sum operation');
  }

  const sum = await model.sum(column, options);
  return sum;
}

module.exports = {
  handleSum,
};
