const { DataTypes } = require('@sequelize/core');

// Data type mapping from Dart enum to Sequelize DataTypes
const dataTypeMap = {
  STRING: DataTypes.STRING,
  TEXT: DataTypes.TEXT,
  INTEGER: DataTypes.INTEGER,
  BIGINT: DataTypes.BIGINT,
  FLOAT: DataTypes.FLOAT,
  DOUBLE: DataTypes.DOUBLE,
  DECIMAL: DataTypes.DECIMAL,
  BOOLEAN: DataTypes.BOOLEAN,
  DATE: DataTypes.DATE,
  DATEONLY: DataTypes.DATEONLY,
  UUID: DataTypes.UUID,
  JSON: DataTypes.JSON,
  JSONB: DataTypes.JSONB,
};

/**
 * Convert Dart attribute definition to Sequelize attribute
 */
function convertAttribute(attrDef) {
  const sequelizeType = dataTypeMap[attrDef.type];
  if (!sequelizeType) {
    throw new Error(`Unknown data type: ${attrDef.type}`);
  }

  return {
    type: sequelizeType,
    primaryKey: attrDef.primaryKey || false,
    autoIncrement: attrDef.autoIncrement || false,
    allowNull: !(attrDef.notNull || false),
    defaultValue: attrDef.defaultValue,
  };
}

/**
 * Convert Dart attributes map to Sequelize attributes
 */
function convertAttributes(attributes) {
  const result = {};
  for (const [key, value] of Object.entries(attributes)) {
    result[key] = convertAttribute(value);
  }
  return result;
}

module.exports = {
  convertAttributes,
  convertAttribute,
};

