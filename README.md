<img src="wasm/images/vim-wasm-logo-128x128.png" width="64" height="64" alt="icon"/> vim.wasm: Vim Ported to WebAssembly
================================================================================
[![Build Status][travis-ci-badge]][travis-ci]
[![npm version][npm-badge]][npm-package]

This project is an experimental fork of [Vim editor][] by [@rhysd][] to compile
it into [WebAssembly][] using [emscripten][] and [binaryen][].  Vim runs on [Web Worker][]
and interacts with the main thread via [`SharedArrayBuffer`][shared-array-buffer].

The goal of this project is running Vim editor on browsers without losing Vim's powerful
functionalities by compiling Vim C sources into WebAssembly.

<img alt="Main Screen" src="./wasm/images/readme/main-screen.png" width=662 height=487 />

## [Try it with your browser][try it]

- **USAGE**
  - Almost all Vim's powerful features (syntax highlighting, Vim script, text objects,
    ...) including the latest features (popup window, ...) are supported.
  - Drag&Drop files to browser tab opens them in Vim.
  - `:write` only writes file on memory.  Download current buffer by `:export` or
    specific file by `:export {file}`.
  - Clipboard register `"*` is supported.  For example, paste system clipboard text
    to Vim with `"*p` or `:put *`, and copy text in Vim to system clipboard with
    `"*y` or `:yank *`.
    If you want to synchronize Vim's clipboard with system clipboard,
    `:set clipboard=unnamed` should work like normal Vim.
  - Files under `~/.vim` directory is persistently stored in [Indexed DB][idb].
    Please write your favorite configuration in `~/.vim/vimrc` (NOT `~/.vimrc`).
  - `file={filepath}={url}` fetches a file from `{url}` to `{filepath}`.  Arbitrary
    remote files can be opened (care about CORS).
  - Default colorscheme is [onedark.vim][onedark], but [vim-monokai][monokai] is
    also available as high-contrast colorscheme.
  - `:!/path/to/file.js` evaluates the JavaScript code in browser.  `:!%` evaluates
    current buffer.
  - vimtutor is available by `:e tutor`.
  - Add `arg=` query parameters (e.g. `?arg=~%2f.vim%2fvimrc&arg=hello.txt`) to
    add `vim` command line arguments.
  - Please read [the usage documentation](./wasm/DEMO_USAGE.md) for more details.

- **NOTICE**
  - Please access from desktop Chrome, Firefox, Safari or Chromium based browsers
    since this project uses `SharedArrayBuffer` and `Atomics`.  On Firefox or Safari,
    feature flags (`javascript.options.shared_memory` for Firefox) must be enabled
    for now.
  - vim.wasm takes key inputs from DOM `keydown` event. Please disable your browser
    extensions which intercept key events (incognito mode would be the best).
  - This project is very early phase of experiment.  You may notice soon on
    trying it... it's buggy :)
  - If inputting something does not change anything, please try to click somewhere
    in the page.  Vim may have lost the focus.
  - Vim exits on `:quit`, but it does not close a browser tab. Please close it
    manually :)

This project is packaged as [`vim-wasm` npm pacakge][npm-package] to be used in
web application easily.  Please read [the documentation](./wasm/README.md) for
more details.

The current ported Vim version is 8.1.1806 with 'normal' and 'small' features sets.
Please check [changelog](./wasm/CHANGELOG.md) for update history.

### Related Projects

Following projects are related to this npm package and may be more suitable for your use case.

