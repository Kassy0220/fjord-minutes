import js from "@eslint/js";
import react from "eslint-plugin-react"
import jsxA11y from "eslint-plugin-jsx-a11y"
import globals from "globals";

export default [
    js.configs.recommended,
    react.configs.flat.recommended,
    react.configs.flat['jsx-runtime'], /* React 17+ で必要 */
    jsxA11y.flatConfigs.recommended,

    {
        files: ['**/*.{js,jsx,mjs,cjs,ts,tsx}'],
        settings: {
            react: {
                version: "detect",
            },
        },
        plugins: {
            react,
            jsxA11y,
        },
        rules: {
            "no-unused-vars": "warn",
            "no-undef": "warn"
        },
        languageOptions: {
            parserOptions: {
                ecmaFeatures: {
                    jsx: true,
                },
            },
            globals: {
                ...globals.browser
            }
        }
    }
];
