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

declare interface FileBufferMessageFromWorker {
    kind: 'open-file-buf:response';
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
