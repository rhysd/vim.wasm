#!/bin/bash

set -e

if [ ! -d .git ]; then
    echo 'build.sh must be run from repository root' 1>&2
    exit 1
fi

run_configure() {
    echo "build.sh: Running ./configure"
    CPP="gcc -E" emconfigure ./configure \
        --enable-fail-if-missing \
        --enable-gui=wasm \
        --with-features=tiny \
        --with-x=no \
        --with-vim-name=vim.bc \
        --with-modified-by=rhysd \
        --with-compiledby=rhysd \
        --disable-darwin \
        --disable-smack \
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
        --disable-netbeans \
        --disable-channel \
        --disable-terminal \
        --disable-autoservername \
        --disable-rightleft \
        --disable-arabic \
        --disable-hangulinput \
        --disable-xim \
        --disable-fontset \
        --disable-gtk2-check \
        --disable-gnome-check \
        --disable-gtk3-check \
        --disable-motif-check \
        --disable-athena-check \
        --disable-nextaw-check \
        --disable-carbon-check \
        --disable-gtktest \
        --disable-icon-cache-update \
        --disable-desktop-database-update \
        --disable-largefile \
        --disable-canberra \
        --disable-acl \
        --disable-gpm \
        --disable-sysmouse \
        --disable-nls
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
        # Note: -g4 generates sourcemap
        extraflags="-O0 -g4 -s ASSERTIONS=1"
    else
        extraflags="-Os"
    fi

    cd wasm/

    if [ ! -f tutor ]; then
        cp ../runtime/tutor/tutor .
    fi

    emcc vim.bc \
        -v \
        -o vim.js \
        --pre-js pre.js \
        --js-library runtime.js \
        -s INVOKE_RUN=1 \
        -s EXIT_RUNTIME=1 \
        -s "EXPORTED_FUNCTIONS=['_wasm_main','_gui_wasm_resize_shell','_gui_wasm_handle_keydown', '_gui_wasm_handle_drop', '_gui_wasm_set_clip_avail', '_gui_wasm_do_cmdline']" \
        -s "EXTRA_EXPORTED_RUNTIME_METHODS=['cwrap']" \
        --preload-file usr \
        --preload-file tutor \
        $extraflags

    if [[ "$RELEASE" != "" ]]; then
        npm run minify
    fi

    cd -
}

run_release() {
    echo "build.sh: Cleaning built files"
    rm -rf wasm/*
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
    cd -
}

run_check() {
    echo "build.sh: Checking built artifacts"
    cd wasm/
    npm run lint
    if [[ "$RELEASE" != "" ]]; then
        npm test
    fi
    cd -
}

run_deploy() {
    echo "build.sh: Deploying gh-pages"
    local hash
    hash="$(git rev-parse HEAD)"

    cp wasm/style.css _style.css
    cp wasm/main.js _main.js
    cp wasm/vimwasm.js _vimwasm.js
    cp wasm/index.html _index.html
    cp -R wasm/images _images

    git checkout gh-pages

    mv _style.css style.css
    mv _main.js main.js
    mv _vimwasm.js vimwasm.js
    mv _index.html index.html
    mv _images/vim-wasm-logo-16x16.png images/
    mv _images/vim-wasm-logo-32x32.png images/

    cp wasm/vim.* .
    rm -rf vim.bc vim.wast vim.wasm.map _images

    git add vim.* index.html style.css main.js vimwasm.js images
    git commit -m "Deploy from ${hash}"
    echo "build.sh: New commit created from ${hash}. Please check diff with 'git show' and deploy it with 'git push'"
}

run_merge-upstream() {
    echo "build.sh: Running tools/merge_upstream_for_wasm.bash"
    ./tools/merge_upstream_for_wasm.bash
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
    run_check
fi

echo "Done."
