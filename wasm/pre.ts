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
 * pre.ts: preloaded TyepScript code for Wasm port of Vim by @rhysd.
 */

function stdin(): null {
    // Tell that user did not give any input. GUI input is caught in 'keydown' listener.
    return null;
}

function prerun() {
    debug('prerun');
    FS.init(stdin, null, null);
}

debug = () => {
    /* noop */
};

Module.preRun.push(prerun);
