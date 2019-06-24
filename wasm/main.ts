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

import { VimWasm } from './vimwasm.js';

const queryParams = new URLSearchParams(window.location.search);
const debugging = queryParams.has('debug');
const perf = queryParams.has('perf');
const clipboardSupported = navigator.clipboard !== undefined;

function fatal(err: string | Error): never {
    if (typeof err === 'string') {
        alert('FATAL: ' + err);
        throw new Error(err);
    } else {
        alert('FATAL: ' + err.message);
        throw err;
    }
}

function checkCompat(prop: string) {
    if (prop in window) {
        return; // OK
    }
    fatal(
        `window.${prop} is not supported by this browser. If you're on Firefox or Safari, please enable browser's feature flag`,
    );
}

checkCompat('Atomics');
checkCompat('SharedArrayBuffer');

const screenCanvasElement = document.getElementById('vim-screen') as HTMLCanvasElement;
const vim = new VimWasm('vim.js', {
    canvas: screenCanvasElement,
    input: document.getElementById('vim-input') as HTMLInputElement,
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

// Do not show dialog not to prevent performance tracing
if (!perf) {
    vim.onVimExit = status => {
        alert(`Vim exited with status ${status}`);
    };
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

vim.readClipboard = () => {
    if (!clipboardSupported) {
        alert('Clipboard API is not supported by this browser. Clipboard register is not available');
        return Promise.reject();
    }
    return navigator.clipboard.readText();
};
vim.onWriteClipboard = text => {
    if (!clipboardSupported) {
        alert('Clipboard API is not supported by this browser. Clipboard register is not available');
        return Promise.reject();
    }
    return navigator.clipboard.writeText(text);
};

vim.onError = fatal;

vim.start({ debug: debugging, perf, clipboard: clipboardSupported });
