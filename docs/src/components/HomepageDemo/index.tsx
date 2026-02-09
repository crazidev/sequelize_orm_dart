import React, {type ReactNode, useMemo, useState} from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import CodeBlock from '@theme/CodeBlock';
import Heading from '@theme/Heading';
import {useInViewOnce} from '@site/src/components/hooks/useInViewOnce';
import styles from './styles.module.css';

const STEP_COLORS = [
  '#2563eb', // blue
  '#059669', // emerald
  '#7c3aed', // violet
  '#dc2626', // red
  '#0891b2', // cyan
  '#4f46e5', // indigo
] as const;

type DemoStep = {
  id: string;
  title: string;
  kicker: string;
  code: {language: string; content: string};
  outputTitle: string;
  output: {language: string; content: string};
};

const DEMO_STEPS: DemoStep[] = [
  {
    id: 'model',
    title: 'Define a model',
    kicker: 'Dart class + annotations',
    code: {
      language: 'dart',
      content: `import 'package:sequelize_orm/sequelize_orm.dart';

part 'users.model.g.dart';

@Table(tableName: 'users', timestamps: false)
abstract class Users {
  @PrimaryKey()
  @AutoIncrement()
  @NotNull()
  DataType id = DataType.INTEGER;

  @Validate.IsEmail('Email is not valid')
  @NotNull()
  DataType email = DataType.STRING;

  @ColumnName('first_name')
  @Validate.Min(4)
  @NotNull()
  DataType firstName = DataType.STRING;

  static UsersModel get model => UsersModel();
}`,
    },
    outputTitle: 'DB shape stays explicit',
    output: {
      language: 'text',
      content: `- table: users
- columns: id (PK, autoincrement), email (NOT NULL, isEmail), first_name (NOT NULL, min 4)
- generated: typed helpers + query extensions`,
    },
  },
  {
    id: 'generate',
    title: 'Generate code',
    kicker: 'build_runner',
    code: {
      language: 'bash',
      content: `dart run build_runner build --delete-conflicting-outputs`,
    },
    outputTitle: 'Generated model wrapper (excerpt)',
    output: {
      language: 'dart',
      content: `// GENERATED CODE - DO NOT MODIFY BY HAND
part of 'users.model.dart';

class UsersModel extends Model {
  @override
  String get name => 'Users';

  @override
  Future<List<UsersValues>> findAll({
    QueryOperator Function(UsersColumns users)? where,
    int? limit,
    int? offset,
    QueryAttributes? attributes,
    dynamic order,
    dynamic group,
  }) { /* ... */ }
}`,
    },
  },
  {
    id: 'query',
    title: 'Query with types',
    kicker: 'Autocomplete-first where()',
    code: {
      language: 'dart',
      content: `// Find users (typed columns)
final users = await Users.model.findAll(
  where: (user) => user.email.isNotNull(),
  limit: 10,
);

// Create with generated helper
final created = await Users.model.create(
  CreateUsers(
    email: 'user@example.com',
    firstName: 'John',
    lastName: 'Doe',
  ),
);`,
    },
    outputTitle: 'Generated SQL',
    output: {
      language: 'sql',
      content: `SELECT * FROM users WHERE email IS NOT NULL LIMIT 10;
INSERT INTO users (email, first_name, last_name) VALUES (...);`,
    },
  },
  {
    id: 'associations',
    title: 'Associations + include',
    kicker: 'Eager loading',
    code: {
      language: 'dart',
      content: `// User has @HasMany(Post, foreignKey: 'userId', as: 'posts')
// Post has @BelongsTo(User, foreignKey: 'userId')

final user = await Users.model.findOne(
  where: (u) => u.id.equals(1),
  include: (u) => [u.posts()],
);

// user.posts is List<Post>?
for (final post in user?.posts ?? []) {
  print(post.title);
}`,
    },
    outputTitle: 'JOIN query',
    output: {
      language: 'sql',
      content: `SELECT users.*, posts.*
FROM users
LEFT OUTER JOIN posts ON posts.user_id = users.id
WHERE users.id = 1;`,
    },
  },
  {
    id: 'seeding',
    title: 'Seeding',
    kicker: 'CLI + programmatic',
    code: {
      language: 'dart',
      content: `// CLI: sync + run all seeders
dart run sequelize_orm_generator:generate --seed

// Programmatic
await sequelize.seed(
  seeders: Db.allSeeders(),
  syncTableMode: SyncTableMode.alter,
);

// Seeder: extend SequelizeSeeding<CreateUser>
// Override seedData with [CreateUser(...), ...]`,
    },
    outputTitle: 'Seeder output',
    output: {
      language: 'text',
      content: `[Seeder] UserSeeder: 2 rows inserted
[Seeder] PostSeeder: 5 rows inserted
Seeding complete.`,
    },
  },
  {
    id: 'run',
    title: 'Run',
    kicker: 'Dart VM or dart2js',
    code: {
      language: 'dart',
      content: `final sequelize = Sequelize().createInstance(
  connection: SequelizeConnection.postgres(
    url: 'postgresql://user:pass@localhost:5432/db',
  ),
  logging: (sql) => SqlFormatter.printFormatted(sql),
);

await sequelize.initialize(models: [Users.model]);`,
    },
    outputTitle: 'Run your app',
    output: {
      language: 'bash',
      content: `# From project root
dart run bin/server.dart`,
    },
  },
];

