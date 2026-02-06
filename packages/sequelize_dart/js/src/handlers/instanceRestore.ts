import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { getModels, getSequelize } from '../utils/state';

type InstanceRestoreParams = {
  model: string;
  primaryKeyValues: Record<string, any>;
};

export async function handleInstanceRestore(params: InstanceRestoreParams): Promise<void> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const primaryKeyValues = params.primaryKeyValues;

  const models = getModels();
  const ModelClass = models.get(modelName);
  checkModelDefinition(ModelClass, modelName);

  // Build the instance from primary key values
  const instance = ModelClass.build(primaryKeyValues, {
    isNewRecord: false,
  });

  // Instance.restore returns void
  await instance.restore();
}
