## 0.1.3

- **FEAT**: Generated columns now emit generic `JsonColumn<T>` references (e.g. `JsonColumn<List<String>>`) for type-safe JSON equality checks.
- **FIX**: `_updateFields()` no longer overwrites eagerly-loaded associations with null when the bridge response omits them (e.g. after `save()`, `increment()`, `decrement()`).
- **IMPROVEMENT**: JSON type hint extracted from `DataType.JSON(type: ...)` / `DataType.JSONB(type: ...)` and forwarded to column generation.
- **FEAT**: Generated `fromJson` now uses shared parse helpers with structured error reporting (model, field, operation, row index).
- **FEAT**: BIGINT columns generate `SequelizeBigInt` fields instead of plain `String`.
- **FEAT**: JSON/JSONB columns now support `type:` parameter — generates correctly typed `List<T>` / `Map<String, T>` fields with `parseJsonList<T>` / `parseJsonMap<T>` parsers.
- **IMPROVEMENT**: `TINYINT`, `SMALLINT`, `MEDIUMINT` mapped to `int`; `BIGINT` to `SequelizeBigInt`.
- **IMPROVEMENT**: `findAll` passes row index to `fromJson` for per-row error context.

## 0.1.1

- **FIX**: generate `modelName` instead of `name` in generated models to prevent collisions with fields named `name`.
- **FIX**: correct `@Default(...)` emission for string and JSON defaults by preserving annotation source for complex literals.
- **FIX**: always generate `originalQuery` on values classes so generated query assignments are valid.
- **FIX**: serialize `DateTime` fields as ISO-8601 strings in generated `toJson()` output to avoid `jsonEncode` failures.
- **IMPROVEMENT**: make generated DateTime parsing tolerant of `DateTime`, epoch integers, and string payloads.
- **CHORE**: add file-level `ignore_for_file` directives in generated model files to suppress known generated-code warnings.

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
