import { VimWasm } from '../vimwasm.js';
import { DummyDrawer, startVim, stopVim } from './helper.js';

describe('jsevalfunc()', function() {
    let drawer: DummyDrawer;
    let editor: VimWasm;

    before(async function() {
        [drawer, editor] = await startVim({
            debug: true,
            fetchFiles: {
                '/test.vim': '/base/test/test_jsevalfunc.vim',
            },
        });
    });

    after(async function() {
        await stopVim(drawer, editor);
    });

    afterEach(function() {
        editor.onFileExport = undefined;
    });

    it('passes unit tests written in Vim script', async function() {
        await editor.cmdline('source /test.vim');

        const exported = new Promise<[string, ArrayBuffer]>(resolve => {
            editor.onFileExport = (fpath, contents) => {
                resolve([fpath, contents]);
            };
        });

        await editor.cmdline('export /test_jsevalfunc_result.txt');

        const [file, contents] = await exported;
        assert.strictEqual(file, '/test_jsevalfunc_result.txt');
        const text = new TextDecoder().decode(contents);
        assert.isEmpty(text);
    });
});
