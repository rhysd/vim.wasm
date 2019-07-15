/* vi:set ts=4 sts=4 sw=4 et:
 *
 * VIM - Vi IMproved		by Bram Moolenaar
 *				Wasm support by rhysd <https://github.com/rhysd>
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */

/*
 * runtime.d.ts: Type definitions only for worker side.
 */

declare type CharPtr = number & { __pointer__: void };
declare const Module: {
    HEAPU8: Uint8Array;
    preRun: Array<() => void>;
    onRuntimeInitialized: () => void;
    cwrap(
        name: string,
        retType: null | string,
        argTypes: string[],
        opts?: { async?: boolean },
    ): (...args: any[]) => any;
    ccall(name: string, retType: null | string, argTypes: string[], args: any[], opts?: { async?: boolean }): any;
    _malloc(bytes: number): CharPtr;
    _free(ptr: CharPtr): void;
};

declare const LibraryManager: any;
declare function UTF8ToString(ptr: CharPtr, maxBytesToRead?: number): string;
declare function stringToUTF8(str: string, outPtr: CharPtr, maxBytesToRead: number): number;
declare function autoAddDeps(lib: object, name: string): void;
declare function mergeInto(libs: any, lib: object): void;

declare const IDBFS: 'IDBFS';
declare interface FileOpenOption {
    flags?: 'r' | 'r+' | 'w' | 'wx' | 'w+' | 'wx+' | 'a' | 'ax' | 'a+' | 'ax+';
}
declare const FS: {
    init(
        stdin: (() => string | null) | null,
        stdout: ((...args: any[]) => void) | null,
        stderr: ((...args: any[]) => void) | null,
    ): void;
    writeFile(name: string, contents: ArrayBufferView | string, opts?: FileOpenOption): void;
    readFile(path: string): Uint8Array;
    readFile(path: string, opts: { encoding: 'binary'; flags?: string }): Uint8Array;
    readFile(path: string, opts: { encoding: 'utf8'; flags?: string }): string;
    mount(type: 'IDBFS', opts: {}, mountpoint: string): void;
    mkdir(dirpath: string): void;
    syncfs(populate: boolean, cb: (err: Error) => void): void;
    syncfs(cb: (err: Error) => void): void;
};

declare let emscriptenRuntimeInitialized: Promise<void>;
declare let debug: (...args: any[]) => void;
