if exists("b:did_8thplugin")
finish
endif
let b:did_8thplugin = 1
setlocal ts=2 sts=2 sw=2 et
setlocal com=s1:/*,mb:*,ex:*/,:\|,:\\
setlocal fo=tcrqol
setlocal matchpairs+=\::;
setlocal iskeyword=!,@,33-35,%,$,38-64,A-Z,91-96,a-z,123-126,128-255
setlocal suffixesadd=.8th
