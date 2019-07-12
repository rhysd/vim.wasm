if exists("b:did_ftplugin") | finish | endif
runtime! ftplugin/xml.vim ftplugin/xml_*.vim ftplugin/xml/*.vim
let b:did_ftplugin = 1
if has("gui_win32") && exists("b:browsefilter")
let  b:browsefilter="XSLT Files (*.xsl,*.xslt)\t*.xsl;*.xslt\n" . b:browsefilter
endif
