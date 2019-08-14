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
 * vimwasm.ts: TypeScript main thread module for Wasm port of Vim by @rhysd.
 */

/// <reference path="common.d.ts"/>

type PerfMark = 'init' | 'raf' | 'draw';
type MessageEncodable = number | boolean | string;

export interface ScreenDrawer {
    draw(msg: DrawEventMessage): void;
    onVimInit(): void;
    onVimExit(): void;
    getDomSize(): { width: number; height: number };
    setPerf(enabled: boolean): void;
    focus(): void;
}

export interface KeyModifiers {
    ctrl?: boolean;
    shift?: boolean;
    alt?: boolean;
    meta?: boolean;
}

export const VIM_VERSION = '8.1.1845';

const AsyncFunction = Object.getPrototypeOf(async function() {}).constructor;

function noop() {
    /* do nothing */
}
let debug: (...args: any[]) => void = noop;

const STATUS_NOT_SET = 0 as const;
const STATUS_NOTIFY_KEY = 1 as const;
const STATUS_NOTIFY_RESIZE = 2 as const;
const STATUS_NOTIFY_OPEN_FILE_BUF_COMPLETE = 3 as const;
const STATUS_NOTIFY_CLIPBOARD_WRITE_COMPLETE = 4 as const;
const STATUS_REQUEST_CMDLINE = 5 as const;
const STATUS_REQUEST_SHARED_BUF = 6 as const;
const STATUS_NOTIFY_ERROR_OUTPUT = 7 as const;
const STATUS_NOTIFY_EVAL_FUNC_RET = 8 as const;

function statusName(s: EventStatusFromMain): string {
    switch (s) {
        case STATUS_NOT_SET:
            return 'NOT_SET';
        case STATUS_NOTIFY_KEY:
            return 'NOTIFY_KEY';
        case STATUS_NOTIFY_RESIZE:
            return 'NOTIFY_RESIZE';
        case STATUS_NOTIFY_OPEN_FILE_BUF_COMPLETE:
            return 'NOTIFY_OPEN_FILE_BUF_COMPLETE';
        case STATUS_NOTIFY_CLIPBOARD_WRITE_COMPLETE:
            return 'NOTIFY_CLIPBOARD_WRITE_COMPLETE';
        case STATUS_REQUEST_CMDLINE:
            return 'REQUEST_CMDLINE';
        case STATUS_REQUEST_SHARED_BUF:
            return 'REQUEST_SHARED_BUF';
        case STATUS_NOTIFY_ERROR_OUTPUT:
            return 'NOTIFY_ERROR_OUTPUT';
        case STATUS_NOTIFY_EVAL_FUNC_RET:
            return 'STATUS_NOTIFY_EVAL_FUNC_RET';
        default:
            return `Unknown command: ${s}`;
    }
}

export function checkBrowserCompatibility(): string | undefined {
    function notSupported(feat: string): string {
        return `${feat} is not supported by this browser. If you're using Firefox or Safari, please enable feature flag.`;
    }

    if (typeof SharedArrayBuffer === 'undefined') {
        return notSupported('SharedArrayBuffer');
    }
    if (typeof Atomics === 'undefined') {
        return notSupported('Atomics API');
    }

    return undefined;
}

export class VimWorker {
    public debug: boolean;
    public readonly sharedBuffer: Int32Array;
    private readonly worker: Worker;
    private readonly onMessage: (msg: MessageFromWorker) => void;
    private readonly onError: (err: Error) => void;
    private onOneshotMessage: Map<MessageKindFromWorker, (msg: MessageFromWorker) => void>;
    // Events are queued since an event may arrive while previous event is still being processed by
    // worker thread. First element is a pair of status and values of an event currently being processed.
    // Rest elements are pending events which will be processed after.
    private pendingEvents: Array<[EventStatusFromMain, MessageEncodable[]]>;

    constructor(scriptPath: string, onMessage: (msg: MessageFromWorker) => void, onError: (err: Error) => void) {
        this.worker = new Worker(scriptPath);
        this.worker.onmessage = this.recvMessage.bind(this);
        this.worker.onerror = this.recvError.bind(this);
        this.sharedBuffer = new Int32Array(new SharedArrayBuffer(Int32Array.BYTES_PER_ELEMENT * 128));
        this.onMessage = onMessage;
        this.onError = onError;
        this.onOneshotMessage = new Map();
        this.debug = false;
        this.pendingEvents = [];
    }

    terminate() {
        this.worker.terminate();
        this.worker.onmessage = null;
        debug('Terminated worker thread. Thank you for working hard!');
    }

    sendStartMessage(msg: StartMessageFromMain) {
        this.worker.postMessage(msg);
        debug('Sent start message', msg);
    }

