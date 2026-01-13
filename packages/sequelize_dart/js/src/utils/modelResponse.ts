import { Model } from '@sequelize/core';

/**
 * Standard response format for model instances
 * Contains the data along with Sequelize instance metadata
 */
export interface ModelResponse {
  /** The model data as JSON */
  data: Record<string, any>;
  // TODO: Enable isNewRecord, changed & previous
  // previous?: Record<string, any>;
  // changed?: string[] | false;
  // isNewRecord?: boolean;
}

/**
 * Converts a Sequelize model instance to a standard response format
 * TODO: Enable isNewRecord, changed & previous
 */
export function toModelResponse(instance: Model): ModelResponse {
  return {
    data: instance.toJSON(),
    // TODO: Enable isNewRecord, changed & previous
    // previous: instance.previous ? instance.previous() : {},
    // changed: instance.changed ? instance.changed() : false,
    // isNewRecord: instance.isNewRecord ?? false,
  };
}

/**
 * Converts an array of Sequelize model instances to standard response format
 */
export function toModelResponseArray(instances: Model[] | any[]): ModelResponse[] {
  return instances.map(toModelResponse);
}
