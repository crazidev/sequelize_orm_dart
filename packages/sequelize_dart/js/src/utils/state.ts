import Sequelize, { ModelStatic } from "@sequelize/core";

let sequelize: Sequelize | null = null;
const models = new Map<string, ModelStatic>();

let options: { hoistIncludeOptions: boolean } = {
  hoistIncludeOptions: false,
};

// Notification callback for SQL logging
// Set by bridge_server.ts (stdio) or bridge_server_worker.ts (Worker Thread)
let notificationCallback: ((notification: any) => void) | null = null;

export function setNotificationCallback(callback: (notification: any) => void): void {
  notificationCallback = callback;
}

export function sendNotification(notification: any): void {
  if (notificationCallback) {
    notificationCallback(notification);
  }
}

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