    notifyOpenFileBufComplete(filename: string, bufId: number) {
        this.enqueueEvent(STATUS_NOTIFY_OPEN_FILE_BUF_COMPLETE, bufId, filename);
    }

    notifyClipboardWriteComplete(cannotSend: boolean, bufId: number) {
        this.enqueueEvent(STATUS_NOTIFY_CLIPBOARD_WRITE_COMPLETE, cannotSend, bufId);
    }

    notifyKeyEvent(key: string, keyCode: number, ctrl: boolean, shift: boolean, alt: boolean, meta: boolean) {
        this.enqueueEvent(STATUS_NOTIFY_KEY, keyCode, ctrl, shift, alt, meta, key);
    }

    notifyResizeEvent(width: number, height: number) {
        this.enqueueEvent(STATUS_NOTIFY_RESIZE, width, height);
    }

    async requestSharedBuffer(byteLength: number): Promise<[number, SharedArrayBuffer]> {
        this.enqueueEvent(STATUS_REQUEST_SHARED_BUF, byteLength);

        const msg = (await this.waitForOneshotMessage('shared-buf:response')) as SharedBufResponseFromWorker;

        if (msg.buffer.byteLength !== byteLength) {
            throw new Error(
                `Size of shared buffer from worker ${msg.buffer.byteLength} bytes mismatches to requested size ${byteLength} bytes`,
            );
        }

        return [msg.bufId, msg.buffer];
    }

    notifyClipboardError() {
        this.notifyClipboardWriteComplete(true, 0);
        debug('Reading clipboard failed. Notify it to worker');
    }

    async responseClipboardText(text: string) {
        const encoded = new TextEncoder().encode(text);
        const [bufId, buffer] = await this.requestSharedBuffer(encoded.byteLength + 1); // `+ 1` for NULL termination

        new Uint8Array(buffer).set(encoded);
        this.notifyClipboardWriteComplete(false, bufId);

        debug('Wrote clipboard', encoded.byteLength, 'bytes text and notified to worker');
    }

    async requestCmdline(cmdline: string) {
        if (cmdline.length === 0) {
            throw new Error('Specified command line is empty');
        }

        this.enqueueEvent(STATUS_REQUEST_CMDLINE, cmdline);

        const msg = (await this.waitForOneshotMessage('cmdline:response')) as CmdlineResultFromWorker;
        debug('Result of command', cmdline, ':', msg.success);
        if (!msg.success) {
            throw Error(`Command '${cmdline}' was invalid and not accepted by Vim`);
        }
    }

    async notifyErrorOutput(message: string) {
        const encoded = new TextEncoder().encode(message);
        const [bufId, buffer] = await this.requestSharedBuffer(encoded.byteLength);
        new Uint8Array(buffer).set(encoded);

        this.enqueueEvent(STATUS_NOTIFY_ERROR_OUTPUT, bufId);
        debug('Sent error message output:', message);
    }

    async notifyEvalFuncRet(ret: string) {
        const encoded = new TextEncoder().encode(ret);
        const [bufId, buffer] = await this.requestSharedBuffer(encoded.byteLength);
        new Uint8Array(buffer).set(encoded);

        this.enqueueEvent(STATUS_NOTIFY_EVAL_FUNC_RET, false /*isError*/, bufId);
        debug('Sent return value of evaluated JS function:', ret);
    }

    async notifyEvalFuncError(msg: string, err: Error, dontReply: boolean) {
        const errmsg = `${msg} for jsevalfunc(): ${err.message}: ${err.stack}`;
        if (dontReply) {
            debug('Will send error output from jsevalfunc() though the invocation was notify-only:', errmsg);
            return this.notifyErrorOutput(errmsg);
        }

        const encoded = new TextEncoder().encode('E9999: ' + errmsg);
        const [bufId, buffer] = await this.requestSharedBuffer(encoded.byteLength);
        new Uint8Array(buffer).set(encoded);

        this.enqueueEvent(STATUS_NOTIFY_EVAL_FUNC_RET, true /*isError*/, bufId);

        debug('Sent exception thrown by evaluated JS function:', msg, err);
    }

    onEventDone(doneStatus: EventStatusFromMain) {
        const done = statusName(doneStatus);

        // First element should be an event being processed by worker.
        // Dequeue it and check it matches to the status notified from worker.
        const finished = this.pendingEvents.shift();

        if (finished === undefined) {
            throw new Error(`FATAL: Received ${done} event but event queue is empty`);
        }

        if (finished[0] !== doneStatus) {
            throw new Error(
                `FATAL: Received ${done} event but queue says previous event was ${statusName(finished[0])} with args ${
                    finished[1]
                }`,
            );
        }

        // Send next pending event if exists

        if (this.pendingEvents.length === 0) {
            debug('No pending event remains after event', done);
            return;
        }

        debug('After', done, 'event, still', this.pendingEvents.length, 'events are pending');
        const [status, values] = this.pendingEvents[0];
        this.sendEvent(status, values);
    }

