if exists("b:did_ftplugin") && exists("b:current_ftplugin") && b:current_ftplugin == 'sql'
finish
endif
let s:save_cpo = &cpo
set cpo&vim
setlocal formatoptions-=t
setlocal formatoptions+=c
if !exists("*SQL_SetType")
function SQL_GetList(ArgLead, CmdLine, CursorPos)
if !exists('s:sql_list')
let list_indent   = globpath(&runtimepath, 'indent/*sql*')
let list_syntax   = globpath(&runtimepath, 'syntax/*sql*')
let list_ftplugin = globpath(&runtimepath, 'ftplugin/*sql*')
let sqls = "\n".list_indent."\n".list_syntax."\n".list_ftplugin."\n"
let sqls = substitute( sqls,
\ '[\n]\%(.\{-}\)\(\w\+\.\w\+\)\n\@=',
\ '\1\n',
\ 'g'
\ )
let index = match(sqls, '.\{-}\ze\n')
while index > -1
let file = matchstr(sqls, '.\{-}\ze\n', index)
let sqls = substitute(sqls, '\%>'.(index+strlen(file)).'c\<'.file.'\>\n', '', 'g')
let index = match(sqls, '.\{-}\ze\n', (index+strlen(file)+1))
endwhile
if v:version >= 700
let mylist = split(sqls, "\n")
let mylist = sort(mylist)
let sqls   = join(mylist, "\n")
endif
let s:sql_list = sqls
endif
return s:sql_list
endfunction
function SQL_SetType(name)
if exists("b:did_ftplugin")
unlet b:did_ftplugin
endif
if exists("b:current_syntax")
syntax clear
if exists("b:current_syntax")
unlet b:current_syntax
endif
endif
if exists("b:did_indent")
unlet b:did_indent
setlocal indentkeys&
setlocal indentexpr&
endif
let new_sql_type = substitute(a:name,
\ '\s*\([^\.]\+\)\(\.\w\+\)\?', '\L\1', '')
if new_sql_type == 'sql'
let new_sql_type = 'sqloracle'
endif
let b:sql_type_override = new_sql_type
if !exists('g:loaded_sql_completion') || g:loaded_sql_completion >= 100
call sqlcomplete#ResetCacheSyntax()
endif
let &filetype = 'sql'
if b:sql_compl_savefunc != ""
call sqlcomplete#PreCacheSyntax()
endif
endfunction
command! -nargs=* -complete=custom,SQL_GetList SQLSetType :call SQL_SetType(<q-args>)
endif
if !exists("*SQL_GetType")
function SQL_GetType()
if exists('b:sql_type_override')
echomsg "Current SQL dialect in use:".b:sql_type_override
else
echomsg "Current SQL dialect in use:".g:sql_type_default
endif
endfunction
command! -nargs=0 SQLGetType :call SQL_GetType()
endif
if exists("b:sql_type_override")
if globpath(&runtimepath, 'ftplugin/'.b:sql_type_override.'.vim') != ''
exec 'runtime ftplugin/'.b:sql_type_override.'.vim'
endif
elseif exists("g:sql_type_default")
if globpath(&runtimepath, 'ftplugin/'.g:sql_type_default.'.vim') != ''
exec 'runtime ftplugin/'.g:sql_type_default.'.vim'
endif
endif
if exists("b:did_ftplugin") && exists("b:current_ftplugin") && b:current_ftplugin == 'sql'
finish
endif
let b:undo_ftplugin = "setl comments< formatoptions< define< omnifunc<" .
\ " | unlet! b:browsefilter b:match_words"
let b:did_ftplugin     = 1
let b:current_ftplugin = 'sql'
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "SQL Files (*.sql)\t*.sql\n" .
\ "All Files (*.*)\t*.*\n"
endif
let s:notend = '\%(\<end\s\+\)\@<!'
let s:when_no_matched_or_others = '\%(\<when\>\%(\s\+\%(\%(\<not\>\s\+\)\?<matched\>\)\|\<others\>\)\@!\)'
let s:or_replace = '\%(or\s\+replace\s\+\)\?'
if !exists("b:match_words")
let b:match_ignorecase = 1
setlocal matchpairs+=<:>
let b:match_words = &matchpairs .
\ ',\%(\<begin\)\%(\s\+\%(try\|catch\)\>\)\@!:\<end\>\W*$,'.
\
\ '\<begin\s\+try\>:'.
\ '\<end\s\+try\>:'.
\ '\<begin\s\+catch\>:'.
\ '\<end\s\+catch\>,'.
\
\ s:notend . '\<if\>:'.
\ '\<elsif\>\|\<elseif\>\|\<else\>:'.
\ '\<end\s\+if\>,'.
\
\ '\(^\s*\)\@<=\(\<\%(do\|for\|while\|loop\)\>.*\):'.
\ '\%(\<exit\>\|\<leave\>\|\<break\>\|\<continue\>\):'.
\ '\%(\<doend\>\|\%(\<end\s\+\%(for\|while\|loop\>\)\)\),'.
\
\ '\%('. s:notend . '\<case\>\):'.
\ '\%('.s:when_no_matched_or_others.'\):'.
\ '\%(\<when\s\+others\>\|\<end\s\+case\>\),' .
\
\ '\<merge\>:' .
\ '\<when\s\+not\s\+matched\>:' .
\ '\<when\s\+matched\>,' .
\
\ '\%(\<create\s\+' . s:or_replace . '\)\?'.
\ '\%(function\|procedure\|event\):'.
\ '\<returns\?\>'
endif
let &l:define = '\c\<\(VARIABLE\|DECLARE\|IN\|OUT\|INOUT\)\>'
nnoremap <buffer> <silent> ]] :call search('\c^\s*begin\>', 'W' )<CR>
nnoremap <buffer> <silent> [[ :call search('\c^\s*begin\>', 'bW' )<CR>
nnoremap <buffer> <silent> ][ :call search('\c^\s*end\W*$', 'W' )<CR>
nnoremap <buffer> <silent> [] :call search('\c^\s*end\W*$', 'bW' )<CR>
xnoremap <buffer> <silent> ]] :<C-U>exec "normal! gv"<Bar>call search('\c^\s*begin\>', 'W' )<CR>
xnoremap <buffer> <silent> [[ :<C-U>exec "normal! gv"<Bar>call search('\c^\s*begin\>', 'bW' )<CR>
xnoremap <buffer> <silent> ][ :<C-U>exec "normal! gv"<Bar>call search('\c^\s*end\W*$', 'W' )<CR>
xnoremap <buffer> <silent> [] :<C-U>exec "normal! gv"<Bar>call search('\c^\s*end\W*$', 'bW' )<CR>
if !exists('g:ftplugin_sql_statements')
let g:ftplugin_sql_statements = 'create'
endif
if !exists('g:ftplugin_sql_objects')
let g:ftplugin_sql_objects = 'function,procedure,event,' .
\ '\(existing\\|global\s\+temporary\s\+\)\{,1}' .
\ 'table,trigger' .
\ ',schema,service,publication,database,datatype,domain' .
\ ',index,subscription,synchronization,view,variable'
endif
if !exists('g:ftplugin_sql_omni_key')
let g:ftplugin_sql_omni_key = '<C-C>'
endif
if !exists('g:ftplugin_sql_omni_key_right')
let g:ftplugin_sql_omni_key_right = '<Right>'
endif
if !exists('g:ftplugin_sql_omni_key_left')
let g:ftplugin_sql_omni_key_left = '<Left>'
endif
let s:ftplugin_sql_objects =
\ '\c^\s*' .
\ '\(\(' .
\ substitute(g:ftplugin_sql_statements, ',\d\@!', '\\\\|', 'g') .
\ '\)\s\+\(or\s\+replace\s\+\)\{,1}\)\{,1}' .
\ '\<\(' .
\ substitute(g:ftplugin_sql_objects, ',\d\@!', '\\\\|', 'g') .
\ '\)\>'
exec "nnoremap <buffer> <silent> ]} :call search('".s:ftplugin_sql_objects."', 'W')<CR>"
exec "nnoremap <buffer> <silent> [{ :call search('".s:ftplugin_sql_objects."', 'bW')<CR>"
exec 'xnoremap <buffer> <silent> ]} /'.s:ftplugin_sql_objects.'<CR>'
exec 'xnoremap <buffer> <silent> [{ ?'.s:ftplugin_sql_objects.'<CR>'
let b:comment_leader = '\(--\\|\/\/\\|\*\\|\/\*\\|\*\/\)'
let b:comment_start  = '^\(\s*'.b:comment_leader.'.*\n\)\@<!'.
\ '\(\s*'.b:comment_leader.'\)'
let b:comment_end = '\(^\s*'.b:comment_leader.'.*\n\)'.
\ '\(^\s*'.b:comment_leader.'\)\@!'
let b:comment_jump_over  = "call search('".
\ '^\(\s*'.b:comment_leader.'.*\n\)\@<!'.
\ "', 'W')"
let b:comment_skip_back  = "call search('".
\ '^\(\s*'.b:comment_leader.'.*\n\)\@<!'.
\ "', 'bW')"
exec 'nnoremap <silent><buffer> ]" :call search('."'".b:comment_start."'".', "W" )<CR>'
exec 'nnoremap <silent><buffer> [" :call search('."'".b:comment_end."'".', "W" )<CR>'
exec 'xnoremap <silent><buffer> ]" :<C-U>exec "normal! gv"<Bar>call search('."'".b:comment_start."'".', "W" )<CR>'
exec 'xnoremap <silent><buffer> [" :<C-U>exec "normal! gv"<Bar>call search('."'".b:comment_end."'".', "W" )<CR>'
setlocal comments=s1:/*,mb:*,ex:*/,:--,://
if exists('&omnifunc')
let b:sql_compl_savefunc = &omnifunc
runtime autoload/sqlcomplete.vim
runtime autoload/syntaxcomplete.vim
setlocal omnifunc=sqlcomplete#Complete
let b:sql_vis = 1
if !exists('g:omni_sql_no_default_maps')
let regex_extra = ''
if exists('g:loaded_syntax_completion') && exists('g:loaded_sql_completion')
if g:loaded_syntax_completion > 120 && g:loaded_sql_completion > 140
let regex_extra = '\\w*'
endif
endif
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'a <C-\><C-O>:call sqlcomplete#Map("syntax")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'k <C-\><C-O>:call sqlcomplete#Map("sqlKeyword'.regex_extra.'")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'f <C-\><C-O>:call sqlcomplete#Map("sqlFunction'.regex_extra.'")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'o <C-\><C-O>:call sqlcomplete#Map("sqlOption'.regex_extra.'")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'T <C-\><C-O>:call sqlcomplete#Map("sqlType'.regex_extra.'")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'s <C-\><C-O>:call sqlcomplete#Map("sqlStatement'.regex_extra.'")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'t <C-\><C-O>:call sqlcomplete#Map("table")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'p <C-\><C-O>:call sqlcomplete#Map("procedure")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'v <C-\><C-O>:call sqlcomplete#Map("view")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'c <C-\><C-O>:call sqlcomplete#Map("column")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'l <C-\><C-O>:call sqlcomplete#Map("column_csv")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'L <C-Y><C-\><C-O>:call sqlcomplete#Map("column_csv")<CR><C-X><C-O>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key_right.' <C-R>=sqlcomplete#DrillIntoTable()<CR>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key_left.'  <C-R>=sqlcomplete#DrillOutOfColumns()<CR>'
exec 'inoremap <buffer> '.g:ftplugin_sql_omni_key.'R <C-\><C-O>:call sqlcomplete#Map("resetCache")<CR><C-X><C-O>'
endif
if b:sql_compl_savefunc != ""
call sqlcomplete#ResetCacheSyntax()
call sqlcomplete#PreCacheSyntax()
endif
endif
let &cpo = s:save_cpo
unlet s:save_cpo
