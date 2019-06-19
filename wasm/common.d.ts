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
        /*strike*/ boolean,
    ];
    invertRect: [/*x*/ number, /*y*/ number, /*w*/ number, /*h*/ number];
    imageScroll: [/*x*/ number, /*sy*/ number, /*dy*/ number, /*w*/ number, /*h*/ number];
}

// ['setColorFG', [string]] | ...
declare type DrawEventMethod = keyof DrawEvents;
declare type DrawEventMessage = { [K in DrawEventMethod]: [K, DrawEvents[K]] }[DrawEventMethod];
// { setColorFG(a0: string): void; ... }
declare type DrawEventHandler = { [Name in DrawEventMethod]: (...args: DrawEvents[Name]) => void };

declare interface StartMessageFromMain {
    kind: 'start';
    debug: boolean;
    buffer: Int32Array;
    canvasDomHeight: number;
    canvasDomWidth: number;
}
declare interface KeyMessageFromMain {
    kind: 'key';
    keyCode: number;
    key: string;
    ctrl: boolean;
    shift: boolean;
    alt: boolean;
    meta: boolean;
}
declare interface ResizeMessageFromMain {
    kind: 'resize';
    height: number;
    width: number;
}
declare type MessageFromMain = StartMessageFromMain | ResizeMessageFromMain | KeyMessageFromMain;

declare interface FileBufferMessageFromWorker {
    kind: 'file-buffer';
    name: string;
    buffer: SharedArrayBuffer;
}
declare type MessageFromWorker =
    | {
          kind: 'draw';
          event: DrawEventMessage;
      }
    | {
          kind: 'started';
      }
    | {
          kind: 'exit';
          status: number;
      }
    | FileBufferMessageFromWorker;
declare type MessageKindFromWorker = MessageFromWorker['kind'];

declare type EventStatusFromMain = 0 | 1 | 2 | 3 | 4;
