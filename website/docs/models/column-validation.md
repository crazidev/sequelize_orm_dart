---
sidebar_position: 5
---

# Column Validation

Add validation rules to ensure data integrity:

## Email Validation

```dart
@ModelAttributes(
  name: 'email',
  type: DataType.STRING,
  validate: ValidateOption(
    isEmail: IsEmail(),
  ),
)
dynamic email;
```

## Length Validation

```dart
@ModelAttributes(
  name: 'username',
  type: DataType.STRING,
  validate: ValidateOption(
    len: Len(min: 3, max: 20),
  ),
)
dynamic username;
```

## Not Empty Validation

```dart
@ModelAttributes(
  name: 'name',
  type: DataType.STRING,
  validate: ValidateOption(
    notEmpty: NotEmpty(),
  ),
)
dynamic name;
```

## Numeric Range Validation

```dart
@ModelAttributes(
  name: 'age',
  type: DataType.INTEGER,
  validate: ValidateOption(
    min: Min(0),
    max: Max(150),
  ),
)
dynamic age;
```

## Custom Validation

```dart
@ModelAttributes(
  name: 'password',
  type: DataType.STRING,
  validate: ValidateOption(
    len: Len(min: 8),
    // Add custom validation logic in your application code
  ),
)
dynamic password;
```
