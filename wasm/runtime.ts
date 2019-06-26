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
            const STATUS_NOT_SET = 0 as const;
            const STATUS_NOTIFY_KEY = 1 as const;
            const STATUS_NOTIFY_RESIZE = 2 as const;
            const STATUS_REQUEST_OPEN_FILE_BUF = 3 as const;
            const STATUS_EVENT_OPEN_FILE_WRITE_COMPLETE = 4 as const;
            const STATUS_EVENT_REQUEST_CLIPBOARD_BUF = 5 as const;
            const STATUS_EVENT_CLIPBOARD_WRITE_COMPLETE = 6 as const;

            let guiWasmResizeShell: (w: number, h: number) => void;
            let guiWasmHandleKeydown: (
                key: CharPtr,
                keycode: number,
                ctrl: boolean,
                shift: boolean,
                alt: boolean,
                meta: boolean,
            ) => void;
            let guiWasmHandleDrop: (p: string) => void;
            let guiWasmSetClipAvail: (a: boolean) => void;
            let wasmMain: () => void;

            // Setup C function bridges.
            // Since Module.cwrap() and Module.ccall() are set in runtime initialization, it must wait
            // until runtime is initialized.
            emscriptenRuntimeInitialized.then(() => {
                guiWasmResizeShell = Module.cwrap('gui_wasm_resize_shell', null, [
                    'number', // dom_width
                    'number', // dom_height
                ]);
                guiWasmHandleKeydown = Module.cwrap('gui_wasm_handle_keydown', null, [
                    'string', // key
                    'number', // keycode
                    'boolean', // ctrl
                    'boolean', // shift
                    'boolean', // alt
                    'boolean', // meta
                ]);
                guiWasmHandleDrop = Module.cwrap('gui_wasm_handle_drop', null, ['string' /* filepath */]);
                wasmMain = Module.cwrap('wasm_main', null, []);
                guiWasmSetClipAvail = Module.cwrap('gui_wasm_set_clip_avail', null, ['boolean' /* avail */]);
            });

            class VimWasmRuntime implements VimWasmRuntime {
                public domWidth: number;
                public domHeight: number;
                private buffer: Int32Array;
                private perf: boolean;
                private started: boolean;
                private openFileContext: {
                    buffer: SharedArrayBuffer;
                    fileName: string;
                } | null;

                constructor() {
                    onmessage = e => this.onMessage(e.data);
                    this.domWidth = 0;
                    this.domHeight = 0;
                    this.openFileContext = null;
                    this.perf = false;
                    this.started = false;
                }

                draw(...event: DrawEventMessage) {
                    this.sendMessage({ kind: 'draw', event });
                }

                vimStarted() {
                    this.sendMessage({ kind: 'started' });
                }

                vimExit(status: number) {
                    this.sendMessage({ kind: 'exit', status });
                }

                onMessage(msg: StartMessageFromMain) {
                    // Print here because debug() is not set before first 'start' message
                    debug('From main:', msg);

                    switch (msg.kind) {
                        case 'start':
                            emscriptenRuntimeInitialized
                                .then(() => this.start(msg))
                                .catch(e => {
                                    switch (e.name) {
                                        case 'ExitStatus':
                                            debug('Program terminated with status', e.status);
                                            break;
                                        default:
                                            this.sendMessage({
                                                kind: 'error',
                                                message: e.message,
                                            });
                                            break;
                                    }
                                });
                            break;
                        default:
                            throw new Error(`Unhandled message from main thread: ${msg}`);
                    }
                }

                start(msg: StartMessageFromMain) {
                    if (this.started) {
                        throw new Error('Vim cannot start because it is already running');
                    }
                    this.domWidth = msg.canvasDomWidth;
                    this.domHeight = msg.canvasDomHeight;
                    this.buffer = msg.buffer;
                    if (msg.debug) {
                        debug = console.log.bind(console, 'worker:'); // eslint-disable-line no-console
                    }
                    this.perf = msg.perf;
                    if (!msg.clipboard) {
                        guiWasmSetClipAvail(false);
                    }
                    wasmMain();
                    this.started = true;
                }

                waitAndHandleEventFromMain(timeout: number | undefined): number {
                    // Note: Should we use performance.now()?
                    const start = Date.now();
                    const status = this.waitForStatusChanged(timeout);
                    let elapsed = 0;

                    if (status === STATUS_NOT_SET) {
                        elapsed = Date.now() - start;
                        debug('No event happened after', timeout, 'ms timeout. Elapsed:', elapsed);
                        return elapsed;
                    }

                    this.handleEvent(status);

                    elapsed = Date.now() - start;
                    debug('Event', status, 'was handled with ms', elapsed);
                    return elapsed;
                }

                exportFile(fullpath: string) {
                    const contents = FS.readFile(fullpath).buffer; // encoding = binary
                    debug('Read', contents.byteLength, 'bytes contents from', fullpath);
                    this.sendMessage({ kind: 'export', path: fullpath, contents }, [contents]);
                    return 1;
                }

                readClipboard(): CharPtr {
                    this.sendMessage({ kind: 'read-clipboard:request' });

                    this.waitUntilStatus(STATUS_EVENT_REQUEST_CLIPBOARD_BUF);

                    // Read data and clear status
                    const isError = !!this.buffer[1];
                    if (isError) {
                        guiWasmSetClipAvail(false);
                        return 0; // NULL
                    }
                    const bytesLen = this.buffer[2];
                    Atomics.store(this.buffer, 0, STATUS_NOT_SET);

                    const clipboardBuf = new SharedArrayBuffer(bytesLen + 1);

                    this.sendMessage({
                        kind: 'clipboard-buf:response',
                        buffer: clipboardBuf,
                    });

                    this.waitUntilStatus(STATUS_EVENT_CLIPBOARD_WRITE_COMPLETE);
                    Atomics.store(this.buffer, 0, STATUS_NOT_SET);

                    const clipboardArr = new Uint8Array(clipboardBuf);
                    clipboardArr[bytesLen] = 0; // Write '\0'

                    const ptr = Module._malloc(clipboardArr.byteLength);
                    if (ptr === 0) {
                        return 0; // NULL
                    }
                    Module.HEAPU8.set(clipboardArr, ptr as number);

                    debug('Malloced', clipboardArr.byteLength, 'bytes and wrote clipboard text');

                    return ptr;
                }

                writeClipboard(text: string) {
                    debug('Send clipboard text:', text);
                    this.sendMessage({
                        kind: 'write-clipboard',
                        text,
                    });
                }

                private waitUntilStatus(status: EventStatusFromMain) {
                    while (true) {
                        const s = this.waitForStatusChanged(undefined);
                        if (s === status) {
                            return;
                        }
                        if (s === STATUS_NOT_SET) {
                            // Note: Should be unreachable
                            continue;
                        }

                        this.handleEvent(s);

                        debug('Event', s, 'was handled in waitUntilStatus()', status);
                    }
                }

                // Note: You MUST clear the status byte after hanlde the event
                private waitForStatusChanged(timeout: number | undefined): EventStatusFromMain {
                    debug('Waiting for event from main with timeout', timeout);

                    const status = this.eventStatus();
                    if (status !== STATUS_NOT_SET) {
                        // Already some result came
                        return status;
                    }

                    if (Atomics.wait(this.buffer, 0, STATUS_NOT_SET, timeout) === 'timed-out') {
                        // Nothing happened
                        debug('No event happened after', timeout, 'ms timeout');
                        return STATUS_NOT_SET;
                    }

                    // Status was changed. Load it.
                    return this.eventStatus();
                }

                private eventStatus() {
                    return Atomics.load(this.buffer, 0) as EventStatusFromMain;
                }

                private handleEvent(status: EventStatusFromMain) {
                    switch (status) {
                        case STATUS_NOTIFY_KEY:
                            this.handleKeyEvent();
                            break;
                        case STATUS_NOTIFY_RESIZE:
                            this.handleResizeEvent();
                            break;
                        case STATUS_REQUEST_OPEN_FILE_BUF:
                            this.handleOpenFileRequest();
                            break;
                        case STATUS_EVENT_OPEN_FILE_WRITE_COMPLETE:
                            this.handleOpenFileWriteComplete();
                            break;
                        default:
                            throw new Error(`Unknown event status ${status}`);
                    }
                    // Clear status
                    Atomics.store(this.buffer, 0, STATUS_NOT_SET);
                }

                private handleOpenFileRequest() {
                    const fileSize = this.buffer[1];
                    const [idx, fileName] = this.decodeStringFromBuffer(2);

                    debug('Read open file request event payload with', idx * 4, 'bytes');

                    const buffer = new SharedArrayBuffer(fileSize);
                    this.sendMessage({
                        kind: 'open-file-buf:response',
                        name: fileName,
                        buffer,
                    });
                    this.openFileContext = { fileName, buffer };
                }

                private handleOpenFileWriteComplete() {
                    if (this.openFileContext === null) {
                        throw new Error('Received FILE_WRITE_COMPLETE event but context does not exist');
                    }
                    const { fileName, buffer } = this.openFileContext;

                    debug(
                        'Handle file',
                        fileName,
                        'open with',
                        buffer.byteLength,
                        'bytes buffer on file write complete event',
                    );

                    const filePath = '/' + fileName;
                    FS.writeFile(filePath, new Uint8Array(buffer));
                    debug('Created file', filePath, 'on in-memory filesystem');

                    guiWasmHandleDrop(filePath);

                    this.openFileContext = null;
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

                    const read = this.decodeStringFromBuffer(idx);
                    idx = read[0];
                    const key = read[1];

                    debug('Read key event payload with', idx * 4, 'bytes');

                    // TODO: Passing string to C causes extra memory allocation to convert JavaScript
                    // string to UTF-8 byte sequence. It can be avoided by writing string in this.buffer
                    // to Wasm memory (Module.HEAPU8) directly with Module._malloc().
                    // Though it must be clarified whether this overhead should be removed.
                    guiWasmHandleKeydown(key, keyCode, ctrl, shift, alt, meta);

                    debug('Key event was handled', key, keyCode, ctrl, shift, alt, meta);
                }

                private decodeStringFromBuffer(idx: number): [number, string] {
                    const len = this.buffer[idx++];
                    const chars = [];
                    for (let i = 0; i < len; i++) {
                        chars.push(this.buffer[idx++]);
                    }
                    const s = String.fromCharCode(...chars);
                    return [idx, s];
                }

                private sendMessage(msg: MessageFromWorker, transfer?: ArrayBuffer[]) {
                    if (this.perf) {
                        // performance.now() is not available because time origin is different between
                        // Window and Worker
                        msg.timestamp = Date.now();
                    }
                    postMessage(msg, transfer as any);
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
    vimwasm_will_exit(status: number) {
        VW.runtime.vimExit(status);
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
        debug('set_title: TODO:', title);
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
        debug('get_dom_width:', VW.runtime.domWidth);
        return VW.runtime.domWidth;
    },

    // int vimwasm_get_dom_height()
    vimwasm_get_dom_height() {
        debug('get_dom_height:', VW.runtime.domHeight);
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
        return VW.runtime.waitAndHandleEventFromMain(timeout > 0 ? timeout : undefined);
    },

    // int vimwasm_export_file(char *);
    vimwasm_export_file(fullpath: CharPtr) {
        return VW.runtime.exportFile(UTF8ToString(fullpath));
    },

    // char *vimwasm_read_clipboard();
    vimwasm_read_clipboard() {
        return VW.runtime.readClipboard();
    },

    // void vimwasm_write_clipboard(char *);
    vimwasm_write_clipboard(textPtr: CharPtr, size: number) {
        const text = UTF8ToString(textPtr, size);
        VW.runtime.writeClipboard(text);
    },
};

autoAddDeps(VimWasmLibrary, '$VW');
mergeInto(LibraryManager.library, VimWasmLibrary);
