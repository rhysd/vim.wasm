function s:CacheRstFold()
if !g:rst_fold_enabled
return
endif
let closure = {'header_types': {}, 'max_level': 0, 'levels': {}}
function closure.Process(match) dict
let curline = getcurpos()[1]
if has_key(self.levels, curline - 1)
return
endif
let lines = split(a:match, '\n')
let key = repeat(lines[-1][0], len(lines))
if !has_key(self.header_types, key)
let self.max_level += 1
let self.header_types[key] = self.max_level
endif
let self.levels[curline] = self.header_types[key]
endfunction
let save_cursor = getcurpos()
let save_mark = getpos("'[")
silent keeppatterns %s/\v^%(%(([=`:.'"~^_*+#-])\1+\n)?.{1,2}\n([=`:.'"~^_*+#-])\2+)|%(%(([=`:.''"~^_*+#-])\3{2,}\n)?.{3,}\n([=`:.''"~^_*+#-])\4{2,})$/\=closure.Process(submatch(0))/gn
call setpos('.', save_cursor)
call setpos("'[", save_mark)
let b:RstFoldCache = closure.levels
endfunction
function RstFold#GetRstFold()
if !g:rst_fold_enabled
return
endif
if !has_key(b:, 'RstFoldCache')
call s:CacheRstFold()
endif
if has_key(b:RstFoldCache, v:lnum)
return '>' . b:RstFoldCache[v:lnum]
else
return '='
endif
endfunction
function RstFold#GetRstFoldText()
if !g:rst_fold_enabled
return
endif
if !has_key(b:, 'RstFoldCache')
call s:CacheRstFold()
endif
let indent = repeat('  ', b:RstFoldCache[v:foldstart] - 1)
let thisline = getline(v:foldstart)
let text = thisline =~ '^\([=`:.''"~^_*+#-]\)\1\+$' ? getline(v:foldstart + 1) : thisline
return indent . text
endfunction
