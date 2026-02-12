## 0.1.0+1

 - **REFACTOR**: rename packages for pub.dev discoverability and add melos workspace management. ([c3c3cb69](https://github.com/crazidev/sequelize_orm_dart/commit/c3c3cb695b555bfe8d3cbfa98c10bbc4e00c8259))
 - **FIX**: harden model generation and runtime serialization. ([c734bb10](https://github.com/crazidev/sequelize_orm_dart/commit/c734bb10d722b41e72453df46c20a98c8ac16e99))
 - **DOCS**: prepare packages for pub.dev publishing and split CLI commands. ([98083c73](https://github.com/crazidev/sequelize_orm_dart/commit/98083c73f80f3156d3ec98de1c093b658180a61a))

## 0.1.0

Initial beta release of `sequelize_orm_generator`.

### Code Generation

- Generates type-safe model classes from `@Table`-annotated Dart classes via `build_runner`.
- Per-model output: `*Model` (static queries), `*Values` (instance data), `Create*` / `Update*` (DTOs), `*Columns`, `*Query`, and `*IncludeHelper`.

### Model Features

- Full support for `@Table` options: timestamps, paranoid, underscored, freezeTableName, schema, engine, charset, version, and more.
- Attribute annotations: `@PrimaryKey`, `@AutoIncrement`, `@AllowNull`, `@NotNull`, `@ColumnName`, `@Default`, `@Comment`, `@Unique`, `@Index`.
- Validation annotations: `@IsEmail`, `@IsUrl`, `@Len`, `@Min`, `@Max`, `@IsUUID`, `@IsIn`, and more.
- Data type mapping for all supported Sequelize types.

### Associations

- `@HasOne`, `@HasMany`, `@BelongsTo` annotations processed during generation.
- Type-safe `IncludeHelper` generated per model for eager loading.
- Association registration code generated for the model registry.

### Model Registry

- Centralized `ModelsRegistry` generated with `defineModels()` and `associateModels()`.
- Automatically discovers and registers all annotated models in the project.

### CLI

- Shared CLI utilities for project scaffolding and model generation.
