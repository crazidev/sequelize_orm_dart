import { PostgresDialect } from '@sequelize/postgres';
import { MySqlDialect } from '@sequelize/mysql';
import { MariaDbDialect } from '@sequelize/mariadb';

export function selectDialect(dialect: string): any {
  switch (dialect) {
    case 'postgres':
      return PostgresDialect;
    case 'mysql':
      return MySqlDialect;
    case 'mariadb':
      return MariaDbDialect;
    default:
      return PostgresDialect;
  }
}
