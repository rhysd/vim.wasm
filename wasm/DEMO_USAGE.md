Usage of [Live Demo][demo]
==========================

This documentation describes how to use [live demo][demo]. For the usage of npm package, please read
[README.md](./README.md).

[Live demo][demo] runs 'normal' feature Vim. It supports almost all Vim's powerful features (syntax
highlighting, Vim script, text objects, ...) including the latest features (popup window, ...)

<img alt="Main Screen" src="./images/readme/main-screen.png" width=662 height=487 />

When opening it, it opens `tryit.js` example JavaScript source code. Basic usage is described in
comments at top of the file. Example source contains min-heap data structure and heap sort algorithm.
Enjoy coding! And `:%` runs the code in your browser.

## Send Local File to Vim

Since Vim is running on a browser, your local file is not directly accessible.

Instead, drag&drop your file on Vim screen sends the file to Vim. Vim will immediately open the file
in Vim.

## Send Edited File from Vim

To get the file edited with Vim, `:export` command is available. The exported file is saved to your local
filesystem like a downloaded file.

**Example:** Export current editing buffer

```
:export
```

**Example:** Export a file specified by path

```
:export /path/to/file
```

## Clipboard Integration

Vim has its own clipboard buffer and can access to system clipboard via `*` register. vim.wasm naturally
supports it.

To read a clipboard, `p` key map or `:put` command is available.

**Example:** Key map to read from clipboard and paste it to buffer

```
"*p
```

**Example:** Command to read from clipboard and paste it to buffer

```vim
:put *
```

To write to a clipboard, `y` key map or `:yank` command is available.

**Example:** Key map to write selected text or text object to clipboard

```
"*y
```

**Example:** Command to write selected text or text object to clipboard

```vim
:yank *
```

If you want to synchronize unnamed register always, please set `clipboard` option. When you yank some
text (e.g. `yy`, `dd`) or put some text (e.g. `p`), Vim's clipboard is always synchronized with system
clipboard.

**Example:** Synchronize system clipboard with Vim's own clipboard

```vim
:set clipboard=unnamed
```

