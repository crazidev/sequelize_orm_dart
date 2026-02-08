import React, {type ReactNode} from 'react';
import Link from '@docusaurus/Link';
import Heading from '@theme/Heading';
import styles from './styles.module.css';

type LinkCard = {
  title: string;
  description: string;
  to: string;
};

const LINKS: LinkCard[] = [
  {
    title: 'Get Started',
    description: 'Install, connect, define your first model, query.',
    to: '/docs/get-started',
  },
  {
    title: 'Models & Tables',
    description: 'Annotations, data types, naming, timestamps, PKs.',
    to: '/docs/models',
  },
  {
    title: 'Associations',
    description: 'hasOne / hasMany / belongsTo, eager loading, options.',
    to: '/docs/associations',
  },
  {
    title: 'Querying',
    description: 'Typed where() operators, includes, ordering, pagination.',
    to: '/docs/querying',
  },
];

export default function HomepageQuickLinks(): ReactNode {
  return (
    <section className={styles.section}>
      <div className="container">
        <div className={styles.header}>
          <Heading as="h2" className={styles.title}>
            Jump to what you need
          </Heading>
          <p className={styles.subtitle}>High-intent shortcuts into the docs.</p>
        </div>

        <div className={styles.grid}>
          {LINKS.map((card) => (
            <Link key={card.to} className={styles.card} to={card.to}>
              <div className={styles.cardTitle}>{card.title}</div>
              <div className={styles.cardDescription}>{card.description}</div>
              <div className={styles.cardCta}>Open →</div>
            </Link>
          ))}
        </div>
      </div>
    </section>
  );
}

