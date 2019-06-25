import { VimWasm } from './node_modules/vim-wasm/vimwasm.js';

const queryParams = new URLSearchParams(window.location.search);
const debugging = queryParams.has('debug');
const perf = queryParams.has('perf');
const clipboardSupported = navigator.clipboard !== undefined;

function fatal(err) {
    if (typeof err === 'string') {
        alert('FATAL: ' + err);
        throw new Error(err);
    } else {
        alert('FATAL: ' + err.message);
        throw err;
    }
}

function checkCompat(prop) {
    if (prop in window) {
        return; // OK
    }
    fatal(
        `window.${prop} is not supported by this browser. If you're on Firefox or Safari, please enable browser's feature flag`,
    );
}

checkCompat('Atomics');
checkCompat('SharedArrayBuffer');

const screenCanvasElement = document.getElementById('vim-screen');
const vim = new VimWasm('./node_modules/vim-wasm/vim.js', {
    canvas: screenCanvasElement,
    input: document.getElementById('vim-input'),
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

vim.onFileExport = (fullpath, contents) => {
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
