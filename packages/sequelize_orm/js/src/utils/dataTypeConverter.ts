import { DataTypes } from '@sequelize/core';

const dataTypeMap: Record<string, any> = {
  STRING: DataTypes.STRING,
  CHAR: DataTypes.CHAR,
  TEXT: DataTypes.TEXT,
  TINYINT: DataTypes.TINYINT,
  SMALLINT: DataTypes.SMALLINT,
  MEDIUMINT: DataTypes.MEDIUMINT,
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
  BLOB: DataTypes.BLOB,
  NOW: DataTypes.NOW,
};

function buildSequelizeType(attrDef: any): any {
  const baseType = dataTypeMap[attrDef.type];
  if (!baseType) {
    throw new Error(`Unknown data type: ${attrDef.type}`);
  }

  let type = baseType;

  const hasLength = typeof attrDef.length === 'number';
  const hasScale = typeof attrDef.scale === 'number';
  const hasVariant =
    typeof attrDef.variant === 'string' && attrDef.variant.length > 0;

  if (hasVariant && (attrDef.type === 'TEXT' || attrDef.type === 'BLOB')) {
    type = baseType(attrDef.variant);
  } else if (hasLength && hasScale) {
    type = baseType(attrDef.length, attrDef.scale);
  } else if (hasLength) {
    type = baseType(attrDef.length);
  }

  if (attrDef.unsigned && type?.UNSIGNED) {
    type = type.UNSIGNED;
  }
  if (attrDef.zerofill && type?.ZEROFILL) {
    type = type.ZEROFILL;
  }
  if (attrDef.binary && type?.BINARY) {
    type = type.BINARY;
  }

  return type;
}

export function convertAttribute(attrDef: any): any {
  const result: any = {
    type: buildSequelizeType(attrDef),
  };

  if (attrDef.primaryKey !== undefined && attrDef.primaryKey !== null) {
    result.primaryKey = attrDef.primaryKey;
  }
  if (attrDef.autoIncrement !== undefined && attrDef.autoIncrement !== null) {
    result.autoIncrement = attrDef.autoIncrement;
  }
  if (
    attrDef.autoIncrementIdentity !== undefined &&
    attrDef.autoIncrementIdentity !== null
  ) {
    result.autoIncrementIdentity = attrDef.autoIncrementIdentity;
  }

  result.allowNull = attrDef.allowNull !== undefined ? attrDef.allowNull : true;

  if (attrDef.defaultValue !== undefined && attrDef.defaultValue !== null) {
    result.defaultValue = attrDef.defaultValue;
  }

  if (attrDef.columnName !== undefined && attrDef.columnName !== null) {
    result.field = attrDef.columnName;
  }

  if (attrDef.unique !== undefined && attrDef.unique !== null) {
    result.unique = attrDef.unique;
  }

  if (attrDef.comment !== undefined && attrDef.comment !== null) {
    result.comment = attrDef.comment;
  }

  if (attrDef.validate !== undefined && attrDef.validate !== null) {
    result.validate = attrDef.validate;
  }

  return result;
}

export function extractIndexes(attributes: Record<string, any>): any[] {
  const indexes: any[] = [];

  for (const [attrName, attrDef] of Object.entries(attributes)) {
    if (attrDef.index !== undefined && attrDef.index !== null) {
      if (attrDef.index === true) {
        indexes.push({
          fields: [attrName],
        });
      } else if (typeof attrDef.index === 'string') {
        let existingIndex = indexes.find((idx) => idx.name === attrDef.index);
        if (existingIndex) {
          existingIndex.fields.push(attrName);
        } else {
          indexes.push({
            name: attrDef.index,
            fields: [attrName],
          });
        }
      } else if (typeof attrDef.index === 'object') {
        const indexDef: any = {
          fields: [attrName],
        };

        if (attrDef.index.name) {
          let existingIndex = indexes.find(
            (idx) => idx.name === attrDef.index.name,
          );
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

export function convertAttributes(attributes: Record<string, any>): any {
  const result: any = {};
  for (const [key, value] of Object.entries(attributes)) {
    result[key] = convertAttribute(value);
  }
  return result;
}
