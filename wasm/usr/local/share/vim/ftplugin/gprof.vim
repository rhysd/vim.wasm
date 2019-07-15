if exists("b:did_ftplugin")
finish
endif
let b:did_ftplugin=1
fun! <SID>GprofJumpToFunctionIndex()
let l:line = getline('.')
if l:line =~ '[\d\+\]$'
norm! $y%
call search('^' . escape(@", '[]'), 'sw')
norm! zz
elseif l:line =~ '^\(\s\+[0-9\.]\+\)\{3}\s\+'
norm! 55|eby$
call search('^\[\d\+\].*\d\s\+' .  escape(@", '[]*.') . '\>', 'sW')
norm! zz
endif
endfun
map <buffer> <silent> <C-]> :call <SID>GprofJumpToFunctionIndex()<CR>
