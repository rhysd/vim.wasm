[npm][] package for [vim.wasm][project]
=======================================
[![Build Status][travis-ci-badge]][travis-ci]
[![npm version][npm-badge]][npm-pkg]
[![code style: prettier][prettier-badge]][prettier]

**WARNING!: This npm package is experimental until v0.1.0 beta release.**

## Introduction

This is an [npm][] package to install pre-built [vim.wasm][project] binary easily. This package contains:

- `vim.wasm`: WebAssembly binary
- `vim.js`: Web Worker script to drive `vim.wasm`
- `vim.data`: Bundled preloaded files loaded into filesystem at start up
- `vimwasm.js`: ES Module to manage lifetime of Web Worker
- `small/vim.{wasm,js,data}`: Small feature version

Please read the following instructions to use this package. You can play with [live demo][demo].
For usage of the demo, please read [usage documentation](./DEMO_USAGE.md).

## Installation

Install [npm package][npm-pkg] via `npm` command.

```
npm install --save vim-wasm
```

## Usage

**NOTE:** This npm package is currently dedicated for browsers. It does not work with Wasm interpreters
outside browser like `node`.

Please see [example directory](./example) for minimal live example and [live demo](./main.ts) for
more complicated example.

### Prepare `index.html`

Put `<canvas>` to render Vim screen and `<input/>` to take user input in HTML file.

```html
<canvas id="vim-screen"></canvas>
<input id="vim-input" autocomplete="off" autofocus />
<script type="module" src="index.js" />
```

Your script `index.js` must be loaded as `type="module"` because this npm package provides ES Module
unless you use some JS source bundler.

### Prepare `index.js`

```javascript
import { VimWasm } from '/path/to/vim-wasm/vimwasm.js';

const vim = new VimWasm({
    canvas: document.getElementById('vim-canvas'),
    input: document.getElementById('vim-input'),
    workerScriptPath: '/path/to/vim-wasm/vim.js',
});

// Setup callbacks if you need...

// Start Vim (give option object if necessary)
vim.start();
```

`VimWasm` class is provided to manage Web Worker lifecycle where Vim is running. Please import it from
`vimwasm.js` ES Module.

`workerScriptPath` is the most important option value which represents a file path to a worker script
which runs Vim in Web Worker. By switching path to scripts `vim-wasm/vim.js` and `vim-wasm/small/vim.js`,
you can switch feature set of Vim. Please read following 'Normal Feature and Small Feature' section.

`VimWasm` provides several callbacks to interact with Vim running in Web Worker. Please check
[example code](./example/index.js) for the callbacks setup.

Finally calling `start()` method starts Vim in new Web Worker. You can pass an options object to the
method call to specify various options.

### Serve `index.html`

Serve `index.html` with HTTP server and access to it from a web browser.

**NOTE:** This project uses [`SharedArrayBuffer`][shared-array-buffer] and [`Atomics` API][atomics-api].
Only Chrome or Chromium-based browsers enable them by default. For Firefox and Safari, feature flag must
be enabled manually for now to enable them. Please also read notices in README.md at [the project page][project].

### Related Projects

Following projects are related to this npm package and may be more suitable for your use case.

