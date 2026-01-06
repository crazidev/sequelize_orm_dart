let sequelize: any = null;
const models = new Map<string, any>();
let options: { hoistIncludeOptions: boolean } = {
  hoistIncludeOptions: false,
};

export function getOptions(): { hoistIncludeOptions: boolean } {
  return options;
}

export function setOptions(newOptions: Partial<{ hoistIncludeOptions: boolean }>): void {
  options = { ...options, ...newOptions };
}

export function getSequelize(): any {
  return sequelize;
}

export function setSequelize(instance: any): void {
  sequelize = instance;
}

export function getModels(): Map<string, any> {
  return models;
}

export function clearState(): void {
  if (sequelize) {
    sequelize = null;
  }
  models.clear();
}
