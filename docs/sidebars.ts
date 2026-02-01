import type { SidebarsConfig } from '@docusaurus/plugin-content-docs';

// This runs in Node.js - Don't use client-side code here (browser APIs, JSX...)

/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation

 The sidebars can be generated from the filesystem, or explicitly defined here.

 Create as many sidebars as you want.
 */
const sidebars: SidebarsConfig = {
  docsSidebar: [
    'get-started',
    'databases',
    {
      type: 'category',
      label: 'Models & Tables',
      items: [
        'models',
        'models/defining-models',
        'models/data-types',
        'models/table-column-naming',
        'models/timestamps',
        'models/column-validation',
        'models/primary-keys',
        'models/auto-increment',
        'models/nullability',
        'models/models-registry',
        'models/complete-example',
      ],
    },
    {
      type: 'category',
      label: 'Associations',
      items: [
        'associations',
        'associations/hasone',
        'associations/hasmany',
        'associations/belongsto',
        'associations/using-associations',
        'associations/eager-loading',
        'associations/association-options',
        'associations/complete-example',
      ],
    },
    'querying',
  ],
};

export default sidebars;
