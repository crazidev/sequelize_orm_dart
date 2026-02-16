import { Sequelize } from '@sequelize/core';

/**
 * Build a JSON path expression from path segments.
 * Equivalent to Sequelize's internal `buildJsonPath` utility.
 * Example: ['metadata', 'role'] -> '$.metadata.role'
 */
function buildJsonPath(path: ReadonlyArray<number | string>): string {
  let jsonPathStr = '$';
  for (const el of path) {
    if (typeof el === 'number') {
      jsonPathStr += `[${el}]`;
    } else {
      // Quote identifiers that aren't simple alphanumeric
      if (/^[a-z_][a-z0-9_]*$/i.test(el)) {
        jsonPathStr += `.${el}`;
      } else {
        jsonPathStr += `."${el.replace(/["\\]/g, (s) => `\\${s}`)}"`;
      }
    }
  }
  return jsonPathStr;
}

/**
 * Monkey-patch the SQLite query generator to support JSON path extraction.
 * SQLite 3.38.0+ supports json_extract(), ->, and ->> natively.
 * Sequelize v7 alpha hasn't implemented this yet (the dialect sets
 * jsonOperations: false with a TODO comment).
 */
export function enableSqliteJsonSupport(sequelize: Sequelize): void {
  const dialect = (sequelize as any).dialect;
  if (!dialect || !dialect.name?.startsWith('sqlite')) return;

  // Enable JSON support flags on the dialect class's static supports object.
  // The `supports` getter returns `this.constructor.supports`, so we must
  // mutate the static object on the class (SqliteDialect.supports).
  const staticSupports = dialect.constructor.supports;
  if (staticSupports) {
    staticSupports.jsonOperations = true;
    if (staticSupports.jsonExtraction) {
      staticSupports.jsonExtraction.unquoted = true;
      staticSupports.jsonExtraction.quoted = true;
    } else {
      staticSupports.jsonExtraction = { unquoted: true, quoted: true };
    }
  }

  // Patch the query generator prototype to emit json_extract / ->> SQL.
  // This ensures all QG instances for this dialect use our implementation.
  const qg = (sequelize as any).queryGenerator;
  if (!qg) return;

  const proto = Object.getPrototypeOf(qg);

  proto.jsonPathExtractionQuery = function (
    sqlExpression: string,
    path: ReadonlyArray<number | string>,
    unquote?: boolean,
  ): string {
    const jsonPath = buildJsonPath(path);
    if (unquote) {
      // ->> returns the SQL value (text, int, etc.) — equivalent to json_unquote
      return `${sqlExpression} ->> ${this.escape(jsonPath)}`;
    }
    // -> returns the JSON representation (strings are double-quoted, matching
    // MySQL/MariaDB json_extract behaviour that Sequelize expects).
    return `${sqlExpression} -> ${this.escape(jsonPath)}`;
  };

  proto.formatUnquoteJson = function (arg: any, options?: any): string {
    // SQLite doesn't have json_unquote; json_extract already returns unquoted.
    // Use ->> on the value with path '$' to extract the raw SQL value.
    return `${this.escape(arg, options)} ->> '$'`;
  };
}
