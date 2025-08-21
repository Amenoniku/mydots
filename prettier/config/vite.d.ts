import type { Plugin } from 'vite';

declare const customizeLogger: (params?: {
  patternsToHide?: string[];
}) => Plugin;
declare const definePostcss: () => Plugin;
declare const defineTwig: (data: object) => Plugin;
declare const watchNodeModules: (modules: string[]) => Plugin;
declare const defineSharedStatic: (prefix?: string) => Plugin;

export {
  customizeLogger,
  definePostcss,
  defineSharedStatic,
  defineTwig,
  watchNodeModules,
};
