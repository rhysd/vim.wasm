import { VimWasm } from '../vimwasm.js';
import { DummyDrawer, startVim, stopVim } from './helper.js';

describe('FileSystem support', function() {
    let drawer: DummyDrawer;
    let editor: VimWasm;

    describe('`dirs` start option', function() {
        afterEach(async function() {
            await stopVim(drawer, editor);
        });

        it('creates new directories', async function() {
            [drawer, editor] = await startVim({
                debug: true,
                dirs: ['/work', '/work/doc'],
            });

            {
                await editor.cmdline('new /work/doc/hello_world');
                await editor.cmdline('redraw');

                const allTexts = drawer.getReceivedText();
                assert.isAbove(allTexts.length, 0);
                assert.include(allTexts, '"/work/doc/hello_world" [New File]');
            }

            {
                await editor.cmdline('redraw!');
                await editor.cmdline('new /work/bye_world');
                await editor.cmdline('redraw');

                const allTexts = drawer.getReceivedText();
                assert.isAbove(allTexts.length, 0);
                assert.include(allTexts, '"/work/bye_world" [New File]');
            }
        });

        it('creates directories on MEMFS', async function() {
            [drawer, editor] = await startVim({ debug: true }); // Restart without previous directories

            const file = '/work/doc/hello_world';
            await editor.cmdline(`new ${file}`);
            await editor.cmdline('write!');
            await editor.cmdline('redraw');

            const allTexts = drawer.getReceivedText();
            assert.isAbove(allTexts.length, 0);

            assert.include(allTexts, 'E212:');
            assert.include(allTexts, `Can't open file for writing ${file}`);
        });
    });

    describe('`files` start option', function() {
        afterEach(async function() {
            await stopVim(drawer, editor);
        });

        it('creates new files', async function() {
            [drawer, editor] = await startVim({
                debug: true,
                files: {
                    '/work/doc/hello_world': 'Hi! Hello this is text for test\n',
                    '/work/goodbye_world': 'This is goodbye text\n',
                },
                dirs: ['/work', '/work/doc'],
            });

            {
                await editor.cmdline('edit /work/doc/hello_world');
                await editor.cmdline('redraw');

                const allTexts = drawer.getReceivedText();
                assert.isAbove(allTexts.length, 0);

                assert.include(allTexts, '/work/doc/hello_world'); // In mode line
                assert.include(allTexts, 'Hi! Hello this is text for test');
            }

            {
                await editor.cmdline('redraw! | edit /work/goodbye_world');
                await editor.cmdline('redraw');

                const allTexts = drawer.getReceivedText();
                assert.isAbove(allTexts.length, 0);

                assert.include(allTexts, '/work/goodbye_world'); // In mode line
                assert.include(allTexts, 'This is goodbye text');
            }
        });

        it('creates files on MEMFS', async function() {
            [drawer, editor] = await startVim({ debug: true }); // Restart without previous files

            const file = '/work/doc/hello_world';
            await editor.cmdline(`new ${file}`);
            await editor.cmdline('write!');
            await editor.cmdline('redraw');

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
            await editor.cmdline('new /work/hello_world | write');
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

            assert.strictEqual(key, '/work/hello_world');

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
            await editor.cmdline('edit /work/hello_world');
            await editor.cmdline('redraw');

            const allTexts = drawer.getReceivedText();
            assert.isAbove(allTexts.length, 0);

            assert.include(allTexts, '/work/hello_world');
            assert.notInclude(allTexts, '[New File]');
        });
    });

    describe('`fetchFiles` start option', function() {
        function waitExported() {
            return new Promise<[string, ArrayBuffer]>(resolve => {
                editor.onFileExport = (file, contents) => {
                    resolve([file, contents]);
                };
            });
        }

        afterEach(async function() {
            await stopVim(drawer, editor);
        });

        for (const [what, url] of [
            ['local files without scheme', '/base/test/hello.txt'],
            ['remote files with http scheme', 'http://localhost:9876/base/test/hello.txt'],
        ]) {
            it('fetches ' + what, async function() {
                [drawer, editor] = await startVim({
                    debug: true,
                    fetchFiles: {
                        '/home/web_user/wow.txt': url,
                    },
                });

                const exported = waitExported();

                await editor.cmdline('export /home/web_user/wow.txt');

                const [file, buf] = await exported;

                assert.strictEqual(file, '/home/web_user/wow.txt');
                assert.isAbove(buf.byteLength, 0);
                const decoder = new TextDecoder();
                const text = decoder.decode(buf);
                assert.include(text, 'Hello, this file is for test.');
            });

            it('ignores not-existing ' + what, async function() {
                const invalidUrl = url.replace('hello.txt', 'goodbye.txt');

                [drawer, editor] = await startVim({
                    debug: true,
                    fetchFiles: {
                        '/home/web_user/foo.txt': invalidUrl,
                    },
                });

                drawer.reset();
                await editor.cmdline('export /home/web_user/foo.txt');

                const text = drawer.getReceivedText();
                assert.include(text, 'E9999: Cannot export file. No such file');
            });
        }
    });
});
