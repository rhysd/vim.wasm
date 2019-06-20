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
    readonly kind: 'start';
    readonly debug: boolean;
    readonly perf: boolean;
    readonly buffer: Int32Array;
    readonly canvasDomHeight: number;
    readonly canvasDomWidth: number;
}

declare interface FileBufferMessageFromWorker {
    readonly kind: 'open-file-buf:response';
    readonly name: string;
    readonly buffer: SharedArrayBuffer;
    timestamp?: number;
}
declare type MessageFromWorker =
    | {
          readonly kind: 'draw';
          readonly event: DrawEventMessage;
          timestamp?: number;
      }
    | {
          readonly kind: 'started';
          timestamp?: number;
      }
    | {
          readonly kind: 'exit';
          readonly status: number;
          timestamp?: number;
      }
    | FileBufferMessageFromWorker;
declare type MessageKindFromWorker = MessageFromWorker['kind'];

declare type EventStatusFromMain = 0 | 1 | 2 | 3 | 4;
