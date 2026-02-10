import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { getModels, getSequelize } from '../utils/state';

type InstanceDestroyParams = {
  model: string;
  primaryKeyValues: Record<string, any>;
  options?: {
    force?: boolean;
  };
};

export async function handleInstanceDestroy(params: InstanceDestroyParams): Promise<void> {
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

  const options = params.options || {};

  // Instance.destroy returns void
  await instance.destroy(options);
}
