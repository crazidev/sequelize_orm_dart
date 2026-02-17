/**
 * Strip null/undefined values from an options object so that
 * Sequelize v7 treats them as "not set" rather than explicit null.
 */
export function cleanOptions(opts: any): any {
  if (!opts || typeof opts !== 'object') return {};
  const cleaned: any = {};
  for (const [k, v] of Object.entries(opts)) {
    if (v !== null && v !== undefined) {
      cleaned[k] = v;
    }
  }
  return cleaned;
}
