---
name: MongoDB Support Plan
overview: Plan to add MongoDB support to the sequelize_orm ecosystem via a new `sequelize_orm_mongodb` package, leveraging the near-identical JSON query format between Sequelize operators and MongoDB's native query language.
todos:
  - id: mongo-pkg-scaffold
    content: Create sequelize_orm_mongodb package scaffold (pubspec, exports, LICENSE, CHANGELOG, README)
    status: pending
  - id: mongo-connection
    content: Implement MongoConnection wrapping mongo_dart client with connection config
    status: pending
  - id: mongo-operator-translator
    content: "Implement operator translator: $notIn->$nin, $like->$regex, $startsWith->^regex, $col->$expr, etc."
    status: pending
  - id: mongo-like-to-regex
    content: Implement LIKE pattern to MongoDB regex converter (%, _, escaping)
    status: pending
  - id: mongo-query-engine
    content: Implement MongoQueryEngine (QueryEngineInterface) for all CRUD methods
    status: pending
  - id: mongo-aggregation
    content: Implement aggregation translator for max/min/sum/count/group -> MongoDB aggregation pipeline
    status: pending
  - id: mongo-lookup
    content: Implement include/association translation to $lookup aggregation stages with nested sub-pipelines
    status: pending
  - id: mongo-belongs-to
    content: Implement belongsToGet/Set/Create using MongoDB findOne/updateOne/insertOne
    status: pending
  - id: mongo-paranoid
    content: Implement paranoid (soft delete) via deletedAt field with $unset for restore
    status: pending
  - id: mongo-dialect-caps
    content: Add MongoDB DialectCapabilities (all operators except match, no sync)
    status: pending
  - id: mongo-generator
    content: "Update generator for mongodb dialect: _id primary key convention, skip sync, skip match"
    status: pending
  - id: mongo-analyzer-rules
    content: "Add analyzer lint rules: mongodb_no_schema_sync, mongodb_match_not_supported, mongodb_id_convention"
    status: pending
  - id: mongo-tests
    content: Write tests for operator translation, aggregation pipeline, $lookup generation, and query engine
    status: pending
  - id: mongo-docs
    content: Document MongoDB setup, connection config, operator mapping, and limitations
    status: pending
isProject: false
---

# MongoDB Support for sequelize_orm

## Why MongoDB Is the Easiest Dialect to Add

The ORM's JSON operator format (`$eq`, `$gt`, `$and`, `$or`, etc.) is nearly identical to MongoDB's native query syntax. The query engine is mostly a **pass-through** with minor key renaming, making this the thinnest translation layer of all dialects.

## Operator Mapping

### Direct Pass-Through (no translation needed)

These JSON operators are sent to MongoDB verbatim:

- `$eq`, `$ne`, `$gt`, `$gte`, `$lt`, `$lte`
- `$in` (array)
- `$and`, `$or`, `$not`

### Minor Translation


| ORM JSON Operator     | MongoDB Equivalent                          | Translation                     |
| --------------------- | ------------------------------------------- | ------------------------------- |
| `$notIn: [...]`       | `$nin: [...]`                               | Rename key                      |
| `$between: [a, b]`    | `{$gte: a, $lte: b}`                        | Decompose                       |
| `$notBetween: [a, b]` | `{$lt: a, $gt: b}` wrapped in `$or`         | Decompose                       |
| `$like: '%x%'`        | `{$regex: 'x', $options: ''}`               | Convert LIKE pattern to regex   |
| `$notLike: '%x%'`     | `{$not: {$regex: 'x'}}`                     | Convert + negate                |
| `$iLike: '%x%'`       | `{$regex: 'x', $options: 'i'}`              | Convert + case insensitive flag |
| `$notILike: '%x%'`    | `{$not: {$regex: 'x', $options: 'i'}}`      | Convert + negate                |
| `$startsWith: 'x'`    | `{$regex: '^x'}`                            | Anchor start                    |
| `$endsWith: 'x'`      | `{$regex: 'x$'}`                            | Anchor end                      |
| `$substring: 'x'`     | `{$regex: 'x'}`                             | Unanchored regex                |
| `$regexp: 'pattern'`  | `{$regex: 'pattern'}`                       | Rename key                      |
| `$notRegexp: 'p'`     | `{$not: {$regex: 'p'}}`                     | Rename + negate                 |
| `$iRegexp: 'p'`       | `{$regex: 'p', $options: 'i'}`              | Rename + flag                   |
| `$is: null`           | `{$eq: null}`                               | Simplify                        |
| `$col: 'otherField'`  | `{$expr: {$eq: ['$field', '$otherField']}}` | Use `$expr`                     |


