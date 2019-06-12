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
        --disable-terminal
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
    echo "build.sh: Building JS/Wasm for web worker with emcc"

    local extraflags
    if [[ "$RELEASE" == "" ]]; then
        # TODO: EMCC_DEBUG=1
        # TODO: STACK_OVERFLOW_CHECK=1
        # TODO: --js-opts 0
        extraflags="-O0 -g -s ASSERTIONS=1"
    else
        extraflags="-Os"
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
        -o vim.js \
        --pre-js pre.js \
        --js-library runtime.js \
        -s "EXPORTED_FUNCTIONS=['_wasm_main','_gui_wasm_send_key','_gui_wasm_resize_shell']" \
        -s "EXTRA_EXPORTED_RUNTIME_METHODS=['cwrap']" \
        --preload-file usr --preload-file tutor \
        $extraflags
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
    npm run lint
    npm run build
    if [[ "$RELEASE" != "" ]]; then
        npm run minify
    fi
    cd -
}

run_deploy() {
    echo "build.sh: Deploying gh-pages"
    local hash
    hash="$(git rev-parse HEAD)"
    cp wasm/style.css _style.css
    cp wasm/main.js _main.js
    cp wasm/index.html _index.html
    cp -R wasm/images _images
    git checkout gh-pages
    mv _style.css style.css
    mv _main.js main.js
    mv _index.html index.html
    mv _images images
    cp wasm/vim.* .
    rm -f vim.bc vim.wast
    git add vim.* index.html style.css main.js images
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
