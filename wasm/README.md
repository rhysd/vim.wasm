[npm][] package for [vim.wasm][project]
=======================================

**WARNING!: This npm package is experimental until v0.1.0 beta release.**

## Installation

```
npm install --save vim-wasm
```

## Usage

**NOTE:** This npm package is currently dedicated for browsers. It does not work with Wasm interpreters
outside browser like `node`.

Please see [example directory](./example) for minimal live example.

### Prepare `index.html`

`<canvas>` to render Vim screen and `<input/>` to take user input are necessary in DOM.

```html
<canvas id="vim-screen"></canvas>
<input id="vim-input" autocomplete="off" autofocus />
<script type="module" src="index.js" />
```

Your script `index.js` must be loaded as `type="module"` because this npm package provides ES Module.

### Prepare `index.js`

```javascript
import { VimWasm } from '/path/to/vim-wasm/vimwasm.js';

const vim = new VimWasm({
    canvas: document.getElementById('vim-canvas'),
    input: document.getElementById('vim-input'),
});

// Setup callbacks if you need...

// Start Vim
vim.start();
```

`VimWasm` class is provided to manage Vim lifecycle. Please import it from `vimwasm.js` ES Module.

`VimWasm` provides several callbacks to interact with Vim running in Web Worker. Please check
[example code](./example/index.js) for the callbacks setup.

Finally calling `start()` method starts Vim in new Web Worker.

### Serve `index.html`

Serve `index.html` with HTTP server and access to it on a browser.

**NOTE:** This project uses [`SharedArrayBuffer`][shared-array-buffer] and [`Atomics` API][atomics-api].
Only Chrome or Chromium-based browsers enable them by default. For Firefox and Safari, feature flag must
be enabled manually for now to enable them. Please also read notices in README.md at [the project page][project].

## Logging

Hosting this directory with web server, setting a query parameter `debug=1` to the URL enables all debug logs.

As JavaScript API, passing `debug: true` to `VimWasm.start()` method call enables debug logging with `console.log`.

```javascript
vim.start({ debug: true });
```

**Note:** Debug logs in C sources are not controlled by the query parameter. It is controlled `GUI_WASM_DEBUG` preprocessor macro.

## Performance

Hosting this directory with web server, a query parameter `perf=1` to the URL enables performance trancing.
After Vim exits (e.g. `:qall!`), it dumps performance measurements in DevTools console as tables.

As JavaScript API, passing `perf: true` to `VimWasm.start()` method call enables the performance tracing.

```javascript
vim.start({ perf: true });
```

**Note:** For performance measurements, please ensure to use release build. Measuring with debug build does not make sense.

**Note:** Please do not use `debug=1` at the same time. Outputting console logs in DevTools slows application.

**Note:** 'Vim exits with status N' dialog does not show up not to prevent performance measurements.

## Sources

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

## Notes

### ES Modules in Worker
ES Modules and JS bundlers (e.g. parcel) are not available in worker because of `emcc`. `emcc` preprocesses input JavaScript
source (here `runtime.js`). It parses the source but the parser only accepts specific format of JavaScript code. The preprocessor
seems to ignore all declarations which don't appear in `mergeInto` call. Dynamic import is also not available for now.

- `import` statement is not available since the `emcc` JS parser cannot parse it
- Dymanic import is not available in dedicated worker: https://bugs.chromium.org/p/chromium/issues/detail?id=680046
- Bundled JS sources by bundlers such as parcel cannot be parsed by the `emcc` JS parser
- Compiling TS sources into one JS file using `--outFile=xxx.js` does not work since toplevel constants are ignored by
  the `emcc` JS parser

### Offscreen Canvas

There were 3 trials but all were not available for now.

- Send `<canvas/>` to worker (runtime.js) by `transferControlToOffscreen()` and render draw events there. This is not avaialble
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

[npm]: https://www.npmjs.com/
[project]: https://github.com/rhysd/vim.wasm
[shared-array-buffer]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer
[atomics-api]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Atomics
