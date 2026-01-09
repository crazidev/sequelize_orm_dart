# Adding New Query Implementations

This guide explains how to add a new query method to Sequelize Dart. We'll use `destroy` as an example.

## Overview

Adding a new query method requires changes in multiple layers:

1. **Interface** - Define the abstract method signature
2. **Dart VM Engine** - Implement bridge communication
3. **JS Engine** - Implement JS interop
4. **Bridge Handler** - Handle the RPC call in Node.js
5. **Bridge Server** - Register the handler
6. **Generator** - Generate the method in models

## Step-by-Step Guide

### Step 1: Define Interface

**File**: `packages/sequelize_dart/lib/src/query/query_engine/query_engine_interface.dart`

```dart
abstract class QueryEngineInterface {
  // ... existing methods ...

  /// Delete records matching the query
  Future<int> destroy({
    required String modelName,
    Query? query,
    dynamic sequelize,
    dynamic model,
  });
}
```

### Step 2: Implement Dart VM Engine

**File**: `packages/sequelize_dart/lib/src/query/query_engine/query_engine_dart.dart`

```dart
@override
Future<int> destroy({
  required String modelName,
  Query? query,
  dynamic sequelize,
  dynamic model,
}) async {
  try {
    final result = await getBridge(sequelize).call('destroy', {
      'model': modelName,
      'options': query?.toJson(),
    });

    if (result is int) {
      return result;
    }

    if (result is num) {
      return result.toInt();
    }

    throw Exception(
      'Invalid response format from bridge: expected int, got ${result.runtimeType}',
    );
  } catch (e) {
    if (e is BridgeException) {
      rethrow;
    }
    throw Exception('Failed to execute destroy: $e');
  }
}
```

### Step 3: Implement JS Engine

**File**: `packages/sequelize_dart/lib/src/query/query_engine/query_engine_js.dart`

```dart
@override
Future<int> destroy({
  required String modelName,
  Query? query,
  dynamic sequelize,
  dynamic model,
}) async {
  final options = _convertQueryOptions(
    query?.toJson(),
    sequelize as JSObject?,
  );
  final res = await (model as SequelizeModel).destroy(options).toDart;

  final result = res.dartify();
  if (result is int) {
    return result;
  }
  if (result is num) {
    return result.toInt();
  }
  throw Exception(
    'Invalid response format from destroy: expected int, got ${result.runtimeType}',
  );
}
```

Also add to `SequelizeModel` JS interop class if needed:

```dart
@JS()
extension type SequelizeModel(JSObject _) implements JSObject {
  // ... existing methods ...
  external JSPromise destroy(JSObject? options);
}
```

### Step 4: Create Bridge Handler

**File**: `packages/sequelize_dart/js/src/handlers/destroy.ts`

```typescript
import { checkConnection, checkModelDefinition } from '../utils/checkUtils';
import { convertQueryOptions } from '../utils/queryConverter';
import { getModels, getSequelize } from '../utils/state';

type DestroyParams = {
  model: string;
  options?: any;
};

export async function handleDestroy(params: DestroyParams): Promise<number> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const modelName = params.model;
  const options = convertQueryOptions(params.options || {});

  const model = getModels().get(modelName);
  checkModelDefinition(model, modelName);

  const result = await model.destroy(options);
  return result;
}
```

### Step 5: Register Handler in Bridge Server

**File**: `packages/sequelize_dart/js/src/bridge_server.ts`

```typescript
// Add import
import { handleDestroy } from './handlers/destroy';

// Add case in handleRequest switch
case 'destroy':
  result = await handleDestroy(params);
  break;
```

### Step 6: Create Generator Method

**File**: `packages/sequelize_dart_generator/lib/src/generators/methods/_generate_destroy_method.dart`

```dart
part of '../../sequelize_model_generator.dart';

void _generateDestroyMethod(
  StringBuffer buffer,
  String className,
  String whereCallbackName,
) {
  final columnsClassName = '\$${className}Columns';

  buffer.writeln('  @override');
  buffer.writeln('  Future<int> destroy({');
  buffer.writeln(
    '    required QueryOperator Function($columnsClassName $whereCallbackName) where,',
  );
  buffer.writeln('  }) {');
  buffer.writeln('    final columns = $columnsClassName();');
  buffer.writeln('    final query = Query.fromCallbacks(');
  buffer.writeln('      where: where,');
  buffer.writeln('      columns: columns,');
  buffer.writeln('    );');
  buffer.writeln('    return QueryEngine().destroy(');
  buffer.writeln('      modelName: name,');
  buffer.writeln('      query: query,');
  buffer.writeln('      sequelize: sequelizeInstance,');
  buffer.writeln('      model: sequelizeModel,');
  buffer.writeln('    );');
  buffer.writeln('  }');
  buffer.writeln();
}
```

