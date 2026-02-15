import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { printLogs } from '../utils/printLogs';
import { getModels, getSequelize } from '../utils/state';
import { Model } from '@sequelize/core';

type SaveParams = {
  model: string;
  currentData: Record<string, any>;
  previousData: Record<string, any> | null;
  primaryKeyValues: Record<string, any>;
  options?: any;
};

export async function handleSave(params: SaveParams): Promise<Record<string, any>> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const ModelClass = getModels().get(modelName);
  checkModelDefinition(ModelClass, modelName);

  const currentData = params.currentData;
  const previousData = params.previousData;
  const primaryKeyValues = params.primaryKeyValues;

  // Get the set of valid attribute names for this model.
  // This filters out association keys (e.g. 'user', 'postDetails') that would
  // confuse Sequelize's build() / set() and cause FK constraint errors.
  // Try multiple ways to get attributes for Sequelize v7 compatibility.
  const modelAttributes =
    (ModelClass as any).getAttributes?.() ??
    (ModelClass as any).rawAttributes ??
    (ModelClass as any).modelDefinition?.attributes ??
    {};
  // modelAttributes can be a Map (v7) or a plain object
  const validKeys = modelAttributes instanceof Map
    ? new Set(modelAttributes.keys())
    : new Set(Object.keys(modelAttributes));

  function filterAttributes(data: Record<string, any>): Record<string, any> {
    const filtered: Record<string, any> = {};
    for (const key of Object.keys(data)) {
      if (validKeys.has(key)) {
        filtered[key] = data[key];
      }
    }
    return filtered;
  }

  const filteredCurrent = filterAttributes(currentData);
  const filteredPrevious = previousData ? filterAttributes(previousData) : null;

  // Determine if this is a new record (no previousData means it's new)
  const isNewRecord = !filteredPrevious || Object.keys(filteredPrevious).length === 0;

  if (isNewRecord) {
    // Create new record using Sequelize's create
    const instance = await ModelClass.create(filteredCurrent, params.options || {});
    return {
      data: (instance && instance.toJSON()) || {},
      isNewRecord: true,
    };
  } else {
    // Update existing record
    // Build instance from filtered data with isNewRecord: false
    // This tells Sequelize this is an existing record that should be updated
    const instance = ModelClass.build(filteredCurrent, {
      isNewRecord: false,
    });

    // Set _previousDataValues to the previous data snapshot
    // Sequelize uses _previousDataValues to compare with dataValues to determine changed fields
    // After build(), _previousDataValues is initialized to match dataValues,
    // so we need to override it with the actual previous values
    if (filteredPrevious) {
      // Copy all previous values into _previousDataValues
      // This ensures Sequelize can properly detect what has changed
      (instance as any)._previousDataValues = { ...filteredPrevious };

      // Also ensure dataValues contains all fields from filteredCurrent
      // Sequelize will compare dataValues (current) with _previousDataValues (previous)
      for (const key of Object.keys(filteredCurrent)) {
        instance.set(key, filteredCurrent[key], { raw: true });
      }
    }

    // Save the instance
    // Sequelize's save() will:
    // - Compare dataValues to _previousDataValues to determine changed fields
    // - Only update changed fields in the database
    // - Perform UPDATE since isNewRecord is false
    const savedInstance = await instance.save(params.options || {});
    return {
      data: savedInstance.toJSON(),
      isNewRecord: false,
    };
  }
}
