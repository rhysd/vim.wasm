import { VimWasm, ScreenDrawer, StartOptions } from '../vimwasm.js';

export function wait(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

export class DummyDrawer implements ScreenDrawer {
    initialized: Promise<void>;
    exited: Promise<void>;
    errored: Promise<Error>;
    didInit: boolean = false;
    didExit: boolean = false;
    perf: boolean = false;
    received: DrawEventMessage[] = [];
    focused: boolean = false;
    private resolveInit: () => void;
    private resolveExit: () => void;
    private rejectError: (e: Error) => void;
    private waitTimeout: number;
    private waitTimer: number | null;
    private resolveDrawComplete: null | (() => void);

    constructor() {
        this.initialized = new Promise(resolve => {
            this.resolveInit = resolve;
        });
        this.exited = new Promise(resolve => {
            this.resolveExit = resolve;
        });
        this.errored = new Promise((_, reject) => {
            this.rejectError = reject;
        });
        this.waitTimeout = 0;
        this.waitTimer = null;
        this.resolveDrawComplete = null;
    }

    onVimInit() {
        this.resolveInit();
        this.didInit = true;
    }

    onVimExit() {
        this.resolveExit();
        this.didExit = true;
    }

    onError(err: Error) {
        this.rejectError(err);
    }

    setPerf(p: boolean) {
        this.perf = p;
    }

    getDomSize() {
        return {
            width: 1280,
            height: 640,
        };
    }

    draw(msg: DrawEventMessage) {
        this.received.push(msg);
        if (this.waitTimeout === 0) {
            return;
        }
        if (this.waitTimer !== null) {
            window.clearTimeout(this.waitTimer);
        }
        this.waitTimer = setTimeout(() => {
            this.waitTimer = null;
            this.waitTimeout = 0;
            this.resolveDrawComplete!();
            this.resolveDrawComplete = null;
        }, this.waitTimeout);
    }

    waitDrawComplete(timeout: number) {
        this.waitTimeout = timeout;
        return new Promise(resolve => {
            this.resolveDrawComplete = resolve;
        });
    }

    focus() {
        this.focused = true;
    }

    reset() {
        this.received.length = 0;
        this.focused = false;
    }
}

export async function startVim(opts: StartOptions): Promise<[DummyDrawer, VimWasm]> {
    const drawer = new DummyDrawer();
    const vim = new VimWasm({ screen: drawer, workerScriptPath: '/base/vim.js' });
    vim.onError = e => {
        drawer.onError(e);
    };
    vim.start(opts);
    await drawer.initialized;
    await drawer.waitDrawComplete(100); // Wait for draw events for first screen
    return [drawer, vim];
}

export async function stopVim(drawer: DummyDrawer, editor: VimWasm) {
    if (editor.isRunning()) {
        editor.cmdline('qall!'); // Do not await because response is never returned
        await Promise.race([drawer.exited, drawer.errored]);
    }
}
