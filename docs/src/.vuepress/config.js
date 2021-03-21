const { description } = require('../../package')

module.exports = {
  /**
   * Ref：https://v1.vuepress.vuejs.org/config/#title
   */
  title: 'Crystal I18n',
  /**
   * Ref：https://v1.vuepress.vuejs.org/config/#description
   */
  description: description,

  /**
   * Extra tags to be injected to the page HTML `<head>`
   *
   * ref：https://v1.vuepress.vuejs.org/config/#head
   */
  head: [
    ['link', { rel: 'icon', href: '/assets/img/favicon.png' }],
    ['meta', { name: 'theme-color', content: '#3eaf7c' }],
    ['meta', { name: 'apple-mobile-web-app-capable', content: 'yes' }],
    ['meta', { name: 'apple-mobile-web-app-status-bar-style', content: 'black' }]
  ],

  /**
   * Theme configuration, here is the default theme configuration for VuePress.
   *
   * ref：https://v1.vuepress.vuejs.org/theme/default-theme-config.html
   */
  themeConfig: {
    repo: 'https://github.com/crystal-i18n/i18n',
    editLinks: false,
    docsDir: '',
    editLinkText: '',
    lastUpdated: false,
    logo: '/assets/img/logo.png',
    nav: [
      {
        text: 'API',
        link: '/ref/index.html',
        target: '_blank'
      }
    ],
    sidebar: {
      '/': [
        {
          title: 'Guide',
          collapsable: false,
          children: [
            'getting_started',
            'locales_activation',
            'translation_lookups',
            'localization',
            'configuration',
          ]
        },
        {
          title: 'Advanced',
          collapsable: false,
          children: [
            'translation_loaders',
            'translation_catalogs',
            'pluralization_rules',
          ]
        },
        {
          title: 'Project',
          collapsable: false,
          children: [
            'CHANGELOG',
          ]
        }
      ],
    }
  },

  /**
   * Apply plugins，ref：https://v1.vuepress.vuejs.org/zh/plugin/
   */
  plugins: [
    '@vuepress/plugin-back-to-top',
    '@vuepress/plugin-medium-zoom',
  ]
}
