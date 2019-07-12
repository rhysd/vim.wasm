if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin=1
if !exists("current_compiler")
:compiler ocaml
endif
if exists('*fnameescape')
function! s:Fnameescape(s)
return fnameescape(a:s)
endfun
else
function! s:Fnameescape(s)
return escape(a:s," \t\n*?[{`$\\%#'\"|!<")
endfun
endif
let s:cposet=&cpoptions
set cpo&vim
setlocal comments=
setlocal commentstring=(*%s*)
if !exists("no_plugin_maps") && !exists("no_ocaml_maps")
if !hasmapto('<Plug>Comment')
nmap <buffer> <LocalLeader>c <Plug>LUncomOn
xmap <buffer> <LocalLeader>c <Plug>BUncomOn
nmap <buffer> <LocalLeader>C <Plug>LUncomOff
xmap <buffer> <LocalLeader>C <Plug>BUncomOff
endif
nnoremap <buffer> <Plug>LUncomOn gI(* <End> *)<ESC>
nnoremap <buffer> <Plug>LUncomOff :s/^(\* \(.*\) \*)/\1/<CR>:noh<CR>
xnoremap <buffer> <Plug>BUncomOn <ESC>:'<,'><CR>`<O<ESC>0i(*<ESC>`>o<ESC>0i*)<ESC>`<
xnoremap <buffer> <Plug>BUncomOff <ESC>:'<,'><CR>`<dd`>dd`<
nmap <buffer> <LocalLeader>s <Plug>OCamlSwitchEdit
nmap <buffer> <LocalLeader>S <Plug>OCamlSwitchNewWin
nmap <buffer> <LocalLeader>t <Plug>OCamlPrintType
xmap <buffer> <LocalLeader>t <Plug>OCamlPrintType
endif
let b:mw =         '\<let\>:\<and\>:\(\<in\>\|;;\)'
let b:mw = b:mw . ',\<if\>:\<then\>:\<else\>'
let b:mw = b:mw . ',\<\(for\|while\)\>:\<do\>:\<done\>'
let b:mw = b:mw . ',\<\(object\|sig\|struct\|begin\)\>:\<end\>'
let b:mw = b:mw . ',\<\(match\|try\)\>:\<with\>'
let b:match_words = b:mw
let b:match_ignorecase=0
function! s:OcpGrep(bang,args) abort
let grepprg = &l:grepprg
let grepformat = &l:grepformat
let shellpipe = &shellpipe
try
let &l:grepprg = "ocp-grep -c never"
setlocal grepformat=%f:%l:%m
if &shellpipe ==# '2>&1| tee' || &shellpipe ==# '|& tee'
let &shellpipe = "| tee"
endif
execute 'grep! '.a:args
if empty(a:bang) && !empty(getqflist())
return 'cfirst'
else
return ''
endif
finally
let &l:grepprg = grepprg
let &l:grepformat = grepformat
let &shellpipe = shellpipe
endtry
endfunction
command! -bar -bang -complete=file -nargs=+ Ocpgrep exe s:OcpGrep(<q-bang>, <q-args>)
if !exists("g:did_ocaml_switch")
let g:did_ocaml_switch = 1
nnoremap <Plug>OCamlSwitchEdit :<C-u>call OCaml_switch(0)<CR>
nnoremap <Plug>OCamlSwitchNewWin :<C-u>call OCaml_switch(1)<CR>
fun OCaml_switch(newwin)
if (match(bufname(""), "\\.mli$") >= 0)
let fname = s:Fnameescape(substitute(bufname(""), "\\.mli$", ".ml", ""))
if (a:newwin == 1)
exec "new " . fname
else
exec "arge " . fname
endif
elseif (match(bufname(""), "\\.ml$") >= 0)
let fname = s:Fnameescape(bufname("")) . "i"
if (a:newwin == 1)
exec "new " . fname
else
exec "arge " . fname
endif
endif
endfun
endif
let lnum = search('^\s*(\*:o\?caml:', 'n')
let s:modeline = lnum? getline(lnum): ""
let s:m = matchstr(s:modeline,'default\s*=\s*\d\+')
if s:m != ""
let s:idef = matchstr(s:m,'\d\+')
elseif exists("g:omlet_indent")
let s:idef = g:omlet_indent
else
let s:idef = 2
endif
let s:m = matchstr(s:modeline,'struct\s*=\s*\d\+')
if s:m != ""
let s:i = matchstr(s:m,'\d\+')
elseif exists("g:omlet_indent_struct")
let s:i = g:omlet_indent_struct
else
let s:i = s:idef
endif
if exists("g:ocaml_folding")
setlocal foldmethod=expr
setlocal foldexpr=OMLetFoldLevel(v:lnum)
endif
let b:undo_ftplugin = "setlocal efm< foldmethod< foldexpr<"
\ . "| unlet! b:mw b:match_words b:match_ignorecase"
if exists("*OMLetFoldLevel")
finish
endif
function s:topindent(lnum)
let l = a:lnum
while l > 0
if getline(l) =~ '\s*\%(\<struct\>\|\<sig\>\|\<object\>\)'
return indent(l)
endif
let l = l-1
endwhile
return -s:i
endfunction
function OMLetFoldLevel(l)
if getline(a:l) !~ '\S'
return -1
endif
if getline(a:l) =~ '^\s*\%(\<val\>\|\<module\>\|\<class\>\|\<type\>\|\<method\>\|\<initializer\>\|\<inherit\>\|\<exception\>\|\<external\>\)'
exe 'return ">' (indent(a:l)/s:i)+1 '"'
endif
if getline(a:l) =~ '^\s*let\>' && indent(a:l) == s:i+s:topindent(a:l)
exe 'return ">' (indent(a:l)/s:i)+1 '"'
endif
if getline(a:l) =~ '^\s*end\>' && synIDattr(synID(a:l, indent(a:l)+1, 0), "name") != "ocamlKeyword"
return (indent(a:l)/s:i)+1
endif
if getline(a:l) =~ '^\s*;;'
exe 'return "<' (indent(a:l)/s:i)+1 '"'
endif
if synIDattr(synID(a:l, indent(a:l)+1, 0), "name") == "ocamlComment"
return -1
endif
return '='
endfunction
function! s:Find_common_path (p1,p2)
let temp = a:p2
while matchstr(a:p1,temp) == ''
let temp = substitute(temp,'/[^/]*$','','')
endwhile
return temp
endfun
function! s:Locate_annotation()
let annot_file_name = s:Fnameescape(expand('%:t:r')).'.annot'
if !exists ("s:annot_file_list[annot_file_name]")
silent exe 'cd' s:Fnameescape(expand('%:p:h'))
let annot_file_path = findfile(annot_file_name,'.')
if annot_file_path != ''
let annot_file_path = getcwd().'/'.annot_file_path
let _build_path = ''
else
let _build_path = finddir('_build','.')
if _build_path != ''
let _build_path = getcwd().'/'._build_path
let annot_file_path           = findfile(annot_file_name,'_build')
if annot_file_path != ''
let annot_file_path = getcwd().'/'.annot_file_path
endif
else
let _build_path = finddir('_build',';')
if _build_path != ''
let project_path                = substitute(_build_path,'/_build$','','')
let path_relative_to_project    = s:Fnameescape(substitute(expand('%:p:h'),project_path.'/','',''))
let annot_file_path           = findfile(annot_file_name,project_path.'/_build/'.path_relative_to_project)
else
let annot_file_path = findfile(annot_file_name,'**')
if annot_file_path != ''
let _build_path = matchstr(annot_file_path,'^[^/]*')
if annot_file_path != ''
let annot_file_path = getcwd().'/'.annot_file_path
let _build_path     = getcwd().'/'._build_path
endif
else
let annot_file_name = ''
endif
endif
endif
endif
if annot_file_path == ''
throw 'E484: no annotation file found'
endif
silent exe 'cd' '-'
let s:annot_file_list[annot_file_name]= [annot_file_path, _build_path, 0]
endif
endfun
let s:annot_file_list = {}
function! s:Enter_annotation_buffer(annot_file_path)
let s:current_pos = getpos('.')
let s:current_hidden = &l:hidden
set hidden
let s:current_buf = bufname('%')
if bufloaded(a:annot_file_path)
silent exe 'keepj keepalt' 'buffer' s:Fnameescape(a:annot_file_path)
else
silent exe 'keepj keepalt' 'view' s:Fnameescape(a:annot_file_path)
endif
call setpos(".", [0, 0 , 0 , 0])
endfun
function! s:Exit_annotation_buffer()
silent exe 'keepj keepalt' 'buffer' s:Fnameescape(s:current_buf)
let &l:hidden = s:current_hidden
call setpos('.',s:current_pos)
endfun
function! s:Load_annotation(annot_file_name)
let annot = s:annot_file_list[a:annot_file_name]
let annot_file_path = annot[0]
let annot_file_last_mod = 0
if exists("annot[2]")
let annot_file_last_mod = annot[2]
endif
if bufloaded(annot_file_path) && annot_file_last_mod < getftime(annot_file_path)
let nr = bufnr(annot_file_path)
silent exe 'keepj keepalt' 'bunload' nr
endif
if !bufloaded(annot_file_path)
call s:Enter_annotation_buffer(annot_file_path)
setlocal nobuflisted
setlocal bufhidden=hide
setlocal noswapfile
setlocal buftype=nowrite
call s:Exit_annotation_buffer()
let annot[2] = getftime(annot_file_path)
let s:annot_file_list[a:annot_file_name] = annot
endif
endfun
function! s:Block_pattern(lin1,lin2,col1,col2)
let start_num1 = a:lin1
let start_num2 = line2byte(a:lin1) - 1
let start_num3 = start_num2 + a:col1
let path       = '"\(\\"\|[^"]\)\+"'
let start_pos  = path.' '.start_num1.' '.start_num2.' '.start_num3
let end_num1   = a:lin2
let end_num2   = line2byte(a:lin2) - 1
let end_num3   = end_num2 + a:col2
let end_pos    = path.' '.end_num1.' '.end_num2.' '.end_num3
return '^'.start_pos.' '.end_pos."$"
endfun
function! s:Match_data()
keepj while search('^type($','ce',line(".")) == 0
keepj if search('^.\{-}($','e') == 0
throw "no_annotation"
endif
keepj if searchpair('(','',')') == 0
throw "malformed_annot_file"
endif
endwhile
let begin = line(".") + 1
keepj if searchpair('(','',')') == 0
throw "malformed_annot_file"
endif
let end = line(".") - 1
return join(getline(begin,end),"\n")
endfun
function! s:Extract_type_data(block_pattern, annot_file_name)
let annot_file_path = s:annot_file_list[a:annot_file_name][0]
call s:Enter_annotation_buffer(annot_file_path)
try
if search(a:block_pattern,'e') == 0
throw "no_annotation"
endif
call cursor(line(".") + 1,1)
let annotation = s:Match_data()
finally
call s:Exit_annotation_buffer()
endtry
return annotation
endfun
let s:ocaml_word_char = '\w|[À-ÿ]|'''
function! s:Match_borders(mode)
if a:mode == "visual"
let cur = getpos(".")
normal `<
let col1 = col(".")
let lin1 = line(".")
normal `>
let col2 = col(".")
let lin2 = line(".")
call cursor(cur[1],cur[2])
return [lin1,lin2,col1-1,col2]
else
let cursor_line = line(".")
let cursor_col  = col(".")
let line = getline('.')
if line[cursor_col-1:cursor_col] == '[|'
let [lin2,col2] = searchpairpos('\[|','','|\]','n')
return [cursor_line,lin2,cursor_col-1,col2+1]
elseif     line[cursor_col-1] == '['
let [lin2,col2] = searchpairpos('\[','','\]','n')
return [cursor_line,lin2,cursor_col-1,col2]
elseif line[cursor_col-1] == '('
let [lin2,col2] = searchpairpos('(','',')','n')
return [cursor_line,lin2,cursor_col-1,col2]
elseif line[cursor_col-1] == '{'
let [lin2,col2] = searchpairpos('{','','}','n')
return [cursor_line,lin2,cursor_col-1,col2]
else
let [lin1,col1] = searchpos('\v%('.s:ocaml_word_char.'|\.)*','ncb')
let [lin2,col2] = searchpos('\v%('.s:ocaml_word_char.'|\.)*','nce')
if col1 == 0 || col2 == 0
throw "no_expression"
endif
return [cursor_line,cursor_line,col1-1,col2]
endif
endif
endfun
function! s:Get_type(mode, annot_file_name)
let [lin1,lin2,col1,col2] = s:Match_borders(a:mode)
return s:Extract_type_data(s:Block_pattern(lin1,lin2,col1,col2), a:annot_file_name)
endfun
function s:unformat_ocaml_type(res)
let res = substitute (a:res, "\n", "", "g" )
let res =substitute(res , "  ", " ", "g")
let res = substitute(res, "^ *", "", "g")
return res
endfunction
if !exists("*Ocaml_get_type")
function Ocaml_get_type(mode)
let annot_file_name = s:Fnameescape(expand('%:t:r')).'.annot'
call s:Locate_annotation()
call s:Load_annotation(annot_file_name)
let res = s:Get_type(a:mode, annot_file_name)
let @" = s:unformat_ocaml_type(res)
return res
endfun
endif
if !exists("*Ocaml_get_type_or_not")
function Ocaml_get_type_or_not(mode)
let t=reltime()
try
let res = Ocaml_get_type(a:mode)
return res
catch
return ""
endtry
endfun
endif
if !exists("*Ocaml_print_type")
function Ocaml_print_type(mode)
if expand("%:e") == "mli"
echohl ErrorMsg | echo "No annotations for interface (.mli) files" | echohl None
return
endif
try
echo Ocaml_get_type(a:mode)
catch /E484:/
echohl ErrorMsg | echo "No type annotations (.annot) file found" | echohl None
catch /no_expression/
echohl ErrorMsg | echo "No expression found under the cursor" | echohl None
catch /no_annotation/
echohl ErrorMsg | echo "No type annotation found for the given text" | echohl None
catch /malformed_annot_file/
echohl ErrorMsg | echo "Malformed .annot file" | echohl None
endtry
endfun
endif
nnoremap <silent> <Plug>OCamlPrintType :<C-U>call Ocaml_print_type("normal")<CR>
xnoremap <silent> <Plug>OCamlPrintType :<C-U>call Ocaml_print_type("visual")<CR>`<
let &cpoptions=s:cposet
unlet s:cposet