- [react-vim-wasm](https://github.com/rhysd/react-vim-wasm): [React](https://reactjs.org/) component for [vim.wasm][project].
  Vim editor can be embedded in your React web application.
- [vimwasm-try-plugin](https://github.com/rhysd/vimwasm-try-plugin): Command line tool to open vim.wasm including specified
  Vim plugin instantly. You can try Vim plugin
  without installing it!
- [vim.wasm.ipynb](https://github.com/nat-chan/vim.wasm.ipynb): Jupyter Notebook integration with vim.wasm.
  [Try it online!](https://mybinder.org/v2/gh/nat-chan/vim.wasm.ipynb/gh-pages?filepath=vim.wasm.ipynb)

## Normal Feature and Small Feature

This package contains two binaries for 'normal' feature set and 'small' feature set.
'normal' feature set provides almost all Vim's powerful features but binary size is 4x bigger than
'small' feature set. 'small' feature set only provides basic features but binary size is much smaller.

|                 | Normal Feature      | Small Feature                                                                      |
|-----------------|---------------------|------------------------------------------------------------------------------------|
| **Script path** | `vim-wasm/vim.js`   | `vim-wasm/small/vim.js`                                                            |
| **Data size**   | 1.3 MB              | 13 KB                                                                              |
| **Wasm size**   | 709 KB              | 374 KB                                                                             |
| **Features**    | Almost all features | Not including syntax highlight, indentation, Vim script support, text objects, ... |

Data size is significantly different because 'normal' feature set includes syntax highlighting and indentation
support for all filetypes. In contrast 'small' feature set only includes colorscheme and minimal vimrc.

By passing a worker script path for each feature to `workerScriptPath` option, you can specify a feature set.
Please choose one considering your application's requirements.

```javascript
const normalVim = new VimWasm({
    canvas,
    input,
    workerScriptPath: '/path/to/vim-wasm/vim.js',
});

const smallVim = new VimWasm({
    canvas,
    input,
    workerScriptPath: '/path/to/vim-wasm/small/vim.js',
});
```

## Check Browser Compatibility

This npm package runs Vim in Web Worker and the main thread communicates with the worker thread via `SharedArrayBuffer`.
Chrome or Chromium based browser supports `SharedArrayBuffer` by default. Safari and Firefox supports it under a feature
flag due to Spectre vulnerability.

To check current browser can use this package, `checkBrowserCompatibility()` utility function is provided.
It returns an error message as string if it is not compatible (otherwise returns `undefined`).

```javascript
const errmsg = checkBrowserCompatibility();
if (errmsg !== undefined) {
    alert(errmsg);
    return;
}

const vim = new VimWasm({...});
```

## Debug Logging

Passing `debug: true` to `VimWasm.start()` method call enables debug logging with `console.log`.

```javascript
vim.start({ debug: true });
```

**Note:** Debug logs in C sources are not controlled by the query parameter. It is controlled `GUI_WASM_DEBUG` preprocessor macro.

## Performance Logging

Passing `perf: true` to `VimWasm.start()` method call enables the performance tracing.
After Vim exits (e.g. `:qall!`), it dumps performance measurements in DevTools console as tables.

```javascript
vim.start({ perf: true });
```

**Note:** For performance measurements, please ensure to use release build. Measuring with debug build does not make sense.

**Note:** Please do not use debug logging at the same time. Outputting console logs in DevTools slows application.

## Program Arguments

Passing program arguments of `vim` command is supported.

Passing `cmdArgs` option to `VimWasm.start()` method call passes the value as Vim command arguments.

```javascript
vim.start({
  cmdArgs: [ '~/.vim/vimrc', '-c', 'set number' ]
});
```

As shown in above example, this feature is useful when you want to open specific file at Vim startup.

## Evaluate JavaScript with `:!`

```
:!/path/to/file.js
```

`:!` evaluates the JavaScript source file. In Vim's command line, `%` is replaced with the current buffer's
file path so `:!%` evaluates the current buffer.

Currently only `*.js` files are executable via `:!` and any other commands are not supported. Console
output is not captured. You need to open console in DevTools or use `alert()` to show value.

The JavaScript code is evaluated in main thread so DOM APIs are available. If the code throws an exception,
the error message and stacktrace is shown as an error message in Vim.

Unlike `:!`, `system()` and `systemlist()` Vim script functions are explicitly not supported because their
calls in Vim plugins are intended to execute shell commands.

## Set Font

`guifont` option is available like other GUI Vim. All font names available in CSS are also available here.
Note that **only monospace fonts are considered**. If you specify other font like `serif`, junks may remain
on re-rendering a screen.

```vim
" Use 'Monaco' font
:set guifont=Monaco
```

If you want to specify font height also, `:h{pixels}` suffix is available.

```vim
" Use 'Monaco' font with 20px font height
:set guifont=Monaco:h20
```

Note that currently only font height can be specified in this format. And integer value is acceptable
since Vim contains font size as integer internally.

If you want to specify font name and font height from JavaScript, set it via `VimWasm.cmdline` method.

```javascript
vim.cmdline(`set guifont=${fontName}:h{fontHeight}`);
```

## FileSystem Setup

`VimWasm.start()` method supports filesystem setup before starting Vim through `dirs`, `files`, `fetchFiles`
and `persistentDirs` options.

`dirs` option creates new directories on filesystem. They are created on memory using emscripten's
`MEMFS` by default. Note that nested directory paths are not available.

Notes:

- You must specify each parent directories to create a nested directory.
- Trying to create an existing directory causes an error.

```javascript
// Create /work/documents directory
vim.start({
    dirs: ['/work', '/work/documents'],
});
```

`persistentDirs` option marks the directories are persistent. They are stored on [Indexed DB][idb]
thanks to emscripten's `IDBFS`. They will remain even if user closes a browser tab.

Notes:

- Marking non-existing directories as persistent causes an error. Please set `dirs` correctly to ensure
  they exists.
- Files are synchronized when Vim exits. Closing browser tab without `:quit` does not save files on Indexed DB.
  This behavior may change in the future.
- This option adds overhead to load files from database at Vim startup.

```javascript
// Create /work/persistent directory. Contents of the directory are persistent
vim.start({
    dirs: ['/work', '/work/persistent'],
    persistentDirs: ['/work/persistent'],
});
```

`files` option creates files on filesystem. It is an object whose keys are file paths and values are files'
contents as `String`.

Notes:

- Parent directories must exist for the files. If they don't exist, please create them by `dirs` option.
- You can overwrite default vimrc as below example.

```javascript
// Create new file /work/hello.txt and overwrite vimrc
vim.start({
    dirs: ['/work'],
    files: {
        '/work/hello.txt': 'hello, world!\n',
        '/.vim/vimrc': 'set number\nset noexpandtab\n',
    },
});
```

`fetchFiles` option fetches remote resources and map them to filesystem entries. It is an object whose
keys are file paths on filesystem and values are remote resource paths (relative file paths or URLs).
It fetches file paths or URLs just before starting Vim and put them on filesystem.

```javascript
vim.start({
    fetchFiles: {
        // Fetch hosted 'vim.js' file and put it as '/foo.js' in filesystem
        '/foo.js': '/vim.js',
        // Fetch 'README.md' file from remote with URL and put it as '/bar.md' in filesystem
        '/bar.md': 'https://raw.githubusercontent.com/rhysd/vim.wasm/wasm/README.md',
    },
});
```

By using this option, external files are easily loaded onto filesystem. For example, if you fetch plugin
files, the plugin is available on Vim starting. [vimwasm-try-plugin][] uses this option to load specified
Vim plugin or colorscheme.

Resources (values of the object) are fetched with [`fetch()`][fetch]. Though all requests are sent
asynchronously, Vim waits all responses. Fetching many files or too large file would slows Vim start
up time so should be avoided.

## Evaluate JavaScript from Vim script

To integrate JavaScript browser APIs into Vim script, `jsevalfunc()` Vim script function is implemented.

```
jsevalfunc({script} [, {args} [, {notify_only}]])
```

The first `{script}` argument is a string of JavaScript code which represents **a function body**.
To return a value from JavaScript to Vim script, `return` statement is necessary. Arguments are accessible
via `arguments` object in the code.

The second `{args}` optional argument is a list value which represents arguments passed to the JavaScript
function. If it is omitted, the function will be called with no argument.

The third `{notify_only}` optional argument is a number or boolean value which indicates if returned
value from the JavaScript function call is notified back to Vim script or not. If the value is truthy,
function body and arguments are just notified to main thread and the returned value will never be notified
back to Vim. In the case, `jsevalfunc()` call always returns `0` and doesn't wait the JavaScript function
call has completed. If it is omitted, the default value is `v:false`. This flag is useful when the returned
value is not necessary since returning a value from main thread to Vim in worker may take time to serialize
and convert values.

The JavaScript code is evaluated in main thread as a JavaScript function. So DOM element and other Web APIs
are available.

```vim
" Get Location object in JavaScript as dict
let location = jsevalfunc('return window.location')

" Get element text
let selector = '.description'
let text = jsevalfunc('
        \ const elem = document.querySelector(arguments[0]);
        \ if (elem === null) {
        \   return null;
        \ }
        \ return elem.textContent;
        \', [selector])

" Run script but does not wait for the script being completed
call jsevalfunc('document.title = arguments[0]', ['hello from Vim'], v:true)
```

Since values are passed by being encoded in JSON between Vim script, arguments passed to JavaScript function
call and returned value from JavaScript function must be JSON serializable. As a special case, `undefined`
is translated to `v:none` in Vim script.

```vim
" Error because funcref is not JSON serializable
call jsevalfunc('return "hello"', [function('empty')])

" Error because Function object is not JSON serializable
let f = jsevalfunc('return fetch')
```

The JavaScript function is called in asynchronous context. So `await` operator is available as follows:

```vim
let slug = 'rhysd/vim.wasm'
let repo = jsevalfunc('
        \ const res = await fetch("https://api.github.com/repos/" + arguments[0]);
        \ if (!res.ok) {
        \   return null;
        \ }
        \ return JSON.parse(await res.text());
        \ ', [slug])
echo repo
```

`jsevalfunc()` throws an exception when:

- some argument passed at 2nd argument is not JSON serializable
- JavaScript code causes syntax error
- evaluating JavaScript code throws an exception
- returned value from the function call is not JSON serializable

## TypeScript Support

[This npm package][npm-pkg] provides complete TypeScript support. Type definitions are put in `vimwasm.d.ts`
and automatically referenced by TypeScript compiler.

## Ported Vim

- Current version: 8.1.1845
- Current features: normal and small

## Development

### Sources

This directory contains a browser runtime for `wasm` GUI frontend written in [TypeScript](https://www.typescriptlang.org/).

- `pre.ts`, `runtime.ts`: Runtime to interact with main thread and Vim on Wasm. It runs on Web Worker.
- `main.ts`, `vimwasm.ts`: Runtime to render a Vim screen and take user key inputs. It runs on main thread and is
  responsible for starting Web Worker.
- `package.json`: Toolchains for this frontend is managed by [`npm`](https://www.npmjs.com/) command.
  You can build this runtime by `npm run build`. You can run linters ([`eslint`](https://eslint.org/),
  [`stylelint`](https://github.com/stylelint/stylelint)) by `npm run lint`.

When you run `./build.sh` from root of this repo, `vim.wasm`, `vim.js`, `vim.data` and `main.js` will
be generated.  Please host this directory on web server and access to `index.html`.

Files are formatted by [prettier](https://prettier.io/).

### Testing

Unit tests are developed at [test](./test) directory. Since `vim.wasm` assumes to be run on browsers, they are run
on headless Chromium using [karma](https://karma-runner.github.io/latest/index.html) test runner.
Basically unit test cases run Vim worker and check draw events from it. Headless Chromium is installed in `node_modules`
locally by puppeteer.

```sh
# Single run
npm test

# Watch test source files and run tests on changes
npm run karma

# Use normal Chromium with DevTools instead of headless version
npm run karma -- --browsers ChromeDebug

# Apply eslint to TypeScript sources
npm run lint

# Run visual testing. It checks Vim screen is rendered correctly
npm run vtest
```

`npm run lint` and `npm run vtest` are run at `git push` by [husky][] :dog:.

`npm test` is run at [Travis CI][travis-ci] for every remote push.

## Notes

### ES Modules in Worker

ES Modules and JS bundlers (e.g. parcel) are not available in worker because of `emcc`. `emcc` preprocesses input JavaScript
source (here `runtime.js`). It parses the source but the parser only accepts specific format of JavaScript code. The preprocessor
seems to ignore all declarations which don't appear in `mergeInto` call. Dynamic import is also not available for now.

- `import` statement is not available since the `emcc` JS parser cannot parse it
- Dynamic import is not available in dedicated worker: https://bugs.chromium.org/p/chromium/issues/detail?id=680046
- Bundled JS sources by bundlers such as parcel cannot be parsed by the `emcc` JS parser
- Compiling TS sources into one JS file using `--outFile=xxx.js` does not work since toplevel constants are ignored by
  the `emcc` JS parser

### Offscreen Canvas

There were 3 trials but all were not available for now.

- Send `<canvas/>` to worker (runtime.js) by `transferControlToOffscreen()` and render draw events there. This is not available
  since runtime.js runs synchronously with `Atomics` API. It sleeps until main thread notifies. In this case, calling draw methods
  of `OffscreenCanvas` does nothing because rendering does not happen until JavaScript context ends (like busy loop in main thread
  prevents DOM rendering).
- In main thread, draw to `OffscreenCanvas` and transfer the rendered result to on-screen `<canvas/>` as `ImageBitmap`. I tried
  this but it was slower than simply drawing to `<canvas/>` directly. It is because sending rendered image to `<canvas/>` causes
  re-rending whole screen.
- Create another worker thread (renderer.js) in worker (runtime.js) and send draw events to renderer.js. In renderer.js, it renders
  them to `OffscreenCanvas` passed from main thread via runtime.js. This solution should be possible and is possibly faster than
  rendering draw events in main thread. However, it is currently not available due to Chromium bug https://bugs.chromium.org/p/chromium/issues/detail?id=977924.
  When a worker thread runs synchronously with `Atomics` API, new `Worker` instance cannot start because new worker is created
  in the same thread and starts asynchronously. This would be fixed by https://bugs.chromium.org/p/chromium/issues/detail?id=835717
  but we need to wait for the fix.

## License

Distributed under VIM License.

Example code is based on https://github.com/trekhleb/javascript-algorithms.

> Copyright (c) 2018 Oleksii Trekhleb

[npm]: https://www.npmjs.com/
[npm-pkg]: https://www.npmjs.com/package/vim-wasm
[project]: https://github.com/rhysd/vim.wasm
[shared-array-buffer]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer
[atomics-api]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Atomics
[idb]: https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API
[travis-ci-badge]: https://travis-ci.org/rhysd/vim.wasm.svg?branch=wasm
[travis-ci]: https://travis-ci.org/rhysd/vim.wasm
[npm-badge]: https://badge.fury.io/js/vim-wasm.svg
[prettier-badge]: https://img.shields.io/badge/code_style-prettier-ff69b4.svg?style=flat
[prettier]: https://github.com/prettier/prettier
[demo]: https://rhysd.github.io/vim.wasm
[husky]: https://github.com/typicode/husky
[fetch]: https://developer.mozilla.org/en-US/docs/Web/API/WindowOrWorkerGlobalScope/fetch
[vimwasm-try-plugin]: https://github.com/rhysd/vimwasm-try-plugin
