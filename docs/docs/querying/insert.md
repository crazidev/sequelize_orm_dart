---
sidebar_position: 2
---

# Insert (Creating Data)

Creating data can be done for single records or records with nested associations.

## Simple Create

Create a single record using the generated Create class.

```dart
final newUser = await Users.model.create(
  CreateUsers(
    email: 'newuser@example.com',
    firstName: 'Alice',
    lastName: 'Wonderland',
  ),
);
```

## Nested Create (Create with Associations)

You can create a record and its related associations in one go. This is very useful for setting up a parent object and its children simultaneously.

```dart
final userWithPost = await Users.model.create(
  CreateUsers(
    email: 'author@example.com',
    firstName: 'John',
    lastName: 'Doe',
    // Create the associated 'post' at the same time
    post: CreatePost(
      title: 'My First Post',
      content: 'This is the content of the post.',
    ),
  ),
);
```
