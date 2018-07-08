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
        cflags="-O1 -g"
    else
        cflags=
    fi
    emmake make -j CFLAGS="$cflags"
    echo "build.sh: Copying bitcode to wasm/"
    cp src/vim wasm/vim.bc
}

run_emcc() {
    echo "build.sh: Building HTML/JS/Wasm with emcc"

    local extraflags
    if [[ "$RELEASE" == "" ]]; then
        # TODO: EMCC_DEBUG=1
        # TODO: STACK_OVERFLOW_CHECK=1
        # TODO: --js-opts 0
        extraflags="-O1 -g -s ASSERTIONS=1 --shell-file template_vim.html -o vim.html"
    else
        extraflags="-O2 --shell-file template_vim_release.html -o index.html"
    fi

    cd wasm/
    emcc vim.bc \
        --pre-js pre.js \
        --js-library runtime.js \
        -s "EXPORTED_FUNCTIONS=['_main','_gui_wasm_send_key']" -s "EXTRA_EXPORTED_RUNTIME_METHODS=['cwrap']" \
        -s EMTERPRETIFY=1 -s EMTERPRETIFY_ASYNC=1 -s 'EMTERPRETIFY_FILE="emterpretify.data"' \
        --preload-file usr \
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

run_deploy() {
    echo "build.sh: Deploying gh-pages"
    local hash
    hash="$(git rev-parse HEAD)"
    cp wasm/style.css ..
    git checkout gh-pages
    mv ../style.css .
    cp wasm/index.* .
    cp wasm/emterpretify.data .
    git add index.* emterpretify.data
    git commit -m "Deploy from ${hash}"
    echo "build.sh: Commit created. Please check diff with 'git show' and deploy it with 'git push'"
}

if [[ "$#" != "0" ]]; then
    for task in "$@"; do
        "run_${task}"
    done
else
    run_configure
    run_make
    run_emcc
fi

echo "Done."
