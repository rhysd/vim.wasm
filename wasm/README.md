This directory contains a browser runtime for `wasm` GUI frontend.

- `pre.ts`, `runtime.ts`: Runtime to render a Vim screen and take user key inputs. Written in
  [TypeScript](https://www.typescriptlang.org/). Files are formatted by [prettier](https://prettier.io/).
- `template_vim.html`, `template_vim_release.html`, `style.css`: HTML file is an entrypoint of application.
  These files are templates of HTML files. `template_vim` is used for a debug build, and `template_vim_release`
  is used for a release build.
- `package.json`: Toolchains for this frontend is managed by [`npm`](https://www.npmjs.com/) command.
  You can build this runtime by `npm run build`. You can run linters ([`eslint`](https://eslint.org/),
  [`tslint`](https://palantir.github.io/tslint/), [`stylelint`](https://github.com/stylelint/stylelint))
  by `npm run lint`.

When you run a debug build by `./build.sh` from root of this repo, `vim.html`, `vim.wasm`, `vim.js`, `vim.data`,
`emterpretify.data` will be generated. You can host them with a web server.

When you run a release build by `./build.sh release` from root of this repo, `index.html`, `index.wasm`, `index.js`,
`index.data`, `emterpretify.data` will be generated. You can host them with a web server.
