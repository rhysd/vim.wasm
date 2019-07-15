if exists('+omnifunc')
if &omnifunc == ""
setlocal omnifunc=syntaxcomplete#Complete
endif
endif
if exists('g:loaded_syntax_completion')
finish
endif
let g:loaded_syntax_completion = 130
let s:cpo_save = &cpo
set cpo&vim
if !exists('g:omni_syntax_ignorecase')
let g:omni_syntax_ignorecase = &ignorecase
endif
if !exists('g:omni_syntax_use_iskeyword')
let g:omni_syntax_use_iskeyword = 1
endif
if !exists('g:omni_syntax_use_single_byte')
let g:omni_syntax_use_single_byte = 1
endif
if !exists('g:omni_syntax_use_iskeyword_numeric')
let g:omni_syntax_use_iskeyword_numeric = 1
endif
if !exists('g:omni_syntax_minimum_length')
let g:omni_syntax_minimum_length = 0
endif
let s:syn_remove_words = 'matchgroup=,contains,'.
\ 'links to,start=,end='
let s:cache_name = []
let s:cache_list = []
let s:prepended  = ''
function! syntaxcomplete#Complete(findstart, base)
if !exists('b:omni_syntax_ignorecase')
if exists('g:omni_syntax_ignorecase')
let b:omni_syntax_ignorecase = g:omni_syntax_ignorecase
else
let b:omni_syntax_ignorecase = &ignorecase
endif
endif
if a:findstart
let line = getline('.')
let start = col('.') - 1
let lastword = -1
while start > 0
if line[start - 1] =~ '\k'
let start -= 1
let lastword = a:findstart
else
break
endif
endwhile
if lastword == -1
let s:prepended = ''
return start
endif
let s:prepended = strpart(line, start, (col('.') - 1) - start)
return start
endif
let base = s:prepended
let filetype = substitute(&filetype, '\.', '_', 'g')
let list_idx = index(s:cache_name, filetype, 0, &ignorecase)
if list_idx > -1
let compl_list = s:cache_list[list_idx]
else
let compl_list   = OmniSyntaxList()
let s:cache_name = add( s:cache_name,  filetype )
let s:cache_list = add( s:cache_list,  compl_list )
endif
if base != ''
let expr = 'v:val '.(g:omni_syntax_ignorecase==1?'=~?':'=~#')." '^".escape(base, '\\/.*$^~[]').".*'"
let compl_list = filter(deepcopy(compl_list), expr)
endif
return compl_list
endfunc
function! syntaxcomplete#OmniSyntaxList(...)
if a:0 > 0
let parms = []
if 3 == type(a:1)
let parms = a:1
elseif 1 == type(a:1)
let parms = split(a:1, ',')
endif
return OmniSyntaxList( parms )
else
return OmniSyntaxList()
endif
endfunc
function! OmniSyntaxList(...)
let list_parms = []
if a:0 > 0
if 3 == type(a:1)
let list_parms = a:1
elseif 1 == type(a:1)
let list_parms = split(a:1, ',')
endif
endif
if !exists('b:omni_syntax_use_iskeyword')
if exists('g:omni_syntax_use_iskeyword')
let b:omni_syntax_use_iskeyword = g:omni_syntax_use_iskeyword
else
let b:omni_syntax_use_iskeyword = 1
endif
endif
if !exists('b:omni_syntax_minimum_length')
if exists('g:omni_syntax_minimum_length')
let b:omni_syntax_minimum_length = g:omni_syntax_minimum_length
else
let b:omni_syntax_minimum_length = 0
endif
endif
let saveL = @l
let filetype = substitute(&filetype, '\.', '_', 'g')
if empty(list_parms)
let syntax_group_include_{filetype} = ''
if exists('g:omni_syntax_group_include_'.filetype)
let syntax_group_include_{filetype} =
\ substitute( g:omni_syntax_group_include_{filetype},'\s\+','','g')
let list_parms = split(g:omni_syntax_group_include_{filetype}, ',')
if syntax_group_include_{filetype} =~ '\w'
let syntax_group_include_{filetype} =
\ substitute( syntax_group_include_{filetype},
\ '\s*,\s*', '\\|', 'g'
\ )
endif
endif
else
endif
if !empty(list_parms) && empty(substitute(join(list_parms), '[a-zA-Z ]', '', 'g'))
redir @l
silent! exec 'syntax list '.join(list_parms)
redir END
else
redir @l
silent! exec 'syntax list'
redir END
endif
let syntax_full = "\n".@l
let @l = saveL
if syntax_full =~ 'E28'
\ || syntax_full =~ 'E411'
\ || syntax_full =~ 'E415'
\ || syntax_full =~ 'No Syntax items'
return []
endif
let filetype = substitute(&filetype, '\.', '_', 'g')
let list_exclude_groups = []
if a:0 > 0
else
let syntax_group_exclude_{filetype} = ''
if exists('g:omni_syntax_group_exclude_'.filetype)
let syntax_group_exclude_{filetype} =
\ substitute( g:omni_syntax_group_exclude_{filetype},'\s\+','','g')
let list_exclude_groups = split(g:omni_syntax_group_exclude_{filetype}, ',')
if syntax_group_exclude_{filetype} =~ '\w'
let syntax_group_exclude_{filetype} =
\ substitute( syntax_group_exclude_{filetype},
\ '\s*,\s*', '\\|', 'g'
\ )
endif
endif
endif
if empty(list_parms)
let list_parms = [&filetype.'\w\+']
endif
let syn_list = ''
let index    = 0
for group_regex in list_parms
let next_group_regex = '\n' .
\ '\zs'.group_regex.'\ze'.
\ '\s\+xxx\s\+'
let index    = match(syntax_full, next_group_regex, index)
if index == -1 && exists('b:current_syntax') && substitute(group_regex, '[^a-zA-Z ]\+.*', '', 'g') !~ '^'.b:current_syntax
let next_group_regex = '\n' .
\ '\zs'.b:current_syntax.'\w\+\ze'.
\ '\s\+xxx\s\+'
let index    = 0
let index    = match(syntax_full, next_group_regex, index)
endif
while index > -1
let group_name = matchstr( syntax_full, '\w\+', index )
let get_syn_list = 1
for exclude_group_name in list_exclude_groups
if '\<'.exclude_group_name.'\>' =~ '\<'.group_name.'\>'
let get_syn_list = 0
endif
endfor
if get_syn_list == 1
let extra_syn_list = s:SyntaxCSyntaxGroupItems(group_name, syntax_full)
let syn_list = syn_list . extra_syn_list . "\n"
endif
let index = index + strlen(group_name)
let index = match(syntax_full, next_group_regex, index)
endwhile
endfor
let compl_list = sort(split(syn_list))
if &filetype == 'vim'
let short_compl_list = []
for i in range(len(compl_list))
if i == len(compl_list)-1
let next = i
else
let next = i + 1
endif
if  compl_list[next] !~ '^'.compl_list[i].'.$'
let short_compl_list += [compl_list[i]]
endif
endfor
return short_compl_list
else
return compl_list
endif
endfunction
function! s:SyntaxCSyntaxGroupItems( group_name, syntax_full )
let syn_list = ""
let syntax_group = matchstr(a:syntax_full,
\ "\n".a:group_name.'\s\+xxx\s\+\zs.\{-}\ze\(\n\w\|\%$\)'
\ )
if syntax_group != ""
let syn_list = substitute(
\    syntax_group, '\<\('.
\    substitute(
\      escape(s:syn_remove_words, '\\/.*$^~[]')
\      , ',', '\\|', 'g'
\    ).
\    '\).\{-}\%($\|'."\n".'\)'
\    , "\n", 'g'
\  )
let syn_list_old = syn_list
while syn_list =~ '\<match\>\s\+\/'
if syn_list =~ 'perlElseIfError'
let syn_list = syn_list
endif
if syn_list =~ '\<match \/\zs.\{-}\<\w\{3,}\>.\{-}\ze\\\@<!\/\%(\%(ms\|me\|hs\|he\|rs\|re\|lc\)\S\+\)\?\s\+'
let syn_list = substitute( syn_list, '\<match \/\zs.\{-}\ze\\%\?(.\{-}\\\@<!\/\%(\%(ms\|me\|hs\|he\|rs\|re\|lc\)\S\+\)\?\s\+', '', 'g' )
let syn_list = substitute( syn_list, '\<match \/.\{-}\\)\zs.\{-}\ze\/\%(\%(ms\|me\|hs\|he\|rs\|re\|lc\)\S\+\)\?\s\+', '', 'g' )
let syn_list = substitute( syn_list, '\%(\<match \/[^/]\{-}\)\@<=\[[^]]*\]\ze.\{-}\\\@<!\/\%(\%(ms\|me\|hs\|he\|rs\|re\|lc\)\S\+\)\?', '', 'g' )
let syn_list = substitute( syn_list, '\%(\<match \/[^/]\{-}\)\@<=\<\w\{1,2}\>\ze.\{-}\\\@<!\/\%(\%(ms\|me\|hs\|he\|rs\|re\|lc\)\S\+\)\?\s\+', '', 'g' )
let syn_list = substitute( syn_list, '\<match \/\zs\(.\{-}\)\ze\\\@<!\/\%(\%(ms\|me\|hs\|he\|rs\|re\|lc\)\S\+\)\?\s\+'
\ , '\=substitute(submatch(1), "\\W\\+", " ", "g")'
\ , 'g' )
let syn_list = substitute( syn_list, '\<match \/\(.\{-}\)\/\%(\%(ms\|me\|hs\|he\|rs\|re\|lc\)\S\+\)\?\s\+', '\1', 'g' )
else
let syn_list = substitute( syn_list, '\<match \/\%(.\{-}\)\?\/\%(\%(ms\|me\|hs\|he\|rs\|re\|lc\)\S\+\)\?\s\+', '', 'g' )
endif
if syn_list =~ '\<match\>\s\+\/'
let syn_list = ''
endif
endwhile
let syn_list = substitute(
\    syn_list, '\<\(contained\|nextgroup=[@a-zA-Z,]*\)'
\    , "", 'g'
\ )
let syn_list = substitute(
\    syn_list, '\<\(skipwhite\|skipnl\|skipempty\)\>'
\    , "", 'g'
\ )
let syn_list = substitute(
\    syn_list, '\%(^\|\n\)\@<=\s*\(@\w\+\)'
\    , "", 'g'
\ )
if b:omni_syntax_use_iskeyword == 0
let syn_list = substitute( syn_list, '[^0-9A-Za-z_ ]', ' ', 'g' )
else
if g:omni_syntax_use_iskeyword_numeric == 1
let accepted_chars = ''
for item in split(&iskeyword, ',')
if item =~ '\d-\d'
let [b:start, b:end] = split(item, '-')
for range_item in range( b:start, b:end )
if range_item <= 127 || g:omni_syntax_use_single_byte == 0
if nr2char(range_item) =~ '\p'
let accepted_chars = accepted_chars . nr2char(range_item)
endif
endif
endfor
elseif item =~ '^\d\+$'
if item < 127 || g:omni_syntax_use_single_byte == 0
if nr2char(item) =~ '\p'
let accepted_chars = accepted_chars . nr2char(item)
endif
endif
else
if char2nr(item) < 127 || g:omni_syntax_use_single_byte == 0
if item =~ '\p'
let accepted_chars = accepted_chars . item
endif
endif
endif
endfor
let accepted_chars = escape(accepted_chars, ']\-^' )
let syn_list = substitute( syn_list, '[^A-Za-z'.accepted_chars.']', ' ', 'g' )
else
let accept_chars = ','.&iskeyword.','
let accept_chars = substitute(accept_chars, ',\@<=[^,]\+-[^,]\+,', '', 'g')
let accept_chars = substitute(accept_chars, ',\@<=\d\{-},', '', 'g')
let accept_chars = substitute(accept_chars, ',', '', 'g')
let accept_chars = escape(accept_chars, ']\-^' )
let syn_list = substitute( syn_list, '[^0-9A-Za-z_'.accept_chars.']', ' ', 'g' )
endif
endif
if b:omni_syntax_minimum_length > 0
let syn_list = substitute(' '.syn_list.' ', ' \S\{,'.b:omni_syntax_minimum_length.'}\ze ', ' ', 'g')
endif
else
let syn_list = ''
endif
return syn_list
endfunction
function! OmniSyntaxShowChars(spec)
let result = []
for item in split(a:spec, ',')
if len(item) > 1
if item == '@-@'
call add(result, char2nr(item))
else
call extend(result, call('range', split(item, '-')))
endif
else
if item == '@'  " assume this is [A-Za-z]
for [c1, c2] in [['A', 'Z'], ['a', 'z']]
call extend(result, range(char2nr(c1), char2nr(c2)))
endfor
else
call add(result, char2nr(item))
endif
endif
endfor
return join(map(result, 'nr2char(v:val)'), ', ')
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
