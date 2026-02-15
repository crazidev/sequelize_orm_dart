# Sequelize Dart — Feature Tracking

> Tracking implementation progress against the original [Sequelize (Node.js)](https://sequelize.org/) ORM.

---

## Supported Databases / Dialects

- ✅ PostgreSQL
- ✅ MySQL
- ✅ MariaDB
- ⚠️ SQLite — Dart API only, JS bridge not wired
- ⚠️ MSSQL — Dart API only, JS bridge not wired
- ⚠️ DB2 — Dart API only, JS bridge not wired
- ❌ DB2 for IBM i
- ❌ Snowflake

---

## Sequelize Instance ([API ref](https://sequelize.org/api/v7/classes/_sequelize_core.index.sequelize))

### Properties

- ✅ `debug` — custom Dart property
- ✅ `bridge` — custom Dart property (internal bridge client)
- ❌ `dialect`
- ❌ `models`
- ❌ `options`
- ❌ `pool` 
- ❌ `rawOptions`

### Accessors

- ❌ `connectionManager`
- ❌ `hooks`
- ❌ `modelManager`
- ❌ `queryGenerator`
- ❌ `queryInterface`
- ❌ `version`

### Methods

- ✅ `createInstance()` — custom Dart factory (replaces constructor pattern)
- ✅ `authenticate()`
- ✅ `initialize()` — custom Dart method (engine + models + associations)
- ✅ `define()`
- ✅ `addModels()`
- ✅ `sync()`
- ✅ `close()`
- ✅ `log()`
- ✅ `getModel()` — equivalent to `model()`
- ✅ `truncate()`
- ✅ `destroyAll()`
- ✅ `seed()` — custom method added for seeding
- ❌ `createSchema()`
- ❌ `drop()`
- ❌ `dropAllSchemas()`
- ❌ `dropSchema()`
- ❌ `escape()`
- ❌ `fetchDatabaseVersion()`
- ❌ `getDatabaseName()`
- ❌ `getDatabaseVersion()`
- ❌ `getDialect()`
- ❌ `getQueryInterface()`
- ❌ `isClosed()`
- ❌ `isDefined()`
- ❌ `normalizeAttribute()`
- ❌ `normalizeDataType()`
- ❌ `query()`
- ❌ `queryRaw()`
- ❌ `removeAllModels()`
- ❌ `showAllSchemas()`
- ❌ `startUnmanagedTransaction()`
- ❌ `transaction()`
- ❌ `validate()`
- ❌ `withConnection()`

### Static / SQL Helpers
- ✅ `Sequelize.fn()`
- ✅ `Sequelize.col()`
- ✅ `Sequelize.literal()`
- ✅ `Sequelize.cast()`
- ✅ `Sequelize.attribute()`
- ✅ `Sequelize.identifier()`
- ✅ `Sequelize.random()`

### Hooks — ❌ Not supported yet

---

## Model ([API ref](https://sequelize.org/api/v7/classes/_sequelize_core.index.model))

### Generated classes per model (via `@Table` + build_runner)

- ✅ `*Model` — static query class (extends `Model`)
- ✅ `*Values` — instance data class with instance methods
- ✅ `Create*` — creation DTO with nested association support
- ✅ `Update*` — update DTO
- ✅ `*Columns` — type-safe column references for where clauses
- ✅ `*Query` — extends columns + association references
- ✅ `*IncludeHelper` — type-safe include builder with full options

### Static / Class Methods (on `*Model`)

- ✅ `findAll()` — with where, include, order, group, limit, offset, attributes, paranoid
- ✅ `findOne()` — same options as findAll
- ✅ `create()` — with type-safe Create DTO, supports nested association creation
- ✅ `update()` — type-safe field-by-field with required where
- ✅ `destroy()` — with where, force, limit, individualHooks
- ✅ `restore()` — with where, limit, individualHooks
- ✅ `truncate()` — with cascade, restartIdentity, force
- ✅ `count()` — with where
- ✅ `max()` — with column function + where
- ✅ `min()` — with column function + where
- ✅ `sum()` — with column function + where
- ✅ `increment()` — generated per-model for numeric fields only
- ✅ `decrement()` — generated per-model for numeric fields only
- ❌ `findByPk()` — use `findOne()` with PK where
- ❌ `findOrCreate()`
- ❌ `findAndCountAll()`
- ❌ `findOrBuild()`
- ❌ `findCreateFind()`
- ❌ `bulkCreate()` — exists in QueryEngine but not exposed on Model
- ❌ `bulkBuild()`
- ❌ `build()`
- ❌ `upsert()`
- ❌ `aggregate()`
- ❌ `drop()`
- ❌ `describe()`
- ❌ `init()`
- ❌ `sync()` (model-level)

### Instance Methods (on `*Values`)

- ✅ `save()` — with optional fields list, handles insert/update
- ✅ `update()` — with data map, reloads after update
- ✅ `destroy()` — with force option for paranoid models
- ✅ `restore()` — for soft-deleted instances
- ✅ `reload()` — preserves original query (includes, order, etc.)
- ✅ `increment()` — per-model numeric fields
- ✅ `decrement()` — per-model numeric fields
- ✅ `toJson()` — equivalent to `toJSON()`
- ✅ `where()` — returns primary key map
- ✅ `previousDataValues` — getter/setter for change tracking
- ✅ `fromJson()` — factory constructor from JSON map
- ❌ `get()` / `set()`
- ❌ `getDataValue()` / `setDataValue()`
- ❌ `changed()`
- ❌ `previous()` — per-field (partial: `previousDataValues` exists)
- ❌ `validate()`
- ❌ `isSoftDeleted()`
- ❌ `equals()` / `equalsOneOf()`
- ❌ `setAttributes()`

### Associations

- ✅ `hasOne()`
- ✅ `hasMany()`
- ✅ `belongsTo()`
- ❌ `belongsToMany()` — exists in JS bridge but not exposed in Dart

### Scopes — ❌ Not supported yet

- ❌ `withScope()` / `scope()`
- ❌ `withoutScope()` / `unscoped()`
- ❌ `addScope()`
- ❌ `withSchema()` / `schema()`
- ❌ `withInitialScope()`

### Model Hooks — ❌ Not supported yet

---

## Operators ([docs ref](https://sequelize.org/docs/v7/querying/operators/))

> Available as both type-safe `Column<T>` extension methods and standalone string-based functions.

### Logical Combinations

- ✅ `and()`
- ✅ `or()`
- ✅ `not()`

### Basic Operators

- ✅ `eq()` — equal (`=`)
- ✅ `ne()` — not equal (`<>`)
- ✅ `gt()` — greater than
- ✅ `gte()` — greater than or equal
- ✅ `lt()` — less than
- ✅ `lte()` — less than or equal
- ✅ `between()`
- ✅ `notBetween()`
- ✅ `in_()`
- ✅ `notIn()`

### IS Operators

- ✅ `isNull()` / `isNotNull()`
- ✅ `isTrue()` / `isFalse()` — PostgreSQL
- ✅ `isNotTrue()` / `isNotFalse()` — PostgreSQL

### String Operators

- ✅ `like()` / `notLike()`
- ✅ `iLike()` / `notILike()` — PostgreSQL
- ✅ `startsWith()`
- ✅ `endsWith()`
- ✅ `substring()`
- ❌ `notStartsWith()`
- ❌ `notEndsWith()`
- ❌ `notSubstring()`

### Regex Operators

- ✅ `regexp()` / `notRegexp()`
- ✅ `iRegexp()` / `notIRegexp()` — PostgreSQL

### Array Operators (PostgreSQL)

- ❌ `contains()` / `contained()`
- ❌ `overlap()`

### Range Operators (PostgreSQL)

- ❌ `contains()` / `contained()` (range)
- ❌ `overlap()` (range)
- ❌ `adjacent()`
- ❌ `strictLeft()` / `strictRight()`
- ❌ `noExtendLeft()` / `noExtendRight()`

### JSONB Operators (PostgreSQL)

- ❌ `contains()` / `contained()` (jsonb)
- ❌ `anyKeyExists()` / `allKeysExist()`

### Misc Operators

- ✅ `col()` — compare to another column
- ✅ `match()` — tsquery full-text search (PostgreSQL)
- ✅ `all()` / `any()`
- ❌ `values()`

### Legacy Aliases (Dart-specific convenience)

- ✅ `equal()`, `not()`, `greaterThan()`, `lessThan()`, `greaterThanOrEqual()`, `lessThanOrEqual()`, `like_()`

---

## Decorators / Annotations

### `@Table` (ModelOptions)

- ✅ `tableName`
- ✅ `omitNull`
- ✅ `noPrimaryKey`
- ✅ `timestamps`
- ✅ `paranoid`
- ✅ `underscored`
- ✅ `hasTrigger`
- ✅ `freezeTableName`
- ✅ `name` (singular/plural)
- ✅ `modelName`
- ✅ `createdAt` — custom name or disable
- ✅ `updatedAt` — custom name or disable
- ✅ `deletedAt` — custom name or disable
- ✅ `schema`
- ✅ `schemaDelimiter`
- ✅ `engine` — MySQL/MariaDB
- ✅ `charset`
- ✅ `comment`
- ✅ `collate`
- ✅ `initialAutoIncrement`
- ✅ `version` — optimistic locking
- ❌ `defaultScope`
- ❌ `scopes`
- ❌ `indexes` — table-level (individual `@Index` on columns exists)
- ❌ `hooks`
- ❌ `validate` — table-level (column-level validators exist)
- ❌ `Table.Abstract`

### Attribute Decorators

- ✅ `@PrimaryKey`
- ✅ `@AutoIncrement`
- ✅ `@AllowNull`
- ✅ `@NotNull`
- ✅ `@ColumnName`
- ✅ `@Default` — value, `Default.uniqid()`, `Default.now()`, `Default.fn()`
- ✅ `@Comment`
- ✅ `@Unique` — bool, string (composite), or UniqueOption
- ✅ `@Index` — bool, string (composite), or IndexOption
- ⚠️ `Attribute` — exists but only takes DataType, not full AttributeOptions bag
- ❌ `@CreatedAt` / `@UpdatedAt` / `@DeletedAt` — as standalone decorators (handled via Table options)
- ❌ `@Version` — as standalone decorator (handled via Table `version` option)

### Attribute Options (ColumnDefinition)

- ✅ `type`
- ✅ `allowNull`
- ✅ `columnName`
- ✅ `defaultValue`
- ✅ `unique`
- ✅ `index`
- ✅ `primaryKey`
- ✅ `autoIncrement`
- ✅ `autoIncrementIdentity` — PostgreSQL
- ✅ `comment`
- ✅ `validate`
- ❌ `references` — foreign key config (handled via association decorators)
- ❌ `onUpdate` / `onDelete` — referential actions
- ❌ `get` / `set` — custom getters/setters

### Association Decorators

- ✅ `@HasOne` — model, foreignKey, as, sourceKey
- ✅ `@HasMany` — model, foreignKey, as, sourceKey
- ✅ `@BelongsTo` — model, foreignKey, as, targetKey
- ❌ `@BelongsToMany`

### Validation Decorators

- ✅ `@IsEmail`, `@IsUrl`, `@IsIP`, `@IsIPv4`, `@IsIPv6`
- ✅ `@IsAlpha`, `@IsAlphanumeric`, `@IsNumeric`, `@IsInt`, `@IsFloat`, `@IsDecimal`
- ✅ `@IsLowercase`, `@IsUppercase`
- ✅ `@NotEmpty`, `@IsArray`, `@IsCreditCard`, `@IsDate`
- ✅ `@Is` / `@Not` — pattern matching with flags
- ✅ `@Equals`, `@Contains`, `@NotContains`
- ✅ `@IsAfter`, `@IsBefore`
- ✅ `@Max`, `@Min`, `@Len`
- ✅ `@IsUUID`, `@IsIn`, `@NotIn`
- ✅ `@Validate.*` — namespace class for all validators
- ✅ `ValidateOption` — combined validator options object
- ❌ `@ValidateAttribute` — decorator form (validators applied via annotations instead)
- ❌ `@ModelValidator` — model-level validation decorator

### Hook Decorators — ❌ Not supported yet

- ❌ `@BeforeCreate` / `@AfterCreate`
- ❌ `@BeforeUpdate` / `@AfterUpdate`
- ❌ `@BeforeDestroy` / `@AfterDestroy`
- ❌ `@BeforeSave` / `@AfterSave`
- ❌ `@BeforeFind` / `@AfterFind`
- ❌ `@BeforeValidate` / `@AfterValidate`
- ❌ `@BeforeSync` / `@AfterSync`
- ❌ `@BeforeBulkCreate` / `@AfterBulkCreate`
- ❌ `@BeforeBulkDestroy` / `@AfterBulkDestroy`
- ❌ `@BeforeBulkUpdate` / `@AfterBulkUpdate`
- ❌ `@BeforeBulkRestore` / `@AfterBulkRestore`
- ❌ `@BeforeUpsert` / `@AfterUpsert`
- ❌ `@BeforeRestore` / `@AfterRestore`
- ❌ `@BeforeAssociate` / `@AfterAssociate`
- ❌ `@BeforeCount`
- ❌ `@ValidationFailed`

---

## Data Types

Runtime bridge status:

- ✅ JS bridge mappings now include `TINYINT`, `SMALLINT`, `MEDIUMINT`, `CHAR`, and `BLOB`.
- ✅ Data type options are forwarded to runtime (`length`, `scale`, `UNSIGNED`, `ZEROFILL`, `BINARY`, `variant`).

### Integer Types

- ✅ `TINYINT` — with length, UNSIGNED, ZEROFILL
- ✅ `SMALLINT` — with length, UNSIGNED, ZEROFILL
- ✅ `MEDIUMINT` — with length, UNSIGNED, ZEROFILL
- ✅ `INTEGER` — with length, UNSIGNED, ZEROFILL
- ✅ `BIGINT` — with length, UNSIGNED, ZEROFILL

### Decimal / Float Types

- ✅ `FLOAT` — with precision, scale, UNSIGNED, ZEROFILL
- ✅ `DOUBLE` — with precision, scale, UNSIGNED, ZEROFILL
- ✅ `DECIMAL` — with precision, scale, UNSIGNED, ZEROFILL

### String Types

- ✅ `STRING` — with length, BINARY
- ✅ `CHAR` — with length, BINARY
- ✅ `TEXT` — with tiny, medium, long variants

### Other Types

- ✅ `BOOLEAN`
- ✅ `DATE`
- ✅ `DATEONLY`
- ✅ `UUID`
- ✅ `JSON`
- ✅ `JSONB`
- ✅ `BLOB` — with tiny, medium, long variants
- ❌ `ENUM`
- ❌ `ARRAY` — PostgreSQL
- ❌ `RANGE` — PostgreSQL
- ❌ `GEOMETRY`
- ❌ `GEOGRAPHY`
- ❌ `HSTORE` — PostgreSQL
- ❌ `CIDR` / `INET` / `MACADDR` — PostgreSQL
- ❌ `CITEXT` — PostgreSQL
- ❌ `VIRTUAL`

---

## Querying Features

### FindOptions / Query Options

- ✅ `where` — type-safe via Column extensions
- ✅ `attributes` — select / exclude columns (QueryAttributes)
- ✅ `order`
- ✅ `group`
- ✅ `limit`
- ✅ `offset`
- ✅ `paranoid` — filter soft-deleted records
- ✅ `include` — eager loading via IncludeBuilder
- ❌ `having`
- ❌ `subQuery` — top-level (exists in IncludeBuilder only)
- ❌ `raw`
- ❌ `lock` / `skipLocked`
- ❌ `plain`
- ❌ `rejectOnEmpty`
- ❌ `logging` — defined in QueryOptions but not wired to Query
- ❌ `benchmark` — defined in QueryOptions but not wired to Query
- ❌ `nest`

### Raw Queries — ❌ Not supported

- ❌ `sequelize.query()`
- ❌ `sequelize.queryRaw()`
- ❌ Replacements / bind parameters
- ❌ Query types

---

## Eager Loading / Includes

### IncludeBuilder Options

- ✅ Nested includes — infinite depth
- ✅ `required` — INNER JOIN
- ✅ `right` — RIGHT OUTER JOIN
- ✅ `separate` — separate queries for HasMany/BelongsToMany
- ✅ `where` — per-include filtering
- ✅ `attributes` — per-include column selection
- ✅ `order` / `group` — per-include
- ✅ `limit` / `offset` — per-include (requires separate)
- ✅ `paranoid` — per-include soft-delete filtering
- ✅ `on` — custom ON clause
- ✅ `or` — bind ON and WHERE with OR
- ✅ `subQuery` — per-include
- ✅ `duplicating`
- ✅ `through` — Map for BelongsToMany (infrastructure ready)
- ✅ `all: true` with `nested: true` — include all associations
- ✅ Type-safe IncludeHelper — generated per model

---

## Associations (Runtime)

### Association Mixin Methods

- ✅ BelongsTo: `getX()`, `setX()`, `createX()` — via JS bridge
- ❌ HasOne: `getX()`, `setX()`, `createX()`
- ❌ HasMany: `getX()`, `countX()`, `hasX()`, `setX()`, `addX()`, `removeX()`, `createX()`
- ❌ BelongsToMany: all mixin methods

### Other

- ✅ Eager loading — fully supported
- ✅ Nested eager loading — fully supported
- ❌ Lazy loading
- ❌ Association scopes
- ⚠️ BelongsToMany — include infrastructure exists, but no annotation/handler

---

## Paranoid Models (Soft Delete)

- ✅ `@Table(paranoid: true)` — enable soft delete
- ✅ `deletedAt` — custom column name or disable
- ✅ `Model.destroy()` — sets deletedAt (static)
- ✅ `instance.destroy()` — sets deletedAt (instance)
- ✅ `instance.destroy(force: true)` — hard delete
- ✅ `Model.destroy(force: true)` — hard delete (static)
- ✅ `Model.restore()` — restore soft-deleted records (static, with where)
- ✅ `instance.restore()` — restore instance
- ✅ `paranoid` query option — filter in findAll/findOne
- ✅ `paranoid` per-include — filter in includes

---

## Connection Options

### Pool Configuration (SequelizePoolOptions)

- ✅ `max`
- ✅ `min`
- ✅ `idle`
- ✅ `acquire`
- ✅ `evict`

### SSL / TLS (SslConfig)

- ✅ Full SSL support — ca, cert, key, passphrase, pfx, rejectUnauthorized, ciphers, etc.

### Dialect-Specific Options

- ✅ PostgreSQL — ssl, queryTimeout, applicationName, statementTimeout, schema, keepAlive, clientEncoding, etc.
- ✅ MySQL — ssl, socketPath, charset, compress, connectTimeout, connectAttributes, etc.
- ✅ MariaDB — ssl, socketPath, compress, maxAllowedPacket, charset, collation, queryTimeout, etc.
- ✅ SQLite — storage, mode flags, sqlitePassword (SQLCipher), foreignKeys
- ✅ MSSQL — instanceName, authentication, encrypt, trustServerCertificate, requestTimeout, tdsVersion, etc.
- ✅ DB2 — hostname, ssl, sslServerCertificate, odbcOptions

### Not Supported

- ❌ Read replication
- ❌ Retry logic

---

## Transactions — ❌ Not supported yet

- ❌ `sequelize.transaction()` — managed transactions
- ❌ `sequelize.startUnmanagedTransaction()` — unmanaged
- ❌ Isolation levels
- ❌ Savepoints
- ❌ Commit / Rollback

---

## Migrations — ❌ Not supported yet

- ❌ Migration files (up/down)
- ❌ Migration runner / CLI
- ❌ Migration table tracking
- ⚠️ `sequelize.sync()` — available for development (force/alter modes)

---

## Seeding

- ✅ `sequelize.seed()` — extension method
- ✅ `SequelizeSeeding` — type-safe base class with `seedData` + `create`
- ✅ `sortByOrder` — order seeders by priority
- ✅ `syncTableMode` — none / alter / force before seeding
- ✅ Custom log function

---

## Indexes & Constraints

- ✅ `@Index` — single and composite (via IndexOption.named)
- ✅ `@Unique` — single and composite (via UniqueOption)
- ✅ `@PrimaryKey` / `@AutoIncrement`
- ✅ Foreign keys — auto-created via associations
- ⚠️ `ReferentialAction` enum — exists (cascade, restrict, setDefault, setNull, noAction) but not exposed in association annotations
- ❌ `onDelete` / `onUpdate` — not configurable on associations
- ❌ Check constraints
- ❌ Table-level indexes (via ModelOptions)

---

## SQL Helpers & Raw Queries ([docs ref](https://sequelize.org/docs/v7/querying/raw-queries/))

### SQL Expression Classes (via `Sequelize.*` static methods)

- ✅ `Sequelize.fn()` — SQL function calls (`SqlFn`)
- ✅ `Sequelize.col()` — column reference (`SqlCol`)
- ✅ `Sequelize.literal()` — raw SQL literal (`SqlLiteral`)
- ✅ `Sequelize.attribute()` — model attribute reference (`SqlAttribute`)
- ✅ `Sequelize.identifier()` — escaped identifier (`SqlIdentifier`)
- ✅ `Sequelize.cast()` — CAST expression (`SqlCast`)
- ✅ `Sequelize.random()` — random ordering (`SqlRandom`)
- ❌ `sql.list()` — treat array as SQL list
- ❌ `sql.join()` — join SQL fragments
- ❌ `sql.where()` — generate WHERE from object
- ❌ `sql.jsonPath()` — JSON property extraction
- ❌ `sql.unquote()` — JSON_UNQUOTE
- ❌ `sql.uuidV4()` / `sql.uuidV1()` — UUID generation functions

### Raw Query Execution

- ❌ `sequelize.query()` — execute raw SQL
- ❌ `sequelize.queryRaw()`
- ❌ Replacements — `:name` or `?` syntax
- ❌ Bind parameters — `$1` or `$name` syntax
- ❌ `QueryTypes` — SELECT, INSERT, UPDATE, DELETE, etc.
- ❌ `sql` tagged template — N/A in Dart (no tagged template literals)

---

## Subqueries ([docs ref](https://sequelize.org/docs/v7/querying/sub-queries/))

- ⚠️ `Sequelize.literal()` can embed raw SQL in where clauses — subqueries possible via literals
- ❌ No explicit subquery helpers or classes
- ❌ `in_()` only accepts `List<T>`, not `SqlExpression` — can't pass a literal subquery to Op.in directly

---

## JSON Querying ([docs ref](https://sequelize.org/docs/v7/querying/json/))

- ✅ `DataType.JSON` / `DataType.JSONB` — column types
- ❌ Dot notation for JSON access (`'jsonColumn.nested.property'`)
- ❌ JSON path extraction (`sql.jsonPath()`)
- ❌ JSON casting syntax (`jsonAttribute.age::integer`)
- ❌ JSON unquoting (`:unquote` modifier / `sql.unquote()`)
- ❌ JSON array index access (`jsonColumn.passwords[0]`)
- ❌ `JSON_NULL` / `SQL_NULL` constants
- ❌ Nested JSON extraction syntax
- ❌ JSON-specific operators (`Op.contains`, `Op.anyKeyExists`, etc. on JSON columns)

---

## Naming Strategies ([docs ref](https://sequelize.org/docs/v6/other-topics/naming-strategies/))

- ✅ `underscored` — auto snake_case column names
- ✅ `freezeTableName` — prevent pluralization
- ✅ `tableName` — explicit table name override
- ✅ `modelName` — explicit model name
- ✅ `name` — singular/plural (`ModelNameOption`)
- ✅ `@ColumnName` — explicit column name per field
- ✅ Automatic pluralization — handled by Sequelize JS engine
- ✅ Foreign key inference — handled by Sequelize JS (e.g. `User` → `userId` / `user_id`)
- ✅ Explicit `foreignKey` in `@HasOne`, `@HasMany`, `@BelongsTo`
