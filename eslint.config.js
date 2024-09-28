import js from "@eslint/js";
import react from "eslint-plugin-react"
import globals from "globals";

export default [
    js.configs.recommended,
    react.configs.flat.recommended,
    react.configs.flat['jsx-runtime'], /* React 17+ で必要 */

    {
        files: ['**/*.{js,jsx,mjs,cjs,ts,tsx}'],
        settings: {
            react: {
                version: "detect",
            },
        },
        plugins: {
            react
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
