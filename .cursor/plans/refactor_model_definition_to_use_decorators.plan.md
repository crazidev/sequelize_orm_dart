# Refactor Model Definition to Use Decorators

## Overview

Refactor to support two patterns for defining model attributes:

1. **Primary pattern** (new): Decorator-based syntax - `DataType fieldName = DataType.TYPE;` with decorators like `@NotNull()`, `@PrimaryKey()`, etc.
2. **Secondary pattern** (legacy): Annotation-based syntax - `@Column(...)` annotation (renamed from `@ModelAttributes`)

Note: The `ModelAttributes` class name remains unchanged in generated code - only the annotation decorator is renamed to `@Column`.

## Changes Required

### 1. Rename ModelAttributes Annotation to Column

**File**: `packages/sequelize_orm_annotations/lib/src/model_attribute.dart`

- Create a new annotation class `Column` that accepts the same parameters as `ModelAttributes`
- This will be used as `@Column(...)` annotation
- Keep `ModelAttributes` class as-is (used in generated code)
- Add `Column` as an alias/annotation class

**Approach**: Create a `Column` class that is a const constructor wrapper around `ModelAttributes` parameters, or create a separate annotation class.

### 2. Add Missing Decorators to Annotations Package

**File**: `packages/sequelize_orm_annotations/lib/src/table.dart`

Add decorator classes matching Sequelize 7 API:

- `AllowNull` - Optional decorator (no parameters)
- `ColumnName(String)` - Required parameter decorator
- `Default` - Decorator with multiple constructors:
  - `Default(dynamic)` - Simple value (e.g., `@Default('value')`)
  - `Default.uniqid()` - Named constructor for uniqid function (maps to `() => uniqid()`)
  - `Default.now()` - Named constructor for NOW (maps to `DataTypes.NOW`)
  - `Default.fn(String)` - Named constructor for SQL functions (maps to `sql.fn('functionName')`)
- `Comment(String)` - Required parameter decorator
- `Unique(UniqueOption? | String?)` - Optional parameter decorator
- `Index(IndexOption? | String?)` - Optional parameter decorator

These should be added after the existing `PrimaryKey`, `NotNull`, and `AutoIncrement` classes (around line 288).

### 3. Update Field Info Model

**File**: `packages/sequelize_orm_generator/lib/src/generators/methods/_models.dart`

Extend `_FieldInfo` class to include new properties:

- `columnName` (String?)
- `comment` (String?)
- `unique` (Object? - bool | String | UniqueOption)
- `index` (Object? - bool | String | IndexOption)
- `autoIncrementIdentity` (bool?)

Update constructor to accept these parameters with defaults.

### 4. Refactor Field Extraction Logic

**File**: `packages/sequelize_orm_generator/lib/src/generators/methods/_get_fields.dart`

Major refactor to support both patterns:

#### Pattern 1: Decorator-based (Primary)

Detect fields like:

```dart
@NotNull()
DataType lastName = DataType.STRING;
```

1. Check if field type is `DataType` enum
2. Read initializer to extract enum value name (e.g., `DataType.INTEGER` → `"INTEGER"`)
3. Parse decorators using `TypeChecker`:
   - `@PrimaryKey()` → `primaryKey: true`
   - `@AutoIncrement()` → `autoIncrement: true`
   - `@NotNull()` → `allowNull: false`
   - `@AllowNull()` → `allowNull: true`
   - `@ColumnName('name')` → `columnName: 'name'`
   - `@Default(value)` → `defaultValue: value` (simple value)
   - `@Default.uniqid()` → `defaultValue: ...` (uniqid function)
   - `@Default.now()` → `defaultValue: ...` (DataTypes.NOW)
   - `@Default.fn('random')` → `defaultValue: sql.fn('random')`
   - `@Comment('text')` → `comment: 'text'`
   - `@Unique(...)` → `unique: ...`
   - `@Index(...)` → `index: ...`

4. Default to `allowNull: true` if no `@NotNull()` or `@AllowNull()` decorator

#### Pattern 2: Annotation-based (Secondary/Legacy)

Detect fields like:

```dart
@Column(
  name: 'id',
  type: DataType.INTEGER,
  primaryKey: true,
  autoIncrement: true,
)
dynamic id;
```

1. Check for `@Column` annotation (using TypeChecker)
2. Extract parameters from annotation (reuse existing `@ModelAttributes` logic but update to check for `@Column`)
3. Map annotation parameters to `_FieldInfo` properties

#### Implementation Strategy

- Check field annotations first for `@Column` (legacy pattern)
- If not found, check if field type is `DataType` (new pattern)
- Extract field information using appropriate method
- Build `_FieldInfo` from extracted data

### 5. Update Attribute Generation

**File**: `packages/sequelize_orm_generator/lib/src/generators/methods/_generate_get_attributes_method.dart`

Update to generate `ModelAttributes` with all new properties:

- `columnName` (if set)
- `comment` (if set)
- `unique` (if set - handle bool/String/UniqueOption cases)
- `index` (if set - handle bool/String/IndexOption cases)
- `autoIncrementIdentity` (if set)
- `allowNull` (explicitly set based on decorators/annotation, default to true if not specified)

### 6. Export New Decorators and Column

**File**: `packages/sequelize_orm_annotations/lib/sequelize_orm_annotations.dart`

Ensure all new decorators and `Column` annotation are exported.

## Implementation Details

### Column Annotation

The `Column` annotation should accept the same parameters as `ModelAttributes` constructor:

- `name` (String, required)
- `type` (DataType, required)
- `allowNull` (bool?)
- `columnName` (String?)
- `defaultValue` (dynamic)
- `unique` (Object?)
- `index` (Object?)
- `primaryKey` (bool?)
- `autoIncrement` (bool?)
- `autoIncrementIdentity` (bool?)
- `comment` (String?)
- `validate` (ValidateOption?)

### Default Decorator Implementation

The `Default` decorator class should have:

```dart
class Default {
  final dynamic value;
  final DefaultType? type;
  final String? functionName;

  // Simple value constructor
  const Default(this.value) : type = null, functionName = null;

  // Named constructors for special cases
  const Default.uniqid() : value = null, type = DefaultType.uniqid, functionName = null;
  const Default.now() : value = null, type = DefaultType.now, functionName = null;
  const Default.fn(this.functionName) : value = null, type = DefaultType.fn;
}

enum DefaultType { uniqid, now, fn }
```

The generator needs to extract the constructor name and parameters to determine which type of default value to generate.

### TypeChecker Updates

Update TypeChecker references in generator:

- Change `ModelAttributes` checker to also check for `Column`
- Or create separate checkers and handle both
- For `@Default`, check constructor name to determine type (default, uniqid, now, fn)

### Backward Compatibility

- Support both `@Column` and `@ModelAttributes` annotations (check for both in generator)
- Or deprecate `@ModelAttributes` in favor of `@Column`
- Generated code continues to use `ModelAttributes` class name

## Testing Considerations

- Test decorator-based pattern with various combinations
- Test `@Column` annotation pattern (legacy)
- Test default nullable behavior (no decorator)
- Test all new decorator types
- Test validation decorators
- Verify generated `ModelAttributes` match expected output
- Test migration from `@ModelAttributes` to `@Column`
