import { VimWasm } from '../vimwasm.js';
import { DummyDrawer, startVim, stopVim } from './helper.js';

describe('cmdArgs option', function() {
    let drawer: DummyDrawer | null;
    let editor: VimWasm | null;

    beforeEach(function() {
        drawer = null;
        editor = null;
    });

    afterEach(async function() {
        if (editor !== null) {
            assert.ok(drawer);
            await stopVim(drawer!, editor);
        }
    });

    it('passes arguments to Vim process', async function() {
        [drawer, editor] = await startVim({
            debug: true,
            cmdArgs: ['-c', 'edit ~/.vim/vimrc'],
        });

        const text = drawer.getReceivedText();
        assert.include(text, '"~/.vim/vimrc"');
        assert.include(text, '" Write your favorite config!');
    });
});
