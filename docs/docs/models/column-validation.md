---
sidebar_position: 5
---

# Column Validation

Add validation rules to ensure data integrity using the `@Validate` namespace annotations:

## Email Validation

```dart
@Validate.IsEmail('Must be a valid email')
DataType email = DataType.STRING;
```

## Length Validation

```dart
@Validate.Len(3, 20, 'Username must be between 3 and 20 characters')
DataType username = DataType.STRING;
```

## Not Empty Validation

```dart
@Validate.NotEmpty('Name cannot be empty')
DataType name = DataType.STRING;
```

## Numeric Range Validation

```dart
@Validate.Min(0, 'Age must be positive')
@Validate.Max(150, 'Age looks invalid')
DataType age = DataType.INTEGER;
```

## Custom Validation

For more complex validation that requires custom logic, you can implement validation methods in your business logic or use lifecycle hooks, as Dart annotations are static constant values.

## Supported Validators

- `@Validate.IsEmail([msg])`
- `@Validate.IsUrl([msg])`
- `@Validate.IsIP([msg])`
- `@Validate.IsAlpha([msg])`
- `@Validate.IsAlphanumeric([msg])`
- `@Validate.IsNumeric([msg])`
- `@Validate.IsInt([msg])`
- `@Validate.IsFloat([msg])`
- `@Validate.IsDecimal([msg])`
- `@Validate.IsLowercase([msg])`
- `@Validate.IsUppercase([msg])`
- `@Validate.NotEmpty([msg])`
- `@Validate.Equals(value, [msg])`
- `@Validate.Contains(value, [msg])`
- `@Validate.Min(value, [msg])`
- `@Validate.Max(value, [msg])`
- `@Validate.Len(min, max, [msg])`
- `@Validate.IsIn(list, [msg])`
- `@Validate.NotIn(list, [msg])`
