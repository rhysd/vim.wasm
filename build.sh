#!/bin/bash

set -e

if [ ! -d .git ]; then
    echo 'build.sh must be run from repository root' 1>&2
    exit 1
fi

message() {
    echo "[1;93mbuild.sh: ${*}[0m"
}

run_configure() {
    local feature
    if [[ "$VIM_FEATURE" == "" ]]; then
        feature='normal'
    else
        feature="$VIM_FEATURE"
    fi
    message "Running ./configure: feature=${feature}"
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
    message "Running make"
    local cflags
    if [[ "$RELEASE" == "" ]]; then
        cflags="-O1 -g -DGUI_WASM_DEBUG"
    else
        cflags="-Os"
    fi
    emmake make -j CFLAGS="$cflags"
    message "Copying bitcode to wasm/"
    cp src/vim.bc wasm/
}

run_emcc() {
    local feature
    local feature_dir
    local src_prefix
    if [[ "$VIM_FEATURE" == "" ]]; then
        feature='normal'
        feature_dir='./wasm'
        src_prefix=''
    else
        feature="$VIM_FEATURE"
        feature_dir="./wasm/${VIM_FEATURE}"
        src_prefix='../'
    fi

    local extraflags
    if [[ "$RELEASE" == "" ]]; then
        # Note: -g4 generates sourcemap
        extraflags="-O0 -g4 -s ASSERTIONS=1"
    else
        extraflags="-Os"
    fi

    message "Running emcc: feature=${feature} flags=${extraflags}"

    cd "$feature_dir"

    if [[ "$PRELOAD_HOME_DIR" != "" && -d ./home ]]; then
        cp ${src_prefix}README.md "./home/web_user/"
        extraflags="${extraflags} --preload-file home"
    fi

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
        npm run minify:common
        npm run "minify:${feature}"
    fi

    cd -
}

run_release() {
    message "Cleaning built files"
    rm -rf wasm/*
    git checkout wasm/
    message "Start release build"
    RELEASE=true ./build.sh
    message "Release build done"
}

# Build both normal feature and small feature
run_release-all() {
    message "Release builds for all features: normal, small"

    run_release

    message "Start release build for small feature"
    make clean
    RELEASE=true VIM_FEATURE=small ./build.sh configure make emcc
    message "Release build done for small feature"
}

run_build_runtime() {
    message "Building runtime JavaScript sources"
    cd wasm/
    npm install
    npm run build
    cd -
}

run_check() {
    message "Checking built artifacts"
    cd wasm/
    npm run lint
    if [[ "$RELEASE" != "" ]]; then
        npm test
    fi
    cd -
}

run_gh-pages() {
    message "Preparing new commit on gh-pages branch"
    local hash
    hash="$(git rev-parse HEAD)"

    cp wasm/style.css _style.css
    cp wasm/main.js _main.js
    cp wasm/vimwasm.js _vimwasm.js
    cp wasm/index.html _index.html
    cp -R wasm/images _images

    mkdir _small
    cp wasm/small/vim.* _small/

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

    mv _small small

    # XXX: Hack for GitHub pages.
    # GitHub pages does not compress binary data file vim.data on sending it to browser. To force
    # GitHub pages to compress it with gzip encoding, vim.data is renamed to vim.data.bmp for fake.
    # GitHub pages recognizes this file as BMP and compress it with gzip.
    sed -i '' -E 's/"vim.data"/"vim.data.bmp"/g' vim.js
    mv vim.data vim.data.bmp

    git add vim.* index.html style.css main.js vimwasm.js images small
    git commit -m "Deploy from ${hash}"
    message "New commit created from ${hash}. Please check diff with 'git show' and deploy it with 'git push'"
}

run_deploy() {
    message "Before deploying gh-pages, run release build"
    export PRELOAD_HOME_DIR=true
    run_release-all

    message "Deploying gh-pages"
    run_gh-pages
}

run_merge-upstream() {
    message "Running tools/merge_upstream_for_wasm.bash"
    ./tools/merge_upstream_for_wasm.bash
}

run_prepare-preload() {
    message "Running tools/prepare_preload_dirs.bash"
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

message "Done."
