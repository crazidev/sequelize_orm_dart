import type { ReactNode } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import Layout from '@theme/Layout';
import HomepageFeatures from '@site/src/components/HomepageFeatures';
import HomepageDemo from '@site/src/components/HomepageDemo';
import HomepageHowItWorks from '@site/src/components/HomepageHowItWorks';
import HomepageQuickLinks from '@site/src/components/HomepageQuickLinks';
import Heading from '@theme/Heading';

import styles from './index.module.css';

function HomepageHeader() {
  const { siteConfig } = useDocusaurusContext();
  return (
    <header className={styles.heroBanner}>
      <div className={styles.heroContent}>
        <Heading as="h1" className={styles.heroTitle}>
          The ORM that<br />Speaks Dart
        </Heading>
        <p className={styles.heroSubtitle}>
          Type-safe, annotation-driven, and multi-dialect.<br />
          Experience the power of Sequelize with the safety of Dart.
        </p>
        <div className={styles.buttons}>
          <Link
            className={styles.primaryButton}
            to="/docs/get-started">
            Start Building
          </Link>
          <button
            type="button"
            className={styles.outlineButton}
            onClick={() => {
              if (typeof window === 'undefined') return;
              const demo = document.getElementById('demo');
              if (demo) {
                demo.scrollIntoView({ behavior: 'smooth', block: 'start' });
                window.history.replaceState(null, '', '#demo');
              } else {
                window.location.hash = 'demo';
              }
            }}>
            View Demo
          </button>
        </div>
        <ul className={styles.trustStrip}>
          <li>Postgres</li>
          <li>MySQL</li>
          <li>SQLite</li>
          <li>MSSQL</li>
          <li>DB2</li>
        </ul>
      </div>
    </header>
  );
}

export default function Home(): ReactNode {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title} - ${siteConfig.tagline}`}
      description="A Dart ORM for Sequelize.js integration with code generation support. Works seamlessly on both Dart server and dart2js.">
      <HomepageHeader />
      <main>
        <HomepageDemo />
        <HomepageHowItWorks />
        <HomepageQuickLinks />
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
