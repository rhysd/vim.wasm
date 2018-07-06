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

// Note: Code must be almost written in ES5 because Emscripten optimizes generated JavaScript
// for Empterpreter with uglifyjs.

const VimWasmRuntime = {
    $VW__postset: 'VW.init()',
    $VW: {
        init: function() {
            // Utilities
            function rgbToHexColor(r, g, b) {
                return '#' + r.toString(16) + g.toString(16) + b.toString(16);
            }

            // TODO: class VimCursor

            // TODO: IME support
            // TODO: Handle pre-edit IME state
            // TODO: Follow cursor position
            function VimInput(font) {
                this.imeRunning = false;
                this.font = font;
                this.elem = document.getElementById('vim-input');
                // TODO: Bind compositionstart event
                // TODO: Bind compositionend event
                this.elem.addEventListener('keydown', this.onKeydown.bind(this));
                this.elem.addEventListener('keypress', function(e) {
                    console.log('keypress:', e);
                });
                this.elem.addEventListener('blur', this.onBlur.bind(this));
                this.elem.addEventListener('focus', this.onFocus.bind(this));
                this.focus();
            }

            VimInput.prototype.onKeydown = function(event) {
                console.log('onKeydown():', event, event.key, event.charCode, event.keyCode);

                let charCode = event.keyCode;
                let special = null;

                // TODO: Move the conversion logic (key name -> key code) to C
                // Since strings cannot be passed to C function as char * if Emterpreter is enabled.
                // Setting { async: true } to ccall() does not help to solve this issue.
                if (event.key.length > 1) {
                    // Handles special keys. Logic was from gui_mac.c
                    switch (event.key) {
                        // Maybe need to handle 'Tab' as <C-i>
                        case 'F1':
                            special = 'k1';
                            break;
                        case 'F2':
                            special = 'k2';
                            break;
                        case 'F3':
                            special = 'k3';
                            break;
                        case 'F4':
                            special = 'k4';
                            break;
                        case 'F5':
                            special = 'k5';
                            break;
                        case 'F6':
                            special = 'k6';
                            break;
                        case 'F7':
                            special = 'k7';
                            break;
                        case 'F8':
                            special = 'k8';
                            break;
                        case 'F9':
                            special = 'k9';
                            break;
                        case 'F10':
                            special = 'F;';
                            break;
                        case 'F11':
                            special = 'F1';
                            break;
                        case 'F12':
                            special = 'F2';
                            break;
                        case 'F13':
                            special = 'F3';
                            break;
                        case 'F14':
                            special = 'F4';
                            break;
                        case 'F15':
                            special = 'F5';
                            break;
                        case 'Backspace':
                            special = 'kb';
                            break;
                        case 'Delete':
                            special = 'kD';
                            break;
                        case 'ArrowLeft':
                            special = 'kl';
                            break;
                        case 'ArrowUp':
                            special = 'ku';
                            break;
                        case 'ArrowRight':
                            special = 'kr';
                            break;
                        case 'ArrowDown':
                            special = 'kd';
                            break;
                        case 'PageUp':
                            special = 'kP';
                            break;
                        case 'PageDown':
                            special = 'kN';
                            break;
                        case 'End':
                            special = '@7';
                            break;
                        case 'Home':
                            special = 'kh';
                            break;
                        case 'Insert':
                            special = 'kI';
                            break;
                        case 'Help':
                            special = '%1';
                            break;
                        case 'Undo':
                            special = '&8';
                            break;
                        case 'Print':
                            special = '%9';
                            break;
                    }
                } else {
                    // When `key` is one character, get character code from `key`.
                    // KeyboardEvent.charCode is not available on 'keydown' event.
                    charCode = event.key.charCodeAt(0);
                }

                if (special === null) {
                    this.sendKeyToVim(charCode, 0, +event.ctrlKey, +event.shiftKey, +event.altKey, +event.metaKey);
                } else {
                    this.sendKeyToVim(
                        special.charCodeAt(0),
                        special.charCodeAt(1),
                        +event.ctrlKey,
                        +event.shiftKey,
                        +event.altKey,
                        +event.metaKey,
                    );
                }
            };

            VimInput.prototype.onFocus = function() {
                console.log('onFocus()');
                // TODO: Send <FocusGained> special character
            };

            VimInput.prototype.onBlur = function(event) {
                console.log('onBlur():', event);
                event.preventDefault();
                // TODO: Send <FocusLost> special character
            };

            VimInput.prototype.setFont = function(name, size) {
                this.elem.style.fontFamily = name;
                this.elem.style.fontSize = size + 'px';
            };

            VimInput.prototype.focus = function() {
                this.elem.focus();
            };

            // Origin is at left-above.
            //
            //      O-------------> x
            //      |
            //      |
            //      |
            //      |
            //      V
            //      y

            // Editor screen renderer
            function CanvasRenderer() {
                // TODO: These font metrics were from gui_mac.c
                // Font metrics should be measured instead of fixed values since monospace font is
                // different on each platform.
                this.charWidth = 7;
                this.charHeight = 11;
                this.charAscent = 6;
                this.rows = 24;
                this.cols = 80;
                this.canvas = document.getElementById('vim-screen');
                this.ctx = this.canvas.getContext('2d', { alpha: false });
                this.canvas.width = this.screenWidth();
                this.canvas.height = this.screenHeight();
                this.canvas.addEventListener('click', this.focus.bind(this));
                this.fontName = 'monospace';
                this.input = new VimInput();
                this.input.setFont(this.fontName, this.charHeight);
            }

            CanvasRenderer.prototype.onVimInit = function() {
                // Setup C function here since when VW.init() is called, Module.cwrap is not set yet.
                //
                // XXX: Coverting 'boolean' to 'number' does not work if Emterpreter is enabled.
                // So converting to 'number' from 'boolean' is done in JavaScript.
                VimInput.prototype.sendKeyToVim = Module.cwrap('gui_wasm_send_key', null, [
                    'number', // key code1
                    'number', // key code2 (used for special otherwise 0)
                    'number', // TRUE iff Ctrl key is pressed
                    'number', // TRUE iff Shift key is pressed
                    'number', // TRUE iff Alt key is pressed
                    'number', // TRUE iff Meta key is pressed
                ]);
                // XXX: Even if {async: true} is set for ccall(), passing strings as char * to C function
                // does not work with Emterpreter
                //
                // VW.VimInput.prototype.sendKeyToVim = function(keyCode, ctrl, shift, meta) {
                //     console.log('Send key:', keyCode);
                //     Module.ccall(
                //         'gui_wasm_send_key',
                //         null,
                //         ['number', 'boolean', 'boolean', 'boolean'],
                //         [keyCode, ctrl, shift, meta],
                //         // { async: true },
                //     );
                // };
            };

            CanvasRenderer.prototype.screenWidth = function() {
                return this.cols * this.getCharWidth();
            };

            CanvasRenderer.prototype.screenHeight = function() {
                return this.rows * this.getCharHeight();
            };

            CanvasRenderer.prototype.getCharWidth = function() {
                return this.charWidth * (window.devicePixelRatio || 1);
            };

            CanvasRenderer.prototype.getCharHeight = function() {
                return this.charHeight * (window.devicePixelRatio || 1);
            };

            CanvasRenderer.prototype.getCharAscent = function() {
                return this.charAscent * (window.devicePixelRatio || 1);
            };

            CanvasRenderer.prototype.mouseX = function() {
                return 0; // TODO
            };

            CanvasRenderer.prototype.mouseY = function() {
                return 0; // TODO
            };

            CanvasRenderer.prototype.setFG = function(r, g, b) {
                this.fgColor = rgbToHexColor(r, g, b);
            };

            CanvasRenderer.prototype.setBG = function(r, g, b) {
                this.bgColor = rgbToHexColor(r, g, b);
            };

            CanvasRenderer.prototype.setSP = function(r, g, b) {
                this.spColor = rgbToHexColor(r, g, b);
            };

            CanvasRenderer.prototype.setFont = function(fontName) {
                this.fontName = fontName;
                this.input.setFont(this.fontName, this.charHeight);
                // TODO: Font metrics should be measured since monospace font is different on each
                // platform.
            };

            CanvasRenderer.prototype.focus = function() {
                this.input.focus();
            };

            CanvasRenderer.prototype.resizeScreen = function(rows, cols) {
                if (this.rows == rows && this.cols == cols) {
                    return;
                }
                this.rows = rows;
                this.cols = cols;
                this.canvas.width = this.screenWidth();
                this.canvas.height = this.screenHeight();
            };

            CanvasRenderer.prototype.invertBlock = function(row, col, rows, cols) {
                const cw = this.getCharWidth();
                const ch = this.getCharHeight();
                const x = Math.floor(cw * col);
                const y = Math.floor(ch * row);
                const w = Math.floor(cw * (col2 - col));
                const h = Math.floor(ch * (row2 - row));
                const img = this.ctx.getImageData(x, y, w, h);
                const data = img.data;
                const len = data.length;
                for (let i = 0; i < len; ++i) {
                    data[i] = 255 - data[i];
                    ++i;
                    data[i] = 255 - data[i];
                    ++i;
                    data[i] = 255 - data[i];
                    ++i; // Skip alpha
                }
                ctx.putImageData(img, x, y);
            };

            CanvasRenderer.prototype.rectPixels = function(row, col, wpix, hpix, color, fill) {
                const cw = this.getCharWidth();
                const ch = this.getCharHeight();
                const x = Math.floor(cw * col);
                const y = Math.floor(ch * row);
                const res = window.devicePixelRatio || 1;
                const w = Math.floor(wpix * res);
                const h = Math.floor(hpix * res);
                this.ctx.fillStyle = color;
                if (fill) {
                    this.ctx.fillRect(x, y, w, h);
                } else {
                    this.ctx.rect(x, y, w, h);
                }
            };

            CanvasRenderer.prototype.rect = function(row, col, row2, col2, color, fill) {
                const cw = this.getCharWidth();
                const ch = this.getCharHeight();
                const x = Math.floor(cw * col);
                const y = Math.floor(ch * row);
                const w = Math.floor(cw * (col2 - col));
                const h = Math.floor(ch * (row2 - row));
                this.ctx.fillStyle = color;
                if (fill) {
                    this.ctx.fillRect(x, y, w, h);
                } else {
                    this.ctx.rect(x, y, w, h);
                }
            };

            CanvasRenderer.prototype.clearBlock = function(row, col, row2, col2) {
                this.rect(row, col, row2, col2, this.bgColor, true);
            };

            CanvasRenderer.prototype.clear = function() {
                this.ctx.fillStyle = this.bgColor;
                this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
            };

            CanvasRenderer.prototype.drawText = function(
                row,
                col,
                str,
                transparent,
                bold,
                underline,
                undercurl,
                strike,
            ) {
                this.clearBlock(row, col, row + 1, col + str.length);
                // TODO: When `transparent` is true, shouldn't we draw text?

                const ch = this.getCharHeight();
                const cw = this.getCharWidth();
                let font = ch + 'px ' + this.fontName;
                if (bold) {
                    font = 'bold ' + font;
                }
                this.ctx.font = font;
                this.ctx.textBaseline = 'top';
                this.ctx.fillStyle = this.fgColor;

                // Note:
                // Line height of <canvas> is fixed to 1.2 (normal).
                // If the specified line height is not 1.2, we should calculate
                // the difference of margin-bottom of text.
                // const margin = ch * (lineHeight - 1.2) / 2;
                // const y = Math.floor(row * ch + margin);

                const x = Math.floor(col * cw);
                const y = Math.floor(row * ch);
                this.ctx.fillText(str, x, y);

                const res = window.devicePixelRatio || 1;
                if (underline) {
                    this.ctx.strokeStyle = this.fgColor;
                    this.ctx.lineWidth = 1 * res;
                    this.ctx.setLineDash([]);
                    this.ctx.beginPath();
                    // Note: 3 is set with considering the width of line.
                    // TODO: Calcurate the position of the underline with descent.
                    const underlineY = y + ch - 3 * res;
                    this.ctx.moveTo(x, underlineY);
                    this.ctx.lineTo(x + cw * str.length, underlineY);
                    this.ctx.stroke();
                } else if (undercurl) {
                    this.ctx.strokeStyle = this.spColor;
                    this.ctx.lineWidth = 1 * res;
                    this.ctx.setLineDash([cw / 3, cw / 3]);
                    this.ctx.beginPath();
                    // Note: 3 is set with considering the width of line.
                    // TODO: Calcurate the position of the underline with descent.
                    const undercurlY = y + ch - 3 * res;
                    this.ctx.moveTo(x, undercurlY);
                    this.ctx.lineTo(x + cw * str.length, undercurlY);
                    this.ctx.stroke();
                } else if (strike) {
                    this.ctx.strokeStyle = this.fgColor;
                    this.ctx.lineWidth = 1 * res;
                    this.ctx.beginPath();
                    const strikeY = y + Math.floor(ch / 2);
                    this.ctx.moveTo(x, strikeY);
                    this.ctx.lineTo(x + cw * str.length, strikeY);
                    this.ctx.stroke();
                }
            };

            CanvasRenderer.prototype.deleteLines = function(row, numLines, left, bottom, right) {
                // TODO
            };

            CanvasRenderer.prototype.insertLines = function(row, numLines, left, bottom, right) {
                // TODO
            };

            VW.VimInput = VimInput;
            VW.CanvasRenderer = CanvasRenderer;
            VW.renderer = new CanvasRenderer();
        },
    },

    /*
     * C bridge
     */

    // int vimwasm_call_shell(char *);
    vimwasm_call_shell: function(command) {
        const c = Pointer_stringify(command);
        console.log('call_shell:', c);
        // Shell command may be passed here. Catch the exception
        // eval(c);
    },

    // void vimwasm_resize_win(int, int);
    vimwasm_resize_win: function(rows, columns) {
        console.log('resize_win: Rows:', rows, 'Columns:', columns);
        VW.renderer.resizeScreen(rows, columns);
    },

    // void vimwasm_will_init(void);
    vimwasm_will_init: function() {
        console.log('will_init:');
        VW.renderer.onVimInit();
    },

    // void vimwasm_will_exit(int);
    vimwasm_will_exit: function(exit_status) {
        console.log('will_exit:', exit_status);
    },

    // int vimwasm_get_char_width(void);
    vimwasm_get_char_width: function() {
        console.log('get_char_width:');
        return VW.renderer.getCharWidth();
    },

    // int vimwasm_get_char_height(void);
    vimwasm_get_char_height: function() {
        console.log('get_char_height:');
        return VW.renderer.getCharHeight();
    },

    // int vimwasm_get_char_height(void);
    vimwasm_get_char_ascent: function() {
        console.log('get_char_ascent:');
        return VW.renderer.getCharAscent();
    },

    // int vimwasm_get_win_width(void);
    vimwasm_get_win_width: function() {
        console.log('get_win_width:');
        return VW.renderer.screenWidth();
    },

    // int vimwasm_get_win_height(void);
    vimwasm_get_win_height: function() {
        console.log('get_win_height:');
        return VW.renderer.screenHeight();
    },

    // int vimwasm_resize(int, int, int, int, int, int, int);
    vimwasm_resize: function(width, height, min_width, min_height, base_width, base_height, direction) {
        console.log('resize:', width, height, min_width, min_height, base_width, base_height);
    },

    // void vimwasm_set_font(char *);
    vimwasm_set_font: function(font_name) {
        font_name = Pointer_stringify(font_name);
        console.log('set_font:', font_name);
        VW.renderer.setFont(font_name);
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
    vimwasm_draw_string: function(row, col, ptr, len, is_transparent, is_bold, is_underline, is_undercurl, is_strike) {
        const str = Pointer_stringify(ptr, len);
        console.log('draw_string:', row, col, str, len, is_transparent, is_bold, is_underline, is_undercurl, is_strike);
        VW.renderer.drawText(row, col, str, is_transparent, is_bold, is_underline, is_undercurl, is_strike);
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
        VW.renderer.rect(row, col, row + 1, col + 1, VW.renderer.fgColor, false);
    },

    // void vimwasm_draw_part_cursor(int, int, int, int);
    vimwasm_draw_part_cursor: function(row, col, width, height) {
        console.log('draw_hollow_cursor:', row, col);
        VW.renderer.rectPixels(row, col, width, height, VW.renderer.fgColor, true);
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
        // TODO: Show dialog and return which button was pressed
    },

    // int vimwasm_get_mouse_x();
    vimwasm_get_mouse_x: function() {
        console.log('get_mouse_x:');
        return VW.renderer.mouseX();
    },

    // int vimwasm_get_mouse_y();
    vimwasm_get_mouse_y: function() {
        console.log('get_mouse_y:');
        return VW.renderer.mouseY();
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
