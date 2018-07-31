#!/bin/bash

set -e

if [ ! -d .git ]; then
    echo 'build.sh must be run from repository root' 1>&2
    exit 1
fi

run_configure() {
    echo "build.sh: Running ./configure"
    CPPFLAGS="-DFEAT_GUI_WASM" \
    CPP="gcc -E" \
    emconfigure ./configure \
        --enable-gui=wasm \
        --with-features=tiny \
        --with-x=no \
        --with-packages=no \
        --with-vim-name=vim.bc \
        --with-modified-by=rhysd \
        --with-compiledby=rhysd \
        --disable-darwin \
        --disable-selinux \
        --disable-xsmp \
        --disable-xsmp-interact \
        --disable-luainterp \
        --disable-mzschemeinterp \
        --disable-perlinterp \
        --disable-pythoninterp \
        --disable-python3interp \
        --disable-tclinterp \
        --disable-rubyinterp \
        --disable-cscope \
        --disable-workshop \
        --disable-netbeans \
        --disable-multibyte \
        --disable-hangulinput \
        --disable-xim \
        --disable-fontset \
        --disable-gtk2-check \
        --disable-gnome-check \
        --disable-motif-check \
        --disable-athena-check \
        --disable-nextaw-check \
        --disable-carbon-check \
        --disable-gtktest \
        --disable-largefile \
        --disable-acl \
        --disable-gpm \
        --disable-sysmouse \
        --disable-nls \
        --disable-channel \
        --disable-terminal \

}

run_make() {
    echo "build.sh: Running make"
    local cflags
    if [[ "$RELEASE" == "" ]]; then
        cflags="-O1 -g -DGUI_WASM_DEBUG"
    else
        cflags="-Os"
    fi
    emmake make -j CFLAGS="$cflags"
    echo "build.sh: Copying bitcode to wasm/"
    cp src/vim.bc wasm/
}

run_emcc() {
    echo "build.sh: Building HTML/JS/Wasm with emcc"

    local extraflags
    if [[ "$RELEASE" == "" ]]; then
        # TODO: EMCC_DEBUG=1
        # TODO: STACK_OVERFLOW_CHECK=1
        # TODO: --js-opts 0
        extraflags="-O0 -g -s ASSERTIONS=1 --shell-file template_vim.html -o vim.html"
    else
        extraflags="-Os --shell-file template_vim_release.html -o index.html"
    fi

    cd wasm/

    if [[ "$RELEASE" != "" ]]; then
        # When debug build, we use tsc --watch so compiling it here is not necessary
        npm run build
    fi

    if [ ! -f tutor ]; then
        cp ../runtime/tutor/tutor .
    fi

    emcc vim.bc \
        --pre-js pre.js \
        --js-library runtime.js \
        -s "EXPORTED_FUNCTIONS=['_main','_gui_wasm_send_key','_gui_wasm_resize_shell']" -s "EXTRA_EXPORTED_RUNTIME_METHODS=['cwrap']" \
        -s EMTERPRETIFY=1 -s EMTERPRETIFY_ASYNC=1 -s 'EMTERPRETIFY_FILE="emterpretify.data"' \
        -s 'EMTERPRETIFY_WHITELIST=["_gui_mch_wait_for_chars", "_flush_buffers", "_vgetorpeek_one", "_vgetorpeek", "_plain_vgetc", "_vgetc", "_safe_vgetc", "_normal_cmd", "_main_loop", "_inchar", "_gui_inchar", "_ui_inchar", "_gui_wait_for_chars", "_gui_wait_for_chars_or_timer", "_vim_main2", "_main", "_gui_wasm_send_key", "_add_to_input_buf", "_simplify_key", "_extract_modifiers", "_edit", "_invoke_edit", "_nv_edit", "_nv_colon", "_n_opencmd", "_nv_open", "_nv_search", "_fsync", "_mf_sync", "_ml_sync_all", "_updatescript", "_before_blocking", "_getcmdline", "_getexline", "_do_cmdline", "_wait_return", "_op_change", "_do_pending_operator", "_get_literal", "_ins_ctrl_v", "_get_keystroke", "_do_more_prompt", "_msg_puts_display", "_msg_puts_attr_len", "_msg_puts_attr", "_msg_putchar_attr", "_msg_putchar", "_list_in_columns", "_list_features", "_list_version", "_ex_version", "_do_one_cmd", "_msg_puts", "_version_msg_wrap", "_version_msg", "_nv_g_cmd"]' \
        --preload-file usr --preload-file tutor \
        $extraflags \

}

run_release() {
    echo "build.sh: Cleaning built files"
    make distclean
    rm -rf wasm
    git checkout wasm/
    export RELEASE=true
    echo "build.sh: Start release build"
    bash build.sh
    echo "build.sh: Release build done"
}

run_build_runtime() {
    echo "build.sh: Building runtime JavaScript sources"
    cd wasm/
    npm install
    npm run build
    npm run lint
    cd -
}

run_deploy() {
    echo "build.sh: Deploying gh-pages"
    local hash
    hash="$(git rev-parse HEAD)"
    cp wasm/style.css _style.css
    git checkout gh-pages
    mv _style.css style.css
    cp wasm/index.* .
    rm index.js.orig.js
    cp wasm/emterpretify.data .
    git add index.* emterpretify.data style.css
    git commit -m "Deploy from ${hash}"
    echo "build.sh: Commit created. Please check diff with 'git show' and deploy it with 'git push'"
}

if [[ "$#" != "0" ]]; then
    for task in "$@"; do
        "run_${task}"
    done
else
    make distclean
    run_configure
    run_make
    run_build_runtime
    run_emcc
fi

echo "Done."