    private enqueueEvent(status: EventStatusFromMain, ...values: MessageEncodable[]) {
        this.pendingEvents.push([status, values]);

        if (this.pendingEvents.length > 1) {
            debug('Other event is being handled by worker. Pending:', statusName(status), values);
            return;
        }

        // When queue was empty, send the event immediately
        this.sendEvent(status, values);
    }

    private sendEvent(status: EventStatusFromMain, values: MessageEncodable[]) {
        const event = statusName(status);

        // TODO: Queueing request/notification to worker and wait status byte is cleared
        // Note: Non-zero means data remains not handled by worker yet.
        if (this.debug) {
            const status = Atomics.load(this.sharedBuffer, 0);
            if (status !== STATUS_NOT_SET) {
                console.error('INVARIANT ERROR! Status byte must be zero cleared:', event); // eslint-disable-line no-console
            }
        }

        debug('Write event', event, 'payload to buffer:', values);

        let idx = 0;
        this.sharedBuffer[idx++] = status;

        for (const value of values) {
            switch (typeof value) {
                case 'string':
                    idx = this.encodeStringToBuffer(value, idx);
                    break;
                case 'number':
                    this.sharedBuffer[idx++] = value;
                    break;
                case 'boolean':
                    this.sharedBuffer[idx++] = +value;
                    break;
                default:
                    throw new Error(`FATAL: Invalid value for payload to worker: ${value}`);
            }
        }
        debug('Wrote', idx * 4, 'bytes to buffer for event', event);

        Atomics.notify(this.sharedBuffer, 0, 1);
        debug('Notified event', event, 'to worker');
    }

    private async waitForOneshotMessage(kind: MessageKindFromWorker) {
        return new Promise<MessageFromWorker>(resolve => {
            this.onOneshotMessage.set(kind, resolve);
        });
    }

    private encodeStringToBuffer(s: string, startIdx: number) {
        let idx = startIdx;
        const len = s.length;
        this.sharedBuffer[idx++] = len;
        for (let i = 0; i < len; ++i) {
            this.sharedBuffer[idx++] = s.charCodeAt(i);
        }
        return idx;
    }

    private recvMessage(e: MessageEvent) {
        const msg: MessageFromWorker = e.data;

        // Handle oneshot communication for RPC call
        const handler = this.onOneshotMessage.get(msg.kind);
        if (handler !== undefined) {
            this.onOneshotMessage.delete(msg.kind);
            handler(msg);
            return;
        }

        // On notification
        this.onMessage(msg);
    }

    private recvError(e: ErrorEvent) {
        debug('Received an error from worker:', e);
        const msg = `${e.message} (${e.filename}:${e.lineno}:${e.colno})`;
        this.onError(new Error(msg));
    }
}

export class ResizeHandler {
    elemHeight: number;
    elemWidth: number;
    private bounceTimerToken: number | null;
    private readonly canvas: HTMLCanvasElement;
    private readonly worker: VimWorker;

    constructor(domWidth: number, domHeight: number, canvas: HTMLCanvasElement, worker: VimWorker) {
        this.canvas = canvas;
        this.worker = worker;
        this.elemHeight = domHeight;
        this.elemWidth = domWidth;
        const dpr = window.devicePixelRatio || 1;
        this.canvas.width = domWidth * dpr;
        this.canvas.height = domHeight * dpr;
        this.bounceTimerToken = null;
        this.onResize = this.onResize.bind(this);
    }

    onVimInit() {
        window.addEventListener('resize', this.onResize, { passive: true });
    }

    onVimExit() {
        window.removeEventListener('resize', this.onResize);
    }

    private doResize() {
        const rect = this.canvas.getBoundingClientRect();
        debug('Resize Vim:', rect);
        this.elemWidth = rect.width;
        this.elemHeight = rect.height;

        const res = window.devicePixelRatio || 1;
        this.canvas.width = rect.width * res;
        this.canvas.height = rect.height * res;

        this.worker.notifyResizeEvent(rect.width, rect.height);
    }

    private onResize() {
        if (this.bounceTimerToken !== null) {
            window.clearTimeout(this.bounceTimerToken);
        }
        this.bounceTimerToken = window.setTimeout(() => {
            this.bounceTimerToken = null;
            this.doResize();
        }, 500);
    }
}

// TODO: IME support
// TODO: Handle pre-edit IME state
// TODO: Follow cursor position
export class InputHandler {
    private readonly worker: VimWorker;
    private readonly elem: HTMLInputElement;

