/* vi:set ts=4 sts=4 sw=4 et:
 *
 * VIM - Vi IMproved		by Bram Moolenaar
 *				Wasm support by rhysd <https://github.com/rhysd>
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */

/*
 * common_types.ts: Common type definitions for both main side and worker side
 */

export interface DrawEvents {
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

// 'setColorFG' | 'setColorBG' | ...
export type DrawEventMethod = keyof DrawEvents;
// ['setColorFG', [string]] | ...
export type DrawEventMessage = { [K in DrawEventMethod]: [K, DrawEvents[K]] }[DrawEventMethod];
// { setColorFG(a0: string): void; ... }
export type DrawEventHandler = { [Name in DrawEventMethod]: (...args: DrawEvents[Name]) => void };

export interface StartMessageFromMain {
    readonly kind: 'start';
    readonly debug: boolean;
    readonly perf: boolean;
    readonly buffer: Int32Array;
    readonly clipboard: boolean;
    readonly canvasDomHeight: number;
    readonly canvasDomWidth: number;
}

export interface FileBufferMessageFromWorker {
    readonly kind: 'open-file-buf:response';
    readonly name: string;
    readonly buffer: SharedArrayBuffer;
    timestamp?: number;
}
export interface ClipboardBufMessageFromWorker {
    readonly kind: 'clipboard-buf:response';
    readonly buffer: SharedArrayBuffer;
    timestamp?: number;
}
export interface CmdlineResultFromWorker {
    readonly kind: 'cmdline:response';
    readonly success: boolean;
    timestamp?: number;
}
export type MessageFromWorker =
    | {
          readonly kind: 'draw';
          readonly event: DrawEventMessage;
          timestamp?: number;
      }
    | {
          readonly kind: 'error';
          readonly message: string;
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
    | FileBufferMessageFromWorker
    | {
          readonly kind: 'export';
          readonly path: string;
          readonly contents: ArrayBuffer;
          timestamp?: number;
      }
    | {
          readonly kind: 'read-clipboard:request';
          timestamp?: number;
      }
    | ClipboardBufMessageFromWorker
    | {
          readonly kind: 'write-clipboard';
          readonly text: string;
          timestamp?: number;
      }
    | CmdlineResultFromWorker;
export type MessageKindFromWorker = MessageFromWorker['kind'];

export type EventStatusFromMain = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7;
