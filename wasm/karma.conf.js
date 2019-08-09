process.env.CHROME_BIN = require('puppeteer').executablePath();

// Note: karma-typescript is not available because JavaScript test source compiled from TypeScript
// by karma-typescript causes weird 'SyntaxError: Unexpected number' error at running tests.
module.exports = function(config) {
    config.set({
        browsers: ['ChromeHeadless'],
        frameworks: ['mocha', 'chai', 'sinon'],
        files: [
            {
                pattern: config.pattern || './test/*.js',
                type: 'module',
                watched: true,
            },
            {
                pattern: './test/helper.js',
                type: 'module',
                watched: true,
            },
            {
                pattern: './vimwasm.js',
                type: 'module',
                included: false,
            },
            {
                pattern: './vim.*',
                included: false,
                served: true,
            },
            {
                pattern: './test/*.js.map',
                included: false,
                served: true,
            },
            {
                pattern: './*.js.map',
                included: false,
                served: true,
            },
            {
                pattern: './test/*.ts',
                included: false,
                served: true,
            },
            {
                pattern: './*.ts',
                included: false,
                served: true,
            },
            {
                pattern: './test/hello.txt',
                included: false,
                served: true,
            },
            {
                pattern: './test/*.vim',
                included: false,
                served: true,
            },
        ],
        client: {
            mocha: {
                timeout: 5000,
            },
            args: config.travisci ? ['--travis-ci'] : [],
        },
        customLaunchers: {
            ChromeDebug: {
                base: 'Chrome',
                flags: ['--auto-open-devtools-for-tabs'],
            },
        },
    });
};
