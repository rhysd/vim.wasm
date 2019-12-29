if exists("g:loaded_matchparen") || &cp || !exists("##CursorMoved")
finish
endif
let g:loaded_matchparen = 1
if !exists("g:matchparen_timeout")
let g:matchparen_timeout = 300
endif
if !exists("g:matchparen_insert_timeout")
let g:matchparen_insert_timeout = 60
endif
augroup matchparen
autocmd! CursorMoved,CursorMovedI,WinEnter * call s:Highlight_Matching_Pair()
if exists('##TextChanged')
autocmd! TextChanged,TextChangedI * call s:Highlight_Matching_Pair()
endif
augroup END
if exists("*s:Highlight_Matching_Pair")
finish
endif
let s:cpo_save = &cpo
set cpo-=C
func s:Highlight_Matching_Pair()
if exists('w:paren_hl_on') && w:paren_hl_on
silent! call matchdelete(3)
let w:paren_hl_on = 0
endif
if pumvisible() || (&t_Co < 8 && !has("gui_running"))
return
endif
let c_lnum = line('.')
let c_col = col('.')
let before = 0
let text = getline(c_lnum)
let matches = matchlist(text, '\(.\)\=\%'.c_col.'c\(.\=\)')
if empty(matches)
let [c_before, c] = ['', '']
else
let [c_before, c] = matches[1:2]
endif
let plist = split(&matchpairs, '.\zs[:,]')
let i = index(plist, c)
if i < 0
if c_col > 1 && (mode() == 'i' || mode() == 'R')
let before = strlen(c_before)
let c = c_before
let i = index(plist, c)
endif
if i < 0
return
endif
endif
if i % 2 == 0
let s_flags = 'nW'
let c2 = plist[i + 1]
else
let s_flags = 'nbW'
let c2 = c
let c = plist[i - 1]
endif
if c == '['
let c = '\['
let c2 = '\]'
endif
if before > 0
let has_getcurpos = exists("*getcurpos")
if has_getcurpos
let save_cursor = getcurpos()
else
let save_cursor = winsaveview()
endif
call cursor(c_lnum, c_col - before)
endif
if !has("syntax") || !exists("g:syntax_on")
let s_skip = "0"
else
let s_skip = '!empty(filter(map(synstack(line("."), col(".")), ''synIDattr(v:val, "name")''), ' .
\ '''v:val =~? "string\\|character\\|singlequote\\|escape\\|comment"''))'
try
execute 'if ' . s_skip . ' | let s_skip = "0" | endif'
catch /^Vim\%((\a\+)\)\=:E363/
return
endtry
endif
let stoplinebottom = line('w$')
let stoplinetop = line('w0')
if i % 2 == 0
let stopline = stoplinebottom
else
let stopline = stoplinetop
endif
if mode() == 'i' || mode() == 'R'
let timeout = exists("b:matchparen_insert_timeout") ? b:matchparen_insert_timeout : g:matchparen_insert_timeout
else
let timeout = exists("b:matchparen_timeout") ? b:matchparen_timeout : g:matchparen_timeout
endif
try
let [m_lnum, m_col] = searchpairpos(c, '', c2, s_flags, s_skip, stopline, timeout)
catch /E118/
let adjustedScrolloff = min([&scrolloff, (line('w$') - line('w0')) / 2])
let bottom_viewable = min([line('$'), c_lnum + &lines - adjustedScrolloff - 2])
let top_viewable = max([1, c_lnum-&lines+adjustedScrolloff + 2])
if i % 2 == 0
if has("byte_offset") && has("syntax_items") && &smc > 0
let stopbyte = min([line2byte("$"), line2byte(".") + col(".") + &smc * 2])
let stopline = min([bottom_viewable, byte2line(stopbyte)])
else
let stopline = min([bottom_viewable, c_lnum + 100])
endif
let stoplinebottom = stopline
else
if has("byte_offset") && has("syntax_items") && &smc > 0
let stopbyte = max([1, line2byte(".") + col(".") - &smc * 2])
let stopline = max([top_viewable, byte2line(stopbyte)])
else
let stopline = max([top_viewable, c_lnum - 100])
endif
let stoplinetop = stopline
endif
let [m_lnum, m_col] = searchpairpos(c, '', c2, s_flags, s_skip, stopline)
endtry
if before > 0
if has_getcurpos
call setpos('.', save_cursor)
else
call winrestview(save_cursor)
endif
endif
if m_lnum > 0 && m_lnum >= stoplinetop && m_lnum <= stoplinebottom 
if exists('*matchaddpos')
call matchaddpos('MatchParen', [[c_lnum, c_col - before], [m_lnum, m_col]], 10, 3)
else
exe '3match MatchParen /\(\%' . c_lnum . 'l\%' . (c_col - before) .
\ 'c\)\|\(\%' . m_lnum . 'l\%' . m_col . 'c\)/'
endif
let w:paren_hl_on = 1
endif
endfunction
command DoMatchParen call s:DoMatchParen()
command NoMatchParen call s:NoMatchParen()
func s:NoMatchParen()
let w = winnr()
noau windo silent! call matchdelete(3)
unlet! g:loaded_matchparen
exe "noau ". w . "wincmd w"
au! matchparen
endfunc
func s:DoMatchParen()
runtime plugin/matchparen.vim
let w = winnr()
silent windo doau CursorMoved
exe "noau ". w . "wincmd w"
endfunc
let &cpo = s:cpo_save
unlet s:cpo_save
