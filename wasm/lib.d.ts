declare interface DrawEvents {
    setColorFG: [/*code*/ string];
    setColorBG: [/*code*/ string];
    setColorSP: [/*code*/ string];
    setFont: [/*name*/ string, /*size*/ number];
    drawRect: [/*x*/ number, /*y*/ number, /*w*/ number, /*h*/ number, /*color*/ string, /*filled*/ boolean];
    drawText: [
        /*text*/ string,
        /*ch*/ number,
        /*lh*/ number,
        /*cw*/ number,
        /*x*/ number,
        /*y*/ number,
        /*bold*/ boolean,
        /*underline*/ boolean,
        /*undercurl*/ boolean,
        /*strike*/ boolean
    ];
    invertRect: [/*x*/ number, /*y*/ number, /*w*/ number, /*h*/ number];
    imageScroll: [/*x*/ number, /*sy*/ number, /*dy*/ number, /*w*/ number, /*h*/ number];
}

// ['setColorFG', [string]] | ...
declare type DrawEventMessage = { [K in keyof DrawEvents]: [K, DrawEvents[K]] }[keyof DrawEvents];
// { setColorFG(a0: string): void; ... }
declare type DrawEventHandler = { [Name in keyof DrawEvents]: (...args: DrawEvents[Name]) => void };

declare type MessageFromWorker =
    | {
          kind: 'draw';
          event: DrawEventMessage;
      }
    | {
          kind: 'Fatal';
          message: string;
      };

declare const Module: any;
declare const LibraryManager: any;
declare class CharPtr {}
declare function debug(...args: any[]): void;
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
declare interface VimWindow {
    elemWidth: number;
    elemHeight: number;
}
declare interface CanvasRenderer extends DrawEventHandler {
    window: VimWindow;
    queue: DrawEventMessage[];
    onVimInit(): void;
    onVimExit(status?: number): void;
    enqueue(method: DrawEventMessage): void;
}
declare interface MainThread {
    renderer: CanvasRenderer;

    draw(...msg: DrawEventMessage): void;
    onVimInit(): void;
    onVimExit(status?: number): void;
}
declare const VW: {
    mainThread: MainThread;
};
