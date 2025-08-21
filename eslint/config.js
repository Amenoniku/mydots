import { createEslintConfig } from "./config/eslint.js";

export default createEslintConfig([
  {
    rules: {
      // Можно убрать, когда отрефакторим всё
      "no-nested-ternary": "off",

      // Убрать, когда ВСЕ компоненты будут на TS
      "vue/block-lang": "off",

      // Убрать при выпуске https://jira.sapient.ru/browse/SL-8191
      "vue/match-component-file-name": "off",
      "vue/multi-word-component-names": "off",

      // Пока чревато конфликтами с параллельными задачами по рефакторингу
      "vue/no-static-inline-styles": "off",
    },
  },
]);
