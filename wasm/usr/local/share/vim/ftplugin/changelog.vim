if &filetype == 'changelog'
if exists('b:did_ftplugin')
finish
endif
let b:did_ftplugin = 1
let s:cpo_save = &cpo
set cpo&vim
if !exists('g:changelog_dateformat')
if exists('g:changelog_timeformat')
let g:changelog_dateformat = g:changelog_timeformat
else
let g:changelog_dateformat = "%Y-%m-%d"
endif
endif
function! s:username()
if exists('g:changelog_username')
return g:changelog_username
elseif $EMAIL != ""
return $EMAIL
elseif $EMAIL_ADDRESS != ""
return $EMAIL_ADDRESS
endif
let login = s:login()
return printf('%s <%s@%s>', s:name(login), login, s:hostname())
endfunction
function! s:login()
return s:trimmed_system_with_default('whoami', 'unknown')
endfunction
function! s:trimmed_system_with_default(command, default)
return s:first_line(s:system_with_default(a:command, a:default))
endfunction
function! s:system_with_default(command, default)
let output = system(a:command)
if v:shell_error
return default
endif
return output
endfunction
function! s:first_line(string)
return substitute(a:string, '\n.*$', "", "")
endfunction
function! s:name(login)
for name in [s:gecos_name(a:login), $NAME, s:capitalize(a:login)]
if name != ""
return name
endif
endfor
endfunction
function! s:gecos_name(login)
for line in s:try_reading_file('/etc/passwd')
if line =~ '^' . a:login . ':'
return substitute(s:passwd_field(line, 5), '&', s:capitalize(a:login), "")
endif
endfor
return ""
endfunction
function! s:try_reading_file(path)
try
return readfile(a:path)
catch
return []
endtry
endfunction
function! s:passwd_field(line, field)
let fields = split(a:line, ':', 1)
if len(fields) < a:field
return ""
endif
return fields[a:field - 1]
endfunction
function! s:capitalize(word)
return toupper(a:word[0]) . strpart(a:word, 1)
endfunction
function! s:hostname()
return s:trimmed_system_with_default('hostname', 'localhost')
endfunction
if !exists('g:changelog_new_date_format')
let g:changelog_new_date_format = "%d  %u\n\n\t* %p%c\n\n"
endif
if !exists('g:changelog_new_entry_format')
let g:changelog_new_entry_format = "\t* %p%c"
endif
if !exists('g:changelog_date_entry_search')
let g:changelog_date_entry_search = '^\s*%d\_s*%u'
endif
if !exists('g:changelog_date_end_entry_search')
let g:changelog_date_end_entry_search = '^\s*$'
endif
function! s:substitute_items(str, date, user, prefix)
let str = a:str
let middles = {'%': '%', 'd': a:date, 'u': a:user, 'p': a:prefix, 'c': '{cursor}'}
let i = stridx(str, '%')
while i != -1
let inc = 0
if has_key(middles, str[i + 1])
let mid = middles[str[i + 1]]
let str = strpart(str, 0, i) . mid . strpart(str, i + 2)
let inc = strlen(mid) - 1
endif
let i = stridx(str, '%', i + 1 + inc)
endwhile
return str
endfunction
function! s:position_cursor()
if search('{cursor}') > 0
let lnum = line('.')
let line = getline(lnum)
let cursor = stridx(line, '{cursor}')
call setline(lnum, substitute(line, '{cursor}', '', ''))
endif
startinsert
endfunction
function! s:new_changelog_entry(prefix)
let save_paste = &paste
let &paste = 1
call cursor(1, 1)
let date = strftime(g:changelog_dateformat)
let search = s:substitute_items(g:changelog_date_entry_search, date,
\ s:username(), a:prefix)
if search(search) > 0
call cursor(nextnonblank(line('.') + 1), 1)
if search(g:changelog_date_end_entry_search, 'W') > 0
let p = (line('.') == line('$')) ? line('.') : line('.') - 1
else
let p = line('.')
endif
let ls = split(s:substitute_items(g:changelog_new_entry_format, '', '', a:prefix),
\ '\n')
call append(p, ls)
call cursor(p + 1, 1)
else
let remove_empty = line('$') == 1
let todays_entry = s:substitute_items(g:changelog_new_date_format,
\ date, s:username(), a:prefix)
if stridx(todays_entry, '{cursor}') == -1
let todays_entry = todays_entry . '{cursor}'
endif
call append(0, split(todays_entry, '\n'))
if remove_empty
$-/^\s*$/-1,$delete
endif
call cursor(1, 1)
endif
call s:position_cursor()
let &paste = save_paste
endfunction
if exists(":NewChangelogEntry") != 2
nnoremap <buffer> <silent> <Leader>o :<C-u>call <SID>new_changelog_entry('')<CR>
xnoremap <buffer> <silent> <Leader>o :<C-u>call <SID>new_changelog_entry('')<CR>
command! -nargs=0 NewChangelogEntry call s:new_changelog_entry('')
endif
let b:undo_ftplugin = "setl com< fo< et< ai<"
setlocal comments=
setlocal formatoptions+=t
setlocal noexpandtab
setlocal autoindent
if &textwidth == 0
setlocal textwidth=78
let b:undo_ftplugin .= " tw<"
endif
let &cpo = s:cpo_save
unlet s:cpo_save
else
let s:cpo_save = &cpo
set cpo&vim
nnoremap <silent> <Leader>o :call <SID>open_changelog()<CR>
function! s:open_changelog()
let path = expand('%:p:h')
if exists('b:changelog_path')
let changelog = b:changelog_path
else
if exists('b:changelog_name')
let name = b:changelog_name
else
let name = 'ChangeLog'
endif
while isdirectory(path)
let changelog = path . '/' . name
if filereadable(changelog)
break
endif
let parent = substitute(path, '/\+[^/]*$', "", "")
if path == parent
break
endif
let path = parent
endwhile
endif
if !filereadable(changelog)
return
endif
if exists('b:changelog_entry_prefix')
let prefix = call(b:changelog_entry_prefix, [])
else
let prefix = substitute(strpart(expand('%:p'), strlen(path)), '^/\+', "", "")
endif
let buf = bufnr(changelog)
if buf != -1
if bufwinnr(buf) != -1
execute bufwinnr(buf) . 'wincmd w'
else
execute 'sbuffer' buf
endif
else
execute 'split' fnameescape(changelog)
endif
call s:new_changelog_entry(prefix)
endfunction
let &cpo = s:cpo_save
unlet s:cpo_save
endif
