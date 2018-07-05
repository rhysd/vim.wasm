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
    $VW__postset: 'VW.init()',
    $VW: {
        init: function() {
            // Utilities
            function rgbToHexColor(r, g, b) {
                return `#{r.toString(16)}{g.toString(16)}{b.toString(16)}`;
            }

            // TODO: class VimCursor

            // Editor screen renderer
            class CanvasRenderer {
                constructor() {
                    // TODO: Measure window height and return dynamic value
                    // Current value is from gui_mac.c
                    this.charWidth = 7;
                    this.charHeight = 11;
                    this.charAscent = 6;
                    this.rows = 24;
                    this.cols = 80;
                }

                get screenWidth() {
                    return this.cols * this.charWidth;
                }

                get screenHeight() {
                    return this.rows * this.charHeight;
                }

                get mouseX() {
                    return 0; // TODO
                }

                get mouseY() {
                    return 0; // TODO
                }

                setFG(r, g, b) {
                    this.fgColor = rgbToHexColor(r, g, b);
                }

                setBG(r, g, b) {
                    this.bgColor = rgbToHexColor(r, g, b);
                }

                setSP(r, g, b) {
                    this.spColor = rgbToHexColor(r, g, b);
                }

                resizeScreen(rows, cols) {
                    if (this.rows == rows && this.cols == cols) {
                        return;
                    }
                    this.rows = rows;
                    this.cols = cols;
                    // TODO: Resize <canvas> with the new rows and cols
                }

                invertBlock(row, col, height, width) {
                    // TODO
                }

                clearBlock(row, col, row2, col2) {
                    // TODO
                }

                clear() {
                    // TODO
                }

                deleteLines(row, numLines, left, bottom, right) {
                    // TODO
                }

                insertLines(row, numLines, left, bottom, right) {
                    // TODO
                }
            }

            VW.renderer = new CanvasRenderer();
        },
    },

    // int vimwasm_call_shell(char *);
    vimwasm_call_shell: function(command) {
        const c = Pointer_stringify(command);
        console.log('call_shell:', c);
        eval(c);
    },

    // void vimwasm_resize_win(int, int);
    vimwasm_resize_win: function(rows, columns) {
        console.log('resize_win: Rows:', rows, 'Columns:', columns);
        VW.renderer.resizeScreen(rows, columns);
    },

    // void vimwasm_will_init(void);
    vimwasm_will_init: function() {
        console.log('will_init:');
    },

    // void vimwasm_will_exit(int);
    vimwasm_will_exit: function(exit_status) {
        console.log('will_exit:', exit_status);
    },

    // int vimwasm_get_char_width(void);
    vimwasm_get_char_width: function() {
        console.log('get_char_width:');
        return VW.renderer.charWidth;
    },

    // int vimwasm_get_char_height(void);
    vimwasm_get_char_height: function() {
        console.log('get_char_height:');
        return VW.renderer.charHeight;
    },

    // int vimwasm_get_char_height(void);
    vimwasm_get_char_ascent: function() {
        console.log('get_char_ascent:');
        return VW.renderer.charAscent;
    },

    // int vimwasm_get_win_width(void);
    vimwasm_get_win_width: function() {
        console.log('get_win_width:');
        return VW.renderer.screenWidth;
    },

    // int vimwasm_get_win_height(void);
    vimwasm_get_win_height: function() {
        console.log('get_win_height:');
        return VW.renderer.screenHeight;
    },

    // int vimwasm_resize(int, int, int, int, int, int, int);
    vimwasm_resize: function(width, height, min_width, min_height, base_width, base_height, direction) {
        console.log('resize:', width, height, min_width, min_height, base_width, base_height);
        // TODO: Change <canvas> size
    },

    // void vimwasm_set_font(char *);
    vimwasm_set_font: function(font_name) {
        font_name = Pointer_stringify(font_name);
        console.log('set_font:', font_name);
        // TODO: Enable to specify font. Currently font name is fixed to monospace
    },

    // int vimwasm_is_font(char *);
    vimwasm_is_font: function(font_name) {
        font_name = Pointer_stringify(font_name);
        console.log('is_font:', font_name);
        // TODO: Check the font name is available. Currently font name is fixed to monospace
        return 1;
    },

    // void vimwasm_set_fg_color(int, int, int);
    vimwasm_set_fg_color: function(r, g, b) {
        console.log('set_fg_color:', r, g, b);
        VW.renderer.setFG(r, g, b);
    },

    // void vimwasm_set_bg_color(int, int, int);
    vimwasm_set_bg_color: function(r, g, b) {
        console.log('set_bg_color:', r, g, b);
        VW.renderer.setBG(r, g, b);
    },

    // void vimwasm_set_sp_color(int, int, int);
    vimwasm_set_sp_color: function(r, g, b) {
        console.log('set_sp_color:', r, g, b);
        VW.renderer.setSP(r, g, b);
    },

    // void vimwasm_draw_string(int, int, char *, int, int, int, int, int, int);
    vimwasm_draw_string: function(row, col, str, len, is_transparent, is_bold, is_underline, is_undercurl, is_strike) {
        console.log('draw_string:', row, col, str, len, is_transparent, is_bold, is_underline, is_undercurl, is_strike);
        // TODO: Render text in screen
    },

    // int vimwasm_is_supported_key(char *);
    vimwasm_is_supported_key: function(key_name) {
        key_name = Pointer_stringify(key_name);
        console.log('is_supported_key:', key_name);
        // TODO: Check the key is supported in the browser
        return 1;
    },

    // void vimwasm_invert_rectangle(int, int, int, int);
    vimwasm_invert_rectangle: function(row, col, height, width) {
        console.log('invert_rectangle:', row, col, height, width);
        VW.renderer.invertBlock(row, col, height, width);
    },

    // void vimwasm_draw_hollow_cursor(int, int);
    vimwasm_draw_hollow_cursor: function(row, col) {
        console.log('draw_hollow_cursor:', row, col);
        // TODO
    },

    // void vimwasm_draw_part_cursor(int, int, int, int);
    vimwasm_draw_part_cursor: function(row, col, width, height) {
        console.log('draw_hollow_cursor:', row, col);
        // TODO
    },

    // void vimwasm_clear_block(int, int, int, int);
    vimwasm_clear_block: function(row1, col1, row2, col2) {
        console.log('clear_block:', row1, col1, row2, col2);
        VW.renderer.clearBlock(row1, col1, row2, col2);
    },

    // void vimwasm_clear_all(void);
    vimwasm_clear_all: function() {
        console.log('clear_all:');
        VW.renderer.clear();
    },

    // void vimwasm_delete_lines(int, int, int, int, int);
    vimwasm_delete_lines: function(row, num_lines, region_left, region_bottom, region_right) {
        console.log('delete_lines:', row, num_lines, region_left, region_bottom, region_right);
        VW.renderer.deleteLines(row, num_lines, region_left, region_bottom, region_right);
    },

    // void vimwasm_insert_lines(int, int, int, int, int);
    vimwasm_insert_lines: function(row, num_lines, region_left, region_bottom, region_right) {
        console.log('insert_lines:', row, num_lines, region_left, region_bottom, region_right);
        VW.renderer.insertLines(row, num_lines, region_left, region_bottom, region_right);
    },

    // int vimwasm_open_dialog(int, char *, char *, char *, int, char *);
    vimwasm_open_dialog: function(type, title, message, buttons, default_button_idx, textfield) {
        title = Pointer_stringify(title);
        message = Pointer_stringify(message);
        buttons = Pointer_stringify(buttons);
        textfield = Pointer_stringify(textfield);
        console.log('open_dialog:', type, title, message, buttons, default_button_idx, textfield);
        // TODO
    },

    // int vimwasm_get_mouse_x();
    vimwasm_get_mouse_x: function() {
        console.log('get_mouse_x:');
        return VW.renderer.mouseX;
    },

    // int vimwasm_get_mouse_y();
    vimwasm_get_mouse_y: function() {
        console.log('get_mouse_y:');
        return VW.renderer.mouseY;
    },

    // void vimwasm_set_title(char *);
    vimwasm_set_title: function(title) {
        title = Pointer_stringify(title);
        console.log('set_title:', title);
        document.title = title;
    },
};

autoAddDeps(VimWasmRuntime, '$VW');
mergeInto(LibraryManager.library, VimWasmRuntime);
