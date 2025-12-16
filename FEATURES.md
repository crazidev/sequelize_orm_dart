# Sequelize Dart - Feature Status

## Core Features

### Connection & Setup

- ✅ **Database Connections**
  - ✅ PostgreSQL
  - ✅ MySQL
  - ✅ MariaDB
  - ❌ SQLite (defined but not fully tested)
- ✅ **Connection Pooling** (max, min, idle, acquire, evict)
- ✅ **Connection URL Support**
- ✅ **SSL Configuration**
- ✅ **Logging Support**
- ✅ **Authentication** (`authenticate()`)
- ✅ **Model Registration** (`addModels()`, `define()`)
- ✅ **Connection Cleanup** (`close()`)

### Platform Support

- ✅ **Dart Server (VM)** - via Node.js bridge
- ✅ **dart2js** - via JS interop
- ✅ **Code Generation** - via build_runner

---

## Query Methods

### Model Query Methods

- ✅ **findAll** - Find all records matching query (accepts typed query builder: `(q) => Query(...)`)
- ✅ **findOne** - Find one record matching query (accepts typed query builder: `(q) => Query(...)`)
- ✅ **create** - Create a new record (interface defined, bridge implemented)
- ❌ **update** - Update records
- ❌ **destroy/delete** - Delete records
- ❌ **findByPk** - Find by primary key
- ❌ **count** - Count records
- ❌ **bulkCreate** - Create multiple records
- ❌ **upsert** - Insert or update
- ❌ **findOrCreate** - Find or create record

---

## Query Options

### Query Class Properties

- ✅ **where** - Where conditions
- ✅ **order** - Order by clauses `[['column', 'ASC|DESC']]`
- ✅ **limit** - Maximum number of records
- ✅ **offset** - Number of records to skip
- ✅ **include** - Associations/joins (defined but not fully implemented)

---

## Operators

### Logical Operators

- ✅ **and** - AND condition
- ✅ **or** - OR condition
- ✅ **not** - NOT condition

### Basic Comparison Operators

- ✅ **eq** / **equal** - Equal (=)
- ✅ **ne** / **notEqual** - Not equal (!=)
- ✅ **is\_** - IS NULL
- ✅ **not\_** - IS NOT

### Number Comparison Operators

- ✅ **gt** / **greaterThan** - Greater than (>)
- ✅ **gte** / **greaterThanOrEqual** - Greater than or equal (>=)
- ✅ **lt** / **lessThan** - Less than (<)
- ✅ **lte** / **lessThanOrEqual** - Less than or equal (<=)
- ✅ **between** - BETWEEN value1 AND value2
- ✅ **notBetween** - NOT BETWEEN value1 AND value2

### List Operators

- ✅ **in\_** - IN [value1, value2, ...]
- ✅ **notIn** - NOT IN [value1, value2, ...]
- ✅ **all** - > ALL (SELECT ...)
- ✅ **any** - ANY (ARRAY[...]) (PostgreSQL only)

### String Operators

- ✅ **like** / **like\_** - LIKE '%pattern%'
- ✅ **notLike** - NOT LIKE '%pattern%'
- ✅ **startsWith** - LIKE 'pattern%'
- ✅ **endsWith** - LIKE '%pattern'
- ✅ **substring** - LIKE '%pattern%'
- ✅ **iLike** - ILIKE '%pattern%' (PostgreSQL only)
- ✅ **notILike** - NOT ILIKE '%pattern%' (PostgreSQL only)

### Regex Operators

- ✅ **regexp** - REGEXP/~ 'pattern' (MySQL/PostgreSQL only)
- ✅ **notRegexp** - NOT REGEXP/!~ 'pattern' (MySQL/PostgreSQL only)
- ✅ **iRegexp** - ~\* 'pattern' (PostgreSQL only)
- ✅ **notIRegexp** - !~\* 'pattern' (PostgreSQL only)

### Other Operators

- ✅ **col** - Column reference (= "table"."column")
- ✅ **match** - Text search match (PostgreSQL only)
- ❌ **fn** - Database function call (e.g., `sequelize.fn('upper', ...)`)
- ❌ **literal** - SQL literal
- ❌ **cast** - Type casting
- ❌ **where** - Complex where conditions

---

## Type-Safe Query Builder

### Column Class

- ✅ **Type-safe column references** - `Column<T>`
- ✅ **All comparison operators** - Available on Column
- ✅ **All string operators** - Available on Column
- ✅ **All number operators** - Available on Column
- ✅ **All list operators** - Available on Column
- ✅ **All regex operators** - Available on Column
- ✅ **col() method** - Column reference on Column
- ✅ **match() method** - Text search match on Column
- ✅ **Legacy aliases** - `equal()`, `not()`, `greaterThan()`, etc.

