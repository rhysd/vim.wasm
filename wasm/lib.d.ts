declare const Module: any;
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