**NOTE:** Clipboard integration is implemented with [browser's clipboard API][clipboard-api] so you
should permit the browser page to use the APIs for enabling it.

## Store `.vimrc` Persistently

The directory `~/.vim` is stored in [Indexed DB][indexed-db] persistently. The configuration written
in `~/.vim/vimrc` is persistently stored. The configuration is read on Vim start up next time.

**Example:** Edit your vimrc

```vim
:edit! ~/.vim/vimrc
```

**NOTE:** Files are stored to Indexed DB on `:quit`.

## Colorscheme

By default [onedark.vim][onedark] is used and [vim-monokai][monokai] is available.

**Example:** Apply `monokai` colorscheme

```vim
:colorscheme monokai
```

## Create Directories

By adding `dir={path}` query parameter, the directory is created before Vim starts. This is useful when
you create a file with `file=` query parameter (described in next section). Note that nested directories
are not created. You need to specify each directories. `dir=` query parameter can appear multiple times.

**Example:** Create `/home/web_user/hello/world`

http://rhysd.github.io/vim.wasm/?dir=/home/web_user/hello&dir=/home/web_user/hello/world

## Fetch Remote Files and Open It in Vim

By adding `file={filepath}={url}` query parameter, the file hosted on `{url}` is fetched as file
`{filepath}` before Vim starts. `{url}` accepts both URL with scheme (e.g. `https://...`) and without
scheme (e.g. `/vim.js`). Due to limitation of CORS checks of GitHub Pages, files only on https://github.com
and https://github.io would be available.

`file=` query parameter can appear multiple times so you can fetch multiple files.

**Example:** Fetch `/vim.js` into `/home/web_user/vim.js`

http://rhysd.github.io/vim.wasm/?file=/home/web_user/vim.js=/vim.js

**Example:** Fetch https://raw.githubusercontent.com/rhysd/vim.wasm/wasm/README.md into `/readme.md`

https://rhysd.github.io/vim.wasm/?file=/readme.md=https://raw.githubusercontent.com/rhysd/vim.wasm/wasm/README.md

**Example:** Try [spring-night](https://github.com/rhysd/vim-color-spring-night) colorscheme

https://rhysd.github.io/vim.wasm/?file=/usr/local/share/vim/colors/spring-night.vim=https://raw.githubusercontent.com/rhysd/vim-color-spring-night/master/colors/spring-night.vim&arg=-c&arg=colorscheme%20spring-night

**Example:** Try [clever-f.vim](https://github.com/rhysd/clever-f.vim) plugin

https://rhysd.github.io/vim.wasm?dir=/usr/local/share/vim/autoload/clever_f&file=/usr/local/share/vim/autoload/clever_f.vim=https://raw.githubusercontent.com/rhysd/clever-f.vim/master/autoload/clever_f.vim&file=/usr/local/share/vim/autoload/clever_f/compat.vim=https://raw.githubusercontent.com/rhysd/clever-f.vim/master/autoload/clever_f/compat.vim&file=/usr/local/share/vim/plugin/clever_f.vim=https://raw.githubusercontent.com/rhysd/clever-f.vim/master/plugin/clever-f.vim

**NOTE:** Preparing the URL for Vim plugin is a work a bit hard. Try [vimwasm-try-plugin][] to generate
a URL of vim.wasm including specified Vim plugin easily.

## Try 'small' Feature Set

By default [live demo][demo] runs Vim with normal feature set. It provides almost all Vim's powerful
features but its binary size is big.

As alternative, `vim-wasm` package also provides Vim with small feature set. It provides only basic
features but its binary size is much smaller.

Giving `feature=small` query parameter switches Vim to small feature set. Please check what feature is not
provided and how small the binary size is.

https://rhysd.github.io/vim.wasm/?feature=small

## Evaluate JavaScript Files

`:!` command can run shell commands in Vim. Since there is no shell command in WebAssembly world, the
command is basically not available. However, only JavaScript files are executable.
Since `%` is a special character indicating the current buffer in Vim's command line, `:!%` runs the
current buffer.

**Example:** Evaluates `/path/to/source.js`

```vim
:!/path/to/source.js
```

**Example:** Evaluates the current buffer

```vim
:!%
```

## Set Font with `guifont` Option

`guifont` option is available like other GUI Vim. All font names available in CSS are also available here.
Note that **only monospace fonts are considered**. If you specify other font like `serif`, junks may remain
on re-rendering a screen. If you want to specify font height also, `:h{pixels}` suffix is available.

**Example:** Set 'Monaco' font

```vim
:set guifont=Monaco
```

**Example:** Set 'Monaco' font with 20 pixels height

```vim
:set guifont=Monaco:h20
```

## Passing Program Arguments

`arg` query parameters are passed to Vim command arguments. For example, passing `-c 'split ~/source.c'`
to Vim can be done with query parameters `?arg=-c&arg=split%20~%2fsource.c` (`%20` is white space and
`%2f` is slash). `arg` can be specified multiple times. One `arg=` query parameter is corresponding
to one argument. This parameter is useful when you want to open some file by default.

**Example:** Executes `:set number` at Vim starting

https://rhysd.github.io/vim.wasm/?arg=-c&arg=set%20number

**Example:** Outputs the version information in DevTools console and immediately quits Vim

https://rhysd.github.io/vim.wasm/?arg=--version

## Try vimtutor

If you're not familiar with Vim, it's nice chance to learn. 'vimtutor' text is put at `/tutor`. Open
the file and start the instruction.

**Example:** Start vimtutor

```vim
:edit /tutor
```

## Check Debug Logging

By adding `debug` query parameter, debug logs are output in DevTools console from both main thread
and worker thread. Note that debug log from C is not output. To enable it, you need to build `vim.wasm`
binary with debug build because debug log is controlled by `GUI_WASM_DEBUG` preprocessor macro.

**Example:**

https://rhysd.github.io/vim.wasm/?debug

## Enable Performance Tracing

By adding `perf` query parameter, it enables performance tracing. After editing some texts or using some
feature in Vim, please quit Vim with `:quit`. Then performance tracing results are output in DevTools
console. Note that please avoid using both `debug` and `perf` query parameters at the same time. Debug
log output slows Vim.

**Example:**

https://rhysd.github.io/vim.wasm/?perf

**Note:** 'Vim exits with status N' dialog does not show up not to prevent performance measurements.

[demo]: https://rhysd.github.io/vim.wasm
[clipboard-api]: https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/clipboard
[indexed-db]: https://developer.mozilla.org/ja/docs/Web/API/IndexedDB_API
[onedark]: https://github.com/joshdick/onedark.vim
[monokai]: https://github.com/sickill/vim-monokai
[vimwasm-try-plugin]: https://github.com/rhysd/vimwasm-try-plugin
