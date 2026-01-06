import Sequelize, { ModelStatic } from "@sequelize/core";

let sequelize: Sequelize | null = null;
const models = new Map<string, ModelStatic>();

let options: { hoistIncludeOptions: boolean } = {
  hoistIncludeOptions: false,
};

export function getOptions(): { hoistIncludeOptions: boolean } {
  return options;
}

export function setOptions(newOptions: Partial<{ hoistIncludeOptions: boolean }>): void {
  options = { ...options, ...newOptions };
}

export function getSequelize(): Sequelize {
  return sequelize;
}

export function setSequelize(instance: Sequelize): void {
  sequelize = instance;
}

export function getModels(): Map<string, ModelStatic> {
  return models;
}

export function clearState(): void {
  if (sequelize) {
    sequelize = null;
  }
  models.clear();
}
