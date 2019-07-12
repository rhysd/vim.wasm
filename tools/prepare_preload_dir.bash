#!/bin/bash

set -e

copy_dirs=('' '/autoload' '/ftplugin' '/indent' '/plugin' '/syntax')
echo 'Copying Vim scripts in' "${copy_dirs[@]}" '...'
for dir in "${copy_dirs[@]}"; do
    cp -R "./runtime${dir}"/*.vim "./wasm/usr/local/share/vim${dir}/"
done

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
