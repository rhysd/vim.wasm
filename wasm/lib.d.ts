declare const Module: any;
declare const LibraryManager: any;
declare class CharPtr {}
declare function debug(...args: any[]): void;
declare function Pointer_stringify(ptr: CharPtr, len?: number): string;
declare function autoAddDeps(lib: object, name: string): void;
declare function mergeInto(libs: any, lib: object): void;
declare const VW: {
    renderer: any; // TODO: type as CanvasRenderer
};
declare const FS: {
    init(stdin: (() => string | null) | null, stdout: Function | null, stderr: Function | null): void;
};
