import { VimWasm } from '../vimwasm.js';
import { DummyDrawer, startVim, stopVim } from './helper.js';

describe('Perf measurement', function() {
    let editor: VimWasm;
    let drawer: DummyDrawer;

    before(async function() {
        [drawer, editor] = await startVim({ perf: true });
    });

    after(async function() {
        await stopVim(drawer, editor);
    });

    it('collects performance marks', function() {
        const entries = performance.getEntries();
        assert.isAbove(entries.length, 0);
    });

    it('collects performance of inter threads messages', function() {
        const perfs = (editor as any).perfMessages;
        const keys = Object.keys(perfs);
        assert.isAbove(keys.length, 0);

        for (const name of keys) {
            assert.isTrue(name === 'started' || name.startsWith('draw:'), name);
            const durations = perfs[name];
            assert.isAbove(durations.length, 0, name);
            for (const d of durations) {
                assert.isAtLeast(d, 0, name);
            }
        }
    });

    it('clears measurements after printing them', async function() {
        editor.cmdline('qall!');
        await drawer.exited;

        assert.isEmpty(performance.getEntriesByType('measure'));
        assert.isEmpty((editor as any).perfMessages);
    });
});
