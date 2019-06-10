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
 * runtime.ts: TypeScript runtime for Wasm port of Vim by @rhysd.
 */

const VimWasmRuntime = {
    $VW__postset: 'VW.init()',
    $VW: {
        init() {
            class VimWindow {
                elemHeight: number;
                elemWidth: number;
                private readonly canvas: HTMLCanvasElement;
                private bounceTimerToken: number | null;
                private resizeVim: (w: number, h: number) => void;

                constructor(canvas: HTMLCanvasElement) {
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

                onVimInit() {
                    this.resizeVim = Module.cwrap('gui_wasm_resize_shell', null, [
                        'number', // dom_width
                        'number', // dom_height
                    ]);
                    // XXX: Following is also not working
                    // this.resizeVim = function(rows, cols) {
                    //     Module.ccall('gui_wasm_resize_shell', null, ['number', 'number'], [rows, cols], { async: true });
                    // };
                }

                onVimExit() {
                    window.removeEventListener('resize', this.onResize);
                }

                private doResize() {
                    if (this.resizeVim === undefined) {
                        // Depending on timing, this method may be called before initialization
                        return;
                    }
                    const rect = this.canvas.getBoundingClientRect();
                    debug('Resize Vim:', rect);
                    this.elemWidth = rect.width;
                    this.elemHeight = rect.height;
                    this.resizeVim(rect.width, rect.height);
                }

                private onResize() {
                    if (this.bounceTimerToken !== null) {
                        window.clearTimeout(this.bounceTimerToken);
                    }
                    this.bounceTimerToken = window.setTimeout(() => {
                        this.bounceTimerToken = null;
                        this.doResize();
                    }, 1000);
                }
            }

            const KeyToSpecialCode: { [key: string]: string } = {
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
            class VimInput {
                private readonly elem: HTMLInputElement;
                private sendKeyToVim: (
                    kc1: number,
                    kc2: number,
                    ctrl: number,
                    shift: number,
                    alt: number,
                    meta: number,
                ) => void;

                constructor() {
                    this.elem = document.getElementById('vim-input') as HTMLInputElement;
                    // TODO: Bind compositionstart event
                    // TODO: Bind compositionend event
                    this.onKeydown = this.onKeydown.bind(this);
                    this.onBlur = this.onBlur.bind(this);
                    this.onFocus = this.onFocus.bind(this);
                    this.elem.addEventListener('keydown', this.onKeydown);
                    this.elem.addEventListener('blur', this.onBlur);
                    this.elem.addEventListener('focus', this.onFocus);
                    this.focus();
                }

                setFont(name: string, size: number) {
                    this.elem.style.fontFamily = name;
                    this.elem.style.fontSize = size + 'px';
                }

                focus() {
                    this.elem.focus();
                }

                onVimInit() {
                    if (VimInput.prototype.sendKeyToVim === undefined) {
                        // Setup C function here since when VW.init() is called, Module.cwrap is not set yet.
                        //
                        // XXX: Coverting 'boolean' to 'number' does not work if Emterpreter is enabled.
                        // So converting to 'number' from 'boolean' is done in JavaScript.
                        VimInput.prototype.sendKeyToVim = Module.cwrap(
                            'gui_wasm_send_key',
                            null,
                            [
                                'number', // key code1
                                'number', // key code2 (used for special otherwise 0)
                                'number', // TRUE iff Ctrl key is pressed
                                'number', // TRUE iff Shift key is pressed
                                'number', // TRUE iff Alt key is pressed
                                'number', // TRUE iff Meta key is pressed
                            ],
                            {
                                async: true,
                            },
                        );
                        // XXX: Even if {async: true} is set for ccall(), passing strings as char * to C function
                        // does not work with Emterpreter
                    }
                }

                onVimExit() {
                    this.elem.removeEventListener('keydown', this.onKeydown);
                    this.elem.removeEventListener('blur', this.onBlur);
                    this.elem.removeEventListener('focus', this.onFocus);
                }

                private onKeydown(event: KeyboardEvent) {
                    event.preventDefault();
                    event.stopPropagation();
                    debug('onKeydown():', event, event.key, event.charCode, event.keyCode);

                    let charCode = event.keyCode;
                    let special: string | null = null;
                    let key = event.key;

                    // TODO: Move the conversion logic (key name -> key code) to C
                    // Since strings cannot be passed to C function as char * if Emterpreter is enabled.
                    // Setting { async: true } to ccall() does not help to solve this issue.
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
                        if (key === '\u00A5' || event.code === 'IntlYen') {
                            // Note: Yen needs to be fixed to backslash
                            // Note: Also check event.code since Ctrl + yen is recognized as Ctrl + | due to Chrome bug.
                            key = '\\';
                        }

                        // When `key` is one character, get character code from `key`.
                        // KeyboardEvent.charCode is not available on 'keydown'
                        charCode = key.charCodeAt(0);
                    }

                    let kc1 = charCode;
                    let kc2 = 0;
                    if (special !== null) {
                        kc1 = special.charCodeAt(0);
                        kc2 = special.charCodeAt(1);
                    }
                    this.sendKeyToVim(kc1, kc2, +event.ctrlKey, +event.shiftKey, +event.altKey, +event.metaKey);
                }

                private onFocus() {
                    debug('onFocus()');
                    // TODO: Send <FocusGained> special character
                }

                private onBlur(event: Event) {
                    debug('onBlur():', event);
                    event.preventDefault();
                    // TODO: Send <FocusLost> special character
                }
            }

            // Origin is at left-above.
            //
            //      O-------------> x
            //      |
            //      |
            //      |
            //      |
            //      V
            //      y

            class CanvasRenderer implements CanvasRenderer, DrawEventHandler {
                canvas: HTMLCanvasElement;
                ctx: CanvasRenderingContext2D;
                window: VimWindow;
                input: VimInput;
                fgColor: string;
                bgColor: string;
                spColor: string;
                fontName: string;
                queue: DrawEventMessage[];
                rafScheduled: boolean;

                constructor() {
                    this.canvas = document.getElementById('vim-screen') as HTMLCanvasElement;
                    this.ctx = this.canvas.getContext('2d', { alpha: false });
                    this.window = new VimWindow(this.canvas);
                    this.canvas.addEventListener('click', this.onClick.bind(this));
                    this.input = new VimInput();
                    this.onAnimationFrame = this.onAnimationFrame.bind(this);
                    this.queue = [];
                    this.rafScheduled = false;
                }

                onVimInit() {
                    this.input.onVimInit();
                    this.window.onVimInit();
                }

                onVimExit() {
                    this.input.onVimExit();
                    this.window.onVimExit();
                }

                enqueue(msg: DrawEventMessage) {
                    if (!this.rafScheduled) {
                        window.requestAnimationFrame(this.onAnimationFrame);
                        this.rafScheduled = true;
                    }
                    this.queue.push(msg);
                }

                setColorFG(name: string) {
                    this.fgColor = name;
                }

                setColorBG(name: string) {
                    this.bgColor = name;
                }

                setColorSP(name: string) {
                    this.spColor = name;
                }

                setFont(name: string, size: number) {
                    this.fontName = name;
                    this.input.setFont(name, size);
                }

                drawRect(x: number, y: number, w: number, h: number, color: string, filled: boolean) {
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
                }

                drawText(
                    text: string,
                    ch: number,
                    lh: number,
                    cw: number,
                    x: number,
                    y: number,
                    bold: boolean,
                    underline: boolean,
                    undercurl: boolean,
                    strike: boolean,
                ) {
                    const dpr = window.devicePixelRatio || 1;
                    ch = ch * dpr;
                    lh = lh * dpr;
                    cw = cw * dpr;
                    x = x * dpr;
                    y = y * dpr;

                    let font = Math.floor(ch) + 'px ' + this.fontName;
                    if (bold) {
                        font = 'bold ' + font;
                    }

                    this.ctx.font = font;
                    this.ctx.textBaseline = 'ideographic';
                    this.ctx.fillStyle = this.fgColor;

                    const yi = Math.floor(y + lh);
                    for (let i = 0; i < text.length; ++i) {
                        this.ctx.fillText(text[i], Math.floor(x + cw * i), yi);
                    }

                    if (underline) {
                        this.ctx.strokeStyle = this.fgColor;
                        this.ctx.lineWidth = 1 * dpr;
                        this.ctx.setLineDash([]);
                        this.ctx.beginPath();
                        // Note: 3 is set with considering the width of line.
                        // TODO: Calcurate the position of the underline with descent.
                        const underlineY = Math.floor(y + lh - 3 * dpr);
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
                }

                invertRect(x: number, y: number, w: number, h: number) {
                    const dpr = window.devicePixelRatio || 1;
                    x = Math.floor(x * dpr);
                    y = Math.floor(y * dpr);
                    w = Math.floor(w * dpr);
                    h = Math.floor(h * dpr);

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
                    this.ctx.putImageData(img, x, y);
                }

                imageScroll(x: number, sy: number, dy: number, w: number, h: number) {
                    const dpr = window.devicePixelRatio || 1;
                    x = Math.floor(x * dpr);
                    sy = Math.floor(sy * dpr);
                    dy = Math.floor(dy * dpr);
                    w = Math.floor(w * dpr);
                    h = Math.floor(h * dpr);
                    this.ctx.drawImage(this.canvas, x, sy, w, h, x, dy, w, h);
                }

                mouseX() {
                    return 0; // TODO
                }

                mouseY() {
                    return 0; // TODO
                }

                private onClick() {
                    this.input.focus();
                }

                private onAnimationFrame() {
                    debug('Rendering events on animation frame:', this.queue.length);
                    for (const [method, args] of this.queue) {
                        this[method].apply(this, args);
                    }
                    this.queue = [];
                    this.rafScheduled = false;
                }
            }

            class MainThread implements MainThread {
                renderer = new CanvasRenderer();

                draw(...msg: DrawEventMessage) {
                    // TODO: Replace this with postMessage
                    this.renderer.enqueue(msg);
                }

                onVimInit() {
                    this.renderer.onVimInit();
                }

                onVimExit() {
                    this.renderer.onVimExit();
                }
            }
            VW.mainThread = new MainThread();
        },
    },

    /*
     * C bridge
     */

    // int vimwasm_call_shell(char *);
    vimwasm_call_shell(command: CharPtr) {
        const c = UTF8ToString(command);
        debug('call_shell:', c);
        // Shell command may be passed here. Catch the exception
        // eval(c);
    },

    // void vimwasm_will_init(void);
    vimwasm_will_init() {
        VW.mainThread.onVimInit(); // TODO
    },

    // void vimwasm_will_exit(int);
    vimwasm_will_exit(_: number) {
        VW.mainThread.onVimExit();
    },

    // int vimwasm_resize(int, int);
    vimwasm_resize(width: number, height: number) {
        debug('resize:', width, height);
    },

    // int vimwasm_is_font(char *);
    vimwasm_is_font(font_name: CharPtr) {
        font_name = UTF8ToString(font_name);
        debug('is_font:', font_name);
        // TODO: Check the font name is available. Currently font name is fixed to monospace
        return 1;
    },

    // int vimwasm_is_supported_key(char *);
    vimwasm_is_supported_key(key_name: CharPtr) {
        key_name = UTF8ToString(key_name);
        debug('is_supported_key:', key_name);
        // TODO: Check the key is supported in the browser
        return 1;
    },

    // int vimwasm_open_dialog(int, char *, char *, char *, int, char *);
    vimwasm_open_dialog(
        type: CharPtr,
        title: CharPtr,
        message: CharPtr,
        buttons: CharPtr,
        default_button_idx: CharPtr,
        textfield: CharPtr,
    ) {
        title = UTF8ToString(title);
        message = UTF8ToString(message);
        buttons = UTF8ToString(buttons);
        textfield = UTF8ToString(textfield);
        debug('open_dialog:', type, title, message, buttons, default_button_idx, textfield);
        // TODO: Show dialog and return which button was pressed
    },

    // int vimwasm_get_mouse_x();
    vimwasm_get_mouse_x() {
        debug('get_mouse_x:');
        // TODO: Get mouse position. But currently it is hard because mouse position cannot be
        // obtained from worker thread with blocking.
        return 0;
    },

    // int vimwasm_get_mouse_y();
    vimwasm_get_mouse_y() {
        debug('get_mouse_y:');
        // TODO: Get mouse position. But currently it is hard because mouse position cannot be
        // obtained from worker thread with blocking.
        return 0;
    },

    // void vimwasm_set_title(char *);
    vimwasm_set_title(ptr: CharPtr) {
        const title = UTF8ToString(ptr);
        debug('set_title:', title);
        document.title = title;
    },

    // void vimwasm_set_fg_color(char *);
    vimwasm_set_fg_color(name: CharPtr) {
        VW.mainThread.draw('setColorFG', [UTF8ToString(name)]);
    },

    // void vimwasm_set_bg_color(char *);
    vimwasm_set_bg_color(name: CharPtr) {
        VW.mainThread.draw('setColorBG', [UTF8ToString(name)]);
    },

    // void vimwasm_set_sp_color(char *);
    vimwasm_set_sp_color(name: CharPtr) {
        VW.mainThread.draw('setColorSP', [UTF8ToString(name)]);
    },

    // int vimwasm_get_dom_width()
    vimwasm_get_dom_width() {
        debug('get_dom_width:');
        return VW.mainThread.renderer.window.elemWidth; // TODO
    },

    // int vimwasm_get_dom_height()
    vimwasm_get_dom_height() {
        debug('get_dom_height:');
        return VW.mainThread.renderer.window.elemHeight; // TODO
    },

    // void vimwasm_draw_rect(int, int, int, int, char *, int);
    vimwasm_draw_rect(x: number, y: number, w: number, h: number, color: CharPtr, filled: number) {
        VW.mainThread.draw('drawRect', [x, y, w, h, UTF8ToString(color), !!filled]);
    },

    // void vimwasm_draw_text(int, int, int, int, int, char *, int, int, int, int, int);
    vimwasm_draw_text(
        charHeight: number,
        lineHeight: number,
        charWidth: number,
        x: number,
        y: number,
        str: CharPtr,
        len: number,
        bold: number,
        underline: number,
        undercurl: number,
        strike: number,
    ) {
        const text = UTF8ToString(str, len);
        VW.mainThread.draw('drawText', [
            text,
            charHeight,
            lineHeight,
            charWidth,
            x,
            y,
            !!bold,
            !!underline,
            !!undercurl,
            !!strike,
        ]);
    },

    // void vimwasm_set_font(char *, int);
    vimwasm_set_font(font_name: CharPtr, font_size: number) {
        VW.mainThread.draw('setFont', [UTF8ToString(font_name), font_size]);
    },

    // void vimwasm_invert_rect(int, int, int, int);
    vimwasm_invert_rect(x: number, y: number, w: number, h: number) {
        VW.mainThread.draw('invertRect', [x, y, w, h]);
    },

    // void vimwasm_image_scroll(int, int, int, int, int);
    vimwasm_image_scroll(x: number, sy: number, dy: number, w: number, h: number) {
        VW.mainThread.draw('imageScroll', [x, sy, dy, w, h]);
    },
};

autoAddDeps(VimWasmRuntime, '$VW');
mergeInto(LibraryManager.library, VimWasmRuntime);
