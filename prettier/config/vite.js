import path from 'node:path';
import { createLogger } from 'vite';

import { inlineScssAndJs } from '../lib/inliner.js';
import { createStaticMiddleware } from '../lib/static.js';
import { renderTwigTemplate } from '../lib/twig.js';
import { postcssConfig } from './postcss.js';

export const customizeLogger = ({ patternsToHide = [] } = {}) => {
  const customLogger = createLogger();
  const originalWarnOnce = customLogger.warnOnce;
  const originalInfo = customLogger.info;

  customLogger.warnOnce = (message, options) => {
    for (const warning of patternsToHide) {
      if (message.includes(warning)) {
        return;
      }
    }
    originalWarnOnce(message, options);
  };
  customLogger.info = (message, options) => {
    for (const warning of patternsToHide) {
      if (message.includes(warning)) {
        return;
      }
    }
    originalInfo(message, options);
  };

  return {
    config() {
      return { customLogger };
    },
    name: 'custom-logger',
  };
};

export const definePostcss = () => ({
  config() {
    return {
      css: { postcss: postcssConfig },
    };
  },
  name: 'define-postcss',
});

export const defineSharedStatic = (prefix = '') => ({
  configureServer(server) {
    server.middlewares.use(createStaticMiddleware(prefix));
  },
  name: 'define-shared-static',
});

export const defineTwig = (data) => ({
  handleHotUpdate({ file, server }) {
    if (path.extname(file) === '.twig') {
      server.ws.send({ type: 'full-reload' });
    }
  },
  name: 'vite-twig',
  transformIndexHtml: {
    async handler(_html, ctx) {
      const page = ctx.path.replace(/^\//, '');
      const result = await renderTwigTemplate(path.join(process.cwd(), page), {
        page,
        ...data,
      });
      const resultWithInlineCode = await inlineScssAndJs(result, ctx);
      return resultWithInlineCode;
    },
    order: 'pre',
  },
});

export const watchNodeModules = (modules) => ({
  config() {
    return {
      optimizeDeps: {
        exclude: modules,
      },
    };
  },
  configureServer(server) {
    const regexp = `/node_modules\\/(?!${modules.join('|')}).*/`;
    const { watcher } = server;
    watcher.options = {
      ...server.watcher.options,
      ignored: ['**/.git/**', '**/test-results/**', new RegExp(regexp)],
    };
    watcher._userIgnored = undefined;
  },
  name: 'watch-node-modules',
});