    constructor(worker: VimWorker, input: HTMLInputElement) {
        this.worker = worker;
        this.elem = input;
        // TODO: Bind compositionstart event
        // TODO: Bind compositionend event
        this.onKeydown = this.onKeydown.bind(this);
        this.onBlur = this.onBlur.bind(this);
        this.onFocus = this.onFocus.bind(this);
        this.focus();
    }

    setFont(name: string, size: number) {
        this.elem.style.fontFamily = name;
        this.elem.style.fontSize = size + 'px';
    }

    focus() {
        this.elem.focus();
    }

    onVimInit() {
        this.elem.addEventListener('keydown', this.onKeydown, { capture: true });
        this.elem.addEventListener('blur', this.onBlur);
        this.elem.addEventListener('focus', this.onFocus);
    }

    onVimExit() {
        this.elem.removeEventListener('keydown', this.onKeydown);
        this.elem.removeEventListener('blur', this.onBlur);
        this.elem.removeEventListener('focus', this.onFocus);
    }

    private onKeydown(event: KeyboardEvent) {
        event.preventDefault();
        event.stopPropagation();
        debug('onKeydown():', event, event.key, event.keyCode);

        let key = event.key;
        const ctrl = event.ctrlKey;
        const shift = event.shiftKey;
        const alt = event.altKey;
        const meta = event.metaKey;

        if (key.length > 1) {
            if (
                key === 'Unidentified' ||
                (ctrl && key === 'Control') ||
                (shift && key === 'Shift') ||
                (alt && key === 'Alt') ||
                (meta && key === 'Meta')
            ) {
                debug('Ignore key input', key);
                return;
            }
        }

        // Note: Yen needs to be fixed to backslash
        // Note: Also check event.code since Ctrl + yen is recognized as Ctrl + | due to Chrome bug.
        // https://bugs.chromium.org/p/chromium/issues/detail?id=871650
        if (key === '\u00A5' || (!shift && key === '|' && event.code === 'IntlYen')) {
            key = '\\';
        }

        this.worker.notifyKeyEvent(key, event.keyCode, ctrl, shift, alt, meta);
    }

    private onFocus() {
        debug('onFocus()');
        // TODO: Send <FocusGained> special character
    }

    private onBlur(event: Event) {
        debug('onBlur():', event);
        event.preventDefault();
        // TODO: Send <FocusLost> special character
    }
}

// Origin is at left-above.
//
//      O-------------> x
//      |
//      |
//      |
//      |
//      V
//      y

export class ScreenCanvas implements DrawEventHandler, ScreenDrawer {
    private readonly worker: VimWorker;
    private readonly canvas: HTMLCanvasElement;
    private readonly ctx: CanvasRenderingContext2D;
    private readonly input: InputHandler;
    private readonly queue: DrawEventMessage[];
    private readonly resizer: ResizeHandler;
    private perf: boolean;
    private fgColor: string;
    private spColor: string;
    private fontName: string;
    private rafScheduled: boolean;
    // Note: BG color is actually unused because color information is included
    // in drawRect event arguments
    // private bgColor: string;

    constructor(worker: VimWorker, canvas: HTMLCanvasElement, input: HTMLInputElement) {
        this.worker = worker;
        this.canvas = canvas;

        const ctx = this.canvas.getContext('2d', { alpha: false });
        if (ctx === null) {
            throw new Error('Cannot get 2D context for <canvas>');
        }
        this.ctx = ctx;

        const rect = this.canvas.getBoundingClientRect();
        const res = window.devicePixelRatio || 1;
        this.canvas.width = rect.width * res;
        this.canvas.height = rect.height * res;
        this.canvas.addEventListener('click', this.onClick.bind(this), {
            capture: true,
            passive: true,
        });

        this.input = new InputHandler(this.worker, input);
        this.resizer = new ResizeHandler(rect.width, rect.height, canvas, worker);

        this.onAnimationFrame = this.onAnimationFrame.bind(this);
        this.queue = [];
        this.rafScheduled = false;
        this.perf = false;
    }

    onVimInit() {
        this.input.onVimInit();
        this.resizer.onVimInit();
    }

    onVimExit() {
        this.input.onVimExit();
        this.resizer.onVimExit();
    }

    draw(msg: DrawEventMessage) {
        if (!this.rafScheduled) {
            window.requestAnimationFrame(this.onAnimationFrame);
            this.rafScheduled = true;
        }
        this.queue.push(msg);
    }

    focus() {
        this.input.focus();
    }

    getDomSize() {
        return {
            width: this.resizer.elemWidth,
            height: this.resizer.elemHeight,
        };
    }

