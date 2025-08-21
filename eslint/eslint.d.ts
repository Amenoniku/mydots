import type { Linter } from 'eslint';

declare const eslintSharedCustomRules: Linter.Config['rules'];
declare const eslintConfigs: Linter.Config[];
declare const nuxtEslintConfigs: Linter.Config[];
declare const createEslintConfig: (
  customConfigs?: Linter.Config[],
) => Linter.Config[];

export {
  createEslintConfig,
  eslintConfigs,
  eslintSharedCustomRules,
  nuxtEslintConfigs,
};
