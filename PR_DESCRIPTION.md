# Pull Request: Include Order Hoisting & Bridge Stability

## Summary

This PR introduces support for hoisting `order` clauses from nested includes to the top-level query, enabling complex sorting scenarios involving associated models. It also enhances `Sequelize.fn` usability and improves the stability of the Node.js bridge process.

## Changes

### 🚀 Features

- **Hoist Include Options**: Added support for `hoistIncludeOptions` in `SequelizeCoreOptions`. When enabled, `order` and `group` clauses defined in nested includes are moved to the top-level query, allowing correct sorting by associated columns (e.g., `ORDER BY "post"."id" DESC`).
- **Sequelize.fn Enhancements**: `Sequelize.fn` now accepts a single argument for function parameters, no longer mandating a list (e.g., `Sequelize.fn('max', Sequelize.col('id'))` is now valid).
- **IncludeBuilder Improvements**: Added `copyWith` method to `IncludeBuilder` and support for properties like `duplicating`, `on`, `or`, and `subQuery`.

### 🐛 Bug Fixes & Stability

- **Bridge Stability**:
  - Fixed a race condition where the bridge process cleanup logic could affect newly started processes during rapid restarts.
  - Resolved "Cannot add new events after calling close" error by properly recreating the response stream controller on bridge restart.
  - Removed redundant error throwing in the stdout handler that conflicted with the exit code listener.

### 🧪 Testing

- **New Ordering Test Suite**: Added `test/ordering_test.dart` covering:
  - Simple column ordering.
  - usage of `Sequelize.fn` and `Sequelize.col` in `order`.
  - Ordering by columns in included models.
  - Verification of `hoistIncludeOptions` behavior.
- **Refactoring**: Reorganized tests to the workspace root and updated them to use the new callback naming conventions.

## Verification

Run the new ordering tests:

```bash
dart test test/ordering_test.dart
```

Run all tests:

```bash
dart test
```
