export const rootDir: string;
export function rootPath(...paths: any[]): string;
export declare namespace PLATFORM {
    const CHROME: string;
    const CHROME_MV3: string;
    const FIREFOX: string;
    const THUNDERBIRD: string;
}
export declare function getDestDir({ debug, platform }: {
    debug: any;
    platform: any;
}): string;
export declare function getTestDestDir(): string;
