/** @type {import('prettier').Config} */
export const baseConfig = {
  htmlWhitespaceSensitivity: 'ignore',
  printWidth: 80,
  quoteProps: 'consistent',
  singleQuote: true,
};

/** @type {import('prettier').Config} */
export const prettierConfig = {
  ...baseConfig,
  overrides: [
    {
      files: '*.vue',
      options: { parser: 'vue' },
    },
    {
      files: '*.{html,twig}',
      options: { parser: 'liquid-html' },
    },
  ],
  plugins: ['@destination/prettier-plugin-twig'],
};

export default prettierConfig;
