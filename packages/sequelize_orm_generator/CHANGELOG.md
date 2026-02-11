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
