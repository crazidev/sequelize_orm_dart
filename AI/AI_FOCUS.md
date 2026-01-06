# Sequelize Dart - Development Focus Areas

## Primary Focus Areas

### 1. Platform Separation Integrity

**Critical Focus**: Maintain strict separation between JS interop and Dart VM code

**Why This Matters**:

- Prevents runtime crashes when JS APIs are unavailable
- Ensures clean compilation on both platforms
- Maintains type safety across platforms

**Key Patterns to Enforce**:

```dart
// ALWAYS use conditional exports
export 'component_stub.dart'
    if (dart.library.js_interop) 'component_js.dart'
    if (dart.library.io) 'component_dart.dart';

// NEVER import JS interop directly in shared code
// WRONG: import 'dart:js_interop' in shared files
// CORRECT: Only in *_js.dart files
```

**Validation Checklist**:

- [ ] No `dart:js_interop` imports in shared files
- [ ] All platform-specific code behind conditional exports
- [ ] Stub files throw `UnimplementedError`
- [ ] Both platform implementations exist

### 2. Bridge Communication Reliability

**Critical Focus**: Robust JSON-RPC communication with Node.js bridge

**Why This Matters**:

- Bridge is the lifeline for Dart VM platform
- Errors here affect all database operations
- Process management is complex and error-prone

**Key Areas to Monitor**:

```dart
// Bridge lifecycle management
await bridge.start(connectionConfig: config);
if (!bridge.isConnected) {
  throw Exception('Bridge connection failed');
}

// Error handling with context
try {
  final result = await bridge.call('method', params);
} catch (e) {
  if (e is BridgeException) {
    // Detailed error information available
    print('Error: ${e.message}');
    print('Code: ${e.code}');
    print('SQL: ${e.sql}');
  }
}
```

**Focus Points**:

- [ ] Process startup and monitoring
- [ ] Connection state management
- [ ] Error propagation with context
- [ ] Graceful shutdown and cleanup
- [ ] Request timeout handling

### 3. Type-Safe Query Building

**Critical Focus**: Generated query builders with full type safety

**Why This Matters**:

- Prevents runtime SQL errors
- Provides excellent IDE support
- Catches type mismatches at compile time

**Generated Pattern**:

```dart
// Type-safe column access
final users = await Users.instance.findAll(
  (q) => Query(
    where: and([
      q.id.gt(10),           // Compile-time type checking
      q.email.like('%@%'),   // Autocomplete support
    ]),
  ),
);
```

**Focus Areas**:

- [ ] Code generation accuracy
- [ ] Type safety in query builders
- [ ] Operator implementation completeness
- [ ] Generated code compilation

### 4. JS Interop Performance

**Critical Focus**: Efficient JavaScript interop for dart2js platform

**Why This Matters**:

- Direct JS calls vs bridge overhead
- Memory management in JS environment
- Type conversion efficiency

**Optimization Patterns**:

```dart
// Efficient extension types
extension type SequelizeJS._(JSObject _) implements JSObject {
  @JS('authenticate')
  external JSPromise authenticate();
}

// Minimal conversion overhead
await model.findAll(options).toDart;
```

**Focus Points**:

- [ ] Extension type usage
- [ ] Minimal JS/Dart conversions
- [ ] Direct API calls where possible
- [ ] Memory leak prevention

## Secondary Focus Areas

### 5. Error Handling Consistency

**Important Focus**: Consistent error patterns across platforms

**Why This Matters**:

- Predictable error handling for users
- Easier debugging and troubleshooting
- Platform-agnostic error information

**Pattern to Maintain**:

```dart
// Consistent error structure
try {
  final result = await someOperation();
} catch (e) {
  if (e is BridgeException) {
    // Bridge-specific handling
  } else if (e is JsException) {
    // JS-specific handling
  } else {
    // Generic handling
    rethrow;
  }
}
```

### 6. Code Generation Maintainability

**Important Focus**: Robust code generation for model implementations

**Why This Matters**:

- Generated code is critical for functionality
- Generation errors break user applications
- Complex annotation processing

**Key Areas**:

- [ ] Annotation parsing accuracy
- [ ] Generated code compilation
- [ ] Platform-specific generation
- [ ] Error handling in generation

