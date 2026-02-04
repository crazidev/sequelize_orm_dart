import React, {type ReactNode} from 'react';
import clsx from 'clsx';
import Heading from '@theme/Heading';
import {useInViewOnce} from '@site/src/components/hooks/useInViewOnce';
import styles from './styles.module.css';

type Step = {
  title: string;
  description: string;
};

const STEPS: Step[] = [
  {
    title: 'Define',
    description: 'Annotate a Dart class with @Table and column annotations.',
  },
  {
    title: 'Generate',
    description: 'Run build_runner to get typed helpers + query extensions.',
  },
  {
    title: 'Run',
    description: 'Use the same API on Dart VM and dart2js.',
  },
];

export default function HomepageHowItWorks(): ReactNode {
  const [ref, inView] = useInViewOnce<HTMLElement>();

  return (
    <section ref={ref} className={styles.section}>
      <div className="container">
        <div className={styles.header}>
          <Heading as="h2" className={styles.title}>
            How it works
          </Heading>
          <p className={styles.subtitle}>A simple flow you can explain in one minute.</p>
        </div>

        <div className={styles.steps}>
          {STEPS.map((step, idx) => (
            <div
              key={step.title}
              className={clsx(styles.step, inView && styles.inView)}
              style={{transitionDelay: `${idx * 80}ms`}}>
              <div className={styles.stepBadge}>{idx + 1}</div>
              <div>
                <div className={styles.stepTitle}>{step.title}</div>
                <div className={styles.stepDescription}>{step.description}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}

