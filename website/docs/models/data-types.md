---
sidebar_position: 2
---

# Data Types

Sequelize Dart supports all major SQL data types:

## Numeric Types

```dart
@ModelAttributes(name: 'id', type: DataType.INTEGER)
dynamic id;

@ModelAttributes(name: 'price', type: DataType.DECIMAL(10, 2))
dynamic price;

@ModelAttributes(name: 'rating', type: DataType.FLOAT)
dynamic rating;
```

## String Types

```dart
@ModelAttributes(name: 'name', type: DataType.STRING)
dynamic name;

@ModelAttributes(name: 'description', type: DataType.TEXT)
dynamic description;

@ModelAttributes(name: 'code', type: DataType.STRING(50))
dynamic code;  // VARCHAR(50)
```

## Date & Time Types

```dart
@ModelAttributes(name: 'created_at', type: DataType.DATE)
dynamic createdAt;

@ModelAttributes(name: 'birthday', type: DataType.DATEONLY)
dynamic birthday;
```

## Boolean Type

```dart
@ModelAttributes(name: 'is_active', type: DataType.BOOLEAN)
dynamic isActive;
```

## JSON Types

```dart
@ModelAttributes(name: 'metadata', type: DataType.JSON)
dynamic metadata;

@ModelAttributes(name: 'settings', type: DataType.JSONB)  // PostgreSQL only
dynamic settings;
```

## UUID Type

```dart
@ModelAttributes(name: 'uuid', type: DataType.UUID)
dynamic uuid;
```
