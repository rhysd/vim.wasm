<a name="wasm-0.0.11"></a>
# [0.0.11 (wasm-0.0.11)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.11) - 01 Aug 2019

- **New:** `fetchFiles` option was added. It can define mapping from Vim's filesystem to external resources (file path or URL). Vim fetches the resources just before starting Vim and maps them to its filesystem entries
- **New:** Small CLI tool [vimwasm-try-plugin](https://github.com/rhysd/vimwasm-try-plugin) was implemented in another repository to try external plugins and colorschemes without installing them
- **New:** Add `jsevalfunc()` Vim script function to evaluate JavaScript code in Vim script. The function makes it easier to integrate browser API into Vim plugin
- **Fix:** Canvas width and height are slightly not fit to its element size when the element has border
- **Improve:** Use `Function` to evaluate JavaScript code
- **New:** Visual testing for screen rendering was introduced as smoke testing


[Changes][wasm-0.0.11]


<a name="wasm-0.0.10"></a>
# [0.0.10 (wasm-0.0.10)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.10) - 18 Jul 2019

- Include 'small' feature binary in addition to 'normal' feature. 'small' feature build only provides basic features but binary size is much smaller
  - Put in `vim-wasm/small` directory
  - You can use 'small' feature by specifying path to `workerScriptPath` option
  - Please read https://github.com/rhysd/vim.wasm/tree/wasm/wasm#normal-feature-and-small-feature for more details
- **Breaking Change**: `VIM_FEATURE` constant was removed because the npm package now provides multiple features
- **Breaking Change**: `workerScriptPath` option of constructor of `VimWasm` is now not optional because almost all case default value is not available.

[Changes][wasm-0.0.10]


<a name="wasm-0.0.9"></a>
# [0.0.9 (wasm-0.0.9)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.9) - 17 Jul 2019

- **Improve:** Normal feature set was supported
  - Almost all features are now supported
    - Syntax highlighting
    - Text object
    - Vim script
    - incremental search with highlight
    - quickfix
    - completion in insert mode and cmdline mode
    - local mappings
    - diff support
    - folding
    - spell check
    - smart indentation
    - digraphs
    - line break
    - tag jump
    - cursor shape support
    - persistent undo
  - Features which require shell commands are disabled (terminal, job, `system()`)
  - Binary size is bigger (total 2MB)
- **Breaking Change**: Colorscheme was changed from `desert` to `onedark`. `monokai` was also added
- **Improve:** Almost all language supports are enabled
  - They include support for syntax highlighting, auto indentation and completion
  - This much increases size of `vim.data`
- **New:** Added title change event. Now JavaScript can handle window title
- **New:** `:!` can evaluate JavaScript file like `:!/path/to/file.js`. JavaScript file is evaluated in main thread. When it caused an error, the error message is output in Vim message area
- **New:** Added `VimWasm.showError` method to output error message in Vim from JavaScript side
- **Fix:** Position of underlines on text rendering
- **Improve:** Merge upstream Vim 1.6.1661
- **New:** Added `VIM_VERSION` and `VIM_FEATURE` constants are added to ES Module to get Vim version and feature set name


[Changes][wasm-0.0.9]


<a name="wasm-0.0.8"></a>
# [0.0.8 (wasm-0.0.8)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.8) - 11 Jul 2019

- **Improve:** Upgrade features set from 'Tiny' to 'Small'
  - This requires slightly bigger memory usage (+10~15%)
  - Binary size almost does not change (about +1.5%)
- **Improve:** Vim is updated to 8.1.1658

[Changes][wasm-0.0.8]


<a name="wasm-0.0.7"></a>
# [0.0.7 (wasm-0.0.7)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.7) - 09 Jul 2019

- **Improve:** Follow the latest upstream 8.1.1640
- **New:** Add `cmdArgs` option to `VimWasm.start()` method call. It defines a command line arguments for running `vim` command. Please read [documentation](https://github.com/rhysd/vim.wasm/tree/wasm/wasm#program-arguments) for more details
- **Improve:** https://rhysd.github.io/vim.wasm learns `arg=` query parameter to pass command line arguments to underlying `vim` command execution
- **Improve:** Running unit tests is made 3x faster

[Changes][wasm-0.0.7]


<a name="wasm-0.0.6"></a>
# [0.0.6 (wasm-0.0.6)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.6) - 06 Jul 2019

- **Fix:** worker script is not minified
- **Improve:** https://rhysd.github.io/vim.wasm now confirms on closing tab when Vim is still running

[Changes][wasm-0.0.6]


<a name="wasm-0.0.5"></a>
# [0.0.5 (wasm-0.0.5)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.5) - 06 Jul 2019

- **New:** FileSystem support via options at `VimWasm.start()`. Now vimrc of https://rhysd.github.io/vim.wasm is persistent
  - `files`: Create files before Vim starts
  - `dirs`: Create directories before Vim starts
  - `persistentDirs`: Mark directories persistent. They are stored on Indexed DB as persistent storage
- **New:** Add `checkBrowserCompatibility()` to check vim.wasm is available
- **Improve:** Optimize for rendering whitespaces. 3.2x speed up
- **Improve:** Timing of `onVimExit` callback is tweaked. It is now called after Vim completely exited
- **Fix:** `:export` error handling. Now error message is correct
- **Fix:** Handling `\` key event bug on Chromium

[Changes][wasm-0.0.5]


<a name="wasm-0.0.4"></a>
# [0.0.4 (wasm-0.0.4)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.4) - 02 Jul 2019

- **Improve:** Support changing font size dynamically by `guifont` option (e.g. `set guifont=Monaco:h12` sets Monaco font with 12px height)
- **Fix:** Fixed type definitions were not correct put in npm package

[Changes][wasm-0.0.4]


<a name="wasm-0.0.3"></a>
# [0.0.3 (wasm-0.0.3)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.3) - 02 Jul 2019

- **Improve:** **BREAKING** Interface of constructor of `VimWasm` changed. Now worker path is part of `VimWasmConstructOptions` and optional
- **Improve:** Added `cmdline()` method to `VimWasm` to execute command from JavaScript
- **Fix:** Fixed timing to clear notification bytes in shared memory buffer between main thread and worker thread
- **Fix:** Prevented Vim starts twice. Previously second run had done nothing incorrectly
- **Improve:** Now screen rendering, event handling and performance measurements are tested with Karma. All tests are run on CI
- **Improve:** Website loads `vimwasm.js` module asynchronously.
- **Improve:** Improved documentation and example. Added keywords to package.json

[Changes][wasm-0.0.3]


<a name="wasm-0.0.2"></a>
# [0.0.2 (wasm-0.0.2)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.2) - 02 Jul 2019

- **Improve:** Correct and improve description in README.md and example of npm package usage

[Changes][wasm-0.0.2]


<a name="wasm-0.0.1"></a>
# [0.0.1 (wasm-0.0.1)](https://github.com/rhysd/vim.wasm/releases/tag/wasm-0.0.1) - 02 Jul 2019

First wasm binary release. Please read [`wasm/README.md`](https://github.com/rhysd/vim.wasm/tree/wasm/wasm) for more details and install npm package from https://www.npmjs.com/package/vim-wasm

[Changes][wasm-0.0.1]


[wasm-0.0.11]: https://github.com/rhysd/vim.wasm/compare/wasm-0.0.10...wasm-0.0.11
[wasm-0.0.10]: https://github.com/rhysd/vim.wasm/compare/wasm-0.0.9...wasm-0.0.10
[wasm-0.0.9]: https://github.com/rhysd/vim.wasm/compare/wasm-0.0.8...wasm-0.0.9
[wasm-0.0.8]: https://github.com/rhysd/vim.wasm/compare/wasm-0.0.7...wasm-0.0.8
[wasm-0.0.7]: https://github.com/rhysd/vim.wasm/compare/wasm-0.0.6...wasm-0.0.7
[wasm-0.0.6]: https://github.com/rhysd/vim.wasm/compare/wasm-0.0.5...wasm-0.0.6
[wasm-0.0.5]: https://github.com/rhysd/vim.wasm/compare/wasm-0.0.4...wasm-0.0.5
[wasm-0.0.4]: https://github.com/rhysd/vim.wasm/compare/wasm-0.0.3...wasm-0.0.4
[wasm-0.0.3]: https://github.com/rhysd/vim.wasm/compare/wasm-0.0.2...wasm-0.0.3
[wasm-0.0.2]: https://github.com/rhysd/vim.wasm/compare/wasm-0.0.1...wasm-0.0.2
[wasm-0.0.1]: https://github.com/rhysd/vim.wasm/tree/wasm-0.0.1

 <!-- Generated by changelog-from-release -->
