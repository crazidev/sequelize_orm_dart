/**
 * Global state management for Sequelize bridge server
 * This module manages the sequelize instance and models map
 */

let sequelize = null;
const models = new Map();

/**
 * Get the current Sequelize instance
 */
function getSequelize() {
  return sequelize;
}

/**
 * Set the Sequelize instance
 */
function setSequelize(instance) {
  sequelize = instance;
}

/**
 * Get the models map
 */
function getModels() {
  return models;
}

/**
 * Clear all state (sequelize and models)
 */
function clearState() {
  if (sequelize) {
    sequelize = null;
  }
  models.clear();
}

module.exports = {
  getSequelize,
  setSequelize,
  getModels,
  clearState,
};

