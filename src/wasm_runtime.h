/* vi:set ts=8 sts=4 sw=4 noet:
 *
 * VIM - Vi IMproved    by Bram Moolenaar
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */

/*
 * wasm_runtime.h: runtime functions for Wasm port
 *
 * Wasm backend has JavaScript runtime to handle some functionalities
 * in JavaScript side. These functions are defined in JavaScript.
 *
 * Author: @rhysd <https://github.com/rhysd>
 */

#if !defined WASM_RUNTIME_H_INCLUDED
#define      WASM_RUNTIME_H_INCLUDED

#ifdef FEAT_GUI_WASM

vimwasm_call_shell(char *, int);

#endif /* FEAT_GUI_WASM */

#endif    // WASM_RUNTIME_H_INCLUDED
