/**
 * Creating a sidebar enables you to:
 - create an ordered group of docs
 - render a sidebar for each doc of that group
 - provide next/previous navigation
 *
 * The sidebars can be generated from the filesystem, or explicitly defined here.
 *
 * Create as many sidebars as you want.
 */

/** @type {import('@docusaurus/plugin-content-docs').SidebarsConfig} */
const sidebars = {
  docs: [
    'intro',
    'getting-started',
    'installation',
    'models',
    'connections',
    {
      type: 'category',
      label: 'Querying',
      items: [
        'querying',
        'typed-queries',
        'dynamic-queries',
        'operators',
      ],
    },
    'examples',
    'api-reference',
    'troubleshooting',
    'faq',
    'changelog',
    'contributing',
  ],
};

module.exports = sidebars;