    setPerf(enabled: boolean) {
        this.perf = enabled;
    }

    setColorFG(name: string) {
        this.fgColor = name;
    }

    setColorBG(_name: string) {
        // Note: BG color is actually unused because color information is included
        // in drawRect event arguments
        // this.bgColor = name;
    }

    setColorSP(name: string) {
        this.spColor = name;
    }

    setFont(name: string, size: number) {
        this.fontName = name;
        this.input.setFont(name, size);
    }

    drawRect(x: number, y: number, w: number, h: number, color: string, filled: boolean) {
        const dpr = window.devicePixelRatio || 1;
        x = Math.floor(x * dpr);
        y = Math.floor(y * dpr);
        w = Math.floor(w * dpr);
        h = Math.floor(h * dpr);
        this.ctx.fillStyle = color;
        if (filled) {
            this.ctx.fillRect(x, y, w, h);
        } else {
            this.ctx.rect(x, y, w, h);
        }
    }

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
    ) {
        const dpr = window.devicePixelRatio || 1;
        ch = ch * dpr;
        lh = lh * dpr;
        cw = cw * dpr;
        x = x * dpr;
        y = y * dpr;

        let font = Math.floor(ch) + 'px ' + this.fontName;
        if (bold) {
            font = 'bold ' + font;
        }

        this.ctx.font = font;
        // Note: 'ideographic' is not available (#23)
        //   https://twitter.com/Linda_pp/status/1139373687474278400
        this.ctx.textBaseline = 'bottom';
        this.ctx.fillStyle = this.fgColor;

        const descent = (lh - ch) / 2;
        const yi = Math.floor(y + lh - descent);
        for (let i = 0; i < text.length; ++i) {
            const c = text[i];
            if (c === ' ') {
                // Note: Skip rendering whitespace
                // XXX: This optimization assumes current font renders nothing on whitespace.
                continue;
            }
            this.ctx.fillText(c, Math.floor(x + cw * i), yi);
        }

        if (underline) {
            this.ctx.strokeStyle = this.fgColor;
            this.ctx.lineWidth = 1 * dpr;
            this.ctx.setLineDash([]);
            this.ctx.beginPath();
            // Note: 3 is set with considering the width of line.
            const underlineY = Math.floor(y + lh - descent - 1 * dpr);
            this.ctx.moveTo(Math.floor(x), underlineY);
            this.ctx.lineTo(Math.floor(x + cw * text.length), underlineY);
            this.ctx.stroke();
        } else if (undercurl) {
            this.ctx.strokeStyle = this.spColor;
            this.ctx.lineWidth = 1 * dpr;
            const curlWidth = Math.floor(cw / 3);
            this.ctx.setLineDash([curlWidth, curlWidth]);
            this.ctx.beginPath();
            // Note: 3 is set with considering the width of line.
            const undercurlY = Math.floor(y + lh - descent - 1 * dpr);
            this.ctx.moveTo(Math.floor(x), undercurlY);
            this.ctx.lineTo(Math.floor(x + cw * text.length), undercurlY);
            this.ctx.stroke();
        } else if (strike) {
            this.ctx.strokeStyle = this.fgColor;
            this.ctx.lineWidth = 1 * dpr;
            this.ctx.beginPath();
            const strikeY = Math.floor(y + lh / 2);
            this.ctx.moveTo(Math.floor(x), strikeY);
            this.ctx.lineTo(Math.floor(x + cw * text.length), strikeY);
            this.ctx.stroke();
        }
    }

    invertRect(x: number, y: number, w: number, h: number) {
        const dpr = window.devicePixelRatio || 1;
        x = Math.floor(x * dpr);
        y = Math.floor(y * dpr);
        w = Math.floor(w * dpr);
        h = Math.floor(h * dpr);

        const img = this.ctx.getImageData(x, y, w, h);
        const data = img.data;
        const len = data.length;
        for (let i = 0; i < len; ++i) {
            data[i] = 255 - data[i];
            ++i;
            data[i] = 255 - data[i];
            ++i;
            data[i] = 255 - data[i];
            ++i; // Skip alpha
        }
        this.ctx.putImageData(img, x, y);
    }

    imageScroll(x: number, sy: number, dy: number, w: number, h: number) {
        const dpr = window.devicePixelRatio || 1;
        x = Math.floor(x * dpr);
        sy = Math.floor(sy * dpr);
        dy = Math.floor(dy * dpr);
        w = Math.floor(w * dpr);
        h = Math.floor(h * dpr);
        this.ctx.drawImage(this.canvas, x, sy, w, h, x, dy, w, h);
    }

    private onClick() {
        this.input.focus();
    }

    private onAnimationFrame() {
        debug('Rendering', this.queue.length, 'events on animation frame');
        this.perfMark('raf');
        for (const [method, args] of this.queue) {
            this.perfMark('draw');
            this[method].apply(this, args);
            this.perfMeasure('draw', `draw:${method}`);
        }
        this.queue.length = 0; // Clear queue
        this.rafScheduled = false;
        this.perfMeasure('raf');
    }

    private perfMark(m: PerfMark) {
        if (this.perf) {
            performance.mark(m);
        }
    }

    private perfMeasure(m: PerfMark, n?: string) {
        if (this.perf) {
            performance.measure(n || m, m);
            performance.clearMarks(m);
        }
    }
}

