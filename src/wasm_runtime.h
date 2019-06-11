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

#include <emscripten.h>

void vimwasm_will_init(void);
void vimwasm_will_exit(int);
int vimwasm_get_dom_width(void);
int vimwasm_get_dom_height(void);
int vimwasm_is_font(char *);
int vimwasm_is_supported_key(char *);
void vimwasm_set_fg_color(char *);
void vimwasm_set_bg_color(char *);
void vimwasm_set_sp_color(char *);
void vimwasm_draw_rect(int, int, int, int, char *, int);
void vimwasm_draw_text(int, int, int, int, int, char *, int, int, int, int, int);
void vimwasm_set_font(char *, int);
void vimwasm_invert_rect(int, int, int, int);
void vimwasm_image_scroll(int, int, int, int, int);
void vimwasm_set_title(char *);
int vimwasm_get_mouse_x(void);
int vimwasm_get_mouse_y(void);
void vimwasm_resize(int, int);
int vimwasm_call_shell(char *);
void vimwasm_wait_for_event(int timeout);

#endif /* FEAT_GUI_WASM */

#endif    // WASM_RUNTIME_H_INCLUDED
