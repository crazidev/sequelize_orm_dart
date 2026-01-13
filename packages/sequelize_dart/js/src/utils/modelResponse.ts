import { Model } from '@sequelize/core';

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
 */
export function toModelResponse(instance: Model | any): ModelResponse {
  return {
    data: instance.toJSON(),
    previous: instance.previous ? instance.previous() : {},
    changed: instance.changed ? instance.changed() : false,
    isNewRecord: instance.isNewRecord ?? false,
  };
}

/**
 * Converts an array of Sequelize model instances to standard response format
 */
export function toModelResponseArray(instances: Model[] | any[]): ModelResponse[] {
  return instances.map(toModelResponse);
}
