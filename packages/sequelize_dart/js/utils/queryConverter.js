const { Op } = require('@sequelize/core');

/**
 * Convert Dart query operators to Sequelize Op operators
 */
function convertWhereClause(where) {
  if (!where || typeof where !== 'object') {
    return where;
  }

  // Handle logical operators ($and, $or, $not)
  if ('$and' in where) {
    return {
      [Op.and]: where.$and.map(convertWhereClause),
    };
  }
  if ('$or' in where) {
    return {
      [Op.or]: where.$or.map(convertWhereClause),
    };
  }
  if ('$not' in where) {
    return {
      [Op.not]: where.$not.map(convertWhereClause),
    };
  }

  // Handle comparison operators
  const result = {};
  for (const [key, value] of Object.entries(where)) {
    if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      // Check for operator objects like {$ne: value}
      const converted = {};
      for (const [opKey, opValue] of Object.entries(value)) {
        switch (opKey) {
          case '$ne':
            converted[Op.ne] = opValue;
            break;
          case '$gt':
            converted[Op.gt] = opValue;
            break;
          case '$gte':
            converted[Op.gte] = opValue;
            break;
          case '$lt':
            converted[Op.lt] = opValue;
            break;
          case '$lte':
            converted[Op.lte] = opValue;
            break;
          case '$like':
            converted[Op.like] = opValue;
            break;
          case '$ilike':
            converted[Op.iLike] = opValue;
            break;
          case '$in':
            converted[Op.in] = opValue;
            break;
          case '$notIn':
            converted[Op.notIn] = opValue;
            break;
          default:
            converted[opKey] = opValue;
        }
      }
      result[key] = Object.keys(converted).length > 0 ? converted : value;
    } else {
      // Simple equality
      result[key] = value;
    }
  }

  return result;
}

/**
 * Convert query options from Dart format to Sequelize format
 */
function convertQueryOptions(options) {
  if (!options) {
    return {};
  }

  const result = {};

  if (options.where) {
    result.where = convertWhereClause(options.where);
  }

  if (options.include) {
    result.include = options.include;
  }

  if (options.order) {
    result.order = options.order;
  }

  if (options.limit !== undefined) {
    result.limit = options.limit;
  }

  if (options.offset !== undefined) {
    result.offset = options.offset;
  }

  return result;
}

module.exports = {
  convertQueryOptions,
  convertWhereClause,
};