### LIKE Pattern to Regex Conversion

The translator converts SQL LIKE patterns to MongoDB regex:

- `%text%` -> `text` (contains)
- `text%` -> `^text` (starts with)
- `%text` -> `text$` (ends with)
- `_` (single char wildcard) -> `.` (regex any char)
- Escape regex special characters in the literal parts

## Package Structure

```
packages/
  sequelize_orm_mongodb/
    lib/
      sequelize_orm_mongodb.dart          # Barrel export
      src/
        mongo_query_engine.dart           # Implements QueryEngineInterface
        mongo_connection.dart             # Wraps mongo_dart / mongo_db_driver client
        mongo_operator_translator.dart    # JSON ops -> MongoDB query document
        mongo_aggregation.dart            # group/max/min/sum -> aggregation pipeline
        mongo_exceptions.dart             # MongoDB-specific error formatting
    pubspec.yaml
    CHANGELOG.md
    LICENSE
    README.md
```

## MongoConnection

Wraps the Dart MongoDB driver. Two options for the underlying driver:

- `mongo_dart` -- mature, widely used
- `mongo_db_driver` -- newer, official-ish

```dart
class MongoConnection {
  final String url;           // mongodb://localhost:27017/mydb
  final String database;
  // Optional: auth, replica set, SSL, connection pool settings

  MongoConnection({
    required this.url,
    required this.database,
  });
}
```

Usage in `sequelize.yaml`:

```yaml
dialect: mongodb

connection:
  default:
    url: mongodb://localhost:27017/mydb
  dev:
    dialect: mongodb
    host: env.MONGO_HOST
    port: env.MONGO_PORT
    database: env.MONGO_DB
    user: env.MONGO_USER
    password: env.MONGO_PASS
```

## MongoQueryEngine

Implements [packages/sequelize_orm/lib/src/query/query_engine/query_engine_interface.dart](packages/sequelize_orm/lib/src/query/query_engine/query_engine_interface.dart).

### Method Mapping


| QueryEngineInterface Method | MongoDB Implementation                                                          |
| --------------------------- | ------------------------------------------------------------------------------- |
| `findAll`                   | `collection.find(translatedQuery).toList()` with sort/skip/limit                |
| `findOne`                   | `collection.findOne(translatedQuery)`                                           |
| `create`                    | `collection.insertOne(data)` -> return inserted doc                             |
| `bulkCreate`                | `collection.insertMany(dataList)`                                               |
| `update`                    | `collection.updateMany(whereQuery, {$set: data})` -> return modified count      |
| `destroy`                   | `collection.deleteMany(whereQuery)` -> return deleted count                     |
| `count`                     | `collection.count(whereQuery)`                                                  |
| `max`                       | Aggregation: `[{$match: where}, {$group: {_id: null, result: {$max: '$col'}}}]` |
| `min`                       | Aggregation: `[{$match: where}, {$group: {_id: null, result: {$min: '$col'}}}]` |
| `sum`                       | Aggregation: `[{$match: where}, {$group: {_id: null, result: {$sum: '$col'}}}]` |
| `increment`                 | `collection.updateMany(where, {$inc: {field: amount}})` -> re-fetch             |
| `decrement`                 | `collection.updateMany(where, {$inc: {field: -amount}})` -> re-fetch            |
| `save`                      | `collection.replaceOne({_id: id}, doc, upsert: true)`                           |
| `truncate`                  | `collection.deleteMany({})`                                                     |
| `restore`                   | `collection.updateMany(where, {$unset: {deletedAt: ''}})` (paranoid)            |
| `instanceDestroy`           | `collection.deleteOne({_id: id})` or set `deletedAt` if paranoid                |
| `instanceRestore`           | `collection.updateOne({_id: id}, {$unset: {deletedAt: ''}})`                    |


### Associations via `$lookup`

MongoDB's `$lookup` is the aggregation equivalent of SQL JOIN. The `include` JSON from `IncludeBuilder` translates to `$lookup` pipeline stages:

```dart
// ORM: UserModel.findAll(include: (i) => [i.posts()])
// MongoDB aggregation:
[
  { $lookup: {
      from: 'posts',             // from @HasMany(model: Post)
      localField: '_id',         // sourceKey (default: _id)
      foreignField: 'userId',    // foreignKey
      as: 'posts'                // association alias
  }}
]
```

Nested includes become nested `$lookup` with sub-pipelines:

