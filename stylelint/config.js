import { createStylelintConfig } from "./stylelint.js";

export default createStylelintConfig({
  // Потом нужно понять, не хлам ли
  customFunctions: [
    "add",
    "darken",
    "escape-svg",
    "fade-in",
    "get-color",
    "get-gradient",
    "join",
    "lighten",
    "map-get",
    "map-merge",
    "nth",
    "quote",
    "subtract",
    "theme-color",
  ],

  customRules: {
    "no-descending-specificity": null, // Сначала лучше избавиться от вложенностей
  },

  useSorting: true,
});