- [react-vim-wasm](https://github.com/rhysd/react-vim-wasm): [React](https://reactjs.org/)
  component for vim.wasm.  Vim editor can be embedded in your React web application.
- [vimwasm-try-plugin](https://github.com/rhysd/vimwasm-try-plugin): Command line tool
  to open vim.wasm including specified Vim plugin instantly. You can try Vim plugin
  without installing it!
- [vim.wasm.ipynb](https://github.com/nat-chan/vim.wasm.ipynb): Jupyter Notebook integration
  with vim.wasm. [Try it online!](https://mybinder.org/v2/gh/nat-chan/vim.wasm.ipynb/gh-pages?filepath=vim.wasm.ipynb)

### Presentations and Blog Posts

- Presentation slides
  - [(English) VimConf 2018 (Nov. 24th, 2018)](https://speakerdeck.com/rhysd/vim-ported-to-webassembly-vimconf-2018)
  - [(Japanese) Emscripten&WebAssembly night!! #8 (Jul. 24th, 2019)](https://speakerdeck.com/rhysd/vim-compiled-to-webassembly)
- Japanese blog posts
  [1](https://rhysd.hatenablog.com/entry/2018/07/09/090115)
  [2](https://rhysd.hatenablog.com/entry/2019/06/13/090519)

## How It Works

### User Interaction

![User Interaction](./wasm/images/readme/user-interaction.png)

In worker thread, Vim is running by compiled into Wasm.  The worker thread is spawned
as dedicated Web Worker from main thread when opening the page.

Let's say you input something with keyboard. Browser takes it as `KeyboardEvent` on
`keydown` event. JavaScript in main thread catches the event and store keydown
information to a shared memory buffer.

The buffer is shared with the worker thread.  Vim waits and gets the keydown information
by polling the shared memory buffer via JavaScript's `Atomics` API.  When key information
is found in the buffer, it loads the information and calculates key sequence. Via
JS to Wasm API thanks to emscripten, the sequence is added to Vim's input buffer
in Wasm.

The sequence in input buffer is processed by core editor logic (update buffer,
screen, ...).  Due to the updates, some draw events happen such as draw text, draw
rects, scroll regions, ...

These draw events are sent to JavaScript in worker thread from Wasm thanks to emscripten's
JS to C API. Considering device pixel ratio and `<canvas/>` API, how to render the
events is calculated and these calculated rendering events are passed from worker thread
to main thread via message passing with `postMessage()`.

Main thread JavaScript receives and enqueues these rendering events. On animation
frame, it renders them to `<canvas/>`.

Finally you can see the rendered screen in the page.

### Build Process

![Build Process](./wasm/images/readme/build-process.png)

WebAssembly frontend for Vim is implemented as a new GUI frontend of Vim like other GUI such as GTK frontend.  C sources are
compiled to each LLVM bitcode files and then they are linked to one bitcode file
`vim.bc` by `emcc`.  `emcc` will finally compile the `vim.bc` into `vim.wasm` binary
using binaryen and generates HTML/JavaScript runtime.

The difference I faced at first was the lack of terminal library such as ncurses.
I modified `configure` script to ignore the terminal library check.  It's OK since
GUI frontend for Wasm is always used instead of CUI frontend. I needed many
workarounds to pass `configure` checks.

emscripten provides Unix-like environment. So `os_unix.c` can support Wasm. However,
some features are not supported by emscripten. I added many `#ifdef FEAT_GUI_WASM`
guards to disable features which cannot be supported by Wasm (i.e. `fork (2)`
support, PTY support, signal handlers are stubbed, ...etc).

I created `gui_wasm.c` heavily referencing `gui_mac.c` and `gui_w32.c`. Event loop
(`gui_mch_update()` and `gui_mch_wait_for_chars()`) is simply implemented with
blocking wait. And almost all UI rendering events are passed to JavaScript layer
by calling JavaScript functions from C thanks to emscripten.

C sources are compiled (with many optimizations) into LLVM bitcode with [Clang][]
which is integrated to emscripten. Then all bitcode files (`.o`) are linked to
one bitcode file `vim.bc` with `llvm-link` linker (also integrated to emscripten).

And I created JavaScript runtime in TypeScript to draw the rendering events sent
from C.  JavaScript runtime is separated into two parts; main thread and worker
thread.  `wasm/main.ts` is for main thread. It starts Vim in worker thread and
draws Vim screen to `<canvas>` receiving draw events from Vim. `wasm/runtime.ts`
and `wasm/pre.ts` are for worker thread. They are written using
[emscripten API][emscripten/interacting with code].

`emcc` (emscripten's C compiler) compiles the `vim.bc` and `runtime.js` into `vim.wasm`,
`vim.js` and `vim.data` with preloaded Vim runtime files (i.e. colorscheme) using
binaryen.  Runtime files are loaded on a virtual file system provided on a browser
by emscripten.  Here, these files are compiled for worker thread. `wasm/main.js`
starts a dedicated Web Worker loading `vim.js`.

Finally, I created a small `wasm/index.html` which contains `<canvas/>` to render
Vim screen and load `wasm/main.js`.

Now hosting `wasm/index.html` with a web server and accessing to it with browser
opens Vim.  It works.

### How to `sleep()` on JavaScript

The hardest part for this porting was how to implement blocking wait (usually done
with `sleep()`).

Since blocking main thread on web page means blocking user interaction, it is basically
prohibited.  Almost all operations taking time are implemented as asynchronous API
in JavaScript.  Wasm running on main thread cannot block the thread except for
busy loop.

But C programs casually use `sleep()` function so it is a problem when porting the programs.
Vim's GUI frontend is also expected to wait user input with blocking wait.

emscripten provides workaround for this problem, [Emterpreter][]. With Emterpreter,
emscripten provides (pseudo) blocking wait functions such as `emscripten_sleep()`.
When they are used in C function, `emcc` compiles the function into Emterpreter byte
code instead of Wasm. And at runtime, the byte code is run on an interpreter (on Wasm).
When the interpreter reaches at the point calling `emscripten_sleep()`, it suspends
byte code execution and sets timer (with `setTimeout` JS function). After time
expires, the interpreter resumes state and continues execution.

By this mechanism, JavaScript's asynchronous wait looks as if synchronous wait from C
world.  At first I used Emterpreter and it worked. However, there were several issues.

- It splits Vim sources into two parts; pure Wasm code directly run and Emterpreter
  byte code run on an interpreter.  I needed to maintain large functions list which
  should be compiled into Emterpreter byte code. When the list is wrong, Vim crashes
- Emterpreter is not so fast so it slows entire application
- Emterpreter makes program unstable. For example JS and C interactions don't work
  in some situations
- Emterpreter makes built binary bigger and compilation longer.  Compiling C code
  into Emterpreter byte code is very slow since it requires massive code transformations.
  Emterpreter byte code is very simple so its binary size is bigger

I looked for an alternative and found [`Atomics.wait()`][js-atomics-wait]. `Atomics.wait()`
is a low-level synchronous primitive function. It waits until a specific byte in shared
memory buffer is updated. It's **blocking wait**. Of course it is not available on
main thread. It must be used on a worker thread.

I moved Wasm code base into Web Worker running on worker thread, though rendering
`<canvas/>` is still done in main thread.

![Polling input sequences](./wasm/images/readme/input-polling-sequence.png)

Vim uses `Atomics.wait()` for waiting user input by watching a shared memory buffer.
When a key event happens, main thread stores key event data to the shared memory buffer
and notifies that a new key event came by `Atomics.notify()`.  Worker thread detects
that the buffer was updated by `Atomics.wait()` and loads the key event data from
the buffer.  Vim calculates a key sequence from the data and add it to input buffer.
Finally Vim handles the event and sends draw events to main thread via JavaScript.

As a bonus, user interaction is no longer prevented since almost all logic including
entire Vim are run in worker thread.

## Development

Please make sure that Emscripten (I'm using 1.38.37) and binaryen (I'm using v84)
are installed.  If you use macOS, they can be installed with
`brew install emscripten binaryen`.

Please use `build.sh` script to hack this project.  Just after cloning this
repository, simply run `./build.sh`.  It builds vim.wasm in `wasm/` directory.
It takes time and CPU power a lot.

Finally host the `wasm/` directly on `localhost` with a web server such as
`python -m http.server 1234`.  Accessing to `localhost:1234?debug` will start
Vim with debug logs.  Note that it's much slower than release build since many
debug features are enabled. Please read [wasm/README.md](./wasm/README.md) for
more details.

Please note that this repository's `wasm` branch frequently merges the latest
[vim/vim][] master branch.  If you want to hack this project, please ensure
to create your own branch and merge `wasm` branch into your branch by `git merge`.

### Known Issues

- ~~WebAssembly nor JavaScript does not provide `sleep()`. By default, emscripten
  compiles `sleep()` into a busy loop.  So vim.wasm is using [Emterpreter][]
  which provides `emscripten_sleep()`. Some whitelisted functions are run with
  Emterpreter. But this feature is not so stable. It makes built binaries larger
  and compilation longer.~~ This was fixed at [#30][issue-30]
- ~~JavaScript to C does not fully work with Emterpreter. For example, calling
  some C APIs breaks Emterpreter stack. This also means that calling C functions
  from JavaScript passing a `string` parameter does not work.~~ This was fixed at
  [#30][issue-30]
- Only Chrome and Chromium based browsers are supported by default. Firefox and Safari
  require enabling feature flags. This is because `SharedArrayBuffer` is disabled
  due to Spectre security vulnerability.

## TODO

Development is managed in [GitHub Projects][].

- Consider to support larger feature set ('big' and 'huge')
- Use WebAssembly's multi-threads support with [Atomic instructions][wasm-atomic-insn]
  instead of [JavaScript Atomics API][js-atomics-api]
- ~~Render `<canvas/>` in worker thread using [Offscreen Canvas][]~~ Currently not
  available. Please read [notes](./wasm/README.md).
- Mouse support
- IME support
- Packaging vim.wasm as Web Component

## Special Thanks

This project was heavily inspired by impressive project [vim.js][] by
[Lu Wang][].

## License

All additional files in this repository are licensed under the same license as
Vim (VIM LICENSE).  Please see `:help license` for more detail.

[Vim editor]: https://www.vim.org/
[@rhysd]: https://github.com/rhysd
[WebAssembly]: https://webassembly.org/
[emscripten]: http://kripken.github.io/emscripten-site/
[binaryen]: https://github.com/WebAssembly/binaryen
[Web Worker]: https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API
[travis-ci-badge]: https://travis-ci.org/rhysd/vim.wasm.svg?branch=wasm
[travis-ci]: https://travis-ci.org/rhysd/vim.wasm
[try it]: http://rhysd.github.io/vim.wasm
[Clang]: https://clang.llvm.org/
[emscripten/interacting with code]: https://kripken.github.io/emscripten-site/docs/porting/connecting_cpp_and_javascript/Interacting-with-code.html
[Emterpreter]: https://github.com/kripken/emscripten/wiki/Emterpreter
[GitHub Projects]: https://github.com/rhysd/vim.wasm/projects/2
[vim/vim]: https://github.com/vim/vim
[vim.js]: https://github.com/coolwanglu/vim.js/
[Lu Wang]: https://github.com/coolwanglu
[wasm-atomic-insn]: https://webassembly.github.io/threads/valid/instructions.html#atomic-memory-instructions
[js-atomics-api]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Atomics
[Offscreen Canvas]: https://developer.mozilla.org/en-US/docs/Web/API/OffscreenCanvas
[js-atomics-wait]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Atomics/wait
[shared-array-buffer]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/SharedArrayBuffer
[issue-30]: https://github.com/rhysd/vim.wasm/pull/30
[npm-package]: https://www.npmjs.com/package/vim-wasm
[npm-badge]: https://badge.fury.io/js/vim-wasm.svg
[idb]: https://developer.mozilla.org/en-US/docs/Web/API/IndexedDB_API
[onedark]: https://github.com/joshdick/onedark.vim
[monokai]: https://github.com/sickill/vim-monokai

Original README is following.

-------------------------------------------------------------------------------

![Vim Logo](https://github.com/vim/vim/blob/master/runtime/vimlogo.gif)

[![Build Status](https://travis-ci.org/vim/vim.svg?branch=master)](https://travis-ci.org/vim/vim)
[![Appveyor Build status](https://ci.appveyor.com/api/projects/status/o2qht2kjm02sgghk?svg=true)](https://ci.appveyor.com/project/chrisbra/vim)
[![Coverage Status](https://codecov.io/gh/vim/vim/coverage.svg?branch=master)](https://codecov.io/gh/vim/vim?branch=master)
[![Coverity Scan](https://scan.coverity.com/projects/241/badge.svg)](https://scan.coverity.com/projects/vim)
[![Language Grade: C/C++](https://img.shields.io/lgtm/grade/cpp/g/vim/vim.svg?logo=lgtm&logoWidth=18)](https://lgtm.com/projects/g/vim/vim/context:cpp)
[![Debian CI](https://badges.debian.net/badges/debian/testing/vim/version.svg)](https://buildd.debian.org/vim)
[![Packages](https://repology.org/badge/tiny-repos/vim.svg)](https://repology.org/metapackage/vim)


## What is Vim? ##

Vim is a greatly improved version of the good old UNIX editor Vi.  Many new
features have been added: multi-level undo, syntax highlighting, command line
history, on-line help, spell checking, filename completion, block operations,
script language, etc.  There is also a Graphical User Interface (GUI)
available.  Still, Vi compatibility is maintained, those who have Vi "in the
fingers" will feel at home.  See `runtime/doc/vi_diff.txt` for differences with
Vi.

This editor is very useful for editing programs and other plain text files.
All commands are given with normal keyboard characters, so those who can type
with ten fingers can work very fast.  Additionally, function keys can be
mapped to commands by the user, and the mouse can be used.

Vim runs under MS-Windows (NT, 2000, XP, Vista, 7, 8, 10), Macintosh, VMS and
almost all flavours of UNIX.  Porting to other systems should not be very
difficult.  Older versions of Vim run on MS-DOS, MS-Windows 95/98/Me, Amiga
DOS, Atari MiNT, BeOS, RISC OS and OS/2.  These are no longer maintained.


## Distribution ##

You can often use your favorite package manager to install Vim.  On Mac and
Linux a small version of Vim is pre-installed, you still need to install Vim
if you want more features.

There are separate distributions for Unix, PC, Amiga and some other systems.
This `README.md` file comes with the runtime archive.  It includes the
documentation, syntax files and other files that are used at runtime.  To run
Vim you must get either one of the binary archives or a source archive.
Which one you need depends on the system you want to run it on and whether you
want or must compile it yourself.  Check http://www.vim.org/download.php for
an overview of currently available distributions.

Some popular places to get the latest Vim:
* Check out the git repository from [github](https://github.com/vim/vim).
* Get the source code as an [archive](https://github.com/vim/vim/releases).
* Get a Windows executable from the
[vim-win32-installer](https://github.com/vim/vim-win32-installer/releases) repository.



## Compiling ##

If you obtained a binary distribution you don't need to compile Vim.  If you
obtained a source distribution, all the stuff for compiling Vim is in the
`src` directory.  See `src/INSTALL` for instructions.


## Installation ##

See one of these files for system-specific instructions.  Either in the
READMEdir directory (in the repository) or the top directory (if you unpack an
archive):

	README_ami.txt		Amiga
	README_unix.txt		Unix
	README_dos.txt		MS-DOS and MS-Windows
	README_mac.txt		Macintosh
	README_vms.txt		VMS

There are other `README_*.txt` files, depending on the distribution you used.


## Documentation ##

The Vim tutor is a one hour training course for beginners.  Often it can be
started as `vimtutor`.  See `:help tutor` for more information.

The best is to use `:help` in Vim.  If you don't have an executable yet, read
`runtime/doc/help.txt`.  It contains pointers to the other documentation
files.  The User Manual reads like a book and is recommended to learn to use
Vim.  See `:help user-manual`.


## Copying ##

Vim is Charityware.  You can use and copy it as much as you like, but you are
encouraged to make a donation to help orphans in Uganda.  Please read the file
`runtime/doc/uganda.txt` for details (do `:help uganda` inside Vim).

Summary of the license: There are no restrictions on using or distributing an
unmodified copy of Vim.  Parts of Vim may also be distributed, but the license
text must always be included.  For modified versions a few restrictions apply.
The license is GPL compatible, you may compile Vim with GPL libraries and
distribute it.


## Sponsoring ##

Fixing bugs and adding new features takes a lot of time and effort.  To show
your appreciation for the work and motivate Bram and others to continue
working on Vim please send a donation.

Since Bram is back to a paid job the money will now be used to help children
in Uganda.  See `runtime/doc/uganda.txt`.  But at the same time donations
increase Bram's motivation to keep working on Vim!

For the most recent information about sponsoring look on the Vim web site:
	http://www.vim.org/sponsor/


## Contributing ##

If you would like to help making Vim better, see the [CONTRIBUTING.md](https://github.com/vim/vim/blob/master/CONTRIBUTING.md) file.


## Information ##

The latest news about Vim can be found on the Vim home page:
	http://www.vim.org/

If you have problems, have a look at the Vim documentation or tips:
	http://www.vim.org/docs.php
	http://vim.wikia.com/wiki/Vim_Tips_Wiki

If you still have problems or any other questions, use one of the mailing
lists to discuss them with Vim users and developers:
	http://www.vim.org/maillist.php

If nothing else works, report bugs directly:
	Bram Moolenaar <Bram@vim.org>


## Main author ##

Send any other comments, patches, flowers and suggestions to:
	Bram Moolenaar <Bram@vim.org>


This is `README.md` for version 8.1 of Vim: Vi IMproved.
