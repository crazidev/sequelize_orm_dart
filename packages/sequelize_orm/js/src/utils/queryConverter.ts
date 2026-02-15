import { Op, sql, Sequelize } from '@sequelize/core';
import { getOptions } from './state';

export function convertSqlExpression(expr: any): any {
  if (!expr || typeof expr !== 'object') {
    return expr;
  }

  if (expr.__type) {
    let result: any;
    switch (expr.__type) {
      case 'fn':
        result = sql.fn(
          expr.fn,
          ...(expr.args || []).map((a: any) => convertSqlExpression(a)),
        );
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
        result =
          typeof (Sequelize as any).random === 'function'
            ? (Sequelize as any).random()
            : sql.fn('RANDOM');
        break;
      default:
        console.warn(`[JS Bridge] Unknown SQL expression type: ${expr.__type}`);
        return expr;
    }
    return result;
  }

  if (Array.isArray(expr)) {
    return expr.map((e) => convertSqlExpression(e));
  }

  return expr;
}

function hoistIncludeOptions(options: any): void {
  if (!options.include) return;

  function walk(include: any, path: any[] = []): void {
    const items = Array.isArray(include) ? include : [include];
    for (const item of items) {
      if (!item || typeof item !== 'object') continue;

      const association = item.as || item.association;
      if (!association) continue;

      const currentPath = [...path, association];

      if (item.order && !item.separate) {
        if (!options.order) options.order = [];
        if (!Array.isArray(options.order)) options.order = [options.order];

        let itemOrders = item.order;
        const isSingleOrder =
          Array.isArray(itemOrders) &&
          itemOrders.length === 2 &&
          typeof itemOrders[1] === 'string' &&
          (itemOrders[1].toUpperCase() === 'ASC' ||
            itemOrders[1].toUpperCase() === 'DESC');

        if (isSingleOrder || !Array.isArray(itemOrders)) {
          itemOrders = [itemOrders];
        }

        for (const order of itemOrders) {
          if (Array.isArray(order)) {
            options.order.push([...currentPath, ...order]);
          } else {
            options.order.push([...currentPath, order]);
          }
        }
        delete item.order;
      }

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

export function convertWhereClause(where: any): any {
  if (!where || typeof where !== 'object') {
    return where;
  }

  if (where.__type) {
    return convertSqlExpression(where);
  }

  if ('$and' in where) {
    return {
      [Op.and]: where.$and.map((w: any) => convertWhereClause(w)),
    };
  }
  if ('$or' in where) {
    return {
      [Op.or]: where.$or.map((w: any) => convertWhereClause(w)),
    };
  }
  if ('$not' in where) {
    return {
      [Op.not]: where.$not.map((w: any) => convertWhereClause(w)),
    };
  }

  const result: any = {};
  for (const [key, value] of Object.entries(where)) {
    if (
      typeof value === 'object' &&
      value !== null &&
      !Array.isArray(value) &&
      !(value as any).__type
    ) {
      const hasOperatorKeys = Object.keys(value as any).some(
        (k) => k.startsWith('$') && k !== '$and' && k !== '$or' && k !== '$not',
      );

      if (hasOperatorKeys) {
        const converted: any = {};
        for (const [opKey, opValue] of Object.entries(value as any)) {
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
              // Postgres supports ILIKE. MySQL/MariaDB don't, so fall back to LIKE (collation controls case-sensitivity).
              if (getOptions().dialect === 'postgres') {
                converted[Op.iLike] = convertedValue;
              } else {
                converted[Op.like] = convertedValue;
              }
              break;
            case '$notILike':
              // Postgres supports NOT ILIKE. MySQL/MariaDB don't, so fall back to NOT LIKE.
              if (getOptions().dialect === 'postgres') {
                converted[Op.notILike] = convertedValue;
              } else {
                converted[Op.notLike] = convertedValue;
              }
              break;
            case '$regexp':
              converted[Op.regexp] = convertedValue;
              break;
            case '$notRegexp':
              converted[Op.notRegexp] = convertedValue;
              break;
            case '$iRegexp':
              // Postgres supports case-insensitive regexp (~*). MySQL/MariaDB don't, so fall back to REGEXP.
              if (getOptions().dialect === 'postgres') {
                converted[Op.iRegexp] = convertedValue;
              } else {
                converted[Op.regexp] = convertedValue;
              }
              break;
            case '$notIRegexp':
              // Postgres supports case-insensitive regexp (!~*). MySQL/MariaDB don't, so fall back to NOT REGEXP.
              if (getOptions().dialect === 'postgres') {
                converted[Op.notIRegexp] = convertedValue;
              } else {
                converted[Op.notRegexp] = convertedValue;
              }
              break;
            case '$col':
              converted[Op.col] = convertedValue;
              break;
            case '$match':
              converted[Op.match] = convertedValue;
              break;
            case '$contains':
              converted[Op.contains] = convertedValue;
              break;
            case '$contained':
              converted[Op.contained] = convertedValue;
              break;
            case '$overlap':
              converted[Op.overlap] = convertedValue;
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

export function convertAttributes(attributes: any): any {
  if (!attributes) return attributes;

  if (Array.isArray(attributes)) {
    return attributes.map((attr) => {
      if (Array.isArray(attr) && attr.length === 2) {
        return [convertSqlExpression(attr[0]), attr[1]];
      }
      return convertSqlExpression(attr);
    });
  }

  if (typeof attributes === 'object' && attributes !== null) {
    if ((attributes as any).exclude && Array.isArray((attributes as any).exclude)) {
      return {
        exclude: (attributes as any).exclude.map((v: any) => convertSqlExpression(v)),
      };
    }
  }

  return attributes;
}

export function convertInclude(include: any): any {
  if (!include) {
    return include;
  }

  if (Array.isArray(include)) {
    return include.map((i) => convertInclude(i));
  }

  if (typeof include === 'object' && include !== null) {
    const converted: any = { ...include };

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

export function convertQueryOptions(options: any): any {
  if (!options) {
    return {};
  }

  const result: any = {};

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

  // Pass through paranoid option (for soft-delete queries)
  if (options.paranoid !== undefined && options.paranoid !== null) {
    result.paranoid = options.paranoid;
  }

  // Pass through force option (for hard delete)
  if (options.force !== undefined && options.force !== null) {
    result.force = options.force;
  }

  // Pass through individualHooks option
  if (options.individualHooks !== undefined && options.individualHooks !== null) {
    result.individualHooks = options.individualHooks;
  }

  if (getOptions().hoistIncludeOptions) {
    hoistIncludeOptions(result);
  }

  return result;
}
