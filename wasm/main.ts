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
 * main.ts: TypeScript main thread runtime for Wasm port of Vim by @rhysd.
 */

import { VimWasm, VIM_VERSION } from './vimwasm.js';

declare global {
    interface Window {
        vim?: VimWasm;
    }
}

const queryParams = new URLSearchParams(window.location.search);
const debugging = queryParams.has('debug');
const perf = queryParams.has('perf');
const feature = queryParams.get('feature') || 'normal';
const clipboardAvailable = navigator.clipboard !== undefined;
const dirs = queryParams.getAll('dir');
const cmdArgs = queryParams.getAll('arg');
if (cmdArgs.length === 0 && feature === 'normal') {
    cmdArgs.push('/home/web_user/tryit.js');
}
const fetchFiles = (function() {
    const ret: { [p: string]: string } = {};
    for (const mapping of queryParams.getAll('file')) {
        const i = mapping.indexOf('=');
        if (i <= 0) {
            continue;
        }
        const path = mapping.slice(0, i);
        const remote = mapping.slice(i + 1);
        ret[path] = remote;
    }
    return ret;
})();
let vimIsRunning = false;

function fatal(err: string | Error): never {
    if (typeof err === 'string') {
        err = new Error(err);
    }
    alert('FATAL: ' + err.message);
    throw err;
}

const screenCanvasElement = document.getElementById('vim-screen') as HTMLCanvasElement;
const workerScriptPath = feature === 'normal' ? './vim.js' : `./${feature}/vim.js`;
const vim = new VimWasm({
    canvas: screenCanvasElement,
    input: document.getElementById('vim-input') as HTMLInputElement,
    workerScriptPath,
});

// Handle drag and drop
screenCanvasElement.addEventListener(
    'dragover',
    e => {
        e.stopPropagation();
        e.preventDefault();
        if (e.dataTransfer) {
            e.dataTransfer.dropEffect = 'copy';
        }
    },
    false,
);
screenCanvasElement.addEventListener(
    'drop',
    e => {
        e.stopPropagation();
        e.preventDefault();

        if (e.dataTransfer === null) {
            return;
        }

        vim.dropFiles(e.dataTransfer.files).catch(fatal);
    },
    false,
);

vim.onVimInit = () => {
    vimIsRunning = true;
};

// Do not show dialog not to prevent performance tracing
if (!perf) {
    vim.onVimExit = status => {
        vimIsRunning = false;
        alert(`Vim exited with status ${status}`);
    };
}

if (!perf && !debugging) {
    window.addEventListener('beforeunload', e => {
        if (vimIsRunning) {
            e.preventDefault();
            e.returnValue = ''; // Chrome requires to set this value
        }
    });
}

vim.onFileExport = (fullpath: string, contents: ArrayBuffer) => {
    const slashIdx = fullpath.lastIndexOf('/');
    const filename = slashIdx !== -1 ? fullpath.slice(slashIdx + 1) : fullpath;
    const blob = new Blob([contents], { type: 'application/octet-stream' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.style.display = 'none';
    a.href = url;
    a.rel = 'noopener';
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
};

function clipboardSupported(): Promise<any> | undefined {
    if (clipboardAvailable) {
        return undefined;
    }
    alert('Clipboard API is not supported by this browser. Clipboard register is not available');
    return Promise.reject();
}
vim.readClipboard = () => {
    return clipboardSupported() || navigator.clipboard.readText();
};
vim.onWriteClipboard = text => {
    return clipboardSupported() || navigator.clipboard.writeText(text);
};
vim.onTitleUpdate = title => {
    document.title = title;
};

vim.onError = fatal;

vim.start({
    debug: debugging,
    perf,
    clipboard: clipboardAvailable,
    persistentDirs: ['/home/web_user/.vim'],
    dirs,
    fetchFiles,
    cmdArgs,
});

if (debugging) {
    window.vim = vim;
    /* eslint-disable no-console */
    console.log('main: Vim version:', VIM_VERSION);
    /* eslint-enable no-console */
}
