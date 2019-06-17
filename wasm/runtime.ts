/* vi:set ts=4 sts=4 sw=4 et:
 *
 * VIM - Vi IMproved		by Bram Moolenaar
 *				Wasm support by rhysd <https://github.com/rhysd>
 *
 * Do ":help uganda"  in Vim to read copying and usage conditions.
 * Do ":help credits" in Vim to see a list of people who contributed.
 * See README.txt for an overview of the Vim source code.
 */

/*
 * runtime.ts: TypeScript worker thread runtime for Wasm port of Vim by @rhysd.
 */

const VimWasmLibrary = {
    $VW__postset: 'VW.init()',
    $VW: {
        init() {
            const STATUS_EVENT_NOT_SET = 0;
            const STATUS_EVENT_KEY = 1;
            const STATUS_EVENT_RESIZE = 2;

            let guiWasmResizeShell: (w: number, h: number) => void;
            let guiWasmHandleKeydown: (
                key: CharPtr,
                keycode: number,
                ctrl: boolean,
                shift: boolean,
                alt: boolean,
                meta: boolean,
            ) => void;

            // Setup C function bridges.
            // Since Module.cwrap() and Module.ccall() are set in runtime initialization, it must wait
            // until runtime is initialized.
            emscriptenRuntimeInitialized.then(() => {
                guiWasmResizeShell = Module.cwrap('gui_wasm_resize_shell', null, [
                    'number', // dom_width
                    'number', // dom_height
                ]);
                guiWasmHandleKeydown = Module.cwrap('gui_wasm_handle_keydown', null, [
                    'string', // key (char *)
                    'number', // keycode (int)
                    'boolean', // ctrl (bool)
                    'boolean', // shift (bool)
                    'boolean', // alt (bool)
                    'boolean', // meta (bool)
                ]);
            });

            class VimWasmRuntime implements VimWasmRuntime {
                public domWidth: number;
                public domHeight: number;
                private buffer: Int32Array;

                // C function bindings
                private wasmMain: () => void;

                constructor() {
                    onmessage = e => this.onMessage(e.data);
                    this.domWidth = 0;
                    this.domHeight = 0;
                }

                draw(...event: DrawEventMessage) {
                    this.sendMessage({ kind: 'draw', event });
                }

                vimStarted() {
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
                            emscriptenRuntimeInitialized.then(() => this.start(msg));
                            break;
                        default:
                            throw new Error(`Unhandled message from main thread: ${msg}`);
                    }
                }

                start(msg: StartMessageFromMain) {
                    this.domWidth = msg.canvasDomWidth;
                    this.domHeight = msg.canvasDomHeight;
                    this.buffer = msg.buffer;
                    if (msg.debug) {
                        debug = console.log; // eslint-disable-line no-console
                    }
                    if (VimWasmRuntime.prototype.wasmMain === undefined) {
                        VimWasmRuntime.prototype.wasmMain = Module.cwrap('wasm_main', null, []);
                    }
                    this.wasmMain();
                }

                waitForEventFromMain(timeout: number | undefined): number {
                    debug('Waiting for event from main with timeout', timeout);

                    const start = Date.now();
                    const status = Atomics.load(this.buffer, 0);

                    if (status !== STATUS_EVENT_NOT_SET) {
                        // Already some result came. Handle it
                        this.handleEvent(status);
                        // Clear status
                        Atomics.store(this.buffer, 0, STATUS_EVENT_NOT_SET);
                        const elapsed = Date.now() - start;
                        debug('Immediately event was handled with ms', elapsed);
                        return elapsed;
                    }

                    if (Atomics.wait(this.buffer, 0, STATUS_EVENT_NOT_SET, timeout) === 'timed-out') {
                        // Nothing happened
                        const elapsed = Date.now() - start;
                        debug('No event happened after', timeout, 'ms timeout. Elapsed:', elapsed);
                        return elapsed;
                    }

                    this.handleEvent(Atomics.load(this.buffer, 0));

                    // Clear status
                    Atomics.store(this.buffer, 0, STATUS_EVENT_NOT_SET);

                    // Avoid shadowing `elapsed`
                    {
                        const elapsed = Date.now() - start;
                        debug('After Atomics.wait() event was handled with ms', elapsed);
                        return elapsed;
                    }
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
                    }
                }

                private handleResizeEvent() {
                    let idx = 1;
                    const width = this.buffer[idx++];
                    const height = this.buffer[idx++];
                    this.domWidth = width;
                    this.domHeight = height;
                    guiWasmResizeShell(width, height);
                    debug('Resize event was handled', width, height);
                }

                private handleKeyEvent() {
                    let idx = 1;
                    const keyCode = this.buffer[idx++];
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

                    if (key === '\u00A5' || code === 'IntlYen') {
                        // Note: Yen needs to be fixed to backslash
                        // Note: Also check event.code since Ctrl + yen is recognized as Ctrl + | due to Chrome bug.
                        // https://bugs.chromium.org/p/chromium/issues/detail?id=871650
                        key = '\\';
                    }
                    debug('Read key event payload with', idx * 4, 'bytes');

                    guiWasmHandleKeydown(key, keyCode, ctrl, shift, alt, meta);

                    debug('Key event was handled', key, code, keyCode, ctrl, shift, alt, meta);
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
                    postMessage(msg);
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
        debug('TODO: set_title:', title);
        // TODO: Send title to main thread and set document.title
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

    // int vimwasm_wait_for_input(int);
    vimwasm_wait_for_event(timeout: number): number {
        return VW.runtime.waitForEventFromMain(timeout > 0 ? timeout : undefined);
    },
};

autoAddDeps(VimWasmLibrary, '$VW');
mergeInto(LibraryManager.library, VimWasmLibrary);
