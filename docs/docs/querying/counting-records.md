---
sidebar_position: 4
---

# Counting Records

## count

Counts the number of records matching the query conditions.

Returns the total count of records that match the specified criteria.

**Parameters:**

- `where`: Optional query conditions to filter records

**Returns:** A `Future` that completes with the count as an integer.

**Example:**

```dart
// Count all users
final total = await Users.instance.count();

// Count with conditions
final activeCount = await Users.instance.count(
  where: Users.instance.email.isNotNull(),
);
```
