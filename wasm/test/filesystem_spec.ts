/* eslint-disable @typescript-eslint/no-non-null-assertion */
import { VimWasm } from '../vimwasm.js';
import { DummyDrawer, startVim, stopVim, wait } from './helper.js';

describe('FileSystem support', function() {
    const drawer = new DummyDrawer();
    let editor: VimWasm;

    beforeEach(function() {
        drawer.reset();
    });

    describe('`dirs` start option', function() {
        before(async function() {
            editor = await startVim(drawer, {
                debug: true,
                dirs: ['/work', '/work/doc'],
            });
        });

        after(async function() {
            await stopVim(drawer, editor);
        });

        it('creates new directories', async function() {
            {
                await editor.cmdline('new /work/doc/hello.txt');
                await wait(500);

                const events = drawer.received.filter(m => m[0] === 'drawText').map(m => m[1][0] as string);
                assert.isAbove(events.length, 0);
                const allTexts = events.join(' ');
                assert.include(allTexts, '"/work/doc/hello.txt" [New File]');
            }

            {
                await editor.cmdline('redraw! | new /work/bye.txt');
                await wait(1000);

                const events = drawer.received.filter(m => m[0] === 'drawText').map(m => m[1][0] as string);
                assert.isAbove(events.length, 0);
                const allTexts = events.join(' ');
                assert.include(allTexts, '"/work/bye.txt" [New File]');
            }
        });

        it('creates directories on MEMFS', async function() {
            await stopVim(drawer, editor);

            drawer.reset();
            editor = await startVim(drawer, { debug: true }); // Restart without previous directories

            const file = 'work/doc/hello.txt';
            await editor.cmdline(`new ${file} | write | redraw`);
            await wait(500);

            const events = drawer.received.filter(m => m[0] === 'drawText').map(m => m[1][0] as string);
            assert.isAbove(events.length, 0);
            const allTexts = events.join(' ');

            assert.include(allTexts, 'E212:');
            assert.include(allTexts, `Can't open file for writing ${file}`);
        });
    });

    describe('`files` start option', function() {
        before(async function() {
            editor = await startVim(drawer, {
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
                await editor.cmdline('edit /work/doc/hello.txt | redraw');
                await wait(500);

                const events = drawer.received.filter(m => m[0] === 'drawText').map(m => m[1][0] as string);
                assert.isAbove(events.length, 0);
                const allTexts = events.join(' ');

                assert.include(allTexts, '/work/doc/hello.txt'); // In mode line
                assert.include(allTexts, 'Hi! Hello this is text for test');
            }

            {
                await editor.cmdline('redraw! | edit /work/goodbye.txt | redraw');
                await wait(1000);

                const events = drawer.received.filter(m => m[0] === 'drawText').map(m => m[1][0] as string);
                assert.isAbove(events.length, 0);
                const allTexts = events.join(' ');

                assert.include(allTexts, '/work/goodbye.txt'); // In mode line
                assert.include(allTexts, 'This is goodbye text');
            }
        });

        it('creates files on MEMFS', async function() {
            await stopVim(drawer, editor);

            drawer.reset();
            editor = await startVim(drawer, { debug: true }); // Restart without previous files

            const file = 'work/doc/hello.txt';
            await editor.cmdline(`new ${file} | write | redraw`);
            await wait(500);

            const events = drawer.received.filter(m => m[0] === 'drawText').map(m => m[1][0] as string);
            assert.isAbove(events.length, 0);
            const allTexts = events.join(' ');

            assert.include(allTexts, 'E212:');
            assert.include(allTexts, `Can't open file for writing ${file}`);
        });
    });

    /* XXX: This test does not work for unknown reason. It checks contents of indexedDB.
     * But there is no data. Though I manually checked contents of indexedDB from DevTools
     * (Application tab and JavaScript console) and confirmed there is a content.
     *
    describe.only('`persistentDirs` start option', function() {
        before(async function() {
            await new Promise(resolve => {
                const req = indexedDB.deleteDatabase('/work/doc');
                req.onerror = resolve;
                req.onsuccess = resolve;
            });

            editor = await startVim(drawer, {
                debug: true,
                dirs: ['/work', '/work/doc'],
                persistentDirs: ['/work/doc'],
            });
        });

        after(async function() {
            await stopVim(drawer, editor);
        });

        it('stores contents of the persistent directories in Indexed DB', async function() {
            await editor.cmdline('new /work/doc/hello.txt | write');
            await stopVim(drawer, editor);
            await wait(3000);

            const db = await new Promise<IDBDatabase>((resolve, reject) => {
                const req = indexedDB.open('/work/doc');
                req.onerror = reject;
                req.onsuccess = () => resolve(req.result);
            });

            const tr = db.transaction(['FILE_DATA'], 'readonly');
            const store = tr.objectStore('FILE_DATA');
            const idx = store.index('timestamp');
            const [key, val] = await new Promise((resolve, reject) => {
                const req = idx.openKeyCursor();
                req.onerror = reject;
                req.onsuccess = (e: any) => {
                    const cursor = e.target.result;
                    assert.isNotNull(cursor);
                    resolve([cursor.primaryKey, cursor.value]);
                };
            });

            assert.strictEqual(key, '/work/doc/hello.txt');
            // TODO: Check val
            assert.ok(val);
        });
    });
     */
    // TODO: Test /work/doc/hello.txt is readable
});
