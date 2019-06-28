import { ScreenDrawer } from '../vimwasm.js';

export class DummyDrawer implements ScreenDrawer {
    initialized: Promise<void>;
    exited: Promise<void>;
    didInit: boolean = false;
    didExit: boolean = false;
    perf: boolean = false;
    received: DrawEventMessage[];
    private resolveInit: () => void;
    private resolveExit: () => void;

    constructor() {
        this.initialized = new Promise(resolve => {
            this.resolveInit = resolve;
        });
        this.exited = new Promise(resolve => {
            this.resolveExit = resolve;
        });
        this.received = [];
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

    reset() {
        this.received.length = 0;
    }
}
