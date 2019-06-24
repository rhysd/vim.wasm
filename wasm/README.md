This directory contains a browser runtime for `wasm` GUI frontend.

- `pre.ts`, `runtime.ts`: Runtime to interact with main thread and Vim on Wasm. It runs on Web Worker.
  Written in [TypeScript](https://www.typescriptlang.org/). Files are formatted by [prettier](https://prettier.io/).
- `main.ts`: Runtime to render a Vim screen and take user key inputs. It runs on main thread and is
  responsible for starting Web Worker. Written in [TypeScript](https://www.typescriptlang.org/).
  Files are formatted by [prettier](https://prettier.io/).
- `package.json`: Toolchains for this frontend is managed by [`npm`](https://www.npmjs.com/) command.
  You can build this runtime by `npm run build`. You can run linters ([`eslint`](https://eslint.org/),
  [`stylelint`](https://github.com/stylelint/stylelint)) by `npm run lint`.

When you run `./build.sh` from root of this repo, `vim.wasm`, `vim.js`, `vim.data` and `main.js` will
be generated.  Please host this directory on web server and access to `index.html`.

## Logging

To enable all debug logs, please set a query parameter `debug=1` to the URL.

**Note:** Debug logs in C sources are not controlled by the query parameter. It is controlled `GUI_WASM_DEBUG` preprocessor macro.

## Performance

To enable performance trancing, please set a query parameter `perf=1` to the URL. After Vim exits (e.g. `:qall!`),
it dumps performance measurements in DevTools console as tables.

**Note:** For performance measurements, please ensure to use release build. Measuring with debug build does not make sense.

**Note:** Please do not use `debug=1` at the same time. Outputting console logs in DevTools slows application.

**Note:** 'Vim exits with status N' dialog does not show up not to prevent performance measurements.

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
