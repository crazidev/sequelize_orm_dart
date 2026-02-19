import { ConnectionError, DatabaseError } from "@sequelize/core";

export function selectDialect(dialect: string): any {
  switch (dialect) {
    case 'postgres':
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      return require('@sequelize/postgres').PostgresDialect;
    case 'mysql':
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      return require('@sequelize/mysql').MySqlDialect;
    case 'mariadb':
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      return require('@sequelize/mariadb').MariaDbDialect;
    case 'sqlite':
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      // return require('@sequelize/sqlite3').SqliteDialect;
      throw new ConnectionError(Error('SQLite3 is currently not supported but we are working on using build hook or providing custom script for downloading the operating system specific sqlite3 native drivers since we cannot package it with sequelize_orm package.'));
    default:
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      return require('@sequelize/postgres').PostgresDialect;
  }
}
