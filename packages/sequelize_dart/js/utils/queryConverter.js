const { Op, sql, Sequelize } = require('@sequelize/core');

/**
 * Convert Dart SQL expressions to Sequelize Expressions
 */
function convertSqlExpression(expr) {
  if (!expr || typeof expr !== 'object') {
    return expr;
  }

  if (expr.__type) {
    let result;
    switch (expr.__type) {
      case 'fn':
        result = sql.fn(expr.fn, ...(expr.args || []).map(convertSqlExpression));
        break;
      case 'col':
        result = sql.col(expr.col);
        break;
      case 'literal':
        result = sql.literal(expr.value);
        break;
      case 'attribute':
        result = sql.attribute(expr.attribute);
        break;
      case 'identifier':
        result = sql.identifier(expr.identifier);
        break;
      case 'cast':
        result = sql.cast(convertSqlExpression(expr.expression), expr.type);
        break;
      case 'random':
        result = typeof Sequelize.random === 'function' ? Sequelize.random() : sql.fn('RANDOM');
        break;
      default:
        console.warn(`[JS Bridge] Unknown SQL expression type: ${expr.__type}`);
        return expr;
    }
    return result;
  }

  if (Array.isArray(expr)) {
    return expr.map(convertSqlExpression);
  }

  return expr;
}

/**
 * Hoist order and group from joined includes to the top level.
 * This is necessary because Sequelize usually ignores 'order' and 'group'
 * properties inside a joined include.
 */
function hoistIncludeOptions(options) {
  if (!options.include) return;

  function walk(include, path = []) {
    const items = Array.isArray(include) ? include : [include];
    for (const item of items) {
      if (!item || typeof item !== 'object') continue;

      const association = item.as || item.association;
      if (!association) continue;

      const currentPath = [...path, association];

      // Hoist order if not separate
      if (item.order && !item.separate) {
        if (!options.order) options.order = [];
        if (!Array.isArray(options.order)) options.order = [options.order];

        let itemOrders = item.order;
        // Handle single order [col, dir] vs multiple orders [[col, dir], [col, dir]]
        const isSingleOrder = Array.isArray(itemOrders) && 
                            itemOrders.length === 2 && 
                            typeof itemOrders[1] === 'string' && 
                            (itemOrders[1].toUpperCase() === 'ASC' || itemOrders[1].toUpperCase() === 'DESC');
        
        if (isSingleOrder || !Array.isArray(itemOrders)) {
          itemOrders = [itemOrders];
        }

        for (const order of itemOrders) {
          if (Array.isArray(order)) {
            // Prepend the association path to the order array
            options.order.push([...currentPath, ...order]);
          } else {
            options.order.push([...currentPath, order]);
          }
        }
        delete item.order;
      }

      // Hoist group if not separate
      if (item.group && !item.separate) {
        if (!options.group) options.group = [];
        if (!Array.isArray(options.group)) options.group = [options.group];

        let itemGroups = item.group;
        if (!Array.isArray(itemGroups)) itemGroups = [itemGroups];

        for (const group of itemGroups) {
          if (Array.isArray(group)) {
            options.group.push([...currentPath, ...group]);
          } else {
            options.group.push([...currentPath, group]);
          }
        }
        delete item.group;
      }

      if (item.include) {
        walk(item.include, currentPath);
      }
    }
  }

  walk(options.include);
}

/**
 * Convert Dart query operators to Sequelize Op operators
 */
