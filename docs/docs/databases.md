---
sidebar_position: 2
toc_max_heading_level: 3
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

# Database Connection

Sequelize Dart supports multiple database dialects. This guide explains how to connect to various databases using the `SequelizeConnection` factory class.

## Quick Start

The easiest way to create a connection is using the `SequelizeConnection` factory. This provides a type-safe API with discoverable parameters for each dialect.

```dart
// Basic PostgreSQL connection
final sequelize = Sequelize().createInstance(
  connection: SequelizeConnection.postgres(
    host: 'localhost',
    database: 'my_db',
    user: 'postgres',
    password: 'password',
  ),
  logging: (sql) => SqlFormatter.printFormatted(sql),
);
```

### Instance Options

When calling `createInstance()`, you can provide global options that apply to the entire instance:

| Option         | Type                    | Description                                                            |
| -------------- | ----------------------- | ---------------------------------------------------------------------- |
| **connection** | `SequelizeCoreOptions`  | The connection configuration created via `SequelizeConnection`.        |
| **logging**    | `Function(String sql)?` | A callback to log SQL queries. Use `SqlFormatter` for pretty printing. |
| **pool**       | `SequelizePoolOptions?` | Connection pool settings (max, min, idle, etc.).                       |

---

## Supported Dialects

Choose your database dialect below to see specific connection examples and configuration options.

