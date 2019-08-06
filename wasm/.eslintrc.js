module.exports = {
    extends: [
        'eslint:recommended',
        'plugin:@typescript-eslint/recommended',
        'plugin:security/recommended',
        'prettier',
        'prettier/@typescript-eslint',
    ],
    env: {
        es6: true,
        browser: true,
        mocha: true,
    },
    globals: {
        debug: 'writable',
        emscriptenRuntimeInitialized: 'writable',
        DEBUGGING: 'readonly',
        VW: 'readonly',
        SharedArrayBuffer: 'readonly',
        Atomics: 'readonly',
        Module: 'readonly',
        UTF8ToString: 'readonly',
        stringToUTF8: 'readonly',
        autoAddDeps: 'readonly',
        mergeInto: 'readonly',
        LibraryManager: 'readonly',
        FS: 'readonly',
        assert: 'readonly',
        sinon: 'readonly',
        IDBFS: 'readonly',
        Asyncify: 'readonly',
        __karma__: 'readonly',
    },
    parser: '@typescript-eslint/parser',
    plugins: ['@typescript-eslint', 'security', 'mocha'],
    rules: {
        // Disabled
        '@typescript-eslint/no-parameter-properties': 'off',
        '@typescript-eslint/explicit-function-return-type': 'off',
        '@typescript-eslint/no-unused-vars': 'off', // Since it is checked by TypeScript compiler
        '@typescript-eslint/no-explicit-any': 'off',
        '@typescript-eslint/explicit-member-accessibility': 'off',
        '@typescript-eslint/no-triple-slash-reference': 'off', // For common.d.ts, /// <reference/> is necessary
        'security/detect-non-literal-fs-filename': 'off',
        'security/detect-object-injection': 'off', // false positive at array index accesses

        // Enabled
        'no-console': 'error',
        '@typescript-eslint/no-floating-promises': 'error',

        // Configured
        '@typescript-eslint/array-type': ['error', 'array-simple'],
        'no-constant-condition': ['error', { checkLoops: false }],
    },
    overrides: [
        {
            files: ['main.ts', 'vimwasm.ts', 'common.d.ts', 'test/*.ts'],
            parserOptions: {
                project: './tsconfig.main.json',
            },
        },
        {
            files: ['runtime.ts', 'pre.ts', 'runtime.d.ts'],
            parserOptions: {
                project: './tsconfig.main.json',
            },
        },
        {
            files: ['test/*.ts'],
            rules: {
                '@typescript-eslint/no-non-null-assertion': 'off',
                'mocha/no-exclusive-tests': 'error',
                'mocha/no-skipped-tests': 'error',
                'mocha/handle-done-callback': 'error',
                'mocha/no-identical-title': 'error',
                'mocha/no-mocha-arrows': 'error',
                'mocha/no-return-and-callback': 'error',
                'mocha/no-sibling-hooks': 'error',
                'mocha/prefer-arrow-callback': 'error',
                'mocha/no-async-describe': 'error',
            },
        },
        {
            files: ['vtest/test.ts', 'vtest/img-diff-js.d.ts'],
            parserOptions: {
                project: './vtest/tsconfig.json',
            },
            env: {
                es6: true,
                browser: false,
                node: true,
            },
            rules: {
                'no-console': 'off',
            },
        },
    ],
};
