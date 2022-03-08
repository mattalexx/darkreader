// Non-public API exposed for testing
import type {ConfigOptions} from 'karma';

declare module 'karma/lib/cli' {
    export function processArgs(
        argv: string[],
        options: ConfigOptions,
        fs: typeof import('fs'),
        path: typeof import('path'),
    ): ConfigOptions;
}
