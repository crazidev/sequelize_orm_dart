const { getSequelize, clearState } = require('../utils/state');

/**
 * Handler for 'close' method
 * Closes the database connection and clears state
 */
async function handleClose() {
  const sequelize = getSequelize();
  if (sequelize) {
    await sequelize.close();
    clearState();
  }
  return { closed: true };
}

module.exports = {
  handleClose,
};

