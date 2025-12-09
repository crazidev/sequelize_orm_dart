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
  // This handles structures like { id: { '$gt': 1 } } or { id: 1 }
  const result = {};
  for (const [key, value] of Object.entries(where)) {
    if (typeof value === 'object' && value !== null && !Array.isArray(value)) {
      // Check if this is an operator object like {$ne: value, $gt: value}
      const hasOperatorKeys = Object.keys(value).some(
        (k) => k.startsWith('$') && k !== '$and' && k !== '$or' && k !== '$not',
      );

      if (hasOperatorKeys) {
        // Convert operator keys to Sequelize Op
        const converted = {};
        for (const [opKey, opValue] of Object.entries(value)) {
          switch (opKey) {
            // Basic operators
            case '$ne':
              converted[Op.ne] = opValue;
              break;
            case '$is':
              converted[Op.is] = opValue;
              break;
            case '$not':
              converted[Op.not] = opValue;
              break;

            // Number comparison operators
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
            case '$between':
              converted[Op.between] = opValue;
              break;
            case '$notBetween':
              converted[Op.notBetween] = opValue;
              break;

            // List operators
            case '$in':
              converted[Op.in] = opValue;
              break;
            case '$notIn':
              converted[Op.notIn] = opValue;
              break;
            case '$all':
              converted[Op.all] = opValue;
              break;
            case '$any':
              converted[Op.any] = opValue;
              break;

            // String operators
            case '$like':
              converted[Op.like] = opValue;
              break;
            case '$notLike':
              converted[Op.notLike] = opValue;
              break;
            case '$startsWith':
              converted[Op.startsWith] = opValue;
              break;
            case '$endsWith':
              converted[Op.endsWith] = opValue;
              break;
            case '$substring':
              converted[Op.substring] = opValue;
              break;
            case '$ilike':
              converted[Op.iLike] = opValue;
              break;
            case '$notILike':
              converted[Op.notILike] = opValue;
              break;

            // Regex operators
            case '$regexp':
              converted[Op.regexp] = opValue;
              break;
            case '$notRegexp':
              converted[Op.notRegexp] = opValue;
              break;
            case '$iRegexp':
              converted[Op.iRegexp] = opValue;
              break;
            case '$notIRegexp':
              converted[Op.notIRegexp] = opValue;
              break;

            // Other operators
            case '$col':
              converted[Op.col] = opValue;
              break;
            case '$match':
              converted[Op.match] = opValue;
              break;

            default:
              // If it's not a recognized operator, keep as is
              converted[opKey] = opValue;
          }
        }
        result[key] = converted;
      } else {
        // Not an operator object, recurse into it
        result[key] = convertWhereClause(value);
      }
    } else {
      // Simple equality (primitive value)
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

  result.where = convertWhereClause(options.where);
  result.include = options.include;
  result.order = options.order;
  result.limit = options.limit;
  result.offset = options.offset;
  result.attributes = options.attributes;

  return result;
}

module.exports = {
  convertQueryOptions,
  convertWhereClause,
};
