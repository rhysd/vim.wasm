process.env.CHROME_BIN = require('puppeteer').executablePath();

// Note: karma-typescript is not available because JavaScript test source compiled from TypeScript
// by karma-typescript causes weird 'SyntaxError: Unexpected number' error at running tests.
module.exports = function(config) {
    config.set({
        browsers: ['ChromeHeadless'],
        frameworks: ['mocha', 'chai', 'sinon'],
        files: [
            {
                pattern: './test/*.js',
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
        ],
        client: {
            mocha: {
                grep: 'clipboard',
                timeout: 5000,
            },
        },
    });
};
