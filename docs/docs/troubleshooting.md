# Troubleshooting

Common issues and solutions when using Sequelize Dart.

## Connection Issues

### Connection Refused

**Symptoms:**
- `SequelizeConnectionRefusedError`
- "Connection refused" error

**Solutions:**

1. **Verify database server is running:**
   ```bash
   # PostgreSQL
   pg_isready
   
   # MySQL
   mysqladmin ping
   ```

2. **Check connection URL:**
   ```dart
   // Verify format: dialect://user:password@host:port/database
   url: 'postgresql://user:password@localhost:5432/dbname'
   ```

3. **Check firewall settings:**
   - Ensure database port is open (5432 for PostgreSQL, 3306 for MySQL)

4. **Verify credentials:**
   - Double-check username and password
   - Ensure user has permission to access the database

### Authentication Failed

**Symptoms:**
- Authentication error
- "Password authentication failed"

**Solutions:**

1. **Verify username and password:**
   ```dart
   // Check for special characters that need encoding
   url: 'postgresql://user:p%40ssw0rd@localhost:5432/dbname'
   ```

2. **Check database user permissions:**
   ```sql
   -- PostgreSQL
   \du
   
   -- MySQL
   SHOW GRANTS FOR 'user'@'localhost';
   ```

3. **Verify database exists:**
   ```sql
   -- PostgreSQL
   \l
   
   -- MySQL
   SHOW DATABASES;
   ```

### SSL Connection Errors

**Symptoms:**
- SSL handshake errors
- Certificate validation errors

**Solutions:**

1. **Disable SSL for development:**
   ```dart
   PostgressConnection(
     url: '...',
     ssl: false, // Set to false for local development
   )
   ```

2. **For production, configure SSL properly:**
   - Ensure SSL certificates are valid
   - Configure SSL options at the database level

## Bridge Issues (Dart Server)

### Failed to Start Bridge

**Symptoms:**
- "Failed to start bridge" error
- Bridge process doesn't start

**Solutions:**

1. **Verify Node.js is installed:**
   ```bash
   node --version
   # Should show v20.0 or higher
   ```

2. **Re-run bridge setup:**
   ```bash
   ./tools/setup_bridge.sh [bun|pnpm|npm]
   ```

3. **Check bundle file exists:**
   ```bash
   ls -la packages/sequelize_dart/js/bridge_server.bundle.js
   ```

4. **Check Node.js permissions:**
   - Ensure Node.js can execute
   - Check file permissions on bundle file

### Bridge Process Crashes

**Symptoms:**
- Bridge starts but crashes during queries
- Intermittent connection errors

**Solutions:**

1. **Check bridge logs:**
   - Look for error messages in stderr
   - Check for memory issues

2. **Restart the application:**
   - Close all connections: `await sequelize.close()`
   - Restart the application

3. **Check database connection limits:**
   - Ensure pool size doesn't exceed database limits
   - Reduce `max` pool size if needed

## Code Generation Issues

### No Models Found

**Symptoms:**
- Code generator doesn't find models
- No `.g.dart` files generated

**Solutions:**

1. **Verify `part` directive:**
   ```dart
   part 'users.model.g.dart'; // Must be present
   ```

2. **Check annotations are imported:**
   ```dart
   import 'package:sequelize_dart/sequelize_dart.dart';
   ```

3. **Verify build_runner is in dev_dependencies:**
   ```yaml
   dev_dependencies:
     build_runner: ^2.10.4
   ```

4. **Clean and regenerate:**
   ```bash
   dart run build_runner clean
   dart run build_runner build --delete-conflicting-outputs
   ```

### Generated Files Not Updating

**Symptoms:**
- Changes to model don't reflect in generated code
- Old code still present

**Solutions:**

1. **Delete generated files and regenerate:**
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

2. **Use watch mode:**
   ```bash
   dart run build_runner watch
   ```

3. **Check for syntax errors:**
   - Ensure model file compiles without errors
   - Fix any Dart analysis errors

## Query Issues

### Invalid Column Reference

**Symptoms:**
- "Invalid column" errors
- Column not found errors

**Solutions:**

1. **Verify column names match database:**
   ```dart
   // Check table structure
   // Ensure @ModelAttributes name matches database column
   ```

