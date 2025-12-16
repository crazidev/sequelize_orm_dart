/**
 * Handler for 'ready' method
 * Returns a ready status
 */
async function handleReady() {
  return { ready: true };
}

module.exports = {
  handleReady,
};

