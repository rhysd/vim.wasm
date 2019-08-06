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
    readonly clipboard: boolean;
    readonly canvasDomHeight: number;
    readonly canvasDomWidth: number;
    readonly persistent: string[];
    readonly dirs: string[];
    readonly files: { [fpath: string]: string };
    readonly fetchFiles: { [fpath: string]: string };
    readonly cmdArgs: string[];
}
interface ReadClipboardMessageFromMain {
    readonly kind: 'read-clipboard:response';
    readonly contents: ArrayBuffer | null; // UTF-8 clipboard contents
}
interface EvalFuncMessageFromMain {
    readonly kind: 'evalfunc:response';
    readonly success: boolean;
    // UTF-8 encoded result of evaluation. On success, it represents returned value
    // from the function. Otherwise, it represents an error message.
    readonly result: ArrayBuffer;
}

type MessageFromMain =
    | StartMessageFromMain
    | ReadClipboardMessageFromMain
    | EvalFuncMessageFromMain
    | {
          readonly kind: 'key';
          readonly key: string;
          readonly keyCode: number;
          readonly ctrl: boolean;
          readonly shift: boolean;
          readonly alt: boolean;
          readonly meta: boolean;
      }
    | {
          readonly kind: 'resize';
          readonly width: number;
          readonly height: number;
      }
    | {
          readonly kind: 'open-file';
          readonly filename: string;
          readonly contents: ArrayBuffer; // UTF-8 file contents
      }
    | {
          readonly kind: 'cmdline';
          readonly cmdline: string;
      }
    | {
          readonly kind: 'emsg';
          readonly message: string;
      };
type MessageKindFromMain = MessageFromMain['kind'];

interface CmdlineResultFromWorker {
    readonly kind: 'cmdline:response';
    readonly success: boolean;
}
interface SharedBufResponseFromWorker {
    readonly kind: 'shared-buf:response';
    readonly buffer: SharedArrayBuffer;
    readonly bufId: number;
}
type MessageFromWorkerWithoutTimestamp =
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
    | {
          readonly kind: 'export';
          readonly path: string;
          readonly contents: ArrayBuffer;
      }
    | {
          readonly kind: 'read-clipboard:request';
      }
    | {
          readonly kind: 'write-clipboard';
          readonly text: string;
      }
    | CmdlineResultFromWorker
    | SharedBufResponseFromWorker
    | {
          readonly kind: 'title';
          readonly title: string;
      }
    | {
          readonly kind: 'eval';
          readonly path: string;
          readonly contents: ArrayBuffer;
      }
    | {
          readonly kind: 'evalfunc';
          readonly body: string;
          readonly argsJson: string | undefined;
          readonly notifyOnly: boolean;
      };

type MessageFromWorker = MessageFromWorkerWithoutTimestamp & { timestamp?: number };
type MessageKindFromWorker = MessageFromWorker['kind'];

type EventStatusFromMain = 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8;
