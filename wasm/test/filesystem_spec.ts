import { VimWasm } from '../vimwasm.js';
import { DummyDrawer, startVim, stopVim } from './helper.js';

describe('FileSystem support', function() {
    let drawer: DummyDrawer;
    let editor: VimWasm;

    describe('`dirs` start option', function() {
        before(async function() {
            [drawer, editor] = await startVim({
                debug: true,
                dirs: ['/work', '/work/doc'],
            });
        });

        afterEach(async function() {
            await stopVim(drawer, editor);
        });

        it('creates new directories', async function() {
            {
                await Promise.all([editor.cmdline('new /work/doc/hello.txt'), drawer.waitDrawComplete()]);

                const allTexts = drawer.getReceivedText();
                assert.isAbove(allTexts.length, 0);
                assert.include(allTexts, '"/work/doc/hello.txt" [New File]');
            }

            {
                await Promise.all([editor.cmdline('redraw! | new /work/bye.txt'), drawer.waitDrawComplete()]);

                const allTexts = drawer.getReceivedText();
                assert.isAbove(allTexts.length, 0);
                assert.include(allTexts, '"/work/bye.txt" [New File]');
            }
        });

        it('creates directories on MEMFS', async function() {
            await stopVim(drawer, editor);

            [drawer, editor] = await startVim({ debug: true }); // Restart without previous directories

            const file = 'work/doc/hello.txt';
            await Promise.all([editor.cmdline(`new ${file} | write | redraw`), drawer.waitDrawComplete()]);

            const allTexts = drawer.getReceivedText();
            assert.isAbove(allTexts.length, 0);

            assert.include(allTexts, 'E212:');
            assert.include(allTexts, `Can't open file for writing ${file}`);
        });
    });

    describe('`files` start option', function() {
        before(async function() {
            [drawer, editor] = await startVim({
                debug: true,
                files: {
                    '/work/doc/hello.txt': 'Hi! Hello this is text for test\n',
                    '/work/goodbye.txt': 'This is goodbye text\n',
                },
                dirs: ['/work', '/work/doc'],
            });
        });

        after(async function() {
            await stopVim(drawer, editor);
        });

        it('creates new files', async function() {
            {
                await Promise.all([editor.cmdline('edit /work/doc/hello.txt | redraw'), drawer.waitDrawComplete()]);

                const allTexts = drawer.getReceivedText();
                assert.isAbove(allTexts.length, 0);

                assert.include(allTexts, '/work/doc/hello.txt'); // In mode line
                assert.include(allTexts, 'Hi! Hello this is text for test');
            }

            {
                await Promise.all([
                    editor.cmdline('redraw! | edit /work/goodbye.txt | redraw'),
                    drawer.waitDrawComplete(),
                ]);

                const allTexts = drawer.getReceivedText();
                assert.isAbove(allTexts.length, 0);

                assert.include(allTexts, '/work/goodbye.txt'); // In mode line
                assert.include(allTexts, 'This is goodbye text');
            }
        });

        it('creates files on MEMFS', async function() {
            await stopVim(drawer, editor);

            [drawer, editor] = await startVim({ debug: true }); // Restart without previous files

            const file = 'work/doc/hello.txt';
            await Promise.all([editor.cmdline(`new ${file} | write | redraw`), drawer.waitDrawComplete()]);

            const allTexts = drawer.getReceivedText();
            assert.isAbove(allTexts.length, 0);

            assert.include(allTexts, 'E212:');
            assert.include(allTexts, `Can't open file for writing ${file}`);
        });
    });

    /* eslint-disable mocha/no-skipped-tests */
    // XXX: This test suite passes alone, but does not pass with other test cases due to mysterious reason.
    // In the case, log says that filesystem was saved to IDB, but actually it is not saved in IDB and below
    // `assert.isNotNull(cursor)` fails. However, if I checked IDB contents in DevTools' Application tab,
    // or I tried to `console.log` contents of IDB in JavaScript console of DevTools, data could be confirmed.
    // This occurs only on tests and never happens when trying to reproduce manually.
    describe.skip('`persistentDirs` start option', function() {
        /* eslint-enable mocha/no-skipped-tests */
        function deleteDB() {
            return new Promise((resolve, reject) => {
                const req = indexedDB.deleteDatabase('/work');
                req.onerror = reject;
                req.onsuccess = resolve;
            });
        }

        before(async function() {
            await deleteDB();

            [drawer, editor] = await startVim({
                debug: true,
                dirs: ['/work'],
                persistentDirs: ['/work'],
            });
        });

        after(async function() {
            await stopVim(drawer, editor);
        });

        it('stores contents of the persistent directories in Indexed DB', async function() {
            await editor.cmdline('new /work/hello.txt | write');
            await stopVim(drawer, editor);

            const db = await new Promise<IDBDatabase>((resolve, reject) => {
                const req = indexedDB.open('/work');
                req.onerror = reject;
                req.onsuccess = () => resolve(req.result);
            });

            const tr = db.transaction(['FILE_DATA'], 'readonly');
            const store = tr.objectStore('FILE_DATA');
            assert.ok(store);

            const [key, val] = await new Promise((resolve, reject) => {
                const req = store.openCursor();
                req.onerror = reject;
                req.onsuccess = (e: any) => {
                    const cursor = e.target.result;
                    assert.isNotNull(cursor);
                    resolve([cursor.primaryKey, cursor.value]);
                };
            });

            assert.strictEqual(key, '/work/hello.txt');

            const { timestamp, mode, contents } = val;
            assert.ok(timestamp); // Date object for index
            assert.isAbove(mode, 0);

            const decoder = new TextDecoder();
            const lines = decoder.decode(contents);
            assert.isEmpty(lines);
        });

        it('loads stored persistent files at next time', async function() {
            [drawer, editor] = await startVim({
                debug: true,
                dirs: ['/work'],
                persistentDirs: ['/work'],
            });

            drawer.reset();
            await Promise.all([editor.cmdline('edit /work/hello.txt | redraw'), drawer.waitDrawComplete()]);

            const allTexts = drawer.getReceivedText();
            assert.isAbove(allTexts.length, 0);

            assert.include(allTexts, '/work/hello.txt');
            assert.notInclude(allTexts, '[New File]');
        });
    });
});
