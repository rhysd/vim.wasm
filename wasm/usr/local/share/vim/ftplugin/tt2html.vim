if exists("b:did_ftplugin")
finish
endif
runtime! ftplugin/html.vim ftplugin/html_*.vim ftplugin/html/*.vim
