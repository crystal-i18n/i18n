import { createRequire } from 'node:module'
import { viteBundler } from '@vuepress/bundler-vite'
import { searchPlugin } from '@vuepress/plugin-search'
import { defaultTheme } from '@vuepress/theme-default'
import { defineUserConfig } from 'vuepress'

const require = createRequire(import.meta.url)
const { description } = require('../../package.json')

// docs/src/CHANGELOG.md is a symlink to the repository changelog. Vite resolves
// that page from the real path, outside this package, so pin Vue to the copy
// installed with the docs.
const vueAlias = [
  {
    find: /^vue\/server-renderer$/,
    replacement: require.resolve('vue/server-renderer'),
  },
  {
    find: /^vue$/,
    replacement: require.resolve('vue'),
  },
]

export default defineUserConfig({
  title: 'Crystal I18n',
  description,

  head: [
    ['link', { rel: 'icon', href: '/assets/img/favicon.png' }],
    ['meta', { name: 'theme-color', content: '#3eaf7c' }],
    ['meta', { name: 'apple-mobile-web-app-capable', content: 'yes' }],
    ['meta', { name: 'apple-mobile-web-app-status-bar-style', content: 'black' }]
  ],

  bundler: viteBundler({
    viteOptions: {
      resolve: {
        alias: vueAlias,
      },
    },
  }),

  theme: defaultTheme({
    repo: 'https://github.com/crystal-i18n/i18n',
    editLink: false,
    lastUpdated: false,
    contributors: false,
    colorMode: 'light',
    colorModeSwitch: false,
    logo: '/assets/img/logo.png',
    // Match the VuePress 1 code blocks: one-dark background, no line numbers.
    themePlugins: {
      prismjs: {
        theme: 'one-dark',
        lineNumbers: false,
      },
    },
    navbar: [
      {
        text: 'API',
        link: '/ref/index.html',
        target: '_blank'
      }
    ],
    sidebar: {
      '/': [
        {
          text: 'Guide',
          collapsible: false,
          children: [
            '/getting_started.md',
            '/locales_activation.md',
            '/translation_lookups.md',
            '/localization.md',
            '/configuration.md',
          ]
        },
        {
          text: 'Advanced',
          collapsible: false,
          children: [
            '/translation_loaders.md',
            '/translation_catalogs.md',
            '/pluralization_rules.md',
          ]
        },
        {
          text: 'Project',
          collapsible: false,
          children: [
            '/CHANGELOG.md',
          ]
        }
      ],
    }
  }),

  plugins: [
    searchPlugin(),
  ]
})
