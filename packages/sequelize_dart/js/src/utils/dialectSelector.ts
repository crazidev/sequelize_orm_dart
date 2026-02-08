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
    default:
      // eslint-disable-next-line @typescript-eslint/no-require-imports
      return require('@sequelize/postgres').PostgresDialect;
  }
}
