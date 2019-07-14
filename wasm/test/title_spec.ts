import { VimWasm } from '../vimwasm.js';
import { DummyDrawer, startVim, stopVim } from './helper.js';

function waitTitleChange(v: VimWasm) {
    return new Promise<string>(resolve => {
        v.onTitleUpdate = resolve;
    });
}

describe('Title change event', function() {
    let drawer: DummyDrawer;
    let editor: VimWasm;
    let onFirstTitle: Promise<string>;

    before(async function() {
        [drawer, editor] = await startVim({ debug: true }, v => {
            onFirstTitle = waitTitleChange(v);
        });
    });

    after(async function() {
        await stopVim(drawer, editor);
    });

    it('is notified to main thread at start up', async function() {
        const title = await onFirstTitle;
        assert.strictEqual(title, '[No Name] - VIM');
    });

    it('is notified on each title change', async function() {
        let onTitleChange = waitTitleChange(editor);
        await editor.cmdline('new /foo_bar');
        await editor.cmdline('redraw');
        let title = await onTitleChange;
        assert.strictEqual(title, 'foo_bar (/) - VIM');

        // Second try
        onTitleChange = waitTitleChange(editor);
        await editor.cmdline('new /piyo_poyo');
        await editor.cmdline('redraw');
        title = await onTitleChange;
        assert.strictEqual(title, 'piyo_poyo (/) - VIM');
    });
});
