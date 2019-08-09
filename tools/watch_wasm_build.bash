#!/bin/bash

# Assumed to be run via `./build.sh watch`

set -e

# Sometimes ./ is prefixed and sometimes not prefixed
# Ensure to remove the prefix.
path="${1#./}"

message() {
    echo "[1;96m${1}[0m"
}

run() {
    message "Running $*"
    "$@"
}


message "[$(date '+%H:%M:%S %m/%d/%Y')] $path"

case "$path" in
    src/*) run ./build.sh make ;;
    wasm/.eslintrc.js) cd wasm && run npm run eslint ;;
    wasm/karma.conf.js) cd wasm && run npm test ;;
    wasm/runtime.js) run ./build.sh emcc ;;
    wasm/vim.bc) run ./build.sh emcc ;;
    wasm/test/*.js)
        cd wasm
        npm test -- --pattern "${path#wasm/}"
        ;;
    wasm/vtest/*.js) cd wasm && run npm run vtest ;;
    wasm/usr/*) run ./build.sh emcc ;;
    *) message "Ignored: $path" ;;
esac

echo "[1;92mOK[0m"
