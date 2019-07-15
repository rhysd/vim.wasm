import { VimWasm } from '../vimwasm.js';
import { DummyDrawer, startVim, stopVim, Callback, wait } from './helper.js';

declare global {
    interface Window {
        cb: Callback;
    }
}

describe('!:', function() {
    let drawer: DummyDrawer;
    let editor: VimWasm;

    before(async function() {
        [drawer, editor] = await startVim({
            debug: true,
            files: {
                '/test.js': 'window.cb.done("hello!");\n',
                '/invalid.js': 'window.setTimeout(\n',
            },
        });
    });

    after(async function() {
        if (editor !== null) {
            assert.ok(drawer);
            await stopVim(drawer!, editor);
        }
    });

    beforeEach(function() {
        drawer.reset();
    });

    afterEach(function() {
        if (window.cb !== undefined) {
            delete window.cb;
        }
    });

    async function inputEnter() {
        editor.sendKeydown('Enter', 13);
        // Wait for draw events after Enter key press
        await drawer.waitDrawComplete();
    }

    it('evaluates JavaScript in main thread', async function() {
        const cb = new Callback();
        window.cb = cb;

        await editor.cmdline('!/test.js');
        const ret = await cb.waitDone();
        assert.strictEqual(ret, 'hello!');

        await inputEnter();
        assert.include(drawer.getReceivedText(), 'Press ENTER or type command to continue');
    });

    it('shows a JavaScript error on invalid evaluating invalid code', async function() {
        await editor.cmdline('!/invalid.js');

        // Wait for error output. This wait is necessary because we need to wait for
        //   (1) evaluating sent JavaScript code in main thread
        //   (2) receiving error message from main thread
        //   (3) output the error message in worker thread
        // This line must be put before cmdline('redraw') because sending command just after
        // JavaScript evaluation may cause overwrite of status byte in shared memory buffer.
        await wait(500);

        await editor.cmdline('redraw');

        const text = drawer.getReceivedText();

        // Check error message
        assert.include(text, 'E9999: Unexpected end of input');
        // Check stacktrace is output
        assert.include(text, 'at eval (<anonymous>)');
        assert.include(text, 'at VimWasm.evalJS');

        await inputEnter(); // Dismiss error message
    });

    it('causes an error on non-JS sources', async function() {
        await editor.cmdline('!echo');
        await editor.cmdline('redraw');

        const text = drawer.getReceivedText();
        assert.include(text, 'E9999: :! only supports executing JavaScript file.');

        await inputEnter(); // Dismiss error message
    });

    it('causes an error on non-existing-sources', async function() {
        await editor.cmdline('!/non_existing_src.js');
        await editor.cmdline('redraw');

        const text = drawer.getReceivedText();
        assert.include(text, 'E9999: No such file or directory');

        await inputEnter(); // Dismiss error message
    });

    context('on system()', function() {
        it('always return an error', async function() {
            await editor.cmdline('call system("echo")');
            await editor.cmdline('redraw');

            const text = drawer.getReceivedText();
            assert.include(text, 'E9999: system() and systemlist() are not supported on WebAssembly fork');

            await inputEnter(); // Dismiss error message
        });
    });
});
