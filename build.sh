#!/bin/bash

set -e

if [ ! -d .git ]; then
    echo 'build.sh must be run from repository root' 1>&2
    exit 1
fi

run_configure() {
    local feature
    if [[ "$VIM_FEATURE" == "" ]]; then
        feature='normal'
    else
        feature="$VIM_FEATURE"
    fi
    echo "build.sh: Running ./configure: feature=${feature}"
    CPP="gcc -E" emconfigure ./configure \
        --enable-fail-if-missing \
        --enable-gui=wasm \
        "--with-features=${feature}" \
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
    local feature
    local prefix
    local src_prefix
    if [[ "$VIM_FEATURE" == "" ]]; then
        feature='normal'
        prefix=''
        src_prefix=''
    else
        feature="$VIM_FEATURE"
        prefix="${VIM_FEATURE}/"
        src_prefix='../'
    fi

    echo "build.sh: Building JS/Wasm for web worker with emcc: feature=${feature}"

    local extraflags
    if [[ "$RELEASE" == "" ]]; then
        # Note: -g4 generates sourcemap
        extraflags="-O0 -g4 -s ASSERTIONS=1"
    else
        extraflags="-Os"
    fi

    if [[ "$PRELOAD_HOME_DIR" != "" ]]; then
        cp ./wasm/README.md ./wasm/home/web_user/
        extraflags="${extraflags} --preload-file home"
    fi

    cd "wasm/$prefix"

    if [ ! -f tutor ]; then
        cp "${src_prefix}../runtime/tutor/tutor" .
    fi

    # Note: ALLOW_MEMORY_GROWTH is necessary because 'normal' feature build requires larger memory size
    emcc "${src_prefix}vim.bc" \
        -v \
        -o vim.js \
        --pre-js "${src_prefix}pre.js" \
        --js-library "${src_prefix}runtime.js" \
        -s INVOKE_RUN=1 \
        -s EXIT_RUNTIME=1 \
        -s ALLOW_MEMORY_GROWTH=1 \
        -s "EXPORTED_FUNCTIONS=['_wasm_main','_gui_wasm_resize_shell','_gui_wasm_handle_keydown', '_gui_wasm_handle_drop', '_gui_wasm_set_clip_avail', '_gui_wasm_do_cmdline', '_gui_wasm_emsg']" \
        -s "EXTRA_EXPORTED_RUNTIME_METHODS=['cwrap']" \
        --preload-file usr \
        --preload-file tutor \
        $extraflags

    if [[ "$RELEASE" != "" ]]; then
        if [[ "$feature" == "normal" ]]; then
            npm run minify
        else
            npm run minify:small
        fi
    fi

    cd -
}

run_release() {
    echo "build.sh: Cleaning built files"
    rm -rf wasm/*
    git checkout wasm/
    export RELEASE=true
    echo "build.sh: Start release build"
    ./build.sh
    echo "build.sh: Release build done"
}

# Build both normal feature and small feature
run_release-all() {
    echo "build.sh: Release build for all features: normal, small"
    echo "build.sh: Cleaning built files"
    rm -rf wasm/*
    git checkout wasm/
    export RELEASE=true
    echo "build.sh: Start release build for normal feature"
    ./build.sh
    echo "build.sh: Release build done for normal feature"
    echo "build.sh: Start release build for small feature"
    make distclean
    VIM_FEATURE=small ./build.sh configure make emcc
    echo "build.sh: Release build done for normal feature"
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

run_gh-pages() {
    echo "build.sh: Preparing new commit on gh-pages branch"
    local hash
    hash="$(git rev-parse HEAD)"

    cp wasm/style.css _style.css
    cp wasm/main.js _main.js
    cp wasm/vimwasm.js _vimwasm.js
    cp wasm/index.html _index.html
    cp -R wasm/images _images

    git checkout gh-pages
    git pull --rebase

    mv _style.css style.css
    mv _main.js main.js
    mv _vimwasm.js vimwasm.js
    mv _index.html index.html
    mv _images/vim-wasm-logo-16x16.png images/
    mv _images/vim-wasm-logo-32x32.png images/

    cp wasm/vim.* .
    rm -rf vim.bc vim.wast vim.wasm.map _images

    # XXX: Hack for GitHub pages.
    # GitHub pages does not compress binary data file vim.data on sending it to browser. To force
    # GitHub pages to compress it with gzip encoding, vim.data is renamed to vim.data.bmp for fake.
    # GitHub pages recognizes this file as BMP and compress it with gzip.
    sed -i '' -E 's/"vim.data"/"vim.data.bmp"/g' vim.js
    mv vim.data vim.data.bmp

    git add vim.* index.html style.css main.js vimwasm.js images
    git commit -m "Deploy from ${hash}"
    echo "build.sh: New commit created from ${hash}. Please check diff with 'git show' and deploy it with 'git push'"
}

run_deploy() {
    echo "build.sh: Before deploying gh-pages, run release build"
    export PRELOAD_HOME_DIR=true
    run_release

    echo "build.sh: Deploying gh-pages"
    run_gh-pages
}

run_merge-upstream() {
    echo "build.sh: Running tools/merge_upstream_for_wasm.bash"
    ./tools/merge_upstream_for_wasm.bash
}

run_prepare-preload() {
    echo "build.sh: Running tools/prepare_preload_dirs.bash"
    ./tools/prepare_preload_dir.bash
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