export interface StartOptions {
    debug?: boolean;
    perf?: boolean;
    clipboard?: boolean;
    persistentDirs?: string[];
    dirs?: string[];
    files?: { [fpath: string]: string };
    fetchFiles?: { [fpath: string]: string };
    cmdArgs?: string[];
}
export interface OptionsRenderToDOM {
    canvas: HTMLCanvasElement;
    input: HTMLInputElement;
    workerScriptPath: string;
}
export interface OptionsUserRenderer {
    screen: ScreenDrawer;
    workerScriptPath: string;
}
export type VimWasmConstructOptions = OptionsRenderToDOM | OptionsUserRenderer;

export class VimWasm {
    public onVimInit?: () => void;
    public onVimExit?: (status: number) => void;
    public onFileExport?: (fullpath: string, contents: ArrayBuffer) => void;
    public onError?: (err: Error) => void;
    public readClipboard?: () => Promise<string>;
    public onWriteClipboard?: (text: string) => void;
    public onTitleUpdate?: (title: string) => void;
    private readonly worker: VimWorker;
    private readonly screen: ScreenDrawer;
    private perf: boolean;
    private debug: boolean;
    private perfMessages: { [name: string]: number[] };
    private running: boolean;
    private end: boolean;

    constructor(opts: VimWasmConstructOptions) {
        const script = opts.workerScriptPath;
        if (!script) {
            throw new Error("'workerScriptPath' option is required");
        }
        this.handleError = this.handleError.bind(this);
        this.worker = new VimWorker(script, this.onMessage.bind(this), this.handleError);
        if ('canvas' in opts && 'input' in opts) {
            this.screen = new ScreenCanvas(this.worker, opts.canvas, opts.input);
        } else if ('screen' in opts) {
            this.screen = opts.screen;
        } else {
            throw new Error('Invalid options for VimWasm construction: ' + JSON.stringify(opts));
        }
        this.perf = false;
        this.debug = false;
        this.perfMessages = {};
        this.running = false;
        this.end = false;
    }

    start(opts?: StartOptions) {
        if (this.running || this.end) {
            throw new Error('Cannot start Vim twice');
        }

        const o = opts || { clipboard: navigator.clipboard !== undefined };

        if (o.debug) {
            debug = console.log.bind(console, 'main:'); // eslint-disable-line no-console
            this.worker.debug = true;
        }

        this.perf = !!o.perf;
        this.debug = !!o.debug;
        this.screen.setPerf(this.perf);
        this.running = true;

        this.perfMark('init');

        const { width, height } = this.screen.getDomSize();
        const msg: StartMessageFromMain = {
            kind: 'start',
            buffer: this.worker.sharedBuffer,
            canvasDomWidth: width,
            canvasDomHeight: height,
            debug: this.debug,
            perf: this.perf,
            clipboard: !!o.clipboard,
            files: o.files || {},
            dirs: o.dirs || [],
            fetchFiles: o.fetchFiles || {},
            persistent: o.persistentDirs || [],
            cmdArgs: o.cmdArgs || [],
        };
        this.worker.sendStartMessage(msg);

        debug('Started with drawer', this.screen);
    }

    // Note: Sending file to Vim requires some message interactions.
    //
    // 1. Main sends FILE_REQUEST event with file size and file name to worker via shared memory buffer
    // 2. Worker waits the event with Atomics.wait() and gets the size and name
    // 3. Worker allocates a new SharedArrayBuffer with the file size
    // 4. Worker sends the buffer to main via 'file-buffer' message using postMessage()
    // 5. Main receives the message and copy file contents to the buffer
    // 6. Main sends FILE_WRITE_COMPLETE event to worker via shared memory buffer
    // 7. Worker waits the event with Atomics.wait()
    // 8. Worker reads file contents from the buffer alolocated at 3. and deletes the buffer
    // 9. Worker handles the file open
    //
    // This a bit complex interactions are necessary because postMessage() from main thread does
    // not work. Worker sleeps in Vim's main loop using Atomics.wait(). So JavaScript context in worker
    // never ends until exit() is called. It means that onmessage callback is never fired.
    async dropFile(name: string, contents: ArrayBuffer) {
        if (!this.running) {
            throw new Error('Cannot open file since Vim is not running');
        }
        debug('Handling to open file', name, contents);

        // Get shared buffer to write file contents from worker
        const [bufId, buffer] = await this.worker.requestSharedBuffer(contents.byteLength);

        // Write file contents
        new Uint8Array(buffer).set(new Uint8Array(contents));

        // Notify worker to start processing the file contents
        this.worker.notifyOpenFileBufComplete(name, bufId);

        debug('Wrote file', name, 'to', contents.byteLength, 'bytes buffer and notified it to worker');
    }