### Step 7: Register Generator in Main Generator

**File**: `packages/sequelize_dart_generator/lib/src/sequelize_model_generator.dart`

Add the part directive:

```dart
part 'generators/methods/_generate_destroy_method.dart';
```

Call the generator in `generateForAnnotatedElement()`:

```dart
_generateDestroyMethod(
  buffer,
  className,
  baseCallbackName,
);
```

### Step 8: Add Base Model Method (Optional)

If you want a default implementation in the base Model class:

**File**: `packages/sequelize_dart/lib/src/model/model_dart.dart`

```dart
Future<int> destroy({
  required QueryOperator Function(dynamic columns) where,
}) async {
  throw UnimplementedError('destroy not implemented for this model');
}
```

## Adding a New Operator

### Step 1: Create Extension

**File**: `packages/sequelize_dart/lib/src/query/operators/extentions/your_operators.dart`

```dart
import 'package:sequelize_dart/src/query/operators/operators_interface.dart';
import 'package:sequelize_dart/src/query/typed_column.dart';

extension YourExtension<T> on Column<T> {
  /// Example operator
  ComparisonOperator myOperator(T value) {
    return ComparisonOperator(
      column: name,
      value: {'\$myOp': value},
    );
  }
}
```

### Step 2: Export the Extension

**File**: `packages/sequelize_dart/lib/src/query/operators/extentions/extensions.dart`

```dart
export 'your_operators.dart';
```

### Step 3: Add to JS Engine Op Symbol Mapping

**File**: `packages/sequelize_dart/lib/src/query/query_engine/query_engine_js.dart`

In `_getOpSymbol()`:

```dart
'\$myOp' => op.myOp,
```

### Step 4: Add to Bridge Query Converter

**File**: `packages/sequelize_dart/js/src/utils/queryConverter.ts`

In `convertWhereClause()`:

```typescript
case '$myOp':
  converted[Op.myOp] = convertedValue;
  break;
```

### Step 5: Add Test

**File**: `test/operators/your_operators_test.dart`

```dart
import 'package:test/test.dart';
import '../test_helper.dart';

void main() {
  setUpAll(() async => await initTestEnvironment());
  tearDownAll(() async => await cleanupTestEnvironment());
  setUp(() => clearCapturedSql());

  group('Your Operators', () {
    test('myOperator produces correct SQL', () async {
      await Users.instance.findAll(where: (u) => u.id.myOperator(1));
      expect(lastSql, contains('expected SQL pattern'));
    });
  });
}
```

## Pattern Reference

### Bridge Call Pattern (Dart VM)

```dart
final result = await getBridge(sequelize).call('methodName', {
  'model': modelName,
  'options': query?.toJson(),
  // additional params
});
```

### JS Interop Pattern

```dart
final options = _convertQueryOptions(query?.toJson(), sequelize as JSObject?);
final res = await (model as SequelizeModel).methodName(options).toDart;
final result = res.dartify();
```

### Generator Pattern

```dart
void _generateMethodName(StringBuffer buffer, ...) {
  buffer.writeln('  @override');
  buffer.writeln('  Future<ReturnType> methodName({');
  // parameters
  buffer.writeln('  }) {');
  // implementation
  buffer.writeln('  }');
}
```

### Handler Pattern (TypeScript)

```typescript
export async function handleMethodName(params: ParamsType): Promise<ResultType> {
  const sequelize = getSequelize();
  checkConnection(sequelize);

  const model = getModels().get(params.model);
  checkModelDefinition(model, params.model);

  const options = convertQueryOptions(params.options || {});
  return await model.methodName(options);
}
```

## Testing Your Implementation

1. **Build the bridge**: `./tools/setup_bridge.sh`
2. **Generate code**: `cd example && dart run build_runner build --delete-conflicting-outputs`
3. **Run tests**: `dart test test/your_test.dart`
4. **Manual test**: Update `example/lib/queries.dart` and run `dart run lib/main.dart`

## Common Gotchas

1. **JSON Serialization**: Ensure all data types can be serialized to JSON for bridge communication
2. **JS Interop Types**: Use proper JS types (`JSObject`, `JSArray`, etc.) in the JS engine
3. **Async Handling**: Both engines are async - use proper Future handling
4. **Error Handling**: Catch and rethrow `BridgeException` in Dart VM engine
5. **Query Conversion**: The `_convertQueryOptions()` function handles where, include, order, etc.