function convertWhereClause(where) {
  if (!where || typeof where !== 'object') {
    return where;
  }

  // If it's a SQL expression, convert it
  if (where.__type) {
    return convertSqlExpression(where);
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
    if (typeof value === 'object' && value !== null && !Array.isArray(value) && !value.__type) {
      // Check if this is an operator object like {$ne: value, $gt: value}
      const hasOperatorKeys = Object.keys(value).some(
        (k) => k.startsWith('$') && k !== '$and' && k !== '$or' && k !== '$not',
      );

      if (hasOperatorKeys) {
        // Convert operator keys to Sequelize Op
        const converted = {};
        for (const [opKey, opValue] of Object.entries(value)) {
          const convertedValue = convertSqlExpression(opValue);
          switch (opKey) {
            case '$eq':
              converted[Op.eq] = convertedValue;
              break;
            case '$ne':
              converted[Op.ne] = convertedValue;
              break;
            case '$is':
              converted[Op.is] = convertedValue;
              break;
            case '$isNot':
              converted[Op.isNot] = convertedValue;
              break;
            case '$not':
              converted[Op.not] = convertedValue;
              break;
            case '$gt':
              converted[Op.gt] = convertedValue;
              break;
            case '$gte':
              converted[Op.gte] = convertedValue;
              break;
            case '$lt':
              converted[Op.lt] = convertedValue;
              break;
            case '$lte':
              converted[Op.lte] = convertedValue;
              break;
            case '$between':
              converted[Op.between] = convertedValue;
              break;
            case '$notBetween':
              converted[Op.notBetween] = convertedValue;
              break;
            case '$in':
              converted[Op.in] = convertedValue;
              break;
            case '$notIn':
              converted[Op.notIn] = convertedValue;
              break;
            case '$all':
              converted[Op.all] = convertedValue;
              break;
            case '$any':
              converted[Op.any] = convertedValue;
              break;
            case '$like':
              converted[Op.like] = convertedValue;
              break;
            case '$notLike':
              converted[Op.notLike] = convertedValue;
              break;
            case '$startsWith':
              converted[Op.startsWith] = convertedValue;
              break;
            case '$endsWith':
              converted[Op.endsWith] = convertedValue;
              break;
            case '$substring':
              converted[Op.substring] = convertedValue;
              break;
            case '$ilike':
              converted[Op.iLike] = convertedValue;
              break;
            case '$notILike':
              converted[Op.notILike] = convertedValue;
              break;
            case '$regexp':
              converted[Op.regexp] = convertedValue;
              break;
            case '$notRegexp':
              converted[Op.notRegexp] = convertedValue;
              break;
            case '$iRegexp':
              converted[Op.iRegexp] = convertedValue;
              break;
            case '$notIRegexp':
              converted[Op.notIRegexp] = convertedValue;
              break;
            case '$col':
              converted[Op.col] = convertedValue;
              break;
            case '$match':
              converted[Op.match] = convertedValue;
              break;
            default:
              converted[opKey] = convertedValue;
          }
        }
        result[key] = converted;
      } else {
        result[key] = convertWhereClause(value);
      }
    } else {
      result[key] = convertSqlExpression(value);
    }
  }

  return result;
}

/**
 * Convert attributes from Dart format to Sequelize format
 */
function convertAttributes(attributes) {
  if (!attributes) return attributes;

  if (Array.isArray(attributes)) {
    return attributes.map(attr => {
      if (Array.isArray(attr) && attr.length === 2) {
        return [convertSqlExpression(attr[0]), attr[1]];
      }
      return convertSqlExpression(attr);
    });
  }

  if (typeof attributes === 'object' && attributes !== null) {
    if (attributes.exclude && Array.isArray(attributes.exclude)) {
      return {
        exclude: attributes.exclude.map(convertSqlExpression)
      };
    }
  }

  return attributes;
}

/**
 * Convert include options from Dart format to Sequelize format
 */
function convertInclude(include) {
  if (!include) {
    return include;
  }

  if (Array.isArray(include)) {
    return include.map(convertInclude);
  }

  if (typeof include === 'object' && include !== null) {
    const converted = { ...include };

    if (converted.where !== undefined && converted.where !== null) {
      converted.where = convertWhereClause(converted.where);
    }

    if (converted.on !== undefined && converted.on !== null) {
      converted.on = convertWhereClause(converted.on);
    }

    if (converted.attributes !== undefined && converted.attributes !== null) {
      converted.attributes = convertAttributes(converted.attributes);
    }

    if (converted.include !== undefined && converted.include !== null) {
      converted.include = convertInclude(converted.include);
    }

    if (converted.order !== undefined && converted.order !== null) {
        converted.order = convertSqlExpression(converted.order);
    }

    if (converted.group !== undefined && converted.group !== null) {
        converted.group = convertSqlExpression(converted.group);
    }

    return converted;
  }

  return include;
}

/**
 * Convert query options from Dart format to Sequelize format
 */
function convertQueryOptions(options) {
  if (!options) {
    return {};
  }

  const result = {};

  if (options.where !== undefined && options.where !== null) {
    result.where = convertWhereClause(options.where);
  }
  if (options.include !== undefined && options.include !== null) {
    result.include = convertInclude(options.include);
  }
  if (options.order !== undefined && options.order !== null) {
    result.order = convertSqlExpression(options.order);
  }
  if (options.group !== undefined && options.group !== null) {
    result.group = convertSqlExpression(options.group);
  }
  if (options.limit !== undefined && options.limit !== null) {
    result.limit = options.limit;
  }
  if (options.offset !== undefined && options.offset !== null) {
    result.offset = options.offset;
  }
  if (options.attributes !== undefined && options.attributes !== null) {
    result.attributes = convertAttributes(options.attributes);
  }

  hoistIncludeOptions(result);

  return result;
}

module.exports = {
  convertQueryOptions,
  convertWhereClause,
  convertInclude,
  convertSqlExpression,
  convertAttributes,
};
