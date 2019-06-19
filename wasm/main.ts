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
 * main.ts: TypeScript main thread runtime for Wasm port of Vim by @rhysd.
 */

type PerfMark = 'init' | 'raf' | 'draw';

const queryParams = new URLSearchParams(window.location.search);
const debugging = queryParams.has('debug');
const perf = queryParams.has('perf');
const debug = debugging
    ? console.log.bind(console, 'main:') // eslint-disable-line no-console
    : () => {
          /* do nothing */
      };

function fatal(msg: string): never {
    alert(msg);
    throw new Error(msg);
}

function checkCompat(prop: string) {
    if (prop in window) {
        return; // OK
    }
    fatal(
        `window.${prop} is not supported by this browser. If you're on Firefox or Safari, please enable browser's feature flag`,
    );
}

checkCompat('Atomics');
checkCompat('SharedArrayBuffer');

const STATUS_NOTIFY_KEY = 1 as const;
const STATUS_NOTIFY_RESIZE = 2 as const;
const STATUS_REQUEST_OPEN_FILE_BUF = 3 as const;
const STATUS_NOTIFY_OPEN_FILE_BUF_COMPLETE = 4 as const;

class VimWorker {
    public readonly sharedBuffer: Int32Array;
    private readonly worker: Worker;
    private readonly onMessage: (msg: MessageFromWorker) => void;
    private onOneshotMessage: Map<MessageKindFromWorker, (msg: MessageFromWorker) => void>;

    constructor(scriptPath: string, onMessage: (msg: MessageFromWorker) => void) {
        this.worker = new Worker(scriptPath);
        this.worker.onmessage = this.recvMessage.bind(this);
        this.sharedBuffer = new Int32Array(new SharedArrayBuffer(Int32Array.BYTES_PER_ELEMENT * 128));
        this.onMessage = onMessage;
        this.onOneshotMessage = new Map();
    }

    sendStartMessage(msg: StartMessageFromMain) {
        debug('Send start message:', msg);
        this.worker.postMessage(msg);
    }

    writeOpenFileRequestEvent(name: string, size: number) {
        let idx = 1;
        this.sharedBuffer[idx++] = size;
        idx = this.encodeStringToBuffer(name, idx);

        debug('Encoded open file size event with', idx * 4, 'bytes');
        this.awakeWorkerThread(STATUS_REQUEST_OPEN_FILE_BUF);
    }

    notifyOpenFileBufComplete() {
        this.awakeWorkerThread(STATUS_NOTIFY_OPEN_FILE_BUF_COMPLETE);
    }

    notifyKeyEvent(key: string, keyCode: number, ctrl: boolean, shift: boolean, alt: boolean, meta: boolean) {
        let idx = 1;
        this.sharedBuffer[idx++] = keyCode;
        this.sharedBuffer[idx++] = +ctrl;
        this.sharedBuffer[idx++] = +shift;
        this.sharedBuffer[idx++] = +alt;
        this.sharedBuffer[idx++] = +meta;

        idx = this.encodeStringToBuffer(key, idx);

        debug('Encoded key event with', idx * 4, 'bytes');

        this.awakeWorkerThread(STATUS_NOTIFY_KEY);

        debug('Sent key event:', key, keyCode, ctrl, shift, alt, meta);
    }

    notifyResizeEvent(width: number, height: number) {
        let idx = 1;
        this.sharedBuffer[idx++] = width;
        this.sharedBuffer[idx++] = height;

        debug('Encoded resize event with', idx * 4, 'bytes');

        this.awakeWorkerThread(STATUS_NOTIFY_RESIZE);

        debug('Sent resize event:', width, height);
    }

