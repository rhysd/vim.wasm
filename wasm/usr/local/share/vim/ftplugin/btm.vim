if exists("b:did_ftplugin")
finish
endif
runtime! ftplugin/dosbatch.vim ftplugin/dosbatch_*.vim ftplugin/dosbatch/*.vim
