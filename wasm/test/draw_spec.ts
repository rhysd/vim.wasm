import { VimWasm, ScreenDrawer } from '../vimwasm.js';

class DummyDrawer implements ScreenDrawer {
    initialized: Promise<void>;
    exited: Promise<void>;
    didInit: boolean = false;
    didExit: boolean = false;
    perf: boolean = false;
    received: DrawEventMessage[];
    private resolveInit: () => void;
    private resolveExit: () => void;
    private resolveDraw: null | ((msg: DrawEventMessage) => void);

    constructor() {
        this.initialized = new Promise(resolve => {
            this.resolveInit = resolve;
        });
        this.exited = new Promise(resolve => {
            this.resolveExit = resolve;
        });
        this.received = [];
        this.resolveDraw = null;
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
        if (this.resolveDraw !== null) {
            this.resolveDraw(msg);
            this.resolveDraw = null;
        }
        this.received.push(msg);
    }

    async waitNextDraw() {
        return new Promise<DrawEventMessage>(resolve => {
            this.resolveDraw = resolve;
        });
    }
}

function wait(ms: number) {
    return new Promise(resolve => setTimeout(resolve, ms));
}

describe('vim.wasm', function() {
    let drawer: DummyDrawer;
    let editor: VimWasm;

    before(async function() {
        drawer = new DummyDrawer();
        editor = new VimWasm({ screen: drawer, workerScriptPath: '/base/vim.js' });
        editor.onError = e => {
            console.error(e);
            throw e;
        };
        editor.start({ debug: true });
        await drawer.initialized;
        await wait(1000); // Wait for draw events for first screen
    });

    after(async function() {
        // await editor.cmdline('qall!');
    });

    it('has been started', function() {
        assert.isTrue(drawer.didInit);
        assert.isFalse(drawer.didExit);
        assert.isAbove(drawer.received.length, 0);
    });

    describe('Draw events', function() {
        it('receives setFont draw events', function() {
            const msgs = drawer.received.filter(m => m[0] === 'setFont');
            assert.isAbove(msgs.length, 0);
            for (const msg of msgs) {
                const [name, size] = msg[1];
                assert.isString(name);
                assert.isNumber(size);
                assert.isAbove(size!, 0);
            }
        });

        it('receives setColorFG draw events', function() {
            const msgs = drawer.received.filter(m => m[0] === 'setColorFG');
            assert.isAbove(msgs.length, 0);
            for (const msg of msgs) {
                const color = msg[1][0] as string;
                assert.isString(color);
                assert.match(color, /^#[0-9a-fA-F]{6}$/);
            }
        });

        it('receives setColorBG draw events', function() {
            const msgs = drawer.received.filter(m => m[0] === 'setColorBG');
            assert.isAbove(msgs.length, 0);
            for (const msg of msgs) {
                const color = msg[1][0] as string;
                assert.isString(color);
                assert.match(color, /^#[0-9a-fA-F]{6}$/);
            }
        });

        it('receives setColorSP draw events', function() {
            const msgs = drawer.received.filter(m => m[0] === 'setColorSP');
            assert.isAbove(msgs.length, 0);
            for (const msg of msgs) {
                const color = msg[1][0] as string;
                assert.isString(color);
                assert.match(color, /^#[0-9a-fA-F]{6}$/);
            }
        });

        it('receives drawRect draw events', function() {
            const msgs = drawer.received.filter(m => m[0] === 'drawRect');
            assert.isAbove(msgs.length, 0);
            for (const msg of msgs) {
                const [x, y, w, h, color, filled] = msg[1] as [number, number, number, number, string, boolean];
                assert.isNumber(x);
                assert.isAtLeast(x, 0);
                assert.isNumber(y);
                assert.isAtLeast(y, 0);
                assert.isNumber(h);
                assert.isAtLeast(h, 0);
                assert.isNumber(w);
                assert.isAtLeast(w, 0);
                assert.isString(color);
                assert.match(color, /^#[0-9a-fA-F]{6}$/);
                assert.isBoolean(filled);
            }
        });

        it('receives drawText draw events', function() {
            const expectedTexts = new Set([
                'Vi IMproved',
                'by Bram Moolenaar',
                'Vim is open source and freely distributable',
                'type  :q',
                'for on-line help',
                '<Enter>',
            ]);

            const msgs = drawer.received.filter(m => m[0] === 'drawText');
            assert.isAbove(msgs.length, 0);
            for (const msg of msgs) {
                const [text, ch, lh, cw, x, y, bold, underline, undercurl, strike] = msg[1] as [
                    string,
                    number,
                    number,
                    number,
                    number,
                    number,
                    boolean,
                    boolean,
                    boolean,
                    boolean,
                ];
                assert.isString(text);
                assert.isNumber(ch);
                assert.isAbove(ch, 0);
                assert.isNumber(lh);
                assert.isAbove(lh, ch); // line height should be greater than char height
                assert.isNumber(cw);
                assert.isAbove(cw, 0);
                assert.isNumber(x);
                assert.isAtLeast(x, 0);
                assert.isNumber(y);
                assert.isAtLeast(y, 0);
                assert.isBoolean(bold);
                assert.isBoolean(underline);
                assert.isBoolean(undercurl);
                assert.isBoolean(strike);

                for (const t of expectedTexts) {
                    if (text.includes(t)) {
                        expectedTexts.delete(t);
                        break;
                    }
                }
            }

            assert.strictEqual(expectedTexts.size, 0, JSON.stringify(Array.from(expectedTexts)));
        });
    });

    // TODO: Test :qall!
});
