export default [
  {
    languageOptions: {
      ecmaVersion: 2022,
    },
    rules: {
      'no-console': 2,
      'no-undef': 2,
      'no-shadow': 2,
      'no-unused-vars': [
        'error',
        {
          vars: 'all',
          args: 'after-used',
          caughtErrors: 'none',
          ignoreRestSiblings: false,
          reportUsedIgnorePattern: true,
          argsIgnorePattern: '^_',
        },
      ],
    },
    ignores: [
      '**/bin/*',
      '**/node_modules/*',
      '**/dist/**',
      '**/build/**',
      '**/.cache/**',
      '**/docs/**',
      '**/api/**',
      '**/src/service/**',
      '**/src/sdk.ts',
      '**/src/index.ts',
    ],
  },
];
