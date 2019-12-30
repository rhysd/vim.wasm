import { VimWasm, ScreenDrawer, StartOptions } from '../vimwasm.js';

export function wait(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

export const ON_TRAVIS_CI = __karma__.config.args.includes('--travis-ci');
if (ON_TRAVIS_CI) {
    console.log('Detected Travis CI. Interval of waiting for draw events is made longer'); // eslint-disable-line no-console
}

export class Callback {
    private readonly promise: Promise<any>;
    private resolve: (x: any) => void;

    constructor() {
        this.resolve = () => {
            throw new Error('FATAL: not initialized yet');
        };
        this.promise = new Promise(resolve => {
            this.resolve = resolve;
        });
    }

    waitDone() {
        return this.promise;
    }

    done(ret?: any) {
        this.resolve(ret);
    }
}

export class DummyDrawer implements ScreenDrawer {
    initialized: Promise<void>;
    exited: Promise<void>;
    errored: Promise<Error>;
    didInit = false;
    didExit = false;
    perf = false;
    received: DrawEventMessage[] = [];
    focused = false;
    private resolveInit: () => void;
    private resolveExit: () => void;
    private rejectError: (e: Error) => void;
    private waitTimeout: number;
    private waitTimer: number | null;
    private resolveDrawComplete: null | (() => void);

    constructor() {
        this.resolveInit = () => {
            throw new Error('FATAL: not initialized yet');
        };
        this.resolveExit = () => {
            throw new Error('FATAL: not initialized yet');
        };
        this.rejectError = () => {
            throw new Error('FATAL: not initialized yet');
        };
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

    waitDrawComplete(timeout = 200) {
        // XXX: This mechanism is not working correctly on Travis CI
        if (ON_TRAVIS_CI) {
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

export async function startVim(opts: StartOptions, onCreate?: (v: VimWasm) => void): Promise<[DummyDrawer, VimWasm]> {
    const drawer = new DummyDrawer();
    const vim = new VimWasm({ screen: drawer, workerScriptPath: '/base/vim.js' });
    vim.onError = e => {
        drawer.onError(e);
    };
    if (onCreate !== undefined) {
        onCreate(vim);
    }
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
