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

// Emterpreter
void emscripten_sleep(int);

int vimwasm_call_shell(char *);
void vimwasm_resize_win(int, int);
void vimwasm_will_init(void);
void vimwasm_will_exit(int);
int vimwasm_get_char_width(void);
int vimwasm_get_char_height(void);
int vimwasm_get_char_ascent(void);
int vimwasm_get_win_width(void);
int vimwasm_get_win_height(void);
int vimwasm_resize(int, int, int, int, int, int, int);
void vimwasm_set_font(char *);
int vimwasm_is_font(char *);
void vimwasm_set_fg_color(long);
void vimwasm_set_bg_color(long);
void vimwasm_set_sp_color(long);
void vimwasm_draw_string(int, int, char *, int, int, int, int, int, int);
int vimwasm_is_supported_key(char *);
void vimwasm_invert_rectangle(int, int, int, int);
void vimwasm_draw_hollow_cursor(int, int);
void vimwasm_draw_part_cursor(int, int, int, int);
void vimwasm_clear_block(int, int, int, int);
void vimwasm_clear_all(void);
void vimwasm_delete_lines(int, int, int, int, int);
void vimwasm_insert_lines(int, int, int, int, int);
int vimwasm_open_dialog(int, char *, char *, char *, int, char *);
int vimwasm_get_mouse_x();
int vimwasm_get_mouse_y();
void vimwasm_set_title(char *);

#endif /* FEAT_GUI_WASM */

#endif    // WASM_RUNTIME_H_INCLUDED
