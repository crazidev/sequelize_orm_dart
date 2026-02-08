import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';
import { toModelResponseArray, ModelResponse } from '../utils/modelResponse';

type DecrementParams = {
  model: string;
  fields: Record<string, number>;
  query?: any;
};

export async function handleDecrement(params: DecrementParams): Promise<ModelResponse[]> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const fields = params.fields;
  const options = convertQueryOptions(params.query || {});

  const models = getModels();
  const model = models.get(modelName);
  checkModelDefinition(model, modelName);

  if (!fields || Object.keys(fields).length === 0) {
    throw new Error('Fields are required for decrement operation');
  }

  const result = await model.decrement(fields, options);

  // result is typically [affectedRows, affectedCount]
  if (!result || !Array.isArray(result)) {
    return [];
  }

  let rows = result[0];

  // If rows is an affected count (number/bigint/null), MySQL doesn't return updated rows (expected).
  // Returning [] keeps the bridge JSON-safe (BigInt cannot be JSON-stringified).
  if (rows === null || rows === undefined || typeof rows === 'number' || typeof rows === 'bigint') {
    return [];
  }

  // If first element is an array, unwrap it (some dialects wrap results)
  if (Array.isArray(rows) && rows.length > 0 && Array.isArray(rows[0])) {
    rows = rows[0];
  }

  // Ensure rows is an array for mapping
  if (!Array.isArray(rows)) {
    rows = [rows];
  }

  // Use shared converter; it filters out non-object values (e.g. BigInt) to keep JSON serialization safe.
  return toModelResponseArray(rows);
}
