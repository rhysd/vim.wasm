declare const Module: any;
declare const LibraryManager: any;
declare class CharPtr {}
declare function debug(...args: any[]): void;
declare function Pointer_stringify(ptr: CharPtr, len?: number): string;
declare function autoAddDeps(lib: object, name: string): void;
declare function mergeInto(libs: any, lib: object): void;
declare const FS: {
    init(stdin: (() => string | null) | null, stdout: Function | null, stderr: Function | null): void;
};
declare interface VimWindowI {
    elemWidth: number;
    elemHeight: number;
}
declare interface CanvasRendererI {
    window: VimWindowI;
    onVimInit(): void;
    onVimExit(status?: number): void;
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
        strike: boolean
    ): void;
    invertRect(x: number, y: number, w: number, h: number): void;
    imageScroll(x: number, sy: number, dy: number, w: number, h: number): void;
    mouseX(): number;
    mouseY(): number;
}
declare const VW: {
    renderer: CanvasRendererI; // TODO: type as CanvasRenderer
};
