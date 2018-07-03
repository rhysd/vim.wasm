/* vi:set ts=4 sts=4 sw=4 et:
 *
 * VIM - Vi IMproved		by Bram Moolenaar
 *				GUI/Motif support by Robert Webb
 *	      Implemented by rhysd <https://github.com/rhysd>
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */

/*
 * runtime.js: JavaScript runtime for Wasm port of Vim by @rhysd.
 */

const VimWasmRuntime = {
    // void vimwasm_resize_win(int, int);
    vimwasm_resize_win: function(rows, columns) {
        console.log('resize_win: Rows:', rows, 'Columns:', columns);
    },
};

mergeInto(LibraryManager.library, VimWasmRuntime);
