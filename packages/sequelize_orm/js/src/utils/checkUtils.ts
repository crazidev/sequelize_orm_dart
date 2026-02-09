import Sequelize, { ModelStatic } from "@sequelize/core";

export function checkConnection(sequelize: Sequelize) {
    if (!sequelize) {
        throw new Error('Not connected. Call connect first.');
    }
}

export function checkModelDefinition(model: ModelStatic, modelName: string) {
    if (!model) {
        throw new Error(`Model "${modelName}" not found. Define it first.`);
    }
}