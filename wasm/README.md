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

To enable all debug logs, please set a query parameter `?debug=1` to the URL.
