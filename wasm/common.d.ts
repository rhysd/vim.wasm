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
declare type DrawEventMessage = { [K in keyof DrawEvents]: [K, DrawEvents[K]] }[keyof DrawEvents];
// { setColorFG(a0: string): void; ... }
declare type DrawEventHandler = { [Name in keyof DrawEvents]: (...args: DrawEvents[Name]) => void };

declare interface StartMessageFromMain {
    kind: 'start';
    debug: boolean;
    buffer: Int32Array;
    canvasDomHeight: number;
    canvasDomWidth: number;
}
declare interface KeyMessageFromMain {
    kind: 'key';
    code: string;
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

declare type MessageFromWorker =
    | {
          kind: 'draw';
          event: DrawEventMessage;
      }
    | {
          kind: 'fatal';
          message: string;
      }
    | {
          kind: 'started';
      }
    | {
          kind: 'exit';
          // TODO: Add exit status
      };
