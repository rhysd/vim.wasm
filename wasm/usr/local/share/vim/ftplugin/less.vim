if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let b:undo_ftplugin = "setl cms< def< inc< inex< ofu< sua<"
setlocal formatoptions-=t formatoptions+=croql
setlocal comments=:// commentstring=//\ %s
setlocal omnifunc=csscomplete#CompleteCSS
setlocal suffixesadd=.less
