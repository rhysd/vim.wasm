import { ScreenDrawer } from '../vimwasm.js';

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
