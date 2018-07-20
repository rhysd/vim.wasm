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
 * runtime.js: preloaded JavaScript code for Wasm port of Vim by @rhysd.
 */

// Note: Code must be written in ES5 because Emscripten optimizes generated JavaScript
// for Empterpreter with uglifyjs/ClosureCompiler.

// This declaration is necessary to make ClosureCompiler know 'debug' global variable.
var debug;

function stdin() {
    // Tell that user did not give any input. GUI input is caught in 'keydown' listener.
    return null;
}

function prerun() {
    debug('prerun');
    FS.init(stdin, null, null);
}

Module.preRun.push(prerun);