---

## Sequelize Instance Methods

### Core Methods

- ✅ **createInstance()** - Create Sequelize instance
- ✅ **authenticate()** - Verify connection
- ✅ **addModels()** - Register models
- ✅ **define()** - Define model manually
- ✅ **close()** - Close connection
- ❌ **fn()** - Create database function call
- ❌ **col()** - Create column reference
- ❌ **literal()** - Create SQL literal
- ❌ **cast()** - Type casting
- ❌ **where()** - Complex where builder

---

## Data Types

### Supported Data Types (via annotations)

- ✅ **STRING** / **VARCHAR** / **TEXT**
- ✅ **INTEGER** / **INT**
- ✅ **BIGINT**
- ✅ **FLOAT** / **DOUBLE** / **REAL**
- ✅ **BOOLEAN**
- ✅ **DATE** / **DATEONLY** / **TIME**
- ✅ **UUID**
- ✅ **JSON** / **JSONB**
- ✅ **ARRAY** (PostgreSQL)
- ✅ **ENUM**
- ✅ **BLOB** / **BINARY**

---

## Model Features

### Model Attributes

- ✅ **Primary Key** - `primaryKey: true`
- ✅ **Auto Increment** - `autoIncrement: true`
- ✅ **Unique** - `unique: true`
- ✅ **Allow Null** - `allowNull: true/false`
- ✅ **Default Value** - `defaultValue`
- ✅ **Data Types** - All Sequelize data types
- ❌ **Validations** - Field validations
- ❌ **Getters/Setters** - Custom getters/setters
- ❌ **Virtual Fields** - Virtual attributes

### Model Options

- ✅ **Table Name** - Custom table name
- ✅ **Timestamps** - `createdAt`, `updatedAt`
- ✅ **Paranoid** - Soft deletes
- ❌ **Indexes** - Database indexes
- ❌ **Hooks** - Model lifecycle hooks
- ❌ **Scopes** - Default scopes
- ❌ **Associations** - Relationships (hasOne, belongsTo, etc.)

---

## Associations / Relationships

- ❌ **hasOne** - One-to-one relationship
- ❌ **belongsTo** - Belongs to relationship
- ❌ **hasMany** - One-to-many relationship
- ❌ **belongsToMany** - Many-to-many relationship
- ❌ **Eager Loading** - Include associations in queries

---

## Transactions

- ❌ **Transaction Support** - Database transactions
- ❌ **Savepoints** - Nested transactions
- ❌ **Isolation Levels** - Transaction isolation

---

## Migrations

- ❌ **Migration Support** - Database migrations
- ❌ **Migration CLI** - Migration commands

---

## Raw Queries

- ❌ **query()** - Execute raw SQL queries
- ❌ **sequelize.query()** - Raw query execution

---

## Hooks / Lifecycle Events

- ❌ **Before Create** - `beforeCreate`
- ❌ **After Create** - `afterCreate`
- ❌ **Before Update** - `beforeUpdate`
- ❌ **After Update** - `afterUpdate`
- ❌ **Before Destroy** - `beforeDestroy`
- ❌ **After Destroy** - `afterDestroy`
- ❌ **Before Find** - `beforeFind`
- ❌ **After Find** - `afterFind`

---

## Summary

### ✅ Implemented (Completed)

- Core connection and setup
- Basic CRUD operations (findAll, findOne, create)
- All comparison operators
- All logical operators
- All string operators
- All regex operators
- Type-safe query builder (Column)
- Type-safe query methods (findAll/findOne accept typed query builder functions)
- Connection pooling
- Multiple database support (PostgreSQL, MySQL, MariaDB)
- Code generation for type-safe queries

### ❌ Not Implemented (Pending)

- Update operations
- Delete operations
- Advanced query methods (findByPk, count, bulkCreate, etc.)
- Sequelize.fn() and sequelize.col() methods
- Associations/relationships
- Transactions
- Migrations
- Raw queries
- Model hooks
- Validations
- Scopes
- Indexes

---

## Notes

- The `create()` method is defined in the interface and implemented in the bridge server, but may need additional testing.
- Type-safe queries via `findAllTyped()` are generated by the code generator, not part of the core package.
- The `include` option is defined in Query but associations are not yet implemented.
- SQLite dialect is defined but not fully tested.
