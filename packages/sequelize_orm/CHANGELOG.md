## 0.1.0+1

 - **REFACTOR**: rename packages for pub.dev discoverability and add melos workspace management. ([c3c3cb69](https://github.com/crazidev/sequelize_orm_dart/commit/c3c3cb695b555bfe8d3cbfa98c10bbc4e00c8259))
 - **FIX**: harden model generation and runtime serialization. ([c734bb10](https://github.com/crazidev/sequelize_orm_dart/commit/c734bb10d722b41e72453df46c20a98c8ac16e99))
 - **DOCS**: prepare packages for pub.dev publishing and split CLI commands. ([98083c73](https://github.com/crazidev/sequelize_orm_dart/commit/98083c73f80f3156d3ec98de1c093b658180a61a))

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
