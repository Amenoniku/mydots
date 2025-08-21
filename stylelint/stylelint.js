import { properties } from './stylelint-properties-order.js';

/** @type {(options?: object) => import('stylelint').Config} */
export const createStylelintConfig = ({
  customFunctions = [],
  customRules = {},
  useSorting = false,
} = {}) => {
  const config = {
    extends: ['stylelint-config-standard'],
    overrides: [
      {
        customSyntax: 'postcss-scss',
        files: ['**/*.scss'],
        rules: {
          'annotation-no-unknown': [true, { ignoreAnnotations: ['default'] }],
          'function-no-unknown': [
            true,
            { ignoreFunctions: ['to-rem', ...customFunctions] },
          ],
        },
      },
      {
        customSyntax: 'postcss-html',
        files: ['**/*.vue'],
        rules: {
          'function-no-unknown': [
            true,
            { ignoreFunctions: ['v-bind', 'to-rem', ...customFunctions] },
          ],
          'selector-pseudo-class-no-unknown': [
            true,
            { ignorePseudoClasses: ['deep', 'global', 'slotted'] },
          ],
        },
      },
    ],
    rules: {
      'alpha-value-notation': 'number',
      'at-rule-empty-line-before': null,
      'at-rule-no-unknown': [
        true,
        {
          ignoreAtRules: [
            'content',
            'each',
            'else',
            'for',
            'forward',
            'function',
            'if',
            'include',
            'mixin',
            'page',
            'return',
            'use',
          ],
        },
      ],
      'color-function-notation': 'legacy',
      'color-hex-length': 'long',
      'color-no-invalid-hex': true,
      'comment-no-empty': true,
      'custom-property-empty-line-before': null,
      'declaration-block-no-redundant-longhand-properties': [
        true,
        { ignoreShorthands: ['grid-template'] },
      ],
      'declaration-block-no-shorthand-property-overrides': true,
      'declaration-block-single-line-max-declarations': 1,
      'font-family-name-quotes': 'always-unless-keyword',
      'function-calc-no-unspaced-operator': true,
      'function-linear-gradient-no-nonstandard-direction': true,
      'function-name-case': 'lower',
      'import-notation': 'string',
      'keyframe-declaration-no-important': true,
      'media-feature-range-notation': 'prefix',
      'no-invalid-double-slash-comments': true,
      'selector-class-pattern': [
        '^(?:(?:o|c|u|t|s|is|has|_|js|qa)-)?[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*(?:__[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*)?(?:--[a-zA-Z0-9]+(?:-[a-zA-Z0-9]+)*)*(?:[.+])?$',
        {
          message: function expected(selectorValue) {
            return `Expected class selector "${selectorValue}" to match BEM CSS pattern https://en.bem.info/methodology/css. Selector validation tool: https://regexr.com/3apms`;
          },
          resolveNestedSelectors: true,
        },
      ],
      'selector-pseudo-element-no-unknown': true,
      'selector-type-case': 'lower',
      'selector-type-no-unknown': true,
      'unit-no-unknown': true,
      'value-keyword-case': ['lower', { camelCaseSvgKeywords: true }],
      ...customRules,
    },
  };

  if (useSorting) {
    config.plugins = ['stylelint-order'];
    config.rules['order/properties-order'] = [{ properties }];
  }

  return config;
};

/** @type {import('stylelint').Config} */
export const stylelintConfig = createStylelintConfig();
