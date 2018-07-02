#!/bin/bash

set -e

if [ ! -d .git ]; then
    echo 'build.sh must be run from repository root' 1>&2
    exit 1
fi

run_configure() {
    echo "Running ./configure"
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
    echo "Running make"
    emmake make -j
    echo "Copying bitcode to wasm/"
    cp src/vim wasm/vim.bc

    echo "Building HTML/JS/Wasm with emcc"
    cd wasm/
    emcc vim.bc -o vim.html
}

if [[ "$1" != "" ]]; then
    "run_$1"
else
    run_configure
    run_make
fi

echo "Done."
