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
  
  // Decrement returns [affectedRows, affectedCount] where affectedRows can be:
  // - Array of Model instances (PostgreSQL with RETURNING)
  // - Array containing an array of plain objects [[{...}]]
  // We need to handle both cases
  let rows = result[0];
  
  // If first element is an array, unwrap it (some dialects wrap results)
  if (Array.isArray(rows) && rows.length > 0 && Array.isArray(rows[0])) {
    rows = rows[0];
  }
  
  // Check if we have Model instances or plain objects
  if (rows.length > 0 && typeof rows[0]?.toJSON === 'function') {
    // Model instances - use the standard converter
    return toModelResponseArray(rows);
  }
  
  // Plain objects - wrap them in the response format
  return rows.map((row: any) => ({
    data: row,
    previous: {},
    changed: false,
    isNewRecord: false,
  }));
}