2. **Check for typos:**
   ```dart
   // Typed queries catch typos at compile time
   where: q.email.eq('...') // Autocomplete helps
   
   // Dynamic queries - double-check spelling
   where: equal('email', '...') // Verify column name
   ```

3. **Verify model is registered:**
   ```dart
   sequelize.addModels([Users.instance]); // Must be called
   ```

### SQL Syntax Errors

**Symptoms:**
- SQL syntax errors in queries
- Invalid SQL generated

**Solutions:**

1. **Check operator usage:**
   - Verify operators are used correctly
   - Check database-specific operators (PostgreSQL vs MySQL)

2. **Review query structure:**
   ```dart
   // Ensure proper nesting
   where: and([
     or([...]),
     equal(...),
   ])
   ```

3. **Check SQL logs:**
   ```dart
   logging: (String sql) => print(sql), // Enable to see generated SQL
   ```

### Type Mismatch Errors

**Symptoms:**
- Type errors when using generated classes
- Incompatible type errors

**Solutions:**

1. **Verify data types match:**
   ```dart
   @ModelAttributes(
     name: 'id',
     type: DataType.INTEGER, // Must match database type
   )
   ```

2. **Check generated value classes:**
   - Ensure `$UsersValues` types match database schema
   - Regenerate if types are incorrect

## Performance Issues

### Slow Queries

**Symptoms:**
- Queries take too long
- Application feels sluggish

**Solutions:**

1. **Add database indexes:**
   ```sql
   CREATE INDEX idx_email ON users(email);
   CREATE INDEX idx_created_at ON users(created_at);
   ```

2. **Use limit for large datasets:**
   ```dart
   Query(limit: 100) // Don't fetch all records
   ```

3. **Optimize connection pool:**
   ```dart
   pool: SequelizePoolOptions(
     max: 10, // Adjust based on workload
     min: 2,
   )
   ```

### Pool Exhausted

**Symptoms:**
- "Pool exhausted" errors
- Timeout errors when acquiring connections

**Solutions:**

1. **Increase pool size:**
   ```dart
   pool: SequelizePoolOptions(
     max: 20, // Increase maximum connections
   )
   ```

2. **Check for connection leaks:**
   - Ensure `sequelize.close()` is called
   - Use try/finally to guarantee cleanup

3. **Reduce idle timeout:**
   ```dart
   pool: SequelizePoolOptions(
     idle: 5000, // Reduce idle time
   )
   ```

## Platform-Specific Issues

### Dart Server Issues

**Symptoms:**
- Bridge errors
- Process communication issues

**Solutions:**

1. **Verify bridge setup:**
   ```bash
   ./tools/setup_bridge.sh
   ```

2. **Check Node.js version:**
   - Requires Node.js v20.0 or higher

3. **Restart bridge:**
   - Close application
   - Restart to spawn new bridge process

### dart2js Issues

**Symptoms:**
- JS interop errors
- Runtime errors in compiled JS

**Solutions:**

1. **Verify Sequelize.js is available:**
   - Ensure Sequelize.js is installed in Node.js environment
   - Check package.json dependencies

2. **Check compilation:**
   ```bash
   dart compile js lib/main.dart -o main.js
   ```

3. **Verify JS interop:**
   - Ensure `dart:js_interop` is available
   - Check Dart SDK version

## Getting Help

If you're still experiencing issues:

1. **Check error messages:**
   - Read full error stack traces
   - Look for specific error codes

2. **Enable logging:**
   ```dart
   logging: (String sql) => print(sql),
   ```

3. **Check documentation:**
   - Review relevant documentation pages
   - Check [Examples](./examples.md) for patterns

4. **Create an issue:**
   - Include error messages
   - Provide minimal reproduction code
   - Specify platform (Dart server or dart2js)

## Common Error Messages

### "SequelizeConnectionRefusedError"
- Database server not running or unreachable
- Check connection URL and server status

### "SequelizeDatabaseError"
- SQL syntax error or database constraint violation
- Check SQL logs and query structure

### "BridgeException"
- Bridge process error (Dart server only)
- Check bridge setup and Node.js installation

### "Model not found"
- Model not registered with `addModels()`
- Verify model registration

### "Column does not exist"
- Column name mismatch between model and database
- Check `@ModelAttributes` name matches database column

## Next Steps

- Review [Installation](./installation.md) for setup requirements
- Check [Examples](./examples.md) for working code
- See [API Reference](./api-reference.md) for detailed API docs
