/**
 * Validates input values for metrics calculation
 * @param {number} deployments - Number of deployments
 * @param {number} failures - Number of failures
 * @returns {boolean} True if inputs are valid
 */
function validateInput(deployments, failures) {
  return (
    typeof deployments === 'number' &&
    typeof failures === 'number' &&
    deployments >= 0 &&
    failures >= 0 &&
    failures <= deployments
  );
}

/**
 * Calculates deployment metrics
 * @param {number} deployments - Total number of deployments
 * @param {number} failures - Number of failed deployments
 * @returns {object} Calculated metrics
 */
function calculateMetrics(deployments, failures) {
  const successRate = deployments > 0 ? ((deployments - failures) / deployments) * 100 : 0;
  const failureRate = deployments > 0 ? (failures / deployments) * 100 : 0;

  return {
    totalDeployments: deployments,
    successfulDeployments: deployments - failures,
    failedDeployments: failures,
    successRate: parseFloat(successRate.toFixed(2)),
    failureRate: parseFloat(failureRate.toFixed(2))
  };
}

/**
 * Formats a timestamp to ISO string
 * @param {Date} date - Date object to format
 * @returns {string} ISO formatted date string
 */
function formatTimestamp(date) {
  return date.toISOString();
}

module.exports = {
  validateInput,
  calculateMetrics,
  formatTimestamp
};
