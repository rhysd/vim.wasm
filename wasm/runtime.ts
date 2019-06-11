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

const VimWasmLibrary = {
    $VW__postset: 'VW.init()',
    $VW: {
        init() {
            const STATUS_EVENT_NOT_SET = 0;
            const STATUS_EVENT_KEY = 1;
            const STATUS_EVENT_RESIZE = 2;

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

            class VimWasmRuntime implements VimWasmRuntime {
                static runtimeInitialized = false;

                public domWidth: number;
                public domHeight: number;
                private buffer: Int32Array;
                private delayedStart: StartMessageFromMain | null;

                // C function bindings
                private wasmMain: () => void;
                private guiWasmSendKey: (
                    kc1: number,
                    kc2: number,
                    ctrl: number,
                    shift: number,
                    alt: number,
                    meta: number,
                ) => void;
                private guiWasmResizeShell: (w: number, h: number) => void;

                constructor() {
                    onmessage = e => this.onMessage(e.data);
                    this.domWidth = 0;
                    this.domHeight = 0;
                    this.delayedStart = null;
                    Module.onRuntimeInitialized = () => {
                        VimWasmRuntime.runtimeInitialized = true;
                        if (this.delayedStart !== null) {
                            this.start(this.delayedStart);
                        }
                    };
                }

                draw(...event: DrawEventMessage) {
                    this.sendMessage({ kind: 'draw', event });
                }

                vimStarted() {
                    // Setup C functions here since when VW.init() is called, Module.cwrap is not set yet.
                    // TODO: Move cwrap() calls to onRuntimeInitialized hook
                    if (VimWasmRuntime.prototype.guiWasmSendKey === undefined) {
                        VimWasmRuntime.prototype.guiWasmSendKey = Module.cwrap('gui_wasm_send_key', null, [
                            'number', // key code1
                            'number', // key code2 (used for special otherwise 0)
                            'number', // TRUE iff Ctrl key is pressed
                            'number', // TRUE iff Shift key is pressed
                            'number', // TRUE iff Alt key is pressed
                            'number', // TRUE iff Meta key is pressed
                        ]);
                    }
                    if (VimWasmRuntime.prototype.guiWasmResizeShell === undefined) {
                        VimWasmRuntime.prototype.guiWasmResizeShell = Module.cwrap('gui_wasm_resize_shell', null, [
                            'number', // dom_width
                            'number', // dom_height
                        ]);
                    }
                    this.sendMessage({ kind: 'started' });
                }

                vimExit() {
                    this.sendMessage({ kind: 'exit' });
                }

                onMessage(msg: MessageFromMain) {
                    // Print here because debug() is not set before first 'start' message
                    debug('from main:', msg);

                    switch (msg.kind) {
                        case 'start':
                            if (VimWasmRuntime.runtimeInitialized) {
                                this.start(msg);
                            } else {
                                this.delayedStart = msg;
                            }
                            break;
                        default:
                            throw new Error(`Unhandled message from main thread: ${msg}`);
                            break;
                    }
                }

                start(msg: StartMessageFromMain) {
                    this.domWidth = msg.canvasDomWidth;
                    this.domHeight = msg.canvasDomHeight;
                    this.buffer = msg.buffer;
                    if (msg.debug) {
                        debug = console.log;
                    }
                    if (VimWasmRuntime.prototype.wasmMain === undefined) {
                        VimWasmRuntime.prototype.wasmMain = Module.cwrap('wasm_main', null, []);
                    }
                    this.wasmMain();
                }

                waitForEventFromMain(timeout: number | undefined) {
                    const status = Atomics.load(this.buffer, 0);

                    if (status !== STATUS_EVENT_NOT_SET) {
                        // Already some result came. Handle it
                        this.handleEvent(status);
                        // Clear status
                        Atomics.store(this.buffer, 0, STATUS_EVENT_NOT_SET);
                        return;
                    }

                    if (Atomics.wait(this.buffer, 0, STATUS_EVENT_NOT_SET, timeout) === 'timed-out') {
                        // Nothing happened
                        return;
                    }

                    this.handleEvent(Atomics.load(this.buffer, 0));

                    // Clear status
                    Atomics.store(this.buffer, 0, STATUS_EVENT_NOT_SET);
                }

                private handleEvent(status: number) {
                    switch (status) {
                        case STATUS_EVENT_KEY:
                            this.handleKeyEvent();
                            break;
                        case STATUS_EVENT_RESIZE:
                            this.handleResizeEvent();
                            break;
                        default:
                            throw new Error(`Unknown event status ${status}`);
                            break;
                    }
                }

                private handleResizeEvent() {
                    let idx = 1;
                    const width = this.buffer[idx++];
                    const height = this.buffer[idx++];
                    this.domWidth = width;
                    this.domHeight = height;
                    this.guiWasmResizeShell(width, height);
                }

                private handleKeyEvent() {
                    let idx = 1;
                    let keyCode = this.buffer[idx++];
                    const ctrl = !!this.buffer[idx++];
                    const shift = !!this.buffer[idx++];
                    const alt = !!this.buffer[idx++];
                    const meta = !!this.buffer[idx++];

                    let read = this.readStringFromBuffer(idx);
                    idx = read[0];
                    const code = read[1];

                    read = this.readStringFromBuffer(idx);
                    idx = read[0];
                    let key = read[1];

                    debug('Read key event payload with', idx * 4, 'bytes');

                    // TODO: Move the conversion logic (key name -> key code) to C

                    let special: string | null = null;

                    if (key.length > 1) {
                        // Handles special keys. Logic was from gui_mac.c
                        // Key names were from https://www.w3.org/TR/DOM-Level-3-Events-key/
                        if (key in KeyToSpecialCode) {
                            special = KeyToSpecialCode[key];
                        }
                    } else {
                        if (key === '\u00A5' || code === 'IntlYen') {
                            // Note: Yen needs to be fixed to backslash
                            // Note: Also check event.code since Ctrl + yen is recognized as Ctrl + | due to Chrome bug.
                            key = '\\';
                        }

                        // When `key` is one character, get character code from `key`.
                        // KeyboardEvent.charCode is not available on 'keydown'
                        keyCode = key.charCodeAt(0);
                    }

                    let kc1 = keyCode;
                    let kc2 = 0;
                    if (special !== null) {
                        kc1 = special.charCodeAt(0);
                        kc2 = special.charCodeAt(1);
                    }
                    this.guiWasmSendKey(kc1, kc2, +ctrl, +shift, +alt, +meta);
                }

                private readStringFromBuffer(idx: number): [number, string] {
                    const len = this.buffer[idx++];
                    const chars = [];
                    for (let i = 0; i < len; i++) {
                        chars.push(this.buffer[idx++]);
                    }
                    const s = String.fromCharCode(...chars);
                    return [idx, s];
                }

                private sendMessage(msg: MessageFromWorker) {
                    // TODO: This script should be compiled separately with webworker lib
                    (postMessage as any)(msg);
                }
            }
            VW.runtime = new VimWasmRuntime();
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
        VW.runtime.vimStarted(); // TODO
    },

    // void vimwasm_will_exit(int);
    vimwasm_will_exit(_: number) {
        VW.runtime.vimExit();
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
        VW.runtime.draw('setColorFG', [UTF8ToString(name)]);
    },

    // void vimwasm_set_bg_color(char *);
    vimwasm_set_bg_color(name: CharPtr) {
        VW.runtime.draw('setColorBG', [UTF8ToString(name)]);
    },

    // void vimwasm_set_sp_color(char *);
    vimwasm_set_sp_color(name: CharPtr) {
        VW.runtime.draw('setColorSP', [UTF8ToString(name)]);
    },

    // int vimwasm_get_dom_width()
    vimwasm_get_dom_width() {
        debug('get_dom_width:');
        return VW.runtime.domWidth;
    },

    // int vimwasm_get_dom_height()
    vimwasm_get_dom_height() {
        debug('get_dom_height:');
        return VW.runtime.domHeight;
    },

    // void vimwasm_draw_rect(int, int, int, int, char *, int);
    vimwasm_draw_rect(x: number, y: number, w: number, h: number, color: CharPtr, filled: number) {
        VW.runtime.draw('drawRect', [x, y, w, h, UTF8ToString(color), !!filled]);
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
        VW.runtime.draw('drawText', [
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
        VW.runtime.draw('setFont', [UTF8ToString(font_name), font_size]);
    },

    // void vimwasm_invert_rect(int, int, int, int);
    vimwasm_invert_rect(x: number, y: number, w: number, h: number) {
        VW.runtime.draw('invertRect', [x, y, w, h]);
    },

    // void vimwasm_image_scroll(int, int, int, int, int);
    vimwasm_image_scroll(x: number, sy: number, dy: number, w: number, h: number) {
        VW.runtime.draw('imageScroll', [x, sy, dy, w, h]);
    },

    // void vimwasm_wait_for_input(int);
    vimwasm_wait_for_event(timeout: number) {
        VW.runtime.waitForEventFromMain(timeout);
    },
};

autoAddDeps(VimWasmLibrary, '$VW');
mergeInto(LibraryManager.library, VimWasmLibrary);
