module.exports = {
  root: true,
  parser: '@typescript-eslint/parser',
  env: {
    browser: false,
    es2021: true,
  },
  plugins: ['@typescript-eslint', 'simple-import-sort'],
  extends: [
    'eslint:recommended',
    'plugin:@typescript-eslint/recommended',
    'prettier',
  ],
  ignorePatterns: ['tests', '.eslintrc.cjs'],
  parserOptions: {
    tsconfigRootDir: __dirname,
    project: './tsconfig.json',
    ecmaVersion: 'latest',
    sourceType: 'module',
  },
  rules: {
    'simple-import-sort/imports': [
      'error',
      {
        groups: [
          // side-effect imports
          ['^\\u0000'],
          // node, scoped, no-scoped packages
          ['^node:', '^@', '^\\w'],

          // Alias imports
          ['^#/utils', '^#/configs'],
          ['^#/types'],
          ['^#/fixtures'],
          ['^#/modules'],

          // Parent, sibling imports.
          ['^\\.\\./', '^\\./'],
        ],
      },
    ],

    // disabled rules
    '@typescript-eslint/no-explicit-any': 0, // controlled by typescript
    '@typescript-eslint/strict-boolean-expressions': 0,
    '@typescript-eslint/explicit-function-return-type': 0,
    '@typescript-eslint/restrict-template-expressions': 0,
    '@typescript-eslint/consistent-type-assertions': 0,
    'no-void': 0,

    // customized rules
    '@typescript-eslint/padding-line-between-statements': [
      2,
      { blankLine: 'always', prev: ['block', 'block-like'], next: '*' },
      { blankLine: 'always', prev: '*', next: ['block', 'block-like'] },
    ],
    '@typescript-eslint/no-floating-promises': 1,
  },
}
