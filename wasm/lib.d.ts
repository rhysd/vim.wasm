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
declare interface CanvasRenderer {
    window: VimWindow;
    onVimInit(): void;
    onVimExit(status?: number): void;
    enqueue(method: (...args: any[]) => void, args: any[]): void;
    setColorFG(name: string): void;
    setColorBG(name: string): void;
    setColorSP(name: string): void;
    setFont(name: string, size: number): void;
    drawRect(x: number, y: number, w: number, h: number, color: string, filled: boolean): void;
    drawText(
        text: string,
        ch: number,
        lh: number,
        cw: number,
        x: number,
        y: number,
        bold: boolean,
        underline: boolean,
        undercurl: boolean,
        strike: boolean,
    ): void;
    invertRect(x: number, y: number, w: number, h: number): void;
    imageScroll(x: number, sy: number, dy: number, w: number, h: number): void;
    mouseX(): number;
    mouseY(): number;
}
declare const VW: {
    renderer: CanvasRenderer; // TODO: type as CanvasRenderer
};
