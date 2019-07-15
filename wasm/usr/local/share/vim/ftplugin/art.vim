if exists("b:did_ftplugin")
finish
endif
run ftplugin/lisp.vim
setl lw-=if
setl lw+=def-art-fun,deffacts,defglobal,defrule,defschema,for,schema,while