export default function HomepageDemo(): ReactNode {
  const [activeStepId, setActiveStepId] = useState<string>('model');
  const [sectionRef, inView] = useInViewOnce<HTMLElement>();
  const [mobileExpanded, setMobileExpanded] = useState(false);

  const active = DEMO_STEPS.find((s) => s.id === activeStepId) ?? DEMO_STEPS[0]!;

  return (
    <section
      id="demo"
      ref={sectionRef}
      className={clsx(styles.demoSection, inView && styles.inView)}>
      <div className="container">
        <div className={styles.headerRow}>
          <div>
            <Heading as="h2" className={styles.title}>
              A quick tour
            </Heading>
            <p className={styles.subtitle}>
              Click through a real model → generator → query flow. Everything is Dart-first.
            </p>
          </div>
        </div>

        <div className={styles.demoLayout}>
          <div className={styles.stepsSection}>
            <div
              className={clsx(
                styles.stepsColumn,
                mobileExpanded && styles.stepsExpanded,
              )}
              role="tablist"
              aria-label="Demo steps">
            {DEMO_STEPS.map((step, idx) => (
              <button
                key={step.id}
                type="button"
                className={clsx(
                  styles.step,
                  step.id === active.id && styles.stepActive,
                  idx > 0 && styles.stepCollapsible,
                )}
                style={
                  {
                    '--step-color': STEP_COLORS[idx % STEP_COLORS.length],
                  } as React.CSSProperties
                }
                role="tab"
                aria-selected={step.id === active.id}
                onClick={() => {
                  setActiveStepId(step.id);
                  if (idx > 0) setMobileExpanded(true);
                }}>
                <span
                  className={styles.stepBadge}
                  style={{
                    backgroundColor: STEP_COLORS[idx % STEP_COLORS.length],
                  }}>
                  {idx + 1}
                </span>
                <span className={styles.stepContent}>
                  <span className={styles.stepKicker}>{step.kicker}</span>
                  <span className={styles.stepTitle}>{step.title}</span>
                </span>
              </button>
            ))}
            </div>
            <button
              type="button"
              className={styles.mobileExpandToggle}
              aria-expanded={mobileExpanded}
              onClick={() => setMobileExpanded(!mobileExpanded)}>
              {mobileExpanded ? 'Hide steps 2–6' : 'Show steps 2–6'}
            </button>
          </div>

          <div className={styles.panelsWrapper}>
            <div key={active.id} className={styles.panels}>
              <div className={styles.panel}>
                <div className={styles.panelHeader}>
                  <span className={styles.panelTitle}>{active.title}</span>
                  <Link className={styles.panelLink} to="/docs/get-started">
                    Open docs
                  </Link>
                </div>
                <CodeBlock language={active.code.language}>
                  {active.code.content}
                </CodeBlock>
              </div>

              <div className={clsx(styles.panel, styles.outputPanel)}>
                <div className={styles.panelHeader}>
                  <span className={styles.panelTitle}>{active.outputTitle}</span>
                </div>
                <CodeBlock language={active.output.language}>
                  {active.output.content}
                </CodeBlock>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
