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
    _free(ptr: CharPtr): void;
};
declare const LibraryManager: any;
declare function UTF8ToString(ptr: CharPtr, maxBytesToRead?: number): string;
declare function stringToUTF8(s: string): CharPtr;
declare function autoAddDeps(lib: object, name: string): void;
declare function mergeInto(libs: any, lib: object): void;
declare const FS: {
    init(
        stdin: (() => string | null) | null,
        stdout: ((...args: any[]) => void) | null,
        stderr: ((...args: any[]) => void) | null,
    ): void;
    writeFile(name: string, contents: Uint8Array): void;
};
declare interface VimWasmRuntime {
    domWidth: number;
    domHeight: number;

    draw(...msg: DrawEventMessage): void;
    vimStarted(): void;
    vimExit(status: number): void;
    waitForEventFromMain(timeout: number | undefined): number;
}
declare const VW: {
    runtime: VimWasmRuntime;
};
declare let emscriptenRuntimeInitialized: Promise<void>;
declare let debug: (...args: any[]) => void;
