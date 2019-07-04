import { VimWasm, ScreenDrawer, StartOptions } from '../vimwasm.js';

export function wait(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

export class DummyDrawer implements ScreenDrawer {
    initialized: Promise<void>;
    exited: Promise<void>;
    didInit: boolean = false;
    didExit: boolean = false;
    perf: boolean = false;
    received: DrawEventMessage[] = [];
    focused: boolean = false;
    private resolveInit: () => void;
    private resolveExit: () => void;

    constructor() {
        this.initialized = new Promise(resolve => {
            this.resolveInit = resolve;
        });
        this.exited = new Promise(resolve => {
            this.resolveExit = resolve;
        });
    }

    onVimInit() {
        this.resolveInit();
        this.didInit = true;
    }

    onVimExit() {
        this.resolveExit();
        this.didExit = true;
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
    }

    focus() {
        this.focused = true;
    }

    reset() {
        this.received.length = 0;
        this.focused = false;
    }
}

export async function startVim(drawer: DummyDrawer, opts: StartOptions) {
    const vim = new VimWasm({ screen: drawer, workerScriptPath: '/base/vim.js' });
    vim.onError = e => {
        console.error(e);
        throw e;
    };
    vim.start(opts);
    await drawer.initialized;
    await wait(1000); // Wait for draw events for first screen
    return vim;
}

export async function stopVim(drawer: DummyDrawer, editor: VimWasm) {
    if (editor.isRunning()) {
        editor.cmdline('qall!'); // Do not await because response is never returned
        await drawer.exited;
    }
}