### 7. Connection Pool Management

**Important Focus**: Efficient database connection handling

**Why This Matters**:

- Performance under load
- Resource management
- Connection lifecycle

**Focus Points**:

- [ ] Pool configuration validation
- [ ] Connection leak prevention
- [ ] Pool exhaustion handling
- [ ] Graceful degradation

### 8. Testing Coverage

**Important Focus**: Comprehensive testing across platforms

**Why This Matters**:

- Dual platform complexity
- Bridge communication testing
- JS interop validation

**Testing Strategy**:

```dart
// Platform-specific tests
test('Bridge communication', () async {
  // Test bridge-specific functionality
});

test('JS interop operations', () async {
  // Test JS-specific functionality
});

// Cross-platform tests
test('Query builder consistency', () async {
  // Test same behavior on both platforms
});
```

## Implementation Priorities

### High Priority (Core Functionality)

1. **Conditional Export Integrity**
   - Audit all conditional exports
   - Validate platform separation
   - Test compilation on both platforms

2. **Bridge Reliability**
   - Process management improvements
   - Error handling enhancements
   - Connection state validation

3. **Query Builder Type Safety**
   - Complete operator implementation
   - Generated code validation
   - Type checking improvements

### Medium Priority (Enhancement)

4. **JS Interop Optimization**
   - Extension type coverage
   - Performance profiling
   - Memory usage optimization

5. **Error Handling Standardization**
   - Consistent error types
   - Better error messages
   - Platform-agnostic handling

6. **Testing Infrastructure**
   - Cross-platform test suite
   - Integration test coverage
   - Performance benchmarking

### Low Priority (Future)

7. **Advanced Features**
   - Association support
   - Transaction handling
   - Migration system

8. **Developer Experience**
   - Better error messages
   - Documentation improvements
   - Debugging tools

## Code Review Focus Areas

### When Reviewing Conditional Exports

```dart
// ✅ GOOD: Clean conditional export
export 'service_stub.dart'
    if (dart.library.js_interop) 'service_js.dart'
    if (dart.library.io) 'service_dart.dart';

// ❌ BAD: Direct imports in shared code
import 'dart:js_interop';  // Wrong location
import 'service_js.dart';  // Should be conditional
```

### When Reviewing Bridge Code

```dart
// ✅ GOOD: Proper error handling
try {
  final result = await bridge.call('method', params);
  return result;
} catch (e) {
  if (e is BridgeException) {
    throw Exception('Operation failed: ${e.message}');
  }
  rethrow;
}

// ❌ BAD: No error handling
final result = await bridge.call('method', params);
return result;  // Could throw unhandled exception
```

### When Reviewing Query Builders

```dart
// ✅ GOOD: Type-safe operators
QueryBuilder<Users> whereClause = and([
  q.id.gt(10),
  q.email.like('%@example.com'),
]);

// ❌ BAD: Dynamic typing
dynamic whereClause = {
  'id': {'$gt': 10},
  'email': {'$like': '%@example.com'},
};
```

### When Reviewing JS Interop

```dart
// ✅ GOOD: Extension types
extension type ModelJS._(JSObject _) implements JSObject {
  @JS('findAll')
  external JSPromise findAll(JSObject? options);
}

// ❌ BAD: Dynamic JS calls
final result = jsObject.callMethod('findAll', [options]);
```

## Performance Focus Areas

### Bridge Performance

- Minimize JSON serialization overhead
- Optimize request batching
- Reduce process communication latency

### JS Interop Performance

- Use extension types for type safety
- Minimize JS/Dart conversions
- Leverage direct API calls

### Query Performance

- Efficient operator implementation
- Optimized SQL generation
- Connection pool utilization

## Security Focus Areas

### Bridge Security

- Validate all input parameters
- Sanitize SQL queries
- Secure process communication

### JS Interop Security

- Safe type conversions
- Memory leak prevention
- Secure module loading

## Monitoring Focus Areas

### Bridge Monitoring

- Process health checks
- Connection state tracking
- Error rate monitoring

### Performance Monitoring

- Query execution times
- Connection pool metrics
- Memory usage tracking

This focus document should guide development priorities and code review efforts to maintain the project's core strengths while addressing critical areas for improvement.
