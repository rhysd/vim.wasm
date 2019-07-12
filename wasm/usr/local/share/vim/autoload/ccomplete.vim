let s:cpo_save = &cpo
set cpo&vim
function! ccomplete#Complete(findstart, base)
if a:findstart
let line = getline('.')
let start = col('.') - 1
let lastword = -1
while start > 0
if line[start - 1] =~ '\w'
let start -= 1
elseif line[start - 1] =~ '\.'
if lastword == -1
let lastword = start
endif
let start -= 1
elseif start > 1 && line[start - 2] == '-' && line[start - 1] == '>'
if lastword == -1
let lastword = start
endif
let start -= 2
elseif line[start - 1] == ']'
let n = 0
let start -= 1
while start > 0
let start -= 1
if line[start] == '['
if n == 0
break
endif
let n -= 1
elseif line[start] == ']'  " nested []
let n += 1
endif
endwhile
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
if base == ''
return []
endif
let s:grepCache = {}
let items = []
let s = 0
let arrays = 0
while 1
let e = match(base, '\.\|->\|\[', s)
if e < 0
if s == 0 || base[s - 1] != ']'
call add(items, strpart(base, s))
endif
break
endif
if s == 0 || base[s - 1] != ']'
call add(items, strpart(base, s, e - s))
endif
if base[e] == '.'
let s = e + 1	" skip over '.'
elseif base[e] == '-'
let s = e + 2	" skip over '->'
else
let n = 0
let s = e
let e += 1
while e < len(base)
if base[e] == ']'
if n == 0
break
endif
let n -= 1
elseif base[e] == '['  " nested [...]
let n += 1
endif
let e += 1
endwhile
let e += 1
call add(items, strpart(base, s, e - s))
let arrays += 1
let s = e
endif
endwhile
let res = []
if searchdecl(items[0], 0, 1) == 0
let line = getline('.')
let col = col('.')
if stridx(strpart(line, 0, col), ';') != -1
let col2 = col - 1
while line[col2] != ';'
let col2 -= 1
endwhile
let line = strpart(line, col2 + 1)
let col -= col2
endif
if stridx(strpart(line, 0, col), ',') != -1
let col2 = col - 1
while line[col2] != ','
let col2 -= 1
endwhile
if strpart(line, col2 + 1, col - col2 - 1) =~ ' *[^ ][^ ]*  *[^ ]'
let line = strpart(line, col2 + 1)
let col -= col2
endif
endif
if len(items) == 1
let match = items[0]
let kind = 'v'
if match(line, '\<' . match . '\s*\[') > 0
let match .= '['
else
let res = s:Nextitem(strpart(line, 0, col), [''], 0, 1)
if len(res) > 0
if match(line, '\*[ \t(]*' . match . '\>') > 0
let match .= '->'
else
let match .= '.'
endif
endif
endif
let res = [{'match': match, 'tagline' : '', 'kind' : kind, 'info' : line}]
elseif len(items) == arrays + 1
let match = items[0]
let kind = 'v'
let tagline = "\t/^" . line . '$/'
let res = [{'match': match, 'tagline' : tagline, 'kind' : kind, 'info' : line}]
else
let res = s:Nextitem(strpart(line, 0, col), items[1:], 0, 1)
endif
endif
if len(items) == 1 || len(items) == arrays + 1
if len(items) == 1
let tags = taglist('^' . base)
else
let tags = taglist('^' . items[0] . '$')
endif
call filter(tags, 'has_key(v:val, "kind") ? v:val["kind"] != "m" : 1')
call filter(tags, '!has_key(v:val, "static") || !v:val["static"] || bufnr("%") == bufnr(v:val["filename"])')
call extend(res, map(tags, 's:Tag2item(v:val)'))
endif
if len(res) == 0
let diclist = taglist('^' . items[0] . '$')
call filter(diclist, 'has_key(v:val, "kind") ? v:val["kind"] != "m" : 1')
let res = []
for i in range(len(diclist))
if has_key(diclist[i], 'typename')
call extend(res, s:StructMembers(diclist[i]['typename'], items[1:], 1))
elseif has_key(diclist[i], 'typeref')
call extend(res, s:StructMembers(diclist[i]['typeref'], items[1:], 1))
endif
if diclist[i]['kind'] == 'v'
let line = diclist[i]['cmd']
if line[0] == '/' && line[1] == '^'
let col = match(line, '\<' . items[0] . '\>')
call extend(res, s:Nextitem(strpart(line, 2, col - 2), items[1:], 0, 1))
endif
endif
endfor
endif
if len(res) == 0 && searchdecl(items[0], 1) == 0
let line = getline('.')
let col = col('.')
let res = s:Nextitem(strpart(line, 0, col), items[1:], 0, 1)
endif
let last = len(items) - 1
let brackets = ''
while last >= 0
if items[last][0] != '['
break
endif
let brackets = items[last] . brackets
let last -= 1
endwhile
return map(res, 's:Tagline2item(v:val, brackets)')
endfunc
function! s:GetAddition(line, match, memarg, bracket)
if a:bracket && match(a:line, a:match . '\s*\[') > 0
return '['
endif
if len(s:SearchMembers(a:memarg, [''], 0)) > 0
if match(a:line, '\*[ \t(]*' . a:match . '\>') > 0
return '->'
else
return '.'
endif
endif
return ''
endfunction
function! s:Tag2item(val)
let res = {'match': a:val['name']}
let res['extra'] = s:Tagcmd2extra(a:val['cmd'], a:val['name'], a:val['filename'])
let s = s:Dict2info(a:val)
if s != ''
let res['info'] = s
endif
let res['tagline'] = ''
if has_key(a:val, "kind")
let kind = a:val['kind']
let res['kind'] = kind
if kind == 'v'
let res['tagline'] = "\t" . a:val['cmd']
let res['dict'] = a:val
elseif kind == 'f'
let res['match'] = a:val['name'] . '('
endif
endif
return res
endfunction
function! s:Dict2info(dict)
let info = ''
for k in sort(keys(a:dict))
let info  .= k . repeat(' ', 10 - len(k))
if k == 'cmd'
let info .= substitute(matchstr(a:dict['cmd'], '/^\s*\zs.*\ze$/'), '\\\(.\)', '\1', 'g')
else
let info .= a:dict[k]
endif
let info .= "\n"
endfor
return info
endfunc
function! s:ParseTagline(line)
let l = split(a:line, "\t")
let d = {}
if len(l) >= 3
let d['name'] = l[0]
let d['filename'] = l[1]
let d['cmd'] = l[2]
let n = 2
if l[2] =~ '^/'
while n < len(l) && l[n] !~ '/;"$'
let n += 1
let d['cmd'] .= "  " . l[n]
endwhile
endif
for i in range(n + 1, len(l) - 1)
if l[i] == 'file:'
let d['static'] = 1
elseif l[i] !~ ':'
let d['kind'] = l[i]
else
let d[matchstr(l[i], '[^:]*')] = matchstr(l[i], ':\zs.*')
endif
endfor
endif
return d
endfunction
function! s:Tagline2item(val, brackets)
let line = a:val['tagline']
let add = s:GetAddition(line, a:val['match'], [a:val], a:brackets == '')
let res = {'word': a:val['match'] . a:brackets . add }
if has_key(a:val, 'info')
let res['info'] = a:val['info']
else
let s = s:Dict2info(s:ParseTagline(line))
if s != ''
let res['info'] = s
endif
endif
if has_key(a:val, 'kind')
let res['kind'] = a:val['kind']
elseif add == '('
let res['kind'] = 'f'
else
let s = matchstr(line, '\t\(kind:\)\=\zs\S\ze\(\t\|$\)')
if s != ''
let res['kind'] = s
endif
endif
if has_key(a:val, 'extra')
let res['menu'] = a:val['extra']
return res
endif
let s = matchstr(line, '[^\t]*\t[^\t]*\t\zs\(/^.*$/\|[^\t]*\)\ze\(;"\t\|\t\|$\)')
if s != ''
let res['menu'] = s:Tagcmd2extra(s, a:val['match'], matchstr(line, '[^\t]*\t\zs[^\t]*\ze\t'))
endif
return res
endfunction
function! s:Tagcmd2extra(cmd, name, fname)
if a:cmd =~ '^/^'
let x = matchstr(a:cmd, '^/^\s*\zs.*\ze$/')
let x = substitute(x, '\<' . a:name . '\>', '@@', '')
let x = substitute(x, '\\\(.\)', '\1', 'g')
let x = x . ' - ' . a:fname
elseif a:cmd =~ '^\d*$'
let x = a:fname . ' - ' . a:cmd
else
let x = a:cmd . ' - ' . a:fname
endif
return x
endfunction
function! s:Nextitem(lead, items, depth, all)
let tokens = split(a:lead, '\s\+\|\<')
let res = []
for tidx in range(len(tokens))
if tokens[tidx] !~ '^\h'
continue
endif
if (tokens[tidx] == 'struct' || tokens[tidx] == 'union' || tokens[tidx] == 'class') && tidx + 1 < len(tokens)
let res = s:StructMembers(tokens[tidx] . ':' . tokens[tidx + 1], a:items, a:all)
break
endif
if index(['int', 'short', 'char', 'float', 'double', 'static', 'unsigned', 'extern'], tokens[tidx]) >= 0
continue
endif
let diclist = taglist('^' . tokens[tidx] . '$')
for tagidx in range(len(diclist))
let item = diclist[tagidx]
if has_key(item, 'typeref')
call extend(res, s:StructMembers(item['typeref'], a:items, a:all))
continue
endif
if has_key(item, 'typename')
call extend(res, s:StructMembers(item['typename'], a:items, a:all))
continue
endif
if item['kind'] != 't'
continue
endif
if has_key(item, 'static') && item['static'] && bufnr('%') != bufnr(item['filename'])
continue
endif
let cmd = item['cmd']
let ei = matchend(cmd, 'typedef\s\+')
if ei > 1
let cmdtokens = split(strpart(cmd, ei), '\s\+\|\<')
if len(cmdtokens) > 1
if cmdtokens[0] == 'struct' || cmdtokens[0] == 'union' || cmdtokens[0] == 'class'
let name = ''
for ti in range(len(cmdtokens) - 1)
if cmdtokens[ti] =~ '^\w'
let name = cmdtokens[ti]
break
endif
endfor
if name != ''
call extend(res, s:StructMembers(cmdtokens[0] . ':' . name, a:items, a:all))
endif
elseif a:depth < 10
call extend(res, s:Nextitem(cmdtokens[0], a:items, a:depth + 1, a:all))
endif
endif
endif
endfor
if len(res) > 0
break
endif
endfor
return res
endfunction
function! s:StructMembers(typename, items, all)
let fnames = join(map(tagfiles(), 'escape(v:val, " \\#%")'))
if fnames == ''
return []
endif
let typename = a:typename
let qflist = []
let cached = 0
if a:all == 0
let n = '1'	" stop at first found match
if has_key(s:grepCache, a:typename)
let qflist = s:grepCache[a:typename]
let cached = 1
endif
else
let n = ''
endif
if !cached
while 1
exe 'silent! keepj noautocmd ' . n . 'vimgrep /\t' . typename . '\(\t\|$\)/j ' . fnames
let qflist = getqflist()
if len(qflist) > 0 || match(typename, "::") < 0
break
endif
let typename = substitute(typename, ':[^:]*::', ':', '')
endwhile
if a:all == 0
let s:grepCache[a:typename] = qflist
endif
endif
let idx = 0
while 1
if idx >= len(a:items)
let target = ''		" No further items, matching all members
break
endif
if a:items[idx][0] != '['
let target = a:items[idx]
break
endif
let idx += 1
endwhile
let matches = []
for l in qflist
let memb = matchstr(l['text'], '[^\t]*')
if memb =~ '^' . target
if match(l['text'], "\tfile:") < 0 || bufnr('%') == bufnr(matchstr(l['text'], '\t\zs[^\t]*'))
let item = {'match': memb, 'tagline': l['text']}
let s = matchstr(l['text'], '\t\(kind:\)\=\zs\S\ze\(\t\|$\)')
if s != ''
let item['kind'] = s
if s == 'f'
let item['match'] = memb . '('
endif
endif
call add(matches, item)
endif
endif
endfor
if len(matches) > 0
let idx += 1
while 1
if idx >= len(a:items)
return matches		" No further items, return the result.
endif
if a:items[idx][0] != '['
break
endif
let idx += 1
endwhile
return s:SearchMembers(matches, a:items[idx :], a:all)
endif
return []
endfunction
function! s:SearchMembers(matches, items, all)
let res = []
for i in range(len(a:matches))
let typename = ''
if has_key(a:matches[i], 'dict')
if has_key(a:matches[i].dict, 'typename')
let typename = a:matches[i].dict['typename']
elseif has_key(a:matches[i].dict, 'typeref')
let typename = a:matches[i].dict['typeref']
endif
let line = "\t" . a:matches[i].dict['cmd']
else
let line = a:matches[i]['tagline']
let e = matchend(line, '\ttypename:')
if e < 0
let e = matchend(line, '\ttyperef:')
endif
if e > 0
let typename = matchstr(line, '[^\t]*', e)
endif
endif
if typename != ''
call extend(res, s:StructMembers(typename, a:items, a:all))
else
let s = match(line, '\t\zs/^')
if s > 0
let e = match(line, '\<' . a:matches[i]['match'] . '\>', s)
if e > 0
call extend(res, s:Nextitem(strpart(line, s, e - s), a:items, 0, a:all))
endif
endif
endif
if a:all == 0 && len(res) > 0
break
endif
endfor
return res
endfunc
let &cpo = s:cpo_save
unlet s:cpo_save
