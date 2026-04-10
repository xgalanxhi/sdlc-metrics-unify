const { validateInput, calculateMetrics, formatTimestamp } = require('../src/utils');

describe('validateInput', () => {
  test('should return true for valid inputs', () => {
    expect(validateInput(10, 2)).toBe(true);
    expect(validateInput(0, 0)).toBe(true);
    expect(validateInput(100, 5)).toBe(true);
  });

  test('should return false for invalid inputs', () => {
    expect(validateInput(-1, 0)).toBe(false);
    expect(validateInput(10, -1)).toBe(false);
    expect(validateInput(5, 10)).toBe(false);
    expect(validateInput('10', 2)).toBe(false);
    expect(validateInput(10, '2')).toBe(false);
  });
});

describe('calculateMetrics', () => {
  test('should calculate metrics correctly for typical values', () => {
    const result = calculateMetrics(100, 5);
    expect(result.totalDeployments).toBe(100);
    expect(result.successfulDeployments).toBe(95);
    expect(result.failedDeployments).toBe(5);
    expect(result.successRate).toBe(95.00);
    expect(result.failureRate).toBe(5.00);
  });

  test('should handle zero deployments', () => {
    const result = calculateMetrics(0, 0);
    expect(result.totalDeployments).toBe(0);
    expect(result.successfulDeployments).toBe(0);
    expect(result.failedDeployments).toBe(0);
    expect(result.successRate).toBe(0);
    expect(result.failureRate).toBe(0);
  });

  test('should handle all successful deployments', () => {
    const result = calculateMetrics(50, 0);
    expect(result.successRate).toBe(100.00);
    expect(result.failureRate).toBe(0);
  });

  test('should round percentages to 2 decimal places', () => {
    const result = calculateMetrics(3, 1);
    expect(result.successRate).toBe(66.67);
    expect(result.failureRate).toBe(33.33);
  });
});

describe('formatTimestamp', () => {
  test('should format date to ISO string', () => {
    const date = new Date('2024-01-15T10:30:00Z');
    const result = formatTimestamp(date);
    expect(result).toBe('2024-01-15T10:30:00.000Z');
  });

  test('should handle current date', () => {
    const date = new Date();
    const result = formatTimestamp(date);
    expect(result).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/);
  });
});
