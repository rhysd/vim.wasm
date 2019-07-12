#!/bin/bash

set -e

copy_dirs=('' '/autoload' '/ftplugin' '/indent' '/plugin' '/syntax')
echo 'Copying Vim scripts in' "${copy_dirs[@]}" '...'
for dir in "${copy_dirs[@]}"; do
    cp -R "./runtime${dir}"/*.vim "./wasm/usr/local/share/vim${dir}/"
done

echo 'Overwriting default runtime files...'
function download_typescript_file() {
    curl -s "https://raw.githubusercontent.com/leafgarland/typescript-vim/master/${1}/typescript.vim" >"./wasm/usr/local/share/vim/${1}/typescript.vim"
}
download_typescript_file 'ftplugin'
download_typescript_file 'indent'
download_typescript_file 'syntax'

blacklist=(
    bugreport.vim
    defaults.vim
    delmenu.vim
    evim.vim
    gvimrc_example.vim
    macmap.vim
    makemenu.vim
    menu.vim
    mswin.vim
    optwin.vim
    synmenu.vim
    vimrc_example.vim
)
echo 'Removing unnecessary files' "${blacklist[@]}" '...'
for file in "${blacklist[@]}"; do
    rm "./wasm/usr/local/share/vim/${file}"
done

echo 'Striping comments and indents in the Vim scripts...'
export LC_ALL=C
files="$(find ./wasm/usr/local/share/vim -type f -name '*.vim')"
remove_comments='/^[[:space:]]*(".*)?$/d'
remove_indents='s/^[[:space:]]*//g'
sed -i '' -E -e "$remove_comments" -e "$remove_indents" $files
