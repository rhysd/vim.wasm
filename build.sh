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
        extraflags="-O1 -g -s ASSERTIONS=1"
    else
        extraflags="-O2"
    fi

    cd wasm/
    emcc vim.bc \
        -o vim.html \
        --pre-js pre.js \
        --js-library runtime.js \
        --shell-file template_vim.html \
        -s EMTERPRETIFY=1 -s EMTERPRETIFY_ASYNC=1 -s 'EMTERPRETIFY_FILE="emterpretify.data"' \
        $extraflags \

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