    async requestOpenFileBuf(name: string, contents: ArrayBuffer) {
        const size = contents.byteLength;

        let idx = 1;
        this.sharedBuffer[idx++] = size;
        idx = this.encodeStringToBuffer(name, idx);

        debug('Encoded open file size event with', idx * 4, 'bytes');
        this.awakeWorkerThread(STATUS_REQUEST_OPEN_FILE_BUF);

        const msg = (await this.waitForOneshotMessage('open-file-buf:response')) as FileBufferMessageFromWorker;
        if (name !== msg.name) {
            // Fatal
            throw new Error(`File name mismatch from worker: '${name}' v.s. '${msg.name}'`);
        }
        if (size !== msg.buffer.byteLength) {
            // Fatal
            throw new Error(
                `Size of shared buffer from worker ${msg.buffer.byteLength} bytes mismatches to file contents size ${size} bytes`,
            );
        }

        return msg.buffer;
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

    private awakeWorkerThread(event: EventStatusFromMain) {
        // TODO: Check byte 1 is zero. Non-zero means data remains not handled by worker yet.
        Atomics.store(this.sharedBuffer, 0, event);
        Atomics.notify(this.sharedBuffer, 0, 1);
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
}

class ResizeHandler {
    elemHeight: number;
    elemWidth: number;
    private bounceTimerToken: number | null;
    private readonly canvas: HTMLCanvasElement;
    private readonly worker: VimWorker;

    constructor(canvas: HTMLCanvasElement, worker: VimWorker) {
        this.canvas = canvas;
        this.worker = worker;
        const rect = this.canvas.getBoundingClientRect();
        this.elemHeight = rect.height;
        this.elemWidth = rect.width;
        const dpr = window.devicePixelRatio || 1;
        this.canvas.width = rect.width * dpr;
        this.canvas.height = rect.height * dpr;
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
        }, 1000);
    }
}

// TODO: IME support
// TODO: Handle pre-edit IME state
// TODO: Follow cursor position
class InputHandler {
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