```dart
// ORM: include posts -> include comments
[
  { $lookup: {
      from: 'posts',
      localField: '_id',
      foreignField: 'userId',
      as: 'posts',
      pipeline: [
        { $lookup: {
            from: 'comments',
            localField: '_id',
            foreignField: 'postId',
            as: 'comments'
        }}
      ]
  }}
]
```

Include options map to sub-pipeline stages:

- `where` on include -> `$match` inside the sub-pipeline
- `attributes` on include -> `$project` inside the sub-pipeline
- `order` on include -> `$sort` inside the sub-pipeline
- `limit`/`offset` on include -> `$limit`/`$skip` inside the sub-pipeline
- `required: true` (INNER JOIN) -> add `$match` after `$lookup` to filter docs where the array is non-empty

### BelongsTo Methods


| Method            | MongoDB Implementation                                                            |
| ----------------- | --------------------------------------------------------------------------------- |
| `belongsToGet`    | `db.collection(targetModel).findOne({_id: foreignKeyValue})`                      |
| `belongsToSet`    | `db.collection(sourceModel).updateOne({_id: id}, {$set: {foreignKey: targetId}})` |
| `belongsToCreate` | Insert into target collection, then update source foreign key                     |


## Dialect Capabilities

```dart
static final mongodb = DialectCapabilities(
  supportsLike: true,           // via $regex translation
  supportsRegex: true,          // native $regex
  supportsILike: true,          // via $regex with 'i' flag
  supportsJoin: true,           // via $lookup aggregation
  supportsTruncate: true,       // deleteMany({})
  supportsSync: false,          // schemaless
  supportsGroup: true,          // via aggregation $group
  supportsBetween: true,        // decompose to $gte/$lte
  supportsColComparison: true,  // via $expr
  supportsMatch: false,         // PostgreSQL-specific tsquery
  supportsCollectionGroup: false,
  supportsSubCollections: false,
  maxWhereInValues: -1,         // unlimited
  maxOrClauses: -1,             // unlimited
);
```

**Generator behavior for `dialect: mongodb`:**

- Skip generating `sync()` (schemaless)
- Skip generating `match()` (PostgreSQL-specific)
- Generate all other methods and operators

## Code Generator Changes

When `dialect: mongodb` in `sequelize.yaml`:

- **Primary key:** Generate `_id` field (MongoDB convention) instead of auto-increment `id`. Support both `ObjectId` and custom string/int IDs.
- **No schema sync:** Skip `$getAttributes()` and `$getAttributesJson()` generation (no schema to define)
- **Collection name:** `@Table(tableName: 'users')` maps to MongoDB collection name
- All operators generated (MongoDB supports everything except `match()`)

## Analyzer Lint Rules for MongoDB

Minimal -- MongoDB is very permissive. Only a few rules needed:

`**mongodb_no_schema_sync**`

- Warn if `sync()` is called when dialect is `mongodb`

`**mongodb_match_not_supported**`

- Flag `match()` usage (PostgreSQL full-text search, not available in MongoDB -- suggest `$text` index + `$search` as alternative)

`**mongodb_id_convention**`

- Info hint if primary key is not named `_id` (MongoDB convention, though custom PKs work)

## Comparison: Engine Complexity Across Dialects


| Aspect               | SQL (current)              | MongoDB (new)               | Firestore (new)                 |
| -------------------- | -------------------------- | --------------------------- | ------------------------------- |
| Operator translation | Delegated to Sequelize.js  | ~15 key renames/transforms  | ~10 mappings, many unsupported  |
| Associations         | SQL JOINs (via bridge)     | `$lookup` aggregation       | Sequential sub-collection reads |
| Aggregations         | SQL GROUP BY (via bridge)  | Aggregation pipeline        | Limited (count/sum/avg/min/max) |
| Schema               | DDL via sync()             | Schemaless                  | Schemaless                      |
| Query complexity     | Full SQL                   | Near-full (missing tsquery) | Very limited                    |
| Engine code size     | Thin (delegates to bridge) | Thin (near pass-through)    | Medium (more translation)       |


MongoDB is the **lowest-effort** dialect to add after the dialect-aware infrastructure is built.

## Implementation Order

Recommended order if building both NoSQL dialects:

1. Build dialect-aware infrastructure first (DialectCapabilities, generator changes, analyzer changes) -- from the Firestore plan
2. Build MongoDB engine second (simpler, validates the architecture)
3. Build Firestore engine third (more complex, benefits from lessons learned with MongoDB)

MongoDB serves as a good **proving ground** for the dialect system before tackling Firestore's more restrictive query model.