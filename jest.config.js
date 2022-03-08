// @ts-check

const {dirname} = require('path');
const rootDir = dirname(require.resolve('./package.json'));

/** @type {import('@jest/types').Config.InitialOptions} */
const config = {
    rootDir,
    projects: [
        // '<rootDir>/tests/browser/jest.config.js',
        '<rootDir>/tests/unit/jest.config.js',
        '<rootDir>/tests/project/jest.config.js',
    ],
};

module.exports = config;