        if (key === '\u00A5' || event.code === 'IntlYen') {
            // Note: Yen needs to be fixed to backslash
            // Note: Also check event.code since Ctrl + yen is recognized as Ctrl + | due to Chrome bug.
            // https://bugs.chromium.org/p/chromium/issues/detail?id=871650
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

class ScreenCanvas implements DrawEventHandler {
    public perf: boolean;
    private readonly worker: VimWorker;
    private readonly canvas: HTMLCanvasElement;
    private readonly ctx: CanvasRenderingContext2D;
    private readonly input: InputHandler;
    private readonly queue: DrawEventMessage[];
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
        this.onAnimationFrame = this.onAnimationFrame.bind(this);
        this.queue = [];
        this.rafScheduled = false;
        this.perf = false;
    }

    onVimInit() {
        this.input.onVimInit();
    }

    onVimExit() {
        this.input.onVimExit();
    }

    enqueue(msg: DrawEventMessage) {
        if (!this.rafScheduled) {
            window.requestAnimationFrame(this.onAnimationFrame);
            this.rafScheduled = true;
        }
        this.queue.push(msg);
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
            this.ctx.fillText(text[i], Math.floor(x + cw * i), yi);
        }

        if (underline) {
            this.ctx.strokeStyle = this.fgColor;
            this.ctx.lineWidth = 1 * dpr;
            this.ctx.setLineDash([]);
            this.ctx.beginPath();
            // Note: 3 is set with considering the width of line.
            const underlineY = Math.floor(y + lh - descent - 3 * dpr);
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
            const undercurlY = Math.floor(y + lh - descent - 3 * dpr);
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

interface StartOptions {
    debug?: boolean;
    perf?: boolean;
}

class VimWasm {
    public onVimInit?: () => void;
    public onVimExit?: (status: number) => void;
    private readonly worker: VimWorker;
    private readonly screen: ScreenCanvas;
    private readonly resizer: ResizeHandler;
    private perf: boolean;
    private running: boolean;

    constructor(workerScript: string, canvas: HTMLCanvasElement, input: HTMLInputElement) {
        this.worker = new VimWorker(workerScript, this.onMessage.bind(this));
        this.screen = new ScreenCanvas(this.worker, canvas, input);
        this.resizer = new ResizeHandler(canvas, this.worker);
        this.perf = false;
        this.running = false;
    }

    start(opts?: StartOptions) {
        if (this.running) {
            throw new Error('Cannot start Vim since it is already running');
        }

        const o = opts || {};

        this.perf = !!o.perf;
        this.screen.perf = this.perf;
        this.running = true;

        this.perfMark('init');

        this.worker.sendStartMessage({
            kind: 'start',
            buffer: this.worker.sharedBuffer,
            canvasDomHeight: this.resizer.elemHeight,
            canvasDomWidth: this.resizer.elemWidth,
            debug: !!o.debug,
        });
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
        const buffer = await this.worker.requestOpenFileBuf(name, contents);

        // Write file contents
        new Uint8Array(buffer).set(new Uint8Array(contents));

        // Notify worker to start processing the file contents
        this.worker.notifyOpenFileBufComplete();

        debug('Wrote file', name, 'to', contents.byteLength, 'bytes buffer and notified it to worker');
    }

    async dropFiles(files: FileList) {
        const reader = new FileReader();
        for (const file of files) {
            const [name, contents] = await this.readFile(reader, file);
            this.dropFile(name, contents);
        }
    }

    private async readFile(reader: FileReader, file: File) {
        // TODO: Handle error
        return new Promise<[string, ArrayBuffer]>(resolve => {
            reader.onload = f => {
                debug('Read file', file.name, 'from D&D:', f);
                resolve([file.name, reader.result as ArrayBuffer]);
            };
            reader.readAsArrayBuffer(file);
        });
    }

    private onMessage(msg: MessageFromWorker) {
        switch (msg.kind) {
            case 'draw':
                this.screen.enqueue(msg.event);
                debug('draw event', msg.event);
                break;
            case 'started':
                this.screen.onVimInit();
                this.resizer.onVimInit();
                if (this.onVimInit) {
                    this.onVimInit();
                }

                this.perfMeasure('init');

                debug('Vim started');
                break;
            case 'exit':
                this.screen.onVimExit();
                this.resizer.onVimExit();
                if (this.onVimExit) {
                    this.onVimExit(msg.status);
                }

                this.printPerfs();

                this.perf = false;
                this.screen.perf = false;
                this.running = false;

                debug('Vim exited with status', msg.status);
                break;
            default:
                throw new Error(`FATAL: Unexpected message from worker: ${msg}`);
        }
    }

    private printPerfs() {
        if (!this.perf) {
            return;
        }

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
        for (const [name, ms] of measurements) {
            /* eslint-disable no-console */
            console.log(`%c${name}`, 'color: green; font-size: large');
            console.table(ms, ['duration', 'startTime']);
            /* eslint-enable no-console */
            const total = ms.reduce((a, m) => a + m.duration, 0);
            averages[name] = total / ms.length;
            amounts[name] = total;
        }

        /* eslint-disable no-console */
        console.log('%cAmounts', 'color: green; font-size: large');
        console.table(amounts);
        console.log('%cAverages', 'color: green; font-size: large');
        console.table(averages);
        /* eslint-enable no-console */

        performance.clearMarks();
        performance.clearMeasures();
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

// Main

const screenCanvasElement = document.getElementById('vim-screen') as HTMLCanvasElement;
const vim = new VimWasm('vim.js', screenCanvasElement, document.getElementById('vim-input') as HTMLInputElement);

// Handle drag and drop
screenCanvasElement.addEventListener(
    'dragover',
    e => {
        e.stopPropagation();
        e.preventDefault();
        if (e.dataTransfer) {
            e.dataTransfer.dropEffect = 'copy';
        }
    },
    false,
);
screenCanvasElement.addEventListener(
    'drop',
    e => {
        e.stopPropagation();
        e.preventDefault();

        if (e.dataTransfer === null) {
            return;
        }

        vim.dropFiles(e.dataTransfer.files).catch(err => {
            alert(err.message);
            throw err;
        });
    },
    false,
);

// Do not show dialog not to prevent performance tracing
if (!perf) {
    vim.onVimExit = status => {
        alert(`Vim exited with status ${status}`);
    };
}

vim.start({ debug: debugging, perf });
