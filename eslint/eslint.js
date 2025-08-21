import markdown from '@eslint/markdown';
import vueTsEslintConfig from '@vue/eslint-config-typescript';
import prettier from 'eslint-config-prettier';
import { readGitignoreFiles } from 'eslint-gitignore';
import perfectionist from 'eslint-plugin-perfectionist';
import pluginVue from 'eslint-plugin-vue';
import globals from 'globals';

const scriptName = process?.env?.npm_lifecycle_event || '';
const strictMode = scriptName.includes('build') || scriptName.includes('lint');

/** @type {import('eslint').Linter.Config['rules']} */
export const eslintSharedCustomRules = {
  'arrow-body-style': 'error',
  'complexity': ['error', 30],
  'consistent-return': 'error',
  'curly': 'error',
  'default-case-last': 'error',
  'eqeqeq': 'error',
  'guard-for-in': 'error',
  'max-params': ['error', 5],
  'no-console': [strictMode ? 'error' : 'off', { allow: ['error', 'info'] }],
  'no-debugger': strictMode ? 'error' : 'off',
  'no-dupe-keys': 'error',
  'no-duplicate-imports': 'error',
  'no-else-return': 'error',
  'no-empty-function': 'error',
  'no-extra-boolean-cast': 'error',
  'no-implicit-coercion': 'error',
  'no-inner-declarations': 'error',
  'no-labels': 'error',
  'no-lone-blocks': 'error',
  'no-lonely-if': 'error',
  'no-negated-condition': 'error',
  'no-nested-ternary': 'error',
  'no-new': 'error',
  'no-new-wrappers': 'error',
  'no-return-assign': ['error', 'always'],
  'no-self-compare': 'error',
  'no-undef': 'error',
  'no-unneeded-ternary': 'error',
  'no-useless-catch': 'error',
  'no-useless-concat': 'error',
  'no-useless-rename': 'error',
  'no-useless-return': 'error',
  'object-shorthand': ['error', 'always', { avoidExplicitReturnArrows: true }],
  'one-var': ['error', 'never'],
  'prefer-const': 'error',
  'prefer-destructuring': 'error',
  'prefer-rest-params': 'error',
  'prefer-spread': 'error',
  'prefer-template': 'error',
  'require-await': 'error',
  'sort-vars': 'error',
  'vars-on-top': 'error',
  'vue/block-order': ['error', { order: ['template', 'script', 'style'] }],
  'vue/component-name-in-template-casing': [
    'error',
    'kebab-case',
    { registeredComponentsOnly: false },
  ],
  'vue/custom-event-name-casing': ['error', 'kebab-case'],
  'vue/enforce-style-attribute': ['error', { allow: ['scoped'] }],
  'vue/html-button-has-type': [
    'error',
    { button: true, reset: true, submit: true },
  ],
  'vue/match-component-file-name': [
    'error',
    { extensions: ['vue'], shouldMatchCase: false },
  ],
  'vue/no-empty-component-block': 'error',
  'vue/no-multiple-objects-in-class': 'error',
  'vue/no-required-prop-with-default': 'error',
  'vue/no-static-inline-styles': 'error',
  'vue/no-template-shadow': 'error',
  'vue/no-unused-emit-declarations': 'error',
  'vue/no-unused-properties': [
    'error',
    {
      deepData: true,
      groups: ['props', 'data', 'computed', 'methods', 'setup'],
    },
  ],
  'vue/no-unused-refs': 'error',
  'vue/no-useless-mustaches': [
    'error',
    { ignoreIncludesComment: true, ignoreStringEscape: true },
  ],
  'vue/no-useless-v-bind': [
    'error',
    { ignoreIncludesComment: true, ignoreStringEscape: true },
  ],
  'vue/object-shorthand': 'error',
  'vue/order-in-components': 'off', // В options API конфликтует с нашей сортировкой
  'vue/padding-line-between-blocks': 'error',
  'vue/prefer-true-attribute-shorthand': 'error',
  'vue/require-direct-export': [
    'error',
    { disallowFunctionalComponentFunction: false },
  ],
  'vue/require-name-property': 'error',
  'vue/require-prop-types': 'error',
  'vue/v-bind-style': ['error', 'shorthand', { sameNameShorthand: 'never' }],
  'vue/v-for-delimiter-style': 'error',
  'yoda': 'error',
};

/** @type {import('eslint').Linter.Config[]} */
const prepend = [
  { files: ['**/*.js', '**/*.ts', '**/*.vue'] },
  { ignores: [...readGitignoreFiles(), '**/*.min.*'] },
];

/** @type {import('eslint').Linter.Config[]} */
const append = [
  prettier,
  perfectionist.configs['recommended-natural'],
  ...markdown.configs.processor,
];

/** @type {import('eslint').Linter.Config[]} */
const languageOptions = [
  {
    languageOptions: {
      globals: {
        ...globals.browser,
        ...globals.node,
        BodyInit: 'readonly',
        EventListener: 'readonly',
        HeadersInit: 'readonly',
        HTMLElementTagNameMap: 'readonly',
        NodeJS: 'readonly',
        ym: 'readonly',
      },
    },
    rules: eslintSharedCustomRules,
  },
  {
    files: ['**/*tests*/**'],
    languageOptions: {
      globals: globals.vitest,
    },
  },
];

/** @type {import('eslint').Linter.Config[]} */
export const nuxtEslintConfigs = [
  ...prepend,
  ...append,
  { rules: eslintSharedCustomRules },
];

/** @type {import('eslint').Linter.Config[]} */
export const eslintConfigs = [
  ...prepend,
  ...pluginVue.configs['flat/recommended'],
  ...vueTsEslintConfig(),
  ...append,
  ...languageOptions,
];

/** @type {(configs?: import('eslint').Linter.Config[]) => import('eslint').Linter.Config[]} */
export const createEslintConfig = (customConfigs = []) => [
  ...eslintConfigs,
  ...customConfigs,
];
