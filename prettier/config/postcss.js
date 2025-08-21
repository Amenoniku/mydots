import autoprefixer from 'autoprefixer';
import sortMediaQueries from 'postcss-sort-media-queries';
import postcssUrl from 'postcss-url';

/** @type {{ plugins?: readonly import('postcss').AcceptedPlugin[] }}} */
export const postcssConfig = {
  plugins: [
    autoprefixer,
    sortMediaQueries(),
    postcssUrl([
      {
        filter: '**/icons/*',
        url: 'inline',
      },
    ]),
  ],
};
