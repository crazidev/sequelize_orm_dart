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

  const result = {
    type: sequelizeType,
  };

  // Primary key and auto increment
  if (attrDef.primaryKey !== undefined && attrDef.primaryKey !== null) {
    result.primaryKey = attrDef.primaryKey;
  }
  if (attrDef.autoIncrement !== undefined && attrDef.autoIncrement !== null) {
    result.autoIncrement = attrDef.autoIncrement;
  }
  if (attrDef.autoIncrementIdentity !== undefined && attrDef.autoIncrementIdentity !== null) {
    result.autoIncrementIdentity = attrDef.autoIncrementIdentity;
  }

  // Allow null - default to true if not specified
  result.allowNull = attrDef.allowNull !== undefined ? attrDef.allowNull : true;

  // Default value
  if (attrDef.defaultValue !== undefined && attrDef.defaultValue !== null) {
    result.defaultValue = attrDef.defaultValue;
  }

  // Column name (maps to 'field' in Sequelize)
  if (attrDef.columnName !== undefined && attrDef.columnName !== null) {
    result.field = attrDef.columnName;
  }

  // Unique constraint
  if (attrDef.unique !== undefined && attrDef.unique !== null) {
    result.unique = attrDef.unique;
  }

  // Comment
  if (attrDef.comment !== undefined && attrDef.comment !== null) {
    result.comment = attrDef.comment;
  }

  // Validation
  if (attrDef.validate !== undefined && attrDef.validate !== null) {
    result.validate = attrDef.validate;
  }

  return result;
}

/**
 * Extract indexes from attributes for model options
 * Sequelize handles indexes at model level, not attribute level
 */
function extractIndexes(attributes) {
  const indexes = [];

  for (const [attrName, attrDef] of Object.entries(attributes)) {
    if (attrDef.index !== undefined && attrDef.index !== null) {
      if (attrDef.index === true) {
        // Simple index on this column
        indexes.push({
          fields: [attrName],
        });
      } else if (typeof attrDef.index === 'string') {
        // Named composite index - find or create
        let existingIndex = indexes.find(idx => idx.name === attrDef.index);
        if (existingIndex) {
          existingIndex.fields.push(attrName);
        } else {
          indexes.push({
            name: attrDef.index,
            fields: [attrName],
          });
        }
      } else if (typeof attrDef.index === 'object') {
        // Index with options
        const indexDef = {
          fields: [attrName],
        };
        if (attrDef.index.name) {
          // Named composite index
          let existingIndex = indexes.find(idx => idx.name === attrDef.index.name);
          if (existingIndex) {
            existingIndex.fields.push(attrName);
          } else {
            indexDef.name = attrDef.index.name;
            indexes.push(indexDef);
          }
        } else {
          indexes.push(indexDef);
        }
      }
    }
  }

  return indexes;
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
  extractIndexes,
};

