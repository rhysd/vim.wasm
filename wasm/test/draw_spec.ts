/* eslint-disable @typescript-eslint/no-non-null-assertion */
/* eslint-disable no-console */
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

    context('On start', function() {
        it('has been started', function() {
            assert.isTrue(drawer.didInit);
            assert.isFalse(drawer.didExit);
            assert.isTrue(editor.isRunning());
            assert.isAbove(drawer.received.length, 0);
        });
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

    describe('resize()', function() {
        beforeEach(function() {
            drawer.reset();
        });

        it('causes additional draw events', async function() {
            editor.resize(720, 1080);
            await wait(1000); // Wait for redraw screen

            assert.isAbove(drawer.received.length, 0);
            const found = drawer.received.find(m => m[0] === 'drawText');
            assert.ok(found);
            const text = found![1][0] as string;
            assert.match(text, /^~ +$/);
        });
    });

    describe('sendKeydown()', function() {
        beforeEach(function() {
            drawer.reset();
        });

        it('inputs single key to Vim', async function() {
            editor.sendKeydown('i', 73);
            await wait(500); // Wait for cmdline redraw

            assert.isAbove(drawer.received.length, 0);
            const found = drawer.received.find(m => m[0] === 'drawText' && m[1].includes('-- INSERT --'));
            assert.ok(found);
        });

        it('inputs special key to Vim', async function() {
            editor.sendKeydown('Escape', 27);
            await wait(500); // Wait for cmdline redraw

            assert.isAbove(drawer.received.length, 0);
            const drawText = drawer.received.find(m => m[0] === 'drawText');
            // Since escape just leave insert mode, no text is rendered. So drawText must not be sent.
            assert.isUndefined(drawText);

            const drawRect = drawer.received.find(m => m[0] === 'drawRect');
            assert.ok(drawRect);
        });

        it('inputs key with modifier to Vim', async function() {
            editor.sendKeydown('g', 71, { ctrl: true });
            await wait(500); // Wait for cmdline redraw

            const expectedTexts = new Set(['"[No', 'Name]"', '--No', 'lines', 'in', 'buffer--']);

            const msgs = drawer.received.filter(m => m[0] === 'drawText');
            assert.isAbove(msgs.length, 0);

            for (const msg of msgs) {
                const text = msg[1][0] as string;

                for (const t of expectedTexts) {
                    if (text.includes(t)) {
                        expectedTexts.delete(t);
                    }
                }
            }

            assert.strictEqual(expectedTexts.size, 0, JSON.stringify(Array.from(expectedTexts)));
        });

        it('ignores modifier key only input', async function() {
            editor.sendKeydown('Control', 17, { ctrl: true });
            editor.sendKeydown('Shift', 16, { shift: true });
            editor.sendKeydown('Meta', 91, { meta: true });
            editor.sendKeydown('Alt', 18, { alt: true });
            editor.sendKeydown('Unidentified', 0);

            await wait(500); // Wait for redraw
            assert.deepEqual(drawer.received, []);
        });
    });

    // TODO: Test dropFiles

    // TODO: Test clipboard read

    // TODO: Test clipboard write

    // TODO: Test export

    describe('cmdline()', function() {
        beforeEach(function() {
            drawer.reset();
        });

        it('runs command line on Vim successfully', async function() {
            await editor.cmdline('redraw!');
            await wait(1000); // Wait for rendering due to :file

            assert.isAbove(drawer.received.length, 0);
            const msgs = drawer.received.filter(m => m[0] === 'drawText');
            assert.isAbove(msgs.length, 0);

            const reEmpty = /^~ +$/;
            const emptyLine = drawer.received.filter(m => reEmpty.test(m[0][1]));
            assert.ok(emptyLine);
        });

        // XXX: No good test case to make cmdline() return false as result. As far as reading do_cmdline(), when 'eval'
        // is added to features, it would be possible by using incomplete :function command.

        it('raises an error when input cmdline is empty', async function() {
            try {
                await editor.cmdline('');
                assert.ok(false, 'Exception was not thrown');
            } catch (err) {
                assert.include(err.message, 'Specified command line is empty');
            }
        });
    });

    // XXX: This test case must be at the end since it stops Vim
    context('On exit', function() {
        it('finally stops Vim by :quit', async function() {
            // XXX: Returned promise of bellow invocation will never be settled because Vim exits immediately
            // at :quit command and never sends response to main thread.
            editor.cmdline('qall!');

            await drawer.exited;
            assert.isFalse(editor.isRunning());
        });
    });
});
