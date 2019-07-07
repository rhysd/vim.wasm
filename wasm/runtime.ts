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

declare interface VimWasmRuntime {
    domWidth: number;
    domHeight: number;

    draw(...msg: DrawEventMessage): void;
    vimStarted(): void;
    waitAndHandleEventFromMain(timeout: number | undefined): number;
    exportFile(fullpath: string): boolean;
    readClipboard(): CharPtr;
    writeClipboard(text: string): void;
}
declare const VW: {
    runtime: VimWasmRuntime;
};

type PerfMark = 'idbfs-init' | 'idbfs-fin';

const VimWasmLibrary = {
    $VW__postset: 'VW.init()',
    $VW: {
        init() {
            const STATUS_NOT_SET = 0 as const;
            const STATUS_NOTIFY_KEY = 1 as const;
            const STATUS_NOTIFY_RESIZE = 2 as const;
            const STATUS_REQUEST_OPEN_FILE_BUF = 3 as const;
            const STATUS_NOTIFY_OPEN_FILE_BUF_COMPLETE = 4 as const;
            const STATUS_REQUEST_CLIPBOARD_BUF = 5 as const;
            const STATUS_NOTIFY_CLIPBOARD_WRITE_COMPLETE = 6 as const;
            const STATUS_REQUEST_CMDLINE = 7 as const;

            function statusName(s: EventStatusFromMain): string {
                switch (s) {
                    case STATUS_NOT_SET:
                        return 'NOT_SET';
                    case STATUS_NOTIFY_KEY:
                        return 'NOTIFY_KEY';
                    case STATUS_NOTIFY_RESIZE:
                        return 'NOTIFY_RESIZE';
                    case STATUS_REQUEST_OPEN_FILE_BUF:
                        return 'REQUEST_OPEN_FILE_BUF';
                    case STATUS_NOTIFY_OPEN_FILE_BUF_COMPLETE:
                        return 'NOTIFY_OPEN_FILE_BUF_COMPLETE';
                    case STATUS_REQUEST_CLIPBOARD_BUF:
                        return 'REQUEST_CLIPBOARD_BUF';
                    case STATUS_NOTIFY_CLIPBOARD_WRITE_COMPLETE:
                        return 'NOTIFY_CLIPBOARD_WRITE_COMPLETE';
                    case STATUS_REQUEST_CMDLINE:
                        return 'REQUEST_CMDLINE';
                    default:
                        return `Unknown command: ${s}`;
                }
            }

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
            let guiWasmDoCmdline: (c: string) => boolean;
            let wasmMain: (c: number, v: number) => void;

            // Setup C function bridges.
            // Since Module.cwrap() and Module.ccall() are set in runtime initialization, it must wait
            // until runtime is initialized.
            emscriptenRuntimeInitialized.then(() => {
                guiWasmResizeShell = Module.cwrap('gui_wasm_resize_shell', null, [
                    'number', // int dom_width
                    'number', // int dom_height
                ]);
                guiWasmHandleKeydown = Module.cwrap('gui_wasm_handle_keydown', null, [
                    'string', // key
                    'number', // int keycode
                    'boolean', // ctrl
                    'boolean', // shift
                    'boolean', // alt
                    'boolean', // meta
                ]);
                guiWasmHandleDrop = Module.cwrap('gui_wasm_handle_drop', null, ['string' /* filepath */]);
                guiWasmSetClipAvail = Module.cwrap('gui_wasm_set_clip_avail', null, ['boolean' /* avail */]);
                guiWasmDoCmdline = Module.cwrap('gui_wasm_do_cmdline', 'boolean', ['string' /* cmdline */]);
                wasmMain = Module.cwrap('wasm_main', null, [
                    'number', // int argc
                    'number', // char **argv
                ]);
            });

            class VimWasmRuntime implements VimWasmRuntime {
                public domWidth: number;
                public domHeight: number;
                private buffer: Int32Array;
                private perf: boolean;
                private syncfsOnExit: boolean;
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
                    this.syncfsOnExit = false;
                    this.started = false;
                }

                draw(...event: DrawEventMessage) {
                    this.sendMessage({ kind: 'draw', event });
                }

                vimStarted() {
                    this.sendMessage({ kind: 'started' });
                }

                onMessage(msg: StartMessageFromMain) {
                    // Print here because debug() is not set before first 'start' message
                    debug('Received from main:', msg);

                    switch (msg.kind) {
                        case 'start':
                            emscriptenRuntimeInitialized
                                .then(() => this.start(msg))
                                .catch(e => {
                                    switch (e.name) {
                                        case 'ExitStatus':
                                            debug('Vim exited with status', e.status);
                                            // Terminate self since Vim completely exited
                                            this.shutdownFileSystem()
                                                .catch(err => {
                                                    // Error but not critical. Only output error log
                                                    console.error('worker: Could not shutdown filesystem:', err); // eslint-disable-line no-console
                                                })
                                                .then(() => {
                                                    this.printPerfs();
                                                    debug('Finally sending exit message', e.status);
                                                    this.sendMessage({
                                                        kind: 'exit',
                                                        status: e.status,
                                                    });
                                                });
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

                start(msg: StartMessageFromMain): Promise<void> {
                    if (this.started) {
                        throw new Error('Vim cannot start because it is already running');
                    }

                    if (msg.debug) {
                        debug = console.log.bind(console, 'worker:'); // eslint-disable-line no-console
                    }
                    this.domWidth = msg.canvasDomWidth;
                    this.domHeight = msg.canvasDomHeight;
                    this.buffer = msg.buffer;
                    this.perf = msg.perf;

                    const willPrepare = this.prepareFileSystem(msg.persistent, msg.dirs, msg.files);

                    if (!msg.clipboard) {
                        guiWasmSetClipAvail(false);
                    }

                    return willPrepare.then(() => this.main(msg.cmdArgs));
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
                    debug('Event', statusName(status), status, 'was handled with ms', elapsed);
                    return elapsed;
                }

                exportFile(fullpath: string): boolean {
                    try {
                        const contents = FS.readFile(fullpath).buffer; // encoding = binary
                        debug('Read', contents.byteLength, 'bytes contents from', fullpath);
                        this.sendMessage({ kind: 'export', path: fullpath, contents }, [contents]);
                        return true;
                    } catch (err) {
                        debug('Could not export file', fullpath, 'due to error:', err);
                        return false;
                    }
                }

                readClipboard(): CharPtr {
                    this.sendMessage({ kind: 'read-clipboard:request' });

                    this.waitUntilStatus(STATUS_REQUEST_CLIPBOARD_BUF);

                    // Read data and clear status
                    const isError = !!this.buffer[1];
                    if (isError) {
                        Atomics.store(this.buffer, 0, STATUS_NOT_SET);
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

                    this.waitUntilStatus(STATUS_NOTIFY_CLIPBOARD_WRITE_COMPLETE);
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

                private main(args: string[]) {
                    this.started = true;
                    debug('Start main function() with args', args);

                    if (args.length === 0) {
                        wasmMain(0, 0 /*NULL*/);
                        return;
                    }

                    // First elment of argv is the program name "vim"
                    args.unshift('vim');

                    // Note: `+ 1` for last NULL
                    const argvBuf = new Uint32Array(args.length + 1); // char **

                    // Buffer to allocate all argument strings
                    const argsPtr = Module._malloc(args.reduce((acc, a) => acc + a.length * 4 + 1, 0));

                    // Allocate argument strings as UTF-8 strings
                    for (let i = 0, offset = 0; i < args.length; i++) {
                        const arg = args[i];
                        const bytes = arg.length * 4;
                        const ptr = ((argsPtr as number) + offset) as CharPtr;
                        stringToUTF8(arg, ptr, bytes);
                        offset += bytes + 1; // `+ 1` for NULL terminated string
                    }

                    // argv must be NULL terminated
                    argvBuf[args.length] = 0; // NULL

                    const argvPtr = Module._malloc(argvBuf.byteLength);
                    Module.HEAPU8.set(new Uint8Array(argvBuf.buffer), argvPtr as number);

                    wasmMain(args.length, argvPtr as number);

                    // Note: These allocated memories will never be free()ed because they should be alive
                    // until wasm_main() returns. Currently it's OK because this worker is for one-shot Vim
                    // process execution.
                }

                private prepareFileSystem(
                    persistentDirs: string[],
                    mkdirs: string[],
                    userFiles: { [fpath: string]: string },
                ): Promise<void> {
                    const dotvim = '/home/web_user/.vim';
                    const vimrc =
                        '" Write your favorite config!\n\nset backspace=indent,eol,start\ncolorscheme desert\n';
                    const files = {
                        [dotvim + '/vimrc']: vimrc,
                    };
                    Object.assign(files, userFiles);

                    FS.mkdir(dotvim);

                    for (const dir of mkdirs) {
                        FS.mkdir(dir);
                    }
                    debug('Created directories:', mkdirs);

                    if (persistentDirs.length === 0) {
                        for (const fpath of Object.keys(files)) {
                            FS.writeFile(fpath, files[fpath]);
                        }
                        debug('Created files on MEMFS', files);
                        return Promise.resolve();
                    }

                    this.perfMark('idbfs-init');
                    for (const dir of persistentDirs) {
                        FS.mount(IDBFS, {}, dir);
                    }
                    this.syncfsOnExit = true;

                    return new Promise<void>((resolve, reject) => {
                        FS.syncfs(true, err => {
                            if (err) {
                                reject(err);
                                return;
                            }
                            debug('Mounted persistent IDBFS:', persistentDirs);

                            for (const fpath of Object.keys(files)) {
                                try {
                                    FS.writeFile(fpath, files[fpath], { flags: 'wx+' });
                                } catch (e) {
                                    debug('File could not create file:', fpath, e);
                                }
                            }
                            debug('Created files on IDBFS or MEMFS:', files);

                            this.perfMeasure('idbfs-init');
                            resolve();
                        });
                    });
                }

                private shutdownFileSystem(): Promise<void> {
                    if (!this.syncfsOnExit) {
                        debug('syncfs() was skipped because of no persistent directory');
                        return Promise.resolve();
                    }

                    return new Promise<void>((resolve, reject) => {
                        this.perfMark('idbfs-fin');
                        FS.syncfs(false, err => {
                            if (err) {
                                debug('Could not save persistent directories:', err);
                                reject(err);
                                return;
                            }

                            debug('Synchronized IDBFS for persistent directories');
                            resolve();
                            this.perfMeasure('idbfs-fin');
                        });
                    });
                }

                private waitUntilStatus(status: EventStatusFromMain) {
                    const event = statusName(status);
                    while (true) {
                        const s = this.waitForStatusChanged(undefined);
                        if (s === status) {
                            debug('Wait completed for', event, status);
                            return;
                        }

                        if (s === STATUS_NOT_SET) {
                            // Note: Should be unreachable
                            continue;
                        }

                        this.handleEvent(s);

                        debug('Event', statusName(s), s, 'was handled while waiting for', event, status);
                    }
                }

                // Note: You MUST clear the status byte after hanlde the event
                private waitForStatusChanged(timeout: number | undefined): EventStatusFromMain {
                    debug('Waiting for any event from main with timeout', timeout);

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

                private handleEvent(s: EventStatusFromMain) {
                    switch (s) {
                        case STATUS_NOTIFY_KEY:
                            this.handleKeyEvent();
                            return;
                        case STATUS_NOTIFY_RESIZE:
                            this.handleResizeEvent();
                            return;
                        case STATUS_REQUEST_OPEN_FILE_BUF:
                            this.handleOpenFileRequest();
                            return;
                        case STATUS_NOTIFY_OPEN_FILE_BUF_COMPLETE:
                            this.handleOpenFileWriteComplete();
                            return;
                        case STATUS_REQUEST_CMDLINE:
                            this.handleRunCommand();
                            return;
                        default:
                            throw new Error(`Cannot handle event ${statusName(s)} (${s})`);
                    }
                }

                private handleRunCommand() {
                    const [idx, cmdline] = this.decodeStringFromBuffer(1);
                    // Note: Status must be cleared here because guiWasmDoCmdline() may cause additional inter
                    // threads communication.
                    Atomics.store(this.buffer, 0, STATUS_NOT_SET);

                    debug('Read cmdline request payload with', idx * 4, 'bytes');

                    const success = guiWasmDoCmdline(cmdline);
                    this.sendMessage({ kind: 'cmdline:response', success });
                }

                private handleOpenFileRequest() {
                    const fileSize = this.buffer[1];
                    const [idx, fileName] = this.decodeStringFromBuffer(2);
                    Atomics.store(this.buffer, 0, STATUS_NOT_SET);

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
                    Atomics.store(this.buffer, 0, STATUS_NOT_SET);

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
                    Atomics.store(this.buffer, 0, STATUS_NOT_SET);

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

                    Atomics.store(this.buffer, 0, STATUS_NOT_SET);

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

                private perfMark(m: PerfMark) {
                    if (this.perf) {
                        performance.mark(m);
                    }
                }

                private perfMeasure(m: PerfMark) {
                    if (this.perf) {
                        performance.measure(m, m);
                        performance.clearMarks(m);
                    }
                }

                private printPerfs() {
                    if (!this.perf) {
                        return;
                    }

                    const entries = performance.getEntriesByType('measure').map(e => ({
                        name: e.name,
                        'duration (ms)': e.duration,
                        'start (ms)': e.startTime,
                    }));

                    /* eslint-disable no-console */
                    console.log('%cWorker Measurements', 'color: green; font-size: large');
                    console.table(entries);
                    /* eslint-enable no-console */
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
        VW.runtime.vimStarted();
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

    // void vimwasm_set_font(char const*, int);
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
        return +VW.runtime.exportFile(UTF8ToString(fullpath));
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