    async dropFiles(files: FileList) {
        const reader = new FileReader();
        for (const file of files) {
            const [name, contents] = await this.readFile(reader, file);
            await this.dropFile(name, contents);
        }
    }

    resize(pixelWidth: number, pixelHeight: number) {
        this.worker.notifyResizeEvent(pixelWidth, pixelHeight);
    }

    sendKeydown(key: string, keyCode: number, modifiers?: KeyModifiers) {
        const { ctrl = false, shift = false, alt = false, meta = false } = modifiers || {};
        if (key.length > 1) {
            if (
                key === 'Unidentified' ||
                (ctrl && key === 'Control') ||
                (shift && key === 'Shift') ||
                (alt && key === 'Alt') ||
                (meta && key === 'Meta')
            ) {
                debug('Ignore key input', key);
                return;
            }
        }

        this.worker.notifyKeyEvent(key, keyCode, ctrl, shift, alt, meta);
    }

    // Note: This command execution does not trigger screen redraw.
    // Please run :redraw like "1put | redraw" if updating screen is necessary.
    cmdline(cmdline: string): Promise<void> {
        return this.worker.requestCmdline(cmdline);
    }

    isRunning() {
        return this.running;
    }

    focus() {
        this.screen.focus();
    }

    showError(message: string) {
        return this.worker.notifyErrorOutput(message);
    }

    private async readFile(reader: FileReader, file: File) {
        return new Promise<[string, ArrayBuffer]>((resolve, reject) => {
            reader.onload = f => {
                debug('Read file', file.name, 'from D&D:', f);
                resolve([file.name, reader.result as ArrayBuffer]);
            };
            reader.onerror = () => {
                reader.abort();
                reject(new Error(`Error on loading file ${file}`));
            };
            reader.readAsArrayBuffer(file);
        });
    }

    private async evalJS(path: string, contents: ArrayBuffer) {
        debug('Evaluating JavaScript file', path, 'with size', contents.byteLength, 'bytes');
        const dec = new TextDecoder();
        const src = '"use strict";' + dec.decode(contents);
        try {
            // Function() is better option to evaluate JavaScript source with global scope rather than eval().
            //   https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/eval#Do_not_ever_use_eval!
            Function(src)();
        } catch (err) {
            debug('Failed to evaluate', path, 'with error:', err);
            await this.showError(`${err.message}\n\n${err.stack}`);
        }
    }

    private async evalFunc(body: string, args: any[], notifyOnly: boolean) {
        debug('Evaluating JavaScript function:', body, args);

        let f;
        try {
            f = new AsyncFunction(body);
        } catch (err) {
            return this.worker.notifyEvalFuncError('Could not construct function', err, notifyOnly);
        }

        let ret;
        try {
            ret = await f(...args);
        } catch (err) {
            return this.worker.notifyEvalFuncError('Exception was thrown while evaluating function', err, notifyOnly);
        }

        if (notifyOnly) {
            debug('Evaluated JavaScript result was discarded since the message was notify-only:', ret, body);
            return Promise.resolve();
        }

        let retJson;
        try {
            retJson = JSON.stringify(ret);
        } catch (err) {
            return this.worker.notifyEvalFuncError(
                'Could not serialize return value as JSON from function',
                err,
                false,
            );
        }

        return this.worker.notifyEvalFuncRet(retJson);
    }