<Tabs>
  <TabItem value="postgres" label="PostgreSQL" default>

    ### PostgreSQL

    Connect to PostgreSQL using `SequelizeConnection.postgres()`.

    #### Standard Connection
    ```dart
    SequelizeConnection.postgres(
      host: 'localhost',
      database: 'my_database',
      user: 'user',
      password: 'password',
      port: 5432,
    )
    ```

    #### Connection via Unix Socket
    Use the `host` option with the absolute path to the socket file:
    ```dart
    SequelizeConnection.postgres(
      host: '/var/run/postgresql',
      database: 'my_database',
      user: 'user',
    )
    ```

    #### Configuration Options

    | Option | Type | Default | Description |
    |--------|------|---------|-------------|
    | `url` | `String?` | - | Full connection URL. Overrides individual options. |
    | `host` | `String` | `'localhost'` | Hostname or Unix socket path. |
    | `port` | `int` | `5432` | Database port. |
    | `user` | `String?` | - | Database username. |
    | `password` | `String?` | - | Database password. |
    | `database` | `String?` | - | Database name. |
    | `schema` | `String` | `'public'` | The default schema to use. |
    | `ssl` | `Object?` | `false` | SSL config (`bool` or `SslConfig`). |
    | `applicationName` | `String?` | - | Name of the application for `pg_stat_activity`. |
    | `clientEncoding` | `String` | `'utf8'` | Character encoding for the connection. |
    | `queryTimeout` | `int?` | - | Query timeout in milliseconds. |
    | `keepAlive` | `bool` | `true` | Enable TCP keep-alive. |

  </TabItem>
  <TabItem value="mysql" label="MySQL">

    ### MySQL

    Connect to MySQL using `SequelizeConnection.mysql()`.

    #### Standard Connection
    ```dart
    SequelizeConnection.mysql(
      host: 'localhost',
      database: 'my_database',
      user: 'user',
      password: 'password',
    )
    ```

    #### Configuration Options

    | Option | Type | Default | Description |
    |--------|------|---------|-------------|
    | `url` | `String?` | - | Full connection URL. |
    | `host` | `String` | `'localhost'` | Database host. |
    | `port` | `int` | `3306` | Database port. |
    | `user` | `String?` | - | Database username. |
    | `password` | `String?` | - | Database password. |
    | `database` | `String?` | - | Database name. |
    | `ssl` | `Object?` | `false` | SSL config (`bool` or `SslConfig`). |
    | `charset` | `String` | `'utf8mb4'` | Character set to use. |
    | `compress` | `bool` | `false` | Enable gzip compression between client and server. |
    | `connectTimeout` | `int` | `10000` | Connection timeout in milliseconds. |
    | `socketPath` | `String?` | - | Path to Unix domain socket or named pipe. |
    | `showWarnings` | `bool` | `false` | Log MySQL warnings to the console. |

  </TabItem>
  <TabItem value="mariadb" label="MariaDB">

    ### MariaDB

    Connect to MariaDB using `SequelizeConnection.mariadb()`.

    #### Standard Connection
    ```dart
    SequelizeConnection.mariadb(
      host: 'localhost',
      database: 'my_database',
      user: 'user',
      password: 'password',
    )
    ```

    #### Configuration Options

    | Option | Type | Default | Description |
    |--------|------|---------|-------------|
    | `url` | `String?` | - | Full connection URL. |
    | `host` | `String` | `'localhost'` | Database host. |
    | `port` | `int` | `3306` | Database port. |
    | `user` | `String?` | - | Database username. |
    | `password` | `String?` | - | Database password. |
    | `database` | `String?` | - | Database name. |
    | `ssl` | `Object?` | `false` | SSL config (`bool` or `SslConfig`). |
    | `charset` | `String` | `'utf8mb4'` | Character set to use. |
    | `connectTimeout` | `int` | `1000` | Connection timeout in milliseconds. |
    | `socketTimeout` | `int` | `0` | Socket timeout after connection established. |
    | `maxAllowedPacket`| `int` | `4196304`| Maximum packet size in bytes. |

  </TabItem>
  <TabItem value="sqlite" label="SQLite">

    ### SQLite

    Connect to SQLite using `SequelizeConnection.sqlite()`.

    #### Persistent File Storage
    By default, SQLite creates the database file if it doesn't exist.
    ```dart
    SequelizeConnection.sqlite(
      storage: './data/database.sqlite',
    )
    ```

    #### Temporary Storages
    SQLite supports two types of temporary storage (destroyed on close):
    - **Memory-based**: Set `storage: ':memory:'`.
    - **Disk-based**: Set `storage: ''` (empty string).

    :::warning
    Using temporary storage requires configuring the **Connection Pool** to keep exactly one connection alive, otherwise state is lost between queries.
    :::

    ```dart
    final sequelize = Sequelize().createInstance(
      connection: SequelizeConnection.sqlite(storage: ':memory:'),
      pool: SequelizePoolOptions(
        max: 1,
        idle: 999999, // Keep the connection alive
      ),
    );
    ```

    #### Configuration Options

    | Option | Type | Default | Description |
    |--------|------|---------|-------------|
    | `storage` | `String` | - | Path to file, `':memory:'`, or `''`. |
    | `foreignKeys` | `bool` | `true` | If set to false, SQLite will not enforce foreign keys. |
    | `mode` | `List<SqliteMode>?` | - | Opening flags (read, write, create, mutex). |
    | `password` | `String?` | - | Password for SQLCipher encryption. |

  </TabItem>
  <TabItem value="mssql" label="MS SQL Server">

    ### Microsoft SQL Server

    Connect to SQL Server using `SequelizeConnection.mssql()`.

    #### Standard Connection
    ```dart
    SequelizeConnection.mssql(
      host: 'localhost',
      database: 'my_database',
      user: 'sa',
      password: 'password',
      encrypt: true,
    )
    ```

    #### Domain Account
    To connect using a domain account, use the `authentication` option:
    ```dart
    SequelizeConnection.mssql(
      authentication: MssqlAuthentication(
        type: 'ntlm',
        options: MssqlAuthOptions(
          domain: 'MY_DOMAIN',
          userName: 'my_user',
          password: 'my_password',
        ),
      ),
    )
    ```

    #### Configuration Options

    | Option | Type | Default | Description |
    |--------|------|---------|-------------|
    | `host` | `String` | `'localhost'` | Database host. |
    | `port` | `int` | `1433` | Database port. |
    | `database` | `String?` | - | Database name. |
    | `encrypt` | `Object` | `true` | Encryption: `true`, `false`, or `'strict'`. |
    | `trustServerCertificate` | `bool` | `false` | Set to `true` for self-signed certificates. |
    | `connectTimeout` | `int` | `15000` | Initial connection timeout (ms). |
    | `requestTimeout` | `int` | `15000` | Timeout for individual queries (ms). |
    | `abortTransactionOnError`| `bool` | `false` | Whether to abort transaction on any error. |

  </TabItem>
</Tabs>

---

## SSL Configuration

For dialects that support SSL (PostgreSQL, MySQL, MariaDB, DB2), use the `SslConfig` class for typed security options.

```dart
// Simple: Enable SSL with default validation
SequelizeConnection.postgres(ssl: true)

// Advanced: Custom certificates and stricter validation
SequelizeConnection.postgres(
  ssl: SslConfig(
    ca: File('ca.pem').readAsStringSync(),
    cert: File('client-cert.pem').readAsStringSync(),
    key: File('client-key.pem').readAsStringSync(),
    rejectUnauthorized: true,
  ),
)

// Development: Allow self-signed certificates
SequelizeConnection.postgres(ssl: SslConfig.selfSigned())
```

---

## Connection Pool

The connection pool manages database connections to improve performance.

```dart
final sequelize = Sequelize().createInstance(
  connection: SequelizeConnection.postgres(...),
  pool: SequelizePoolOptions(
    max: 10,      // Max connections
    min: 0,       // Min connections
    idle: 10000,  // Max idle time (ms)
    acquire: 30000, // Max time to get connection (ms)
    evict: 1000,    // Idle connection eviction interval (ms)
  ),
);
```
