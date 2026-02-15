## 0.1.3

- **FEAT**: Type-safe JSON querying via `JsonColumn<T>`, `JsonPath`, and `JsonText` classes — fluent API for navigating and comparing JSON/JSONB columns.
- **FEAT**: `.key()` for object property access, `.at()` for array index access, `.unquote()` for text extraction with string-specific operators.
- **FEAT**: `contains()` operator for PostgreSQL JSONB containment checks (`@>`).
- **FEAT**: `normalizeJsonTypes` configuration — automatically converts `JSON`↔`JSONB` based on the connected database dialect for cross-database portability.
- **FIX**: `save()` no longer sends association keys to the bridge, preventing FK constraint violations when saving instances with eagerly-loaded associations.
- **FIX**: PostgreSQL `TRUNCATE CASCADE` now executes correctly via raw SQL fallback when `Model.truncate({cascade: true})` doesn't cascade properly in Sequelize v7.
- **FIX**: Non-PostgreSQL dialects no longer receive a `public` schema default, preventing `Unknown database 'public'` errors on MySQL/MariaDB.
- **IMPROVEMENT**: `$contains`, `$contained`, and `$overlap` operators mapped in the query converter for JSONB queries.

## 0.1.2

- **FEAT**: `SequelizeBigInt` type for BIGINT columns — wraps the string value with `.toBigInt()`, `.toInt()`, and `.toJson()` helpers.
- **FEAT**: Colored `ModelParseException` for `fromJson` failures — shows field, model, operation, types, and row index in a single line.
- **FEAT**: Strict type-safe parse helpers for all supported data types.
- **FEAT**: JS bridge support for `TINYINT`, `SMALLINT`, `MEDIUMINT`, `CHAR`, and `BLOB`.
- **FEAT**: Customizable `DataType.JSON` / `DataType.JSONB` with `type:` parameter for specifying the Dart deserialization type (e.g. `List<String>`, `Map<String, int>`).
- **FEAT**: Generic `parseJsonList<T>` and `parseJsonMap<T>` helpers with automatic `jsonDecode` fallback for bridge string payloads.
- **IMPROVEMENT**: Datatype options (length, scale, UNSIGNED, ZEROFILL, BINARY, variant) now forwarded to the JS bridge.

## 0.1.1

- **FIX**: migrate model identity usage from `name` to `modelName` across runtime model APIs to avoid clashes with columns named `name`.
- **FIX**: keep backward compatibility by deprecating `Model.name` and forwarding it to `modelName`.
- **FIX**: update Sequelize registration/association flows to use `modelName` consistently.
- **FIX**: move bridge server bundle to package source path for runtime packaging consistency.

## 0.1.0

Initial beta release of `sequelize_orm`.

### Highlights

- Type-safe ORM for Dart powered by Sequelize (Node.js) via a JS bridge.
- Support for **PostgreSQL**, **MySQL**, and **MariaDB** (SQLite, MSSQL, DB2 have Dart API stubs).

### Sequelize Instance

- `createInstance()`, `authenticate()`, `initialize()`, `sync()`, `close()`.
- `define()`, `addModels()`, `getModel()`.
- `truncate()`, `destroyAll()`, `seed()`.
- SQL helpers: `Sequelize.fn()`, `col()`, `literal()`, `cast()`, `attribute()`, `identifier()`, `random()`.

### Models & Code Generation

- `@Table` annotation with full model options (timestamps, paranoid, underscored, freezeTableName, schema, engine, charset, version, and more).
- Generates `*Model`, `*Values`, `Create*`, `Update*`, `*Columns`, `*Query`, and `*IncludeHelper` classes per model.
- Static methods: `findAll()`, `findOne()`, `create()`, `update()`, `destroy()`, `restore()`, `truncate()`, `count()`, `max()`, `min()`, `sum()`, `increment()`, `decrement()`.
- Instance methods: `save()`, `update()`, `destroy()`, `restore()`, `reload()`, `increment()`, `decrement()`, `toJson()`.

### Associations

- `@HasOne`, `@HasMany`, `@BelongsTo` annotations with foreignKey, as, sourceKey, targetKey.
- Eager loading via type-safe `IncludeBuilder` with nested includes, where, attributes, order, limit, separate, required, right join, and more.
- BelongsTo mixin methods: `getX()`, `setX()`, `createX()`.

### Operators

- Logical: `and()`, `or()`, `not()`.
- Comparison: `eq()`, `ne()`, `gt()`, `gte()`, `lt()`, `lte()`, `between()`, `notBetween()`, `in_()`, `notIn()`.
- IS: `isNull()`, `isNotNull()`, `isTrue()`, `isFalse()`, `isNotTrue()`, `isNotFalse()`.
- String: `like()`, `notLike()`, `iLike()`, `notILike()`, `startsWith()`, `endsWith()`, `substring()`.
- Regex: `regexp()`, `notRegexp()`, `iRegexp()`, `notIRegexp()`.
- Misc: `col()`, `match()`, `all()`, `any()`.

### Data Types

- Integer: `TINYINT`, `SMALLINT`, `MEDIUMINT`, `INTEGER`, `BIGINT` (with UNSIGNED, ZEROFILL).
- Decimal: `FLOAT`, `DOUBLE`, `DECIMAL`.
- String: `STRING`, `CHAR`, `TEXT` (with variants).
- Other: `BOOLEAN`, `DATE`, `DATEONLY`, `UUID`, `JSON`, `JSONB`, `BLOB`.

### Attribute Annotations

- `@PrimaryKey`, `@AutoIncrement`, `@AllowNull`, `@NotNull`, `@ColumnName`, `@Default`, `@Comment`, `@Unique`, `@Index`.
- Validation: `@IsEmail`, `@IsUrl`, `@IsIP`, `@IsAlpha`, `@IsNumeric`, `@Len`, `@Min`, `@Max`, `@IsUUID`, `@IsIn`, and more.

### Paranoid (Soft Delete)

- Full support for soft delete with `paranoid: true`, custom `deletedAt` column, force delete, and restore.

### Connection

- Pool configuration (max, min, idle, acquire, evict).
- Full SSL/TLS support.
- Dialect-specific options for PostgreSQL, MySQL, MariaDB, SQLite, MSSQL, and DB2.

### Seeding

- `sequelize.seed()` with type-safe `SequelizeSeeding` base class, ordering, and sync modes.