    private onMessage(msg: MessageFromWorker) {
        if (this.perf && msg.timestamp !== undefined) {
            // performance.now() is not available because time origin is different between Window and Worker
            const duration = Date.now() - msg.timestamp;
            const name = msg.kind === 'draw' ? `draw:${msg.event[0]}` : msg.kind;
            const timestamps = this.perfMessages[name];
            if (timestamps === undefined) {
                this.perfMessages[name] = [duration];
            } else {
                this.perfMessages[name].push(duration);
            }
        }

        switch (msg.kind) {
            case 'draw':
                this.screen.draw(msg.event);
                debug('draw event', msg.event);
                break;
            case 'done':
                this.worker.onEventDone(msg.status);
                break;
            case 'evalfunc': {
                const args = msg.argsJson === undefined ? [] : JSON.parse(msg.argsJson);
                this.evalFunc(msg.body, args, msg.notifyOnly).catch(this.handleError);
                break;
            }
            case 'title':
                if (this.onTitleUpdate) {
                    debug('title was updated:', msg.title);
                    this.onTitleUpdate(msg.title);
                }
                break;
            case 'read-clipboard:request':
                if (this.readClipboard) {
                    this.readClipboard()
                        .then(text => this.worker.responseClipboardText(text))
                        .catch(err => {
                            debug('Cannot read clipboard:', err);
                            this.worker.notifyClipboardError();
                        });
                } else {
                    debug('Cannot read clipboard because VimWasm.readClipboard is not set');
                    this.worker.notifyClipboardError();
                }
                break;
            case 'write-clipboard':
                debug('Handle writing text', msg.text, 'to clipboard with', this.onWriteClipboard);
                if (this.onWriteClipboard) {
                    this.onWriteClipboard(msg.text);
                }
                break;
            case 'export':
                if (this.onFileExport !== undefined) {
                    debug('Exporting file', msg.path, 'with size in bytes', msg.contents.byteLength);
                    this.onFileExport(msg.path, msg.contents);
                }
                break;
            case 'eval':
                this.evalJS(msg.path, msg.contents).catch(this.handleError);
                break;
            case 'started':
                this.screen.onVimInit();
                if (this.onVimInit) {
                    this.onVimInit();
                }

                this.perfMeasure('init');

                debug('Vim started');
                break;
            case 'exit':
                this.screen.onVimExit();
                this.printPerfs();

                this.worker.terminate();

                if (this.onVimExit) {
                    this.onVimExit(msg.status);
                }

                debug('Vim exited with status', msg.status);

                this.perf = false;
                this.debug = false;
                this.screen.setPerf(false);
                this.running = false;
                this.end = true;
                break;
            case 'error':
                debug('Vim threw an error:', msg.message);
                this.handleError(new Error(msg.message));
                this.worker.terminate();
                break;
            default:
                throw new Error(`Unexpected message from worker: ${JSON.stringify(msg)}`);
        }
    }

    private handleError(err: Error) {
        if (this.onError) {
            this.onError(err);
        }
    }

    private printPerfs() {
        if (!this.perf) {
            return;
        }

        {
            const measurements = new Map<string, PerformanceEntry[]>();
            for (const e of performance.getEntries()) {
                const ms = measurements.get(e.name);
                if (ms === undefined) {
                    measurements.set(e.name, [e]);
                } else {
                    ms.push(e);
                }
            }

            const averages: { [name: string]: number } = {};
            const amounts: { [name: string]: number } = {};
            const timings: PerformanceEntry[] = [];
            for (const [name, ms] of measurements) {
                if (ms.length === 1 && ms[0].entryType !== 'measure') {
                    timings.push(ms[0]);
                    continue;
                }
                /* eslint-disable no-console */
                console.log(`%c${name}`, 'color: green; font-size: large');
                console.table(ms, ['duration', 'startTime']);
                /* eslint-enable no-console */
                const total = ms.reduce((a, m) => a + m.duration, 0);
                averages[name] = total / ms.length;
                amounts[name] = total;
            }

            /* eslint-disable no-console */
            console.log('%cTimings (ms)', 'color: green; font-size: large');
            console.table(timings, ['name', 'entryType', 'startTime', 'duration']);
            console.log('%cAmount: Perf Mark Durations (ms)', 'color: green; font-size: large');
            console.table(amounts);
            console.log('%cAverage: Perf Mark Durations (ms)', 'color: green; font-size: large');
            console.table(averages);
            /* eslint-enable no-console */

            performance.clearMarks();
            performance.clearMeasures();
        }

        {
            const averages: { [name: string]: number } = {};
            for (const name of Object.keys(this.perfMessages)) {
                const durations = this.perfMessages[name];
                const total = durations.reduce((a, d) => a + d, 0);
                averages[name] = total / durations.length;
            }

            // Note: Amounts of durations of inter-thread messages don't make sense since messaging is asynchronous. Multiple messages are sent and processed
            /* eslint-disable no-console */
            console.log('%cAverage: Inter-thread Messages Duration (ms)', 'color: green; font-size: large');
            console.table(averages);
            /* eslint-enable no-console */

            this.perfMessages = {};
        }
    }

    private perfMark(m: PerfMark) {
        if (this.perf) {
            performance.mark(m);
        }
    }

    private perfMeasure(m: PerfMark) {
        if (this.perf) {
            performance.measure(m, m);
            performance.clearMarks(m);
        }
    }
}
