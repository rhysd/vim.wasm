import { VimWasm, ScreenDrawer } from '../vimwasm.js';
import { SinonStub } from 'sinon';

class DummyDrawer implements ScreenDrawer {
    initialized: Promise<void>;
    exited: Promise<void>;
    didInit: boolean = false;
    didExit: boolean = false;
    draw: SinonStub<any[], any>;
    perf: boolean = false;
    private resolveInit: () => void;
    private resolveExit: () => void;

    constructor() {
        this.initialized = new Promise(resolve => {
            this.resolveInit = resolve;
        });
        this.exited = new Promise(resolve => {
            this.resolveExit = resolve;
        });
        this.draw = sinon.stub();
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
            width: 128,
            height: 64,
        };
    }

    reset() {
        this.draw.reset();
    }
}

describe('Draw events', function() {
    let drawer: DummyDrawer;
    let v: VimWasm;

    beforeEach(async function() {
        drawer = new DummyDrawer();
        v = new VimWasm({ screen: drawer, workerScriptPath: '/base/vim.js' });
        // v.onError = e => {
        //     throw e;
        // };
        v.start();
        await drawer.initialized;
    });

    afterEach(async function() {
        // await v.cmdline('qall!');
    });

    it('should have been started', function() {
        assert.isTrue(drawer.didInit);
        assert.isFalse(drawer.didExit);
    });
});
