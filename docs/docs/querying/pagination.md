---
sidebar_position: 7
---

# Limiting and Pagination

## Limit

Limit the number of results:

```dart
final users = await Users.instance.findAll(
  limit: 10,
);
```

## Offset

Skip a number of records (useful for pagination):

```dart
final users = await Users.instance.findAll(
  limit: 10,
  offset: 20,  // Skip first 20 records
);
```

## Pagination Example

```dart
Future<List<Users>> getUsersPage(int page, int pageSize) async {
  return await Users.instance.findAll(
    limit: pageSize,
    offset: (page - 1) * pageSize,
    order: Users.instance.id.desc(),
  );
}
```
