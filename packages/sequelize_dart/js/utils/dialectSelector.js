const { PostgresDialect } = require('@sequelize/postgres');
const { MySqlDialect } = require('@sequelize/mysql');
const { MariaDbDialect } = require('@sequelize/mariadb');

/**
 * Select the appropriate Sequelize dialect class based on dialect string
 */
function selectDialect(dialect) {
  switch (dialect) {
    case 'postgres':
      return PostgresDialect;
    case 'mysql':
      return MySqlDialect;
    case 'mariadb':
      return MariaDbDialect;
    default:
      // Default to postgres if not specified
      return PostgresDialect;
  }
}

module.exports = {
  selectDialect,
};

