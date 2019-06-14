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

const debugging = new URLSearchParams(window.location.search).has('debug');
const debug = debugging
    ? console.log // eslint-disable-line no-console
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

const STATUS_EVENT_KEY = 1;
const STATUS_EVENT_RESIZE = 2;

class VimWorker {
    public readonly sharedBuffer: Int32Array;
    private readonly worker: Worker;
    private readonly onMessage: (msg: MessageFromWorker) => void;

    constructor(scriptPath: string, onMessage: (msg: MessageFromWorker) => void) {
        this.worker = new Worker(scriptPath);
        this.worker.onmessage = this.recvMessage.bind(this);
        this.sharedBuffer = new Int32Array(new SharedArrayBuffer(Int32Array.BYTES_PER_ELEMENT * 128));
        this.onMessage = onMessage;
    }

    sendMessage(msg: MessageFromMain) {
        debug('send to worker:', msg);
        switch (msg.kind) {
            case 'start':
                this.worker.postMessage(msg);
                break;
            case 'key':
                this.writeKeyEvent(msg);
                break;
            case 'resize':
                this.writeResizeEvent(msg);
                break;
            default:
                throw new Error(`Unknown message from main to worker: ${msg}`);
        }
    }

    private writeKeyEvent(msg: KeyMessageFromMain) {
        let idx = 1;
        this.sharedBuffer[idx++] = +msg.keyCode;
        this.sharedBuffer[idx++] = +msg.ctrl;
        this.sharedBuffer[idx++] = +msg.shift;
        this.sharedBuffer[idx++] = +msg.alt;
        this.sharedBuffer[idx++] = +msg.meta;

        idx = this.encodeStringToBuffer(msg.code, idx);
        idx = this.encodeStringToBuffer(msg.key, idx);

        debug('Encoded key event with', idx * 4, 'bytes');

        this.awakeWorkerThread(STATUS_EVENT_KEY);
    }

    private writeResizeEvent(msg: ResizeMessageFromMain) {
        let idx = 1;
        this.sharedBuffer[idx++] = msg.width;
        this.sharedBuffer[idx++] = msg.height;

        debug('Encoded resize event with', idx * 4, 'bytes');

        this.awakeWorkerThread(STATUS_EVENT_RESIZE);
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

    private awakeWorkerThread(event: 1 | 2) {
        // TODO: Define how to use the shared memory buffer
        Atomics.store(this.sharedBuffer, 0, event);
        Atomics.notify(this.sharedBuffer, 0, 1);
    }

    private recvMessage(e: MessageEvent) {
        this.onMessage(e.data);
    }
}

class ResizeHandler {
    elemHeight: number;
    elemWidth: number;
    private readonly canvas: HTMLCanvasElement;
    private bounceTimerToken: number | null;
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
        this.worker.sendMessage({
            kind: 'resize',
            height: rect.height,
            width: rect.width,
        });
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

        const key = event.key;
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

        this.worker.sendMessage({
            kind: 'key',
            code: event.code,
            keyCode: event.keyCode,
            key,
            ctrl,
            shift,
            alt,
            meta,
        });
        // TODO: wake worker thread by writing shared buffer
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

        this.canvas.addEventListener('click', this.onClick.bind(this), {
            capture: true,
            passive: true,
        });
        this.input = new InputHandler(this.worker, input);
        this.onAnimationFrame = this.onAnimationFrame.bind(this);
        this.queue = [];
        this.rafScheduled = false;
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
            // TODO: Calcurate the position of the underline with descent.
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
            // TODO: Calcurate the position of the underline with descent.
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
        debug('Rendering events on animation frame:', this.queue.length);
        for (const [method, args] of this.queue) {
            this[method].apply(this, args);
        }
        this.queue.length = 0; // Clear queue
        this.rafScheduled = false;
    }
}

interface StartOptions {
    debug?: boolean;
}

class VimWasm {
    public onVimInit?: () => void;
    public onVimExit?: () => void;
    private readonly worker: VimWorker;
    private readonly screen: ScreenCanvas;
    private readonly resizer: ResizeHandler;

    constructor(workerScript: string, canvas: HTMLCanvasElement, input: HTMLInputElement) {
        this.worker = new VimWorker(workerScript, this.onMessage.bind(this));
        this.screen = new ScreenCanvas(this.worker, canvas, input);
        this.resizer = new ResizeHandler(canvas, this.worker);
    }

    start(opts?: StartOptions) {
        const o = opts || {};
        this.worker.sendMessage({
            kind: 'start',
            buffer: this.worker.sharedBuffer,
            canvasDomHeight: this.resizer.elemHeight,
            canvasDomWidth: this.resizer.elemWidth,
            debug: !!o.debug,
        });
    }

    private onMessage(msg: MessageFromWorker) {
        debug('received from worker:', msg);
        switch (msg.kind) {
            case 'draw':
                this.screen.enqueue(msg.event);
                break;
            case 'started':
                this.screen.onVimInit();
                this.resizer.onVimInit();
                if (this.onVimInit) {
                    this.onVimInit();
                }
                break;
            case 'exit':
                this.screen.onVimExit();
                this.resizer.onVimExit();
                if (this.onVimExit) {
                    this.onVimExit();
                }
                break;
            case 'fatal':
                fatal(msg.message);
                break;
            default:
                throw new Error(`FATAL: Unexpected message from worker: ${msg}`);
        }
    }
}

const vim = new VimWasm(
    'vim.js',
    document.getElementById('vim-screen') as HTMLCanvasElement,
    document.getElementById('vim-input') as HTMLInputElement,
);
vim.start({ debug: debugging });
