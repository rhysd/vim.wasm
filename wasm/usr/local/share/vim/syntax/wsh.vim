if exists("b:current_syntax")
finish
endif
let s:wsh_cpo_save = &cpo
set cpo&vim
runtime! syntax/xml.vim
unlet b:current_syntax
syn case ignore
syn include @wshVBScript <sfile>:p:h/vb.vim
unlet b:current_syntax
syn include @wshJavaScript <sfile>:p:h/javascript.vim
unlet b:current_syntax
syn region wshVBScript
\ matchgroup=xmlTag    start="<script[^>]*VBScript\(>\|[^>]*[^/>]>\)"
\ matchgroup=xmlEndTag end="</script>"
\ fold
\ contains=@wshVBScript
\ keepend
syn region wshJavaScript
\ matchgroup=xmlTag    start="<script[^>]*J\(ava\)\=Script\(>\|[^>]*[^/>]>\)"
\ matchgroup=xmlEndTag end="</script>"
\ fold
\ contains=@wshJavaScript
\ keepend
syn cluster xmlRegionHook add=wshVBScript,wshJavaScript
let b:current_syntax = "wsh"
let &cpo = s:wsh_cpo_save
unlet s:wsh_cpo_save
