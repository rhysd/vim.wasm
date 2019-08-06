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

    start(): void;
    draw(...msg: DrawEventMessage): void;
    vimStarted(): void;
    exportFile(fullpath: string): boolean;
    writeClipboard(text: string): void;
    setTitle(title: string): void;
    evalJavaScriptFile(file: string): number;
    sendError(err: Error): void;
    handleNextEvent(timeout: number | undefined): Promise<number>;
    readClipboard(): Promise<CharPtr>;
    evalJavaScriptFunc(func: string, argsJson: string | undefined, notifyOnly: boolean): Promise<CharPtr>;
}
declare const VW: {
    runtime: VimWasmRuntime;
};

type PerfMark = 'idbfs-init' | 'idbfs-fin';

const VimWasmLibrary = {
    $VW__postset: 'VW.init()', // eslint-disable-line @typescript-eslint/camelcase
    $VW: {
        init() {
            const NULL = 0 as CharPtr;

            function after(ms: number) {
                return new Promise<null>(resolve => setTimeout(() => resolve(null), ms));
            }

            let guiWasmResizeShell: (w: number, h: number) => void;
            let guiWasmHandleKeydown: (
                key: string,
                keycode: number,
                ctrl: boolean,
                shift: boolean,
                alt: boolean,
                meta: boolean,
            ) => void;
            let guiWasmHandleDrop: (p: string) => void;
            let guiWasmSetClipAvail: (a: boolean) => void;
            let guiWasmDoCmdline: (c: string) => boolean;
            let guiWasmEmsg: (m: string) => void;
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
                guiWasmEmsg = Module.cwrap('gui_wasm_emsg', null, ['string' /* msg */]);
                wasmMain = Module.cwrap('wasm_main', null, [
                    'number', // int argc
                    'number', // char **argv
                ]);
            });

            class VimWasmRuntime implements VimWasmRuntime {
                public domWidth: number;
                public domHeight: number;
                private perf: boolean;
                private syncfsOnExit: boolean;
                private started: boolean;
                private resolveMessage?: (msg: MessageFromMain) => void;

                constructor() {
                    onmessage = e => this.onMessage(e.data);
                    this.domWidth = 0;
                    this.domHeight = 0;
                    this.perf = false;
                    this.syncfsOnExit = false;
                    this.started = false;
                    this.sendError = this.sendError.bind(this);
                }

                draw(...event: DrawEventMessage) {
                    this.sendMessage({ kind: 'draw', event });
                }

                vimStarted() {
                    this.sendMessage({ kind: 'started' });
                }

                sendError(err: Error) {
                    this.sendMessage({
                        kind: 'error',
                        message: err.message || err.toString(),
                    });
                    debug('Error was thrown in worker:', err);
                }

                onMessage(msg: MessageFromMain) {
                    // Print here because debug() is not set before first 'start' message
                    debug('Received from main:', msg);

                    if (this.resolveMessage === undefined) {
                        throw new Error(`Received ${msg.kind} message but no receiver is set: ${msg}`);
                    }

                    this.resolveMessage(msg);
                    this.resolveMessage = undefined;
                }

                awaitNextMessage(): Promise<MessageFromMain> {
                    return new Promise<MessageFromMain>(resolve => {
                        // Note: Here it cannot assert this.resolveMessage !== undefined.
                        // because this promise may not be settled when awaiting the next message
                        // with timeout and exceeding the timeout.
                        this.resolveMessage = resolve;
                    });
                }

                beforeStart(msg: StartMessageFromMain): Promise<void> {
                    if (this.started) {
                        throw new Error('Vim cannot start because it is already running');
                    }

                    if (msg.debug) {
                        debug = console.log.bind(console, 'worker:'); // eslint-disable-line no-console
                    }

                    debug('Received start message:', msg);

                    this.domWidth = msg.canvasDomWidth;
                    this.domHeight = msg.canvasDomHeight;
                    this.perf = msg.perf;

                    const willPrepare = this.prepareFileSystem(msg.persistent, msg.dirs, msg.files, msg.fetchFiles);

                    if (!msg.clipboard) {
                        guiWasmSetClipAvail(false);
                    }

                    return willPrepare;
                }

                start() {
                    Promise.all([emscriptenRuntimeInitialized, this.awaitNextMessage()])
                        .then(([_, msg]) => {
                            if (msg.kind !== 'start') {
                                throw new Error(`FATAL: First message from main is not 'start': ${msg}`);
                            }
                            return this.beforeStart(msg).then(() => this.main(msg.cmdArgs));
                        })
                        .catch(e => {
                            if (e.name !== 'ExitStatus') {
                                this.sendError(e);
                                return;
                            }

                            debug('Shutting down after Vim exited with status', e.status);

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
                                })
                                .catch(this.sendError);
                        });
                }

                handleNextEvent(timeout: number | undefined): Promise<number> {
                    const start = Date.now();
                    let p: Promise<MessageFromMain | null> = this.awaitNextMessage();
                    if (timeout !== undefined) {
                        p = Promise.race([after(timeout), p]);
                    }

                    return p.then(msg => {
                        let elapsed = 0;

                        if (msg === null) {
                            elapsed = Date.now() - start;
                            debug('No event happened after', timeout, 'ms timeout. Elapsed:', elapsed);
                            return elapsed;
                        }

                        debug('Received event from main:', msg);

                        this.handleEvent(msg);

                        elapsed = Date.now() - start;
                        debug('Event', msg.kind, 'was handled with ms', elapsed, msg);
                        return elapsed;
                    });
                }

                private handleEventsUntil(kind: MessageKindFromMain): Promise<MessageFromMain> {
                    return this.awaitNextMessage().then(msg => {
                        if (msg.kind === kind) {
                            return msg;
                        }
                        this.handleEvent(msg);
                        debug('While awaiting for', kind, 'other event handled', msg);

                        // Loop until target message arrives handling other events
                        return this.handleEventsUntil(kind);
                    });
                }

                private handleEvent(m: MessageFromMain) {
                    // Note: Following events are not handled here
                    //   - read-clipboard:response
                    //   - evalfunc:response
                    switch (m.kind) {
                        case 'key':
                            guiWasmHandleKeydown(m.key, m.keyCode, m.ctrl, m.shift, m.alt, m.meta);
                            break;
                        case 'resize':
                            this.domWidth = m.width;
                            this.domHeight = m.height;
                            guiWasmResizeShell(m.width, m.height);
                            break;
                        case 'open-file': {
                            const fpath = '/' + m.filename;
                            FS.writeFile(fpath, new Uint8Array(m.contents));
                            guiWasmHandleDrop(fpath);
                            debug('Created file', fpath, m.contents.byteLength, 'bytes on filesystem');
                            break;
                        }
                        case 'cmdline': {
                            const success = guiWasmDoCmdline(m.cmdline);
                            this.sendMessage({ kind: 'cmdline:response', success });
                            debug('Result of cmdline', m.cmdline, ': success:', success);
                            break;
                        }
                        case 'emsg': {
                            const output = `E9999: ${m.message}`;
                            for (const line of output.split('\n')) {
                                guiWasmEmsg(line);
                            }
                            debug('Output error message:', output);
                            break;
                        }
                        default:
                            debug('Message cannot be handled in handleEvent():', m);
                            throw new Error(`Cannot handle ${m.kind} event: ${m}`);
                    }
                }

                readClipboard(): Promise<CharPtr> {
                    this.sendMessage({ kind: 'read-clipboard:request' });

                    return this.handleEventsUntil('read-clipboard:response').then((m: ReadClipboardMessageFromMain) => {
                        if (m.contents === null) {
                            guiWasmSetClipAvail(false);
                            debug('Could not read clipboard text. Turned clipboard support off');
                            return NULL;
                        }

                        const len = m.contents.byteLength;
                        const ptr = Module._malloc(len + 1); // `+ 1` for NULL termination
                        if (ptr === NULL) {
                            return NULL;
                        }

                        Module.HEAPU8.set(new Uint8Array(m.contents), ptr as number);
                        Module.HEAPU8[ptr + len] = NULL;

                        debug('Allocated', len + 1, 'bytes and wrote clipboard text');
                        return ptr;
                    });
                }

                // Old start

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

                writeClipboard(text: string) {
                    debug('Send clipboard text:', text);
                    this.sendMessage({
                        kind: 'write-clipboard',
                        text,
                    });
                }

                setTitle(title: string) {
                    debug('Send window title:', title);
                    this.sendMessage({
                        kind: 'title',
                        title,
                    });
                }

                evalJavaScriptFile(file: string) {
                    try {
                        const contents = FS.readFile(file).buffer; // encoding = binary
                        this.sendMessage({ kind: 'eval', path: file, contents }, [contents]);
                        debug('Sent JavaScript file:', file);
                        return 1; // OK
                    } catch (err) {
                        debug('Could not read file', file, ':', err);
                        guiWasmEmsg(`E9999: Could not access ${file}: ${err.message}`);
                        return 0; // FAIL
                    }
                }

                evalJavaScriptFunc(func: string, argsJson: string | undefined, notifyOnly: boolean): Promise<CharPtr> {
                    debug('Will send function and args to main for jsevalfunc():', func, argsJson, notifyOnly);

                    this.sendMessage({
                        kind: 'evalfunc',
                        body: func,
                        argsJson,
                        notifyOnly,
                    });

                    if (notifyOnly) {
                        debug('Evaluating JavaScript does not require result', func);
                        return Promise.resolve(NULL);
                    }

                    return this.handleEventsUntil('evalfunc:response').then((m: EvalFuncMessageFromMain) => {
                        if (!m.success) {
                            const errmsg = new TextDecoder().decode(m.result);
                            guiWasmEmsg(errmsg);
                            debug('jsevalfunc() failed. Output error message:', errmsg);
                            return NULL;
                        }

                        // When jsevalfunc() succeeded, it returns serialized JSON string.
                        // Pass it to Vim directly.

                        const len = m.result.byteLength;
                        const ptr = Module._malloc(len + 1); // `+ 1` for NULL
                        if (ptr === NULL) {
                            return NULL;
                        }

                        Module.HEAPU8.set(new Uint8Array(m.result), ptr as number);
                        Module.HEAPU8[ptr + len] = NULL;

                        debug('Allocated', len + 1, 'bytes and wrote result of jsevalfunc()');

                        return ptr;
                    });
                }

                private main(args: string[]) {
                    this.started = true;
                    debug('Start main function() with args', args);

                    if (args.length === 0) {
                        wasmMain(0, NULL);
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
                        argvBuf[i] = ptr;
                    }

                    // argv must be NULL terminated
                    argvBuf[args.length] = NULL;

                    const argvPtr = Module._malloc(argvBuf.byteLength);
                    Module.HEAPU8.set(new Uint8Array(argvBuf.buffer), argvPtr as number);

                    wasmMain(args.length, argvPtr as number);

                    // Note: These allocated memories will never be free()ed because they should be alive
                    // until wasm_main() returns. Currently it's OK because this worker is for one-shot Vim
                    // process execution.
                }

                private preloadFiles(
                    files: { [fpath: string]: string },
                    remoteFiles: { [fpath: string]: string },
                ): Promise<unknown> {
                    for (const fpath of Object.keys(files)) {
                        try {
                            FS.writeFile(fpath, files[fpath], { flags: 'wx+' });
                        } catch (e) {
                            debug('Could not create file:', fpath, e);
                        }
                    }

                    const paths = Object.keys(remoteFiles);
                    return Promise.all(
                        paths.map(path => {
                            const remotePath = remoteFiles[path];
                            return fetch(remotePath)
                                .then(res => {
                                    if (!res.ok) {
                                        throw new Error(
                                            `Response of request to {remotePath} was not successful: ${res.status}: ${res.statusText}`,
                                        );
                                    }
                                    return res.text();
                                })
                                .then(text => {
                                    try {
                                        FS.writeFile(path, text, { flags: 'wx+' });
                                        debug('Fetched file from', remotePath, 'to', path);
                                    } catch (e) {
                                        debug('Could not create file', path, 'fetched from', remotePath, e, text);
                                    }
                                })
                                .catch(err => {
                                    debug('Could not fetch file:', path, err);
                                });
                        }),
                    );
                }

                private prepareFileSystem(
                    persistentDirs: string[],
                    mkdirs: string[],
                    userFiles: { [fpath: string]: string },
                    remoteFiles: { [fpath: string]: string },
                ): Promise<void> {
                    const dotvim = '/home/web_user/.vim';
                    const vimrc =
                        '" Write your favorite config!\n\nset expandtab tabstop=4 shiftwidth=4 softtabstop=4\ncolorscheme onedark\nsyntax enable\n';
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
                        return this.preloadFiles(files, remoteFiles).then(() => {
                            debug('Created files on MEMFS', files, remoteFiles);
                        });
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

                            this.preloadFiles(files, remoteFiles)
                                .then(() => {
                                    debug('Created files on IDBFS or MEMFS:', files, remoteFiles);
                                    this.perfMeasure('idbfs-init');
                                    resolve();
                                })
                                .catch(reject);
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
            VW.runtime.start();
        },
    },

    /*
     * C bridge
     */
    /* eslint-disable @typescript-eslint/camelcase */

    // int vimwasm_call_shell(char *);
    vimwasm_call_shell(cmd: CharPtr) {
        return VW.runtime.evalJavaScriptFile(UTF8ToString(cmd));
    },

    // void vimwasm_will_init(void);
    vimwasm_will_init() {
        VW.runtime.vimStarted();
    },

    // int vimwasm_resize(int, int);
    vimwasm_resize(width: number, height: number) {
        debug('resize:', width, height);
    },

    // int vimwasm_is_font(char * font_name);
    vimwasm_is_font(fontNamePtr: CharPtr) {
        const fontName = UTF8ToString(fontNamePtr);
        debug('is_font:', fontName);
        // TODO: Check the font name is available. Currently font name is fixed to monospace
        return 1;
    },

    // int vimwasm_is_supported_key(char * key_name);
    vimwasm_is_supported_key(keyNamePtr: CharPtr) {
        const keyName = UTF8ToString(keyNamePtr);
        debug('is_supported_key:', keyName);
        // TODO: Check the key is supported in the browser
        return 1;
    },

    // int vimwasm_open_dialog(int, char *, char *, char *, int, char *);
    vimwasm_open_dialog(
        type: number,
        titlePtr: CharPtr,
        messagePtr: CharPtr,
        buttonsPtr: CharPtr,
        defaultButtonIdx: number,
        textfieldPtr: CharPtr,
    ) {
        const title = UTF8ToString(titlePtr);
        const message = UTF8ToString(messagePtr);
        const buttons = UTF8ToString(buttonsPtr);
        const textfield = UTF8ToString(textfieldPtr);
        debug('open_dialog:', type, title, message, buttons, defaultButtonIdx, textfield);
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
    vimwasm_set_title(title: CharPtr) {
        VW.runtime.setTitle(UTF8ToString(title));
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
    vimwasm_set_font(name: CharPtr, size: number) {
        VW.runtime.draw('setFont', [UTF8ToString(name), size]);
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
    vimwasm_wait_for_event(timeout: number) {
        return Asyncify.handleSleep<number>(wakeUp => {
            VW.runtime
                .handleNextEvent(timeout > 0 ? timeout : undefined)
                .then(wakeUp)
                .catch(VW.runtime.sendError);
        });
    },

    // int vimwasm_export_file(char *);
    vimwasm_export_file(fullpath: CharPtr) {
        return +VW.runtime.exportFile(UTF8ToString(fullpath));
    },

    // char *vimwasm_read_clipboard();
    vimwasm_read_clipboard() {
        return Asyncify.handleSleep<CharPtr>(wakeUp => {
            VW.runtime
                .readClipboard()
                .then(wakeUp)
                .catch(VW.runtime.sendError);
        });
    },

    // void vimwasm_write_clipboard(char *);
    vimwasm_write_clipboard(textPtr: CharPtr, size: number) {
        const text = UTF8ToString(textPtr, size);
        VW.runtime.writeClipboard(text);
    },

    // char *vimwasm_eval_js(char *script, char *args_json, int just_notify);
    vimwasm_eval_js(scriptPtr: CharPtr, argsJsonPtr: CharPtr, justNotify: number) {
        return Asyncify.handleSleep<CharPtr>(wakeUp => {
            // Note: argsJsonPtr is NULL when no arguments are set
            const script = UTF8ToString(scriptPtr);
            const argsJson = argsJsonPtr === 0 /*NULL*/ ? undefined : UTF8ToString(argsJsonPtr);
            VW.runtime
                .evalJavaScriptFunc(script, argsJson, !!justNotify)
                .then(wakeUp)
                .catch(VW.runtime.sendError);
        });
    },

    /* eslint-enable @typescript-eslint/camelcase */
};

autoAddDeps(VimWasmLibrary, '$VW');
mergeInto(LibraryManager.library, VimWasmLibrary);
