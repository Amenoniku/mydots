import type { Config } from 'stylelint';

declare const stylelintConfig: Config;
declare const createStylelintConfig: (options?: {
  customFunctions: string[];
  customRules: Config['rules'];
  useSorting: boolean;
}) => Config;

export { createStylelintConfig, stylelintConfig };
