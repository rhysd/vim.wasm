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
 * common.d.ts: Common type definitions for both main side and worker side
 */

interface DrawEvents {
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
type DrawEventMethod = keyof DrawEvents;
// ['setColorFG', [string]] | ...
type DrawEventMessage = { [K in DrawEventMethod]: [K, DrawEvents[K]] }[DrawEventMethod];
// { setColorFG(a0: string): void; ... }
type DrawEventHandler = { [Name in DrawEventMethod]: (...args: DrawEvents[Name]) => void };

interface StartMessageFromMain {
    readonly kind: 'start';
    readonly debug: boolean;
    readonly perf: boolean;
    readonly buffer: Int32Array;
    readonly clipboard: boolean;
    readonly canvasDomHeight: number;
    readonly canvasDomWidth: number;
}

interface FileBufferMessageFromWorker {
    readonly kind: 'open-file-buf:response';
    readonly name: string;
    readonly buffer: SharedArrayBuffer;
}
interface ClipboardBufMessageFromWorker {
    readonly kind: 'clipboard-buf:response';
    readonly buffer: SharedArrayBuffer;
}
interface CmdlineResultFromWorker {
    readonly kind: 'cmdline:response';
    readonly success: boolean;
}
type MessageFromWorkerWithoutTS =
    | {
          readonly kind: 'draw';
          readonly event: DrawEventMessage;
      }
    | {
          readonly kind: 'error';
          readonly message: string;
      }
    | {
          readonly kind: 'started';
      }
    | {
          readonly kind: 'exit';
          readonly status: number;
      }
    | FileBufferMessageFromWorker
    | {
          readonly kind: 'export';
          readonly path: string;
          readonly contents: ArrayBuffer;
      }
    | {
          readonly kind: 'read-clipboard:request';
      }
    | ClipboardBufMessageFromWorker
    | {
          readonly kind: 'write-clipboard';
          readonly text: string;
      }
    | CmdlineResultFromWorker;

type MessageFromWorker = MessageFromWorkerWithoutTS & { timestamp?: number };
type MessageKindFromWorker = MessageFromWorker['kind'];

type EventStatusFromMain = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7;
