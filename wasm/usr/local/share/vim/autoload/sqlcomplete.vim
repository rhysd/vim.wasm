if exists('&omnifunc')
if &omnifunc == ""
setlocal omnifunc=sqlcomplete#Complete
endif
endif
if exists('g:loaded_sql_completion')
finish
endif
let g:loaded_sql_completion = 160
let s:keepcpo= &cpo
set cpo&vim
let s:sql_file_table        = ""
let s:sql_file_procedure    = ""
let s:sql_file_view         = ""
let s:tbl_name              = []
let s:tbl_alias             = []
let s:tbl_cols              = []
let s:syn_list              = []
let s:syn_value             = []
let s:save_inc              = ""
let s:save_exc              = ""
if !exists('g:omni_syntax_group_include_sql')
let g:omni_syntax_group_include_sql = ''
endif
if !exists('g:omni_syntax_group_exclude_sql')
let g:omni_syntax_group_exclude_sql = ''
endif
let s:save_inc = g:omni_syntax_group_include_sql
let s:save_exc = g:omni_syntax_group_exclude_sql
let s:save_prev_table       = ""
if !exists('g:omni_sql_use_tbl_alias')
let g:omni_sql_use_tbl_alias = 'a'
endif
if !exists('g:omni_sql_precache_syntax_groups')
let g:omni_sql_precache_syntax_groups = [
\ 'syntax\w*',
\ 'sqlKeyword\w*',
\ 'sqlFunction\w*',
\ 'sqlOption\w*',
\ 'sqlType\w*',
\ 'sqlStatement\w*'
\ ]
endif
if !exists('g:omni_sql_ignorecase')
let g:omni_sql_ignorecase = &ignorecase
endif
if !exists('g:omni_sql_include_owner')
let g:omni_sql_include_owner = 0
if exists('g:loaded_dbext')
if g:loaded_dbext >= 300
let g:omni_sql_include_owner = 1
endif
endif
endif
if !exists('g:omni_sql_default_compl_type')
let g:omni_sql_default_compl_type = 'table'
endif
function! sqlcomplete#Complete(findstart, base)
let compl_type = 'table'
if exists('b:sql_compl_type')
let compl_type = b:sql_compl_type
endif
let begindot = 0
if a:findstart
let line     = getline('.')
let start    = col('.') - 1
let lastword = -1
if line[start - 1] == '.'
let begindot = 1
endif
while start > 0
if line[start - 1] !~ '\(\w\|\.\)'
break
elseif line[start - 1] =~ '\w'
let start -= 1
elseif line[start - 1] =~ '\.' &&
\ compl_type =~ 'column\|table\|view\|procedure'
if lastword != -1 && compl_type == 'column'
\ && g:omni_sql_include_owner == 0
break
endif
if lastword == -1 && compl_type == 'column' && begindot == 1
let lastword = start
endif
if lastword == -1 &&
\ compl_type =~ '\<\(table\|view\|procedure\|column\|column_csv\)\>' &&
\ g:omni_sql_include_owner == 0
let lastword = start
break
endif
let start -= 1
else
break
endif
endwhile
if lastword == -1
let s:prepended = ''
return start
endif
let s:prepended = strpart(line, start, lastword - start)
return lastword
endif
let base = s:prepended . a:base
let compl_list = []
let compl_type = g:omni_sql_default_compl_type
if exists('b:sql_compl_type')
let compl_type = b:sql_compl_type
unlet b:sql_compl_type
endif
if compl_type == 'tableReset'
let compl_type = 'table'
let base = ''
endif
if compl_type == 'table' ||
\ compl_type == 'procedure' ||
\ compl_type == 'view'
if s:SQLCCheck4dbext() == -1
return []
endif
if g:loaded_dbext >= 300
let saveSetting = DB_listOption('dict_show_owner')
exec 'DBSetOption dict_show_owner='.(g:omni_sql_include_owner==1?'1':'0')
endif
let compl_type_uc = substitute(compl_type, '\w\+', '\u&', '')
let s:sql_file_{compl_type} = DB_getDictionaryName(compl_type_uc)
if s:sql_file_{compl_type} != ""
if filereadable(s:sql_file_{compl_type})
let compl_list = readfile(s:sql_file_{compl_type})
endif
endif
if g:loaded_dbext > 300
exec 'DBSetOption dict_show_owner='.saveSetting
endif
elseif compl_type =~? 'column'
if s:SQLCCheck4dbext() == -1
return []
endif
if base == ""
let base = s:save_prev_table
endif
let owner  = ''
let column = ''
if base =~ '\.'
let owner  = matchstr( base, '^\zs.*\ze\..*\..*' )
let table  = matchstr( base, '^\(.*\.\)\?\zs.*\ze\..*' )
let column = matchstr( base, '.*\.\zs.*' )
if g:omni_sql_include_owner == 1 && owner == '' && table != '' && column != ''
let owner  = table
let table  = column
let column = ''
endif
let found = -1
if g:omni_sql_include_owner == 1 && owner == ''
if filereadable(s:sql_file_table)
let tbl_list = readfile(s:sql_file_table)
let found    = index( tbl_list, ((table != '')?(table.'.'):'').column)
endif
endif
else
if compl_type == 'column' && s:save_prev_table != ''
let table     = s:save_prev_table
let list_type = ''
let compl_list  = s:SQLCGetColumns(table, list_type)
if ! empty(compl_list)
let compl_list = filter(deepcopy(compl_list), 'v:val=~"^'.base.'"' )
if ! empty(compl_list)
return compl_list
endif
endif
endif
let table  = base
endif
if table != ""
let s:save_prev_table = base
let list_type         = ''
if compl_type == 'column_csv'
let list_type     = 'csv'
endif
if g:omni_sql_include_owner == 1 && owner != '' && table != ''
let compl_list  = s:SQLCGetColumns(owner.'.'.table, list_type)
else
let compl_list  = s:SQLCGetColumns(table, list_type)
endif
if column != ''
let compl_list = map(compl_list, 'table.".".v:val')
if owner != ''
let compl_list = map(compl_list, 'owner.".".v:val')
endif
else
let base = ''
endif
if compl_type == 'column_csv'
let compl_list        = [join(compl_list, ', ')]
endif
endif
elseif compl_type == 'resetCache'
let s:tbl_name           = []
let s:tbl_alias          = []
let s:tbl_cols           = []
let s:syn_list           = []
let s:syn_value          = []
if s:sql_file_table != ""
if g:loaded_dbext >= 2300
call DB_DictionaryDelete("table")
else
DBCompleteTables!
endif
endif
if s:sql_file_procedure != ""
if g:loaded_dbext >= 2300
call DB_DictionaryDelete("procedure")
else
DBCompleteProcedures!
endif
endif
if s:sql_file_view != ""
if g:loaded_dbext >= 2300
call DB_DictionaryDelete("view")
else
DBCompleteViews!
endif
endif
let s:sql_file_table     = ""
let s:sql_file_procedure = ""
let s:sql_file_view      = ""
let msg = "All SQL cached items have been removed."
call s:SQLCWarningMsg(msg)
:sleep 2
else
let compl_list = s:SQLCGetSyntaxList(compl_type)
endif
if base != ''
let expr = 'v:val '.(g:omni_sql_ignorecase==1?'=~?':'=~#').' "\\(^'.base.'\\|^\\(\\w\\+\\.\\)\\?'.base.'\\)"'
let compl_list = filter(deepcopy(compl_list), expr)
if empty(compl_list) && compl_type == 'table' && base =~ '\.$'
let list_type = ''
let compl_list  = s:SQLCGetColumns(base, list_type)
endif
endif
if exists('b:sql_compl_savefunc') && b:sql_compl_savefunc != ""
let &omnifunc = b:sql_compl_savefunc
endif
if empty(compl_list)
call s:SQLCWarningMsg( 'Could not find type['.compl_type.'] using prepend[.'.s:prepended.'] base['.a:base.']' )
endif
return compl_list
endfunc
function! sqlcomplete#PreCacheSyntax(...)
let syn_group_arr = []
let syn_items     = []
if a:0 > 0
if type(a:1) != 3
call s:SQLCWarningMsg("Parameter is not a list. Example:['syntaxGroup1', 'syntaxGroup2']")
return ''
endif
let syn_group_arr = a:1
else
let syn_group_arr = g:omni_sql_precache_syntax_groups
endif
if !empty(syn_group_arr)
for group_name in syn_group_arr
let syn_items = extend( syn_items, s:SQLCGetSyntaxList(group_name) )
endfor
endif
return syn_items
endfunction
function! sqlcomplete#ResetCacheSyntax(...)
let syn_group_arr = []
if a:0 > 0
if type(a:1) != 3
call s:SQLCWarningMsg("Parameter is not a list. Example:['syntaxGroup1', 'syntaxGroup2']")
return ''
endif
let syn_group_arr = a:1
else
let syn_group_arr = g:omni_sql_precache_syntax_groups
endif
if !empty(syn_group_arr)
for group_name in syn_group_arr
let list_idx = index(s:syn_list, group_name, 0, &ignorecase)
if list_idx > -1
call remove( s:syn_list, list_idx )
call remove( s:syn_value, list_idx )
endif
endfor
endif
endfunction
function! sqlcomplete#Map(type)
let b:sql_compl_type=a:type
if &omnifunc != "" && &omnifunc != 'sqlcomplete#Complete'
let b:sql_compl_savefunc=&omnifunc
endif
let &omnifunc='sqlcomplete#Complete'
endfunction
function! sqlcomplete#DrillIntoTable()
if pumvisible()
call sqlcomplete#Map('column')
call feedkeys("\<C-Y>\<C-X>\<C-O>", 'n')
else
exec 'call feedkeys("\'.g:ftplugin_sql_omni_key_right.'", "n")'
endif
return ""
endfunction
function! sqlcomplete#DrillOutOfColumns()
if pumvisible()
call sqlcomplete#Map('tableReset')
call feedkeys("\<C-X>\<C-O>")
else
exec 'call feedkeys("\'.g:ftplugin_sql_omni_key_left.'", "n")'
endif
return ""
endfunction
function! s:SQLCWarningMsg(msg)
echohl WarningMsg
echomsg 'SQLComplete:'.a:msg
echohl None
endfunction
function! s:SQLCErrorMsg(msg)
echohl ErrorMsg
echomsg 'SQLComplete:'.a:msg
echohl None
endfunction
function! s:SQLCGetSyntaxList(syn_group)
let syn_group  = a:syn_group
let compl_list = []
let list_idx = index(s:syn_list, syn_group, 0, &ignorecase)
if list_idx > -1
let compl_list = s:syn_value[list_idx]
else
let s:save_inc = g:omni_syntax_group_include_sql
let s:save_exc = g:omni_syntax_group_exclude_sql
let g:omni_syntax_group_include_sql = ''
let g:omni_syntax_group_exclude_sql = ''
if syn_group == 'syntax'
let syn_value                       = syntaxcomplete#OmniSyntaxList()
else
let g:omni_syntax_group_include_sql = syn_group
let syn_value                       = syntaxcomplete#OmniSyntaxList(syn_group)
endif
let g:omni_syntax_group_include_sql = s:save_inc
let g:omni_syntax_group_exclude_sql = s:save_exc
let s:syn_list  = add( s:syn_list,  syn_group )
let s:syn_value = add( s:syn_value, syn_value )
let compl_list  = syn_value
endif
return compl_list
endfunction
function! s:SQLCCheck4dbext()
if !exists('g:loaded_dbext')
let msg = "The dbext plugin must be loaded for dynamic SQL completion"
call s:SQLCErrorMsg(msg)
:sleep 2
return -1
elseif g:loaded_dbext < 600
let msg = "The dbext plugin must be at least version 5.30 " .
\ " for dynamic SQL completion"
call s:SQLCErrorMsg(msg)
:sleep 2
return -1
endif
return 1
endfunction
function! s:SQLCAddAlias(table_name, table_alias, cols)
let table_name  = matchstr(a:table_name, '\%(.\{-}\.\)\?\zs\(.*\)' )
let table_alias = a:table_alias
let cols        = a:cols
if g:omni_sql_use_tbl_alias != 'n'
if table_alias == ''
if 'da' =~? g:omni_sql_use_tbl_alias
if table_name =~ '_'
let save_keyword = &iskeyword
setlocal iskeyword-=_
let table_alias = substitute(
\ table_name,
\ '\<[[:alpha:]]\+\>_\?',
\ '\=strpart(submatch(0), 0, 1)',
\ 'g'
\ )
let &iskeyword = save_keyword
elseif table_name =~ '\u\U'
let table_alias = substitute(
\ table_name, '\(\u\)\U*', '\1', 'g')
else
let table_alias = strpart(table_name, 0, 1)
endif
endif
endif
if table_alias != ''
let table_alias = substitute(table_alias, '\w\zs\.\?\s*$', '.', '')
if 'a' =~? g:omni_sql_use_tbl_alias && a:table_alias == ''
let table_alias = inputdialog("Enter table alias:", table_alias)
endif
endif
if table_alias != ''
let cols = substitute(cols, '\<\w', table_alias.'&', 'g')
endif
endif
return cols
endfunction
function! s:SQLCGetObjectOwner(object)
let owner = matchstr( a:object, '^\("\|\[\)\?\zs\.\{-}\ze\("\|\]\)\?\.' )
return owner
endfunction
function! s:SQLCGetColumns(table_name, list_type)
if a:table_name =~ '\.'
let owner  = matchstr( a:table_name, '^\zs.*\ze\..*\..*' )
let table  = matchstr( a:table_name, '^\(.*\.\)\?\zs.*\ze\..*' )
let column = matchstr( a:table_name, '.*\.\zs.*' )
if g:omni_sql_include_owner == 1 && owner == '' && table != '' && column != ''
let owner  = table
let table  = column
let column = ''
endif
else
let owner  = ''
let table  = matchstr(a:table_name, '^["\[\]a-zA-Z0-9_ ]\+\ze\.\?')
let column = ''
endif
let table_name   = table
let table_cols   = []
let table_alias  = ''
let move_to_top  = 1
let table_name   = substitute(table_name, '\s*\(.\{-}\)\s*$', '\1', 'g')
let table_name   = substitute(table_name, '^\c\(WHERE\|AND\|OR\)\s\+', '', '')
if g:loaded_dbext >= 300
let saveSettingAlias = DB_listOption('use_tbl_alias')
exec 'DBSetOption use_tbl_alias=n'
endif
let table_name_stripped = substitute(table_name, '["\[\]]*', '', 'g')
let list_idx = index(s:tbl_name, table_name_stripped, 0, &ignorecase)
if list_idx > -1
let table_cols = split(s:tbl_cols[list_idx], '\n')
else
let list_idx = index(s:tbl_alias, table_name_stripped, 0, &ignorecase)
if list_idx > -1
let table_alias = table_name_stripped
let table_name  = s:tbl_name[list_idx]
let table_cols  = split(s:tbl_cols[list_idx], '\n')
endif
endif
if list_idx == -1
let saveY      = @y
let saveSearch = @/
let saveWScan  = &wrapscan
let curline    = line(".")
let curcol     = col(".")
setlocal nowrapscan
exec 'silent! normal! ?\<\c\(select\|update\|delete\|;\)\>'."\n"
exec 'silent! normal! vl/\c\(\<select\>\|\<update\>\|\<delete\>\|;\s*$\|\%$\)'."\n".'"yy'
let query = @y
let query = substitute(query, "\n", ' ', 'g')
let found = 0
if query =~? '^\(select\|update\|delete\)'
let found = 1
let table_name_new = matchstr(@y,
\ '\c\(\<from\>\|\<join\>\|,\)\s*'.
\ '\zs\(\("\|\[\)\?\w\+\("\|\]\)\?\.\)\?'.
\ '\("\|\[\)\?\w\+\("\|\]\)\?\ze'.
\ '\s\+\%(as\s\+\)\?\<'.
\ matchstr(table_name, '.\{-}\ze\.\?$').
\ '\>'.
\ '\s*\.\@!.*'.
\ '\(\<where\>\|$\)'.
\ '.*'
\ )
if table_name_new != ''
let table_alias = table_name
if g:omni_sql_include_owner == 1
let table_name  = matchstr( table_name_new, '^\zs\(.\{-}\.\)\?\(.\{-}\.\)\?.*\ze' )
else
let table_name  = matchstr( table_name_new, '^\(.\{-}\.\)\?\zs\(.\{-}\.\)\?.*\ze' )
endif
let list_idx = index(s:tbl_name, table_name, 0, &ignorecase)
if list_idx > -1
let table_cols  = split(s:tbl_cols[list_idx])
let s:tbl_name[list_idx]  = table_name
let s:tbl_alias[list_idx] = table_alias
else
let list_idx = index(s:tbl_alias, table_name, 0, &ignorecase)
if list_idx > -1
let table_cols = split(s:tbl_cols[list_idx])
let s:tbl_name[list_idx]  = table_name
let s:tbl_alias[list_idx] = table_alias
endif
endif
endif
else
let found = 1
endif
let @y        = saveY
let @/        = saveSearch
let &wrapscan = saveWScan
call cursor(curline, curcol)
if found == 0
if g:loaded_dbext > 300
exec 'DBSetOption use_tbl_alias='.saveSettingAlias
endif
return []
endif
endif
if empty(table_cols)
let table_cols_str = DB_getListColumn((owner!=''?owner.'.':'').table_name, 1, 1)
if table_cols_str != ""
let s:tbl_name  = add( s:tbl_name,  table_name )
let s:tbl_alias = add( s:tbl_alias, table_alias )
let s:tbl_cols  = add( s:tbl_cols,  table_cols_str )
let table_cols  = split(table_cols_str, '\n')
endif
endif
if g:loaded_dbext > 300
exec 'DBSetOption use_tbl_alias='.saveSettingAlias
endif
if a:list_type == 'csv' && !empty(table_cols)
let cols       = join(table_cols, ', ')
let cols       = s:SQLCAddAlias(table_name, table_alias, cols)
let table_cols = [cols]
endif
return table_cols
endfunction
let &cpo= s:keepcpo
unlet s:keepcpo
