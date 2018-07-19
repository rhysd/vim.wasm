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
            function VimWindow(canvas) {
                this.canvas = canvas;
                const rect = this.canvas.getBoundingClientRect();
                this.elemHeight = rect.height;
                this.elemWidth = rect.width;
                const dpr = window.devicePixelRatio || 1;
                this.canvas.width = rect.width * dpr;
                this.canvas.height = rect.height * dpr;
                this.bounceTimerToken = null;
                this.onResize = this.onResize.bind(this);
                window.addEventListener('resize', this.onResize, { passive: true });
            }

            VimWindow.prototype.onVimInit = function() {
                this.resizeVim = Module.cwrap('gui_wasm_resize_shell', null, [
                    'number', // dom_width
                    'number', // dom_height
                ]);
                // XXX: Following is also not working
                // this.resizeVim = function(rows, cols) {
                //     Module.ccall('gui_wasm_resize_shell', null, ['number', 'number'], [rows, cols], { async: true });
                // };
            };

            VimWindow.prototype.onVimExit = function() {
                window.removeEventListener('resize', this.onResize);
            };

            VimWindow.prototype.onResize = function(event) {
                if (this.bounceTimerToken !== null) {
                    window.clearTimeout(this.bounceTimerToken);
                }
                const that = this;
                this.bounceTimerToken = setTimeout(function() {
                    that.bounceTimerToken = null;
                    that.doResize();
                }, 1000);
            };

            VimWindow.prototype.doResize = function() {
                const rect = this.canvas.getBoundingClientRect();
                debug('Resize Vim:', rect);
                this.elemWidth = rect.width;
                this.elemHeight = rect.height;
                this.resizeVim(rect.width, rect.height);
            };

            const KeyToSpecialCode = {
                F1: 'k1',
                F2: 'k2',
                F3: 'k3',
                F4: 'k4',
                F5: 'k5',
                F6: 'k6',
                F7: 'k7',
                F8: 'k8',
                F9: 'k9',
                F10: 'F;',
                F11: 'F1',
                F12: 'F2',
                F13: 'F3',
                F14: 'F4',
                F15: 'F5',
                Backspace: 'kb',
                Delete: 'kD',
                ArrowLeft: 'kl',
                ArrowUp: 'ku',
                ArrowRight: 'kr',
                ArrowDown: 'kd',
                PageUp: 'kP',
                PageDown: 'kN',
                End: '@7',
                Home: 'kh',
                Insert: 'kI',
                Help: '%1',
                Undo: '&8',
                Print: '%9',
            };

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
                this.elem.addEventListener('blur', this.onBlur.bind(this));
                this.elem.addEventListener('focus', this.onFocus.bind(this));
                this.focus();
            }

            VimInput.prototype.onKeydown = function(event) {
                event.preventDefault();
                event.stopPropagation();
                debug('onKeydown():', event, event.key, event.charCode, event.keyCode);

                var charCode = event.keyCode;
                var special = null;

                // TODO: Move the conversion logic (key name -> key code) to C
                // Since strings cannot be passed to C function as char * if Emterpreter is enabled.
                // Setting { async: true } to ccall() does not help to solve this issue.
                const key = event.key;
                if (key.length > 1) {
                    if (
                        key === 'Unidentified' ||
                        (event.ctrlKey && key === 'Control') ||
                        (event.shiftKey && key === 'Shift') ||
                        (event.altKey && key === 'Alt') ||
                        (event.metaKey && key === 'Meta')
                    ) {
                        debug('Ignore key input', key);
                        return;
                    }

                    // Handles special keys. Logic was from gui_mac.c
                    // Key names were from https://www.w3.org/TR/DOM-Level-3-Events-key/
                    if (key in KeyToSpecialCode) {
                        special = KeyToSpecialCode[key];
                    }
                } else {
                    // When `key` is one character, get character code from `key`.
                    // KeyboardEvent.charCode is not available on 'keydown'
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
                        +event.metaKey
                    );
                }
            };

            VimInput.prototype.onFocus = function() {
                debug('onFocus()');
                // TODO: Send <FocusGained> special character
            };

            VimInput.prototype.onBlur = function(event) {
                debug('onBlur():', event);
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

            VimInput.prototype.onVimInit = function() {
                if (VimInput.prototype.sendKeyToVim === undefined) {
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
                }
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

            function CanvasRenderer() {
                this.canvas = document.getElementById('vim-screen');
                this.ctx = this.canvas.getContext('2d', { alpha: false });
                this.window = new VimWindow(this.canvas);
                this.canvas.addEventListener('click', this.onClick.bind(this));
                this.input = new VimInput();
            }

            CanvasRenderer.prototype.onVimInit = function() {
                this.input.onVimInit();
                this.window.onVimInit();
            };

            CanvasRenderer.prototype.onVimExit = function() {
                this.window.onVimExit();
            };

            CanvasRenderer.prototype.onClick = function(event) {
                this.input.focus();
            };

            CanvasRenderer.prototype.setColorFG = function(name) {
                this.fgColor = name;
            };

            CanvasRenderer.prototype.setColorBG = function(name) {
                this.bgColor = name;
            };

            CanvasRenderer.prototype.setColorSP = function(name) {
                this.spColor = name;
            };

            CanvasRenderer.prototype.setFont = function(name, size) {
                this.fontName = name;
                this.input.setFont(name, size);
            };

            CanvasRenderer.prototype.drawRect = function(x, y, w, h, color, filled) {
                const dpr = window.devicePixelRatio || 1;
                x = Math.floor(x * dpr);
                y = Math.floor(y * dpr);
                w = Math.floor(w * dpr);
                h = Math.floor(h * dpr);
                this.ctx.fillStyle = color;
                if (filled) {
                    this.ctx.fillRect(x, y, w, h);
                } else {
                    this.ctx.rect(x, y, w, h);
                }
            };

            CanvasRenderer.prototype.drawText = function(text, ch, lh, cw, x, y, bold, underline, undercurl, strike) {
                const dpr = window.devicePixelRatio || 1;
                ch = ch * dpr;
                lh = lh * dpr;
                cw = cw * dpr;
                x = x * dpr;
                y = y * dpr;

                var font = Math.floor(ch) + 'px ' + this.fontName;
                if (bold) {
                    font = 'bold ' + font;
                }

                this.ctx.font = font;
                this.ctx.textBaseline = 'top'; // FIXME: Should set 'bottom' from descent of the font
                this.ctx.fillStyle = this.fgColor;

                const yi = Math.floor(y);
                for (var i = 0; i < text.length; ++i) {
                    this.ctx.fillText(text[i], Math.floor(x + cw * i), yi);
                }

                if (underline) {
                    this.ctx.strokeStyle = this.fgColor;
                    this.ctx.lineWidth = 1 * dpr;
                    this.ctx.setLineDash([]);
                    this.ctx.beginPath();
                    // Note: 3 is set with considering the width of line.
                    // TODO: Calcurate the position of the underline with descent.
                    const underlineY = Math.floor(y + lh - 3 * res);
                    this.ctx.moveTo(Math.floor(x), underlineY);
                    this.ctx.lineTo(Math.floor(x + cw * text.length), underlineY);
                    this.ctx.stroke();
                } else if (undercurl) {
                    this.ctx.strokeStyle = this.spColor;
                    this.ctx.lineWidth = 1 * dpr;
                    const curlWidth = Math.floor(cw / 3);
                    this.ctx.setLineDash([curlWidth, curlWidth]);
                    this.ctx.beginPath();
                    // Note: 3 is set with considering the width of line.
                    // TODO: Calcurate the position of the underline with descent.
                    const undercurlY = Math.floor(y + lh - 3 * dpr);
                    this.ctx.moveTo(Math.floor(x), undercurlY);
                    this.ctx.lineTo(Math.floor(x + cw * text.length), undercurlY);
                    this.ctx.stroke();
                } else if (strike) {
                    this.ctx.strokeStyle = this.fgColor;
                    this.ctx.lineWidth = 1 * dpr;
                    this.ctx.beginPath();
                    const strikeY = Math.floor(y + lh / 2);
                    this.ctx.moveTo(Math.floor(x), strikeY);
                    this.ctx.lineTo(Math.floor(x + cw * text.length), strikeY);
                    this.ctx.stroke();
                }
            };

            CanvasRenderer.prototype.invertRect = function(x, y, w, h) {
                const dpr = window.devicePixelRatio || 1;
                x = Math.floor(x * dpr);
                y = Math.floor(y * dpr);
                w = Math.floor(w * dpr);
                h = Math.floor(h * dpr);

                const img = this.ctx.getImageData(x, y, w, h);
                const data = img.data;
                const len = data.length;
                for (var i = 0; i < len; ++i) {
                    data[i] = 255 - data[i];
                    ++i;
                    data[i] = 255 - data[i];
                    ++i;
                    data[i] = 255 - data[i];
                    ++i; // Skip alpha
                }
                this.ctx.putImageData(img, x, y);
            };

            CanvasRenderer.prototype.imageScroll = function(x, sy, dy, w, h) {
                const dpr = window.devicePixelRatio || 1;
                x = Math.floor(x * dpr);
                sy = Math.floor(sy * dpr);
                dy = Math.floor(dy * dpr);
                w = Math.floor(w * dpr);
                h = Math.floor(h * dpr);
                this.ctx.drawImage(this.canvas, x, sy, w, h, x, dy, w, h);
            };

            CanvasRenderer.prototype.mouseX = function() {
                return 0; // TODO
            };

            CanvasRenderer.prototype.mouseY = function() {
                return 0; // TODO
            };

            VW.renderer = new CanvasRenderer();
        },
    },

    /*
     * C bridge
     */

    // int vimwasm_call_shell(char *);
    vimwasm_call_shell: function(command) {
        const c = Pointer_stringify(command);
        debug('call_shell:', c);
        // Shell command may be passed here. Catch the exception
        // eval(c);
    },

    // void vimwasm_will_init(void);
    vimwasm_will_init: function() {
        VW.renderer.onVimInit();
    },

    // void vimwasm_will_exit(int);
    vimwasm_will_exit: function(exit_status) {
        VW.renderer.onVimExit();
    },

    // int vimwasm_resize(int, int);
    vimwasm_resize: function(width, height) {
        debug('resize:', width, height);
    },

    // int vimwasm_is_font(char *);
    vimwasm_is_font: function(font_name) {
        font_name = Pointer_stringify(font_name);
        debug('is_font:', font_name);
        // TODO: Check the font name is available. Currently font name is fixed to monospace
        return 1;
    },

    // int vimwasm_is_supported_key(char *);
    vimwasm_is_supported_key: function(key_name) {
        key_name = Pointer_stringify(key_name);
        debug('is_supported_key:', key_name);
        // TODO: Check the key is supported in the browser
        return 1;
    },

    // int vimwasm_open_dialog(int, char *, char *, char *, int, char *);
    vimwasm_open_dialog: function(type, title, message, buttons, default_button_idx, textfield) {
        title = Pointer_stringify(title);
        message = Pointer_stringify(message);
        buttons = Pointer_stringify(buttons);
        textfield = Pointer_stringify(textfield);
        debug('open_dialog:', type, title, message, buttons, default_button_idx, textfield);
        // TODO: Show dialog and return which button was pressed
    },

    // int vimwasm_get_mouse_x();
    vimwasm_get_mouse_x: function() {
        debug('get_mouse_x:');
        return VW.renderer.mouseX();
    },

    // int vimwasm_get_mouse_y();
    vimwasm_get_mouse_y: function() {
        debug('get_mouse_y:');
        return VW.renderer.mouseY();
    },

    // void vimwasm_set_title(char *);
    vimwasm_set_title: function(title) {
        title = Pointer_stringify(title);
        debug('set_title:', title);
        document.title = title;
    },

    // void vimwasm_set_fg_color(char *);
    vimwasm_set_fg_color: function(name) {
        name = Pointer_stringify(name);
        VW.renderer.setColorFG(name);
    },

    // void vimwasm_set_bg_color(char *);
    vimwasm_set_bg_color: function(name) {
        name = Pointer_stringify(name);
        VW.renderer.setColorBG(name);
    },

    // void vimwasm_set_sp_color(char *);
    vimwasm_set_sp_color: function(name) {
        name = Pointer_stringify(name);
        VW.renderer.setColorSP(name);
    },

    // int vimwasm_get_dom_width()
    vimwasm_get_dom_width: function() {
        debug('get_dom_width:');
        return VW.renderer.window.elemWidth;
    },

    // int vimwasm_get_dom_height()
    vimwasm_get_dom_height: function() {
        debug('get_dom_height:');
        return VW.renderer.window.elemHeight;
    },

    // void vimwasm_draw_rect(int, int, int, int, char *, int);
    vimwasm_draw_rect: function(x, y, w, h, color, filled) {
        color = Pointer_stringify(color);
        VW.renderer.drawRect(x, y, w, h, color, !!filled);
    },

    // void vimwasm_draw_text(int, int, int, int, int, char *, int, int, int, int, int);
    vimwasm_draw_text: function(charHeight, lineHeight, charWidth, x, y, str, len, bold, underline, undercurl, strike) {
        const text = Pointer_stringify(str, len);
        VW.renderer.drawText(text, charHeight, lineHeight, charWidth, x, y, !!bold, !!underline, !!undercurl, !!strike);
    },

    // void vimwasm_set_font(char *, int);
    vimwasm_set_font: function(font_name, font_size) {
        VW.renderer.setFont(Pointer_stringify(font_name), font_size);
    },

    // void vimwasm_invert_rect(int, int, int, int);
    vimwasm_invert_rect: function(x, y, w, h) {
        VW.renderer.invertRect(x, y, w, h);
    },

    // void vimwasm_image_scroll(int, int, int, int, int);
    vimwasm_image_scroll: function(x, sy, dy, w, h) {
        debug('image_scroll:', x, sy, dy, w, h);
        VW.renderer.imageScroll(x, sy, dy, w, h);
    },
};

autoAddDeps(VimWasmRuntime, '$VW');
mergeInto(LibraryManager.library, VimWasmRuntime);
