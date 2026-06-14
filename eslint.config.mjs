import neostandard from 'neostandard'
import prettier from 'eslint-config-prettier'

export default [
  {
    ignores: ['node_modules/**', 'public/packs/**', 'public/packs-test/**']
  },
  ...neostandard({
    files: ['app/javascript/**/*.js'],
    env: ['browser', 'jquery', 'node'],
    globals: {
      Worker: 'readonly',
      IntersectionObserver: 'readonly'
    },
    rules: {
      'no-unused-vars': [
        'error',
        {
          args: 'all',
          argsIgnorePattern: '^_',
          caughtErrorsIgnorePattern: '^_'
        }
      ]
    }
  }),
  prettier
]
