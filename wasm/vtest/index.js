import { VimWasm } from '../vimwasm.js';

const screenCanvasElement = document.getElementById('vim-screen');
const vim = new VimWasm({
    workerScriptPath: '../vim.js',
    canvas: screenCanvasElement,
    input: document.getElementById('vim-input'),
});

vim.onError = console.error;
vim.start({
    fetchFiles: {
        '/tryit.js': '../home/web_user/tryit.js',
    },
    cmdArgs: ['/tryit.js', '-c', 'normal G'],
});
