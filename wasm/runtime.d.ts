declare const Module: {
    preRun: Array<() => void>;
    onRuntimeInitialized: () => void;
    cwrap(name: string, retType: null | string, argTypes: string[], opts?: { async?: boolean }): any;
    ccall(name: string, retType: null | string, argTypes: string[], args: any[], opts?: { async?: boolean }): any;
};
declare const LibraryManager: any;
declare class CharPtr {}
declare function UTF8ToString(ptr: CharPtr, maxBytesToRead?: number): string;
declare function autoAddDeps(lib: object, name: string): void;
declare function mergeInto(libs: any, lib: object): void;
declare const FS: {
    init(
        stdin: (() => string | null) | null,
        stdout: ((...args: any[]) => void) | null,
        stderr: ((...args: any[]) => void) | null,
    ): void;
};
declare interface VimWasmRuntime {
    domWidth: number;
    domHeight: number;

    draw(...msg: DrawEventMessage): void;
    vimStarted(): void;
    vimExit(): void;
    waitForEventFromMain(timeout: number | undefined): number;
}
declare const VW: {
    runtime: VimWasmRuntime;
};
declare let emscriptenRuntimeInitialized: Promise<void>;
