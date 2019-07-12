if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
let b:undo_ftplugin = 'setlocal iskeyword< define< formatoptions< comments< commentstring< lispwords<'
setlocal iskeyword+=?,-,*,!,+,/,=,<,>,.,:,$
setlocal define=\\v[(/]def(ault)@!\\S*
setlocal formatoptions-=t
setlocal comments=n:;
setlocal commentstring=;\ %s
setlocal lispwords=as->,binding,bound-fn,case,catch,cond->,cond->>,condp,def,definline,definterface,defmacro,defmethod,defmulti,defn,defn-,defonce,defprotocol,defrecord,defstruct,deftest,deftest-,deftype,doseq,dotimes,doto,extend,extend-protocol,extend-type,fn,for,if,if-let,if-not,if-some,let,letfn,locking,loop,ns,proxy,reify,set-test,testing,when,when-first,when-let,when-not,when-some,while,with-bindings,with-in-str,with-local-vars,with-open,with-precision,with-redefs,with-redefs-fn,with-test
for s:setting in ['omnifunc', 'completefunc']
if exists('&' . s:setting) && empty(eval('&' . s:setting))
execute 'setlocal ' . s:setting . '=clojurecomplete#Complete'
let b:undo_ftplugin .= ' | setlocal ' . s:setting . '<'
endif
endfor
if exists('$CLOJURE_SOURCE_DIRS')
for s:dir in split($CLOJURE_SOURCE_DIRS, (has("win32") || has("win64")) ? ';' : ':')
let s:dir = fnameescape(s:dir)
let s:dir = substitute(s:dir, '\', '\\\\', 'g')
let s:dir = substitute(s:dir, '\ ', '\\ ', 'g')
execute "setlocal path+=" . s:dir . "/**"
endfor
let b:undo_ftplugin .= ' | setlocal path<'
endif
if exists('loaded_matchit')
let b:match_words = &matchpairs
let b:match_skip = 's:comment\|string\|regex\|character'
let b:undo_ftplugin .= ' | unlet! b:match_words b:match_skip'
endif
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "Clojure Source Files (*.clj)\t*.clj\n" .
\ "ClojureScript Source Files (*.cljs)\t*.cljs\n" .
\ "Java Source Files (*.java)\t*.java\n" .
\ "All Files (*.*)\t*.*\n"
let b:undo_ftplugin .= ' | unlet! b:browsefilter'
endif
let &cpo = s:cpo_save
unlet! s:cpo_save s:setting s:dir
