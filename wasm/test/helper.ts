import { VimWasm, ScreenDrawer, StartOptions } from '../vimwasm.js';

export function wait(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

const on_travis_ci = __karma__.config.args.includes('--travis-ci');
if (on_travis_ci) {
    console.log('Detected Travis CI. Interval of waiting for draw events is made longer'); // eslint-disable-line no-console
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

    waitDrawComplete(timeout: number = 200) {
        // XXX: This mechanism is not working correctly on Travis CI
        if (on_travis_ci) {
            return wait(1000);
        }

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

    getReceivedText(): string {
        // Note: Newlines are not included
        return this.received
            .filter(m => m[0] === 'drawText')
            .map(m => m[1][0] as string)
            .join(' ');
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
    await drawer.waitDrawComplete(); // Wait for draw events for first screen
    return [drawer, vim];
}

export async function stopVim(drawer: DummyDrawer, editor: VimWasm) {
    if (editor.isRunning()) {
        // Note: Do not await because response is never returned
        editor.cmdline('qall!'); // eslint-disable-line @typescript-eslint/no-floating-promises
        await drawer.exited;
    }
}
