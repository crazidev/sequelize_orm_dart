import { Model } from '@sequelize/core';
import { printLogs } from './printLogs';

/**
 * Standard response format for model instances
 * Contains the data along with Sequelize instance metadata
 */
export interface ModelResponse {
  /** The model data as JSON */
  data: Record<string, any>;
  /** Previous values before any changes (from _previousDataValues) */
  previous: Record<string, any>;
  /** List of changed field names, or false if no changes */
  changed: string[] | false;
  /** True if this instance has not been persisted to the database */
  isNewRecord: boolean;
}

/**
 * Converts a Sequelize model instance to a standard response format
 *
 * NOTE: `changed()` and `previous()` are temporarily disabled for testing.
 *
 * Implementation details:
 * - `instance.changed()` returns `false` if no changes, or `string[]` of changed field names
 * - `instance.previous()` returns `Partial<TModelAttributes>` with previous values
 * - These methods work on Sequelize model instances that have been loaded from DB
 * - For newly created instances or instances from increment/decrement with RETURNING,
 *   the metadata may not be available or may need special handling
 *
 * TODO: Test and enable `changed()` and `previous()`:
 * 1. Test with findAll() - should work as instances are loaded from DB
 * 2. Test with findOne() - should work as instances are loaded from DB
 * 3. Test with create() - may need special handling for new records
 * 4. Test with increment/decrement - may return plain objects, not model instances
 * 5. Verify the Dart side correctly handles both `false` and `string[]` for `changed`
 * 6. Verify the Dart side correctly handles empty `{}` and populated maps for `previous`
 */
export function toModelResponse(instance: Model): ModelResponse {
  // Debug: log what changed() returns to understand the structure
  printLogs(instance.changed());

  return {
    data: instance.toJSON(),
    // TODO: Enable once testing confirms it works correctly
    // Previous values from Sequelize's _previousDataValues
    // Returns a partial object with only changed fields' previous values
    previous: {}, // instance.previous ? instance.previous() : {},
    // TODO: Enable once testing confirms it works correctly
    // Changed fields - returns false if no changes, or array of field names
    // This tracks which fields have been modified since the instance was loaded
    changed: false, // instance.changed ? instance.changed() : false,
    isNewRecord: instance.isNewRecord ?? false,
  };
}

/**
 * Converts an array of Sequelize model instances to standard response format
 */
export function toModelResponseArray(instances: Model[] | any[]): ModelResponse[] {
  return instances.map(toModelResponse);
}
