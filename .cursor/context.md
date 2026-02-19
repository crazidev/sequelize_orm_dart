# Sequelize Dart – Codebase Context

This document summarizes how the Sequelize Dart ORM codebase is structured and how its parts work together. Use it for onboarding and when making changes across packages.

## 1. Package Structure

| Package / Area | Purpose |
|----------------|--------|
| **`packages/sequelize_orm`** | Core ORM: `Sequelize`, `Model`, query API, connection options, bridge client. |
| **`packages/sequelize_orm_generator`** | Build-time generator: reads `@Table` models and emits `*.model.g.dart` (model classes, columns, CRUD, associations). |
| **`packages/sequelize_orm_analyzer`** | Analyzer/lint rules (e.g. table must be abstract). |
| **`example`** | Sample app: `Db` registry, models, seeders, `main.dart` wiring. |
| **`packages/sequelize_orm/js`** | Node bridge: TypeScript server that runs Sequelize.js and handles JSON-RPC. |

## 2. High-Level Flow

1. **Bootstrap:** App calls `Sequelize().createInstance(connection: …, logging: …)` then `await sequelize.initialize(models: Db.allModels())`. That starts the **bridge** (Node process), sends **connect**, then for each model **defineModel** (name, attributes, options). The JS side runs `sequelize.define(...)` and stores the Sequelize model. Then **associateModel** is called for each association (hasOne, hasMany, belongsTo). All of this is JSON-RPC over the bridge.

2. **Queries:** You use the **generated model class** (e.g. `UsersModel()` from `users.model.dart` + `users.model.g.dart`). Calls like `Db.users.findAll(...)`, `findOne(...)`, `create(...)`, `update`, `destroy`, etc. go to the base **`Model`** in `model_impl.dart`. **`QueryEngine`** (`query_engine_impl.dart`) turns that into a single **bridge call** (`findAll`, `findOne`, `create`, …) with `modelName` and serialized options (e.g. `query.toJson()`). The **Node bridge** (`request_handler.ts`) dispatches to handlers (e.g. `handleFindAll`, `handleFindOne`), which use the stored Sequelize model and return plain data. Results are converted to **`ModelInstanceData`** and then into your typed model instances (e.g. `Users`, `UsersValues`) by the generated code.

**Summary:** Dart (typed API) → QueryEngine → bridge (JSON-RPC) → Node (Sequelize.js) → DB.

## 3. Bridge (Dart ↔ Node)

- **Interface:** `BridgeClientInterface`: `start(connectionConfig)`, `call(method, params)`, logging callback, `close`.
- **Implementations:** **Dart VM:** `bridge_client_dart.dart` – spawns a Node process, communicates via **stdio** (JSON-RPC lines). **dart2js:** `bridge_client_js.dart` – uses a **worker thread** (or similar) to run the same Node bridge.
- **Node side:** `packages/sequelize_orm/js` – one process that: handles **connect** (creates Sequelize with the given dialect/URL); **defineModel** (creates and stores the Sequelize model); **associateModel** and all query methods (**findAll**, **findOne**, **create**, **update**, **destroy**, **count**, **max**, **min**, **sum**, **truncate**, **restore**, etc.). So every DB operation is a single `bridge.call('findAll', { model, options })` (or similar); the actual SQL is executed in Node via Sequelize.js.

## 4. Models and Code Generation

- **You write:** An abstract class with `@Table(...)`, e.g. `Users` in `users.model.dart`: fields with `DataType.*` and annotations (`@PrimaryKey`, `@ColumnName`, `Validate.*`, `@HasOne`, `@HasMany`, etc.), and `part 'users.model.g.dart';`.
- **Generator** (`sequelize_model_generator.dart` and its `_generate_*` parts): Finds `@Table` classes and emits a **concrete model class** (e.g. `UsersModel extends Model`) that implements `define`, `$getAttributes` / `$getAttributesJson`, `getOptionsJson`, and **associateModel** (calling `hasOne`/`hasMany`/`belongsTo` as declared). It also emits **column getters** (e.g. for query builders and `where: (users) => users.status.eq(...)`), **Values/Create/Update** classes, and **query builder** / **include helper** so that `findAll`/`findOne` get typed `where` and `include` callbacks.
- **Runtime:** Only the generated class (e.g. `UsersModel`) is instantiated and registered with `Sequelize`. It holds `modelName`, `sequelize`, and forwards all CRUD to **QueryEngine** with that `modelName` and the serialized query.

## 5. Query Building

- **Query** is built from **callbacks**: e.g. `findOne(where: (users) => users.status.eq(UsersStatus.active))`. The generated **columns** object (e.g. `UsersColumns`) exposes typed column references; the callback returns a **QueryOperator** tree.
- **Query** class holds `where`, `include`, `order`, `group`, `limit`, `offset`, `attributes`, `paranoid`.
- **QueryEngine** only sees the serialized form: `query.toJson()` (e.g. `where` as a JSON tree). It passes that to the bridge; the Node side passes it straight to Sequelize’s `findAll`/`findOne` options.

So: **typed Dart callbacks → Query (and QueryOperator tree) → toJson() → bridge → Sequelize options.**

## 6. Example App Flow

- **`example/lib/main.dart`:** Creates `Sequelize` with SQLite (or Postgres/MySQL), calls `initialize(Db.allModels())`, optionally `seed(Db.allSeeders())`, then `runQueries()` and `close()`.
- **`example/lib/db/db.dart`:** Central **Db** registry: `Db.users`, `Db.post`, etc., and `Db.allModels()` / `Db.allSeeders()`.
- **`example/lib/db/models/users.model.dart`:** Declares the `Users` table (columns, validators, `@HasOne`/`@HasMany` to `Post`).
- **`example/lib/queries.dart`:** Uses `Db.users.findOne(where: (users) => users.status.eq(UsersStatus.active))` – this goes through the generated model → QueryEngine → bridge → Sequelize.js.

## 7. Key Files by Concern

| Concern | Files |
|--------|--------|
| **App bootstrap** | `example/lib/main.dart`, `example/lib/db/db.dart` |
| **Sequelize instance & init** | `packages/sequelize_orm/lib/src/sequelize/sequelize_impl.dart` |
| **Model base & CRUD API** | `packages/sequelize_orm/lib/src/model/model_impl.dart` |
| **Running queries** | `packages/sequelize_orm/lib/src/query/query_engine/query_engine_impl.dart` |
| **Query shape** | `packages/sequelize_orm/lib/src/query/query/query.dart` |
| **Bridge (Dart)** | `packages/sequelize_orm/lib/src/bridge/bridge_client_interface.dart`, `bridge_client_dart.dart` (and JS variant) |
| **Bridge (Node)** | `packages/sequelize_orm/js/src/request_handler.ts`, `handlers/*.ts` |
| **Code generation** | `packages/sequelize_orm_generator/lib/src/sequelize_model_generator.dart` and `generators/methods/_generate_*.dart` |
| **Annotations** | `packages/sequelize_orm/lib/src/annotations.dart` and `annotations/*.dart` |

## 8. Tech Stack Summary

- **Dart:** Main app and ORM API; runs as Dart VM or compiled to JS (dart2js).
- **Node.js + Sequelize.js:** All actual DB access; invoked via a bridge process.
- **Code gen:** `build_runner` + `sequelize_orm_generator`; generator uses `source_gen` and analyzer APIs.
- **Supported DBs:** PostgreSQL, MySQL, MariaDB, SQLite (and others via Sequelize.js).
