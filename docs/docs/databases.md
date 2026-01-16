---
sidebar_position: 2
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';

# Database Connection

Sequelize Dart supports multiple database dialects. This guide explains how to connect to your database using specific connection classes for each dialect.

<Tabs>
  <TabItem value="postgres" label="PostgreSQL" default>

    ## PostgreSQL

    To connect to a PostgreSQL database, use the `PostgressConnection` class.

    ### Minimal Example

    ```dart
    final sequelize = Sequelize().createInstance(
      PostgressConnection(
        url: 'postgresql://postgres:password@localhost:5432/my_database',
      ),
    );
    ```

    ### Full Configuration

    ```dart
    final sequelize = Sequelize().createInstance(
      PostgressConnection(
        database: 'my_database',
        user: 'postgres',
        password: 'password',
        host: 'localhost',
        port: 5432,
        ssl: false,
        schema: 'public',
        // logging: (sql) => print(sql),
      ),
    );
    ```

    ### Configuration Options

    | Option | Type | Description |
    |--------|------|-------------|
    | `url` | `String?` | Connection URL (overrides other options) |
    | `host` | `String?` | Database host (default: `localhost`) |
    | `port` | `int?` | Database port (default: `5432`) |
    | `user` | `String?` | Database username |
    | `password` | `String?` | Database password |
    | `database` | `String?` | Database name |
    | `schema` | `String?` | PostgreSQL schema (default: `public`) |
    | `ssl` | `bool` | Enable SSL connection (default: `false`) |
    | `logging` | `Function(String)?` | SQL logging callback |
    | `pool` | `SequelizePoolOptions?` | Connection pool configuration |

  </TabItem>
  <TabItem value="mysql" label="MySQL">

    ## MySQL

    To connect to a MySQL database, use the `MysqlConnection` class.

    ### Minimal Example

    ```dart
    final sequelize = Sequelize().createInstance(
      MysqlConnection(
        url: 'mysql://user:password@localhost:3306/my_database',
      ),
    );
    ```

    ### Full Configuration

    ```dart
    final sequelize = Sequelize().createInstance(
      MysqlConnection(
        database: 'my_database',
        user: 'user',
        password: 'password',
        host: 'localhost',
        port: 3306,
        ssl: false,
      ),
    );
    ```

    ### Configuration Options

    | Option | Type | Description |
    |--------|------|-------------|
    | `url` | `String?` | Connection URL (overrides other options) |
    | `host` | `String?` | Database host (default: `localhost`) |
    | `port` | `int?` | Database port (default: `3306`) |
    | `user` | `String?` | Database username |
    | `password` | `String?` | Database password |
    | `database` | `String?` | Database name |
    | `ssl` | `bool` | Enable SSL connection (default: `false`) |
    | `logging` | `Function(String)?` | SQL logging callback |
    | `pool` | `SequelizePoolOptions?` | Connection pool configuration |

  </TabItem>
  <TabItem value="mariadb" label="MariaDB">

    ## MariaDB

    To connect to a MariaDB database, use the `MariadbConnection` class.

    ### Minimal Example

    ```dart
    final sequelize = Sequelize().createInstance(
      MariadbConnection(
        url: 'mariadb://user:password@localhost:3306/my_database',
      ),
    );
    ```

    ### Full Configuration

    ```dart
    final sequelize = Sequelize().createInstance(
      MariadbConnection(
        database: 'my_database',
        user: 'user',
        password: 'password',
        host: 'localhost',
        port: 3306,
        ssl: false,
      ),
    );
    ```

    ### Configuration Options

    | Option | Type | Description |
    |--------|------|-------------|
    | `url` | `String?` | Connection URL (overrides other options) |
    | `host` | `String?` | Database host (default: `localhost`) |
    | `port` | `int?` | Database port (default: `3306`) |
    | `user` | `String?` | Database username |
    | `password` | `String?` | Database password |
    | `database` | `String?` | Database name |
    | `ssl` | `bool` | Enable SSL connection (default: `false`) |
    | `logging` | `Function(String)?` | SQL logging callback |
    | `pool` | `SequelizePoolOptions?` | Connection pool configuration |

  </TabItem>
</Tabs>
