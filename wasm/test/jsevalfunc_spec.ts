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
        // Test results are sent from Vim script side with :export
        const exported = new Promise<[string, ArrayBuffer]>(resolve => {
            editor.onFileExport = (fpath, contents) => {
                resolve([fpath, contents]);
            };
        });

        // Trigger to run tests written in Vim script
        await editor.cmdline('source /test.vim');

        // Wait for tests have completed
        const [file, contents] = await exported;
        assert.strictEqual(file, '/test_jsevalfunc_result.txt');
        const text = new TextDecoder().decode(contents);
        assert.isEmpty(text);
    });
});
