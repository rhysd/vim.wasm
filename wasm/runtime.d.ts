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

declare class CharPtr {}
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
declare function lengthBytesUTF8(s: string): number;
declare function autoAddDeps(lib: object, name: string): void;
declare function mergeInto(libs: any, lib: object): void;
declare const FS: {
    init(
        stdin: (() => string | null) | null,
        stdout: ((...args: any[]) => void) | null,
        stderr: ((...args: any[]) => void) | null,
    ): void;
    writeFile(name: string, contents: Uint8Array): void;
    readFile(path: string, opts?: { encoding?: string; flags?: string }): Uint8Array;
};
declare interface VimWasmRuntime {
    domWidth: number;
    domHeight: number;

    draw(...msg: DrawEventMessage): void;
    vimStarted(): void;
    vimExit(status: number): void;
    waitAndHandleEventFromMain(timeout: number | undefined): number;
    exportFile(fullpath: string): number;
    readClipboard(): CharPtr;
    writeClipboard(text: string): void;
}
declare const VW: {
    runtime: VimWasmRuntime;
};
declare let emscriptenRuntimeInitialized: Promise<void>;
declare let debug: (...args: any[]) => void;
