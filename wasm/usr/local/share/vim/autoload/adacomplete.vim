if version < 700
finish
endif
function! adacomplete#Complete (findstart, base)
if a:findstart == 1
return ada#User_Complete (a:findstart, a:base)
else
if exists ("g:ada_omni_with_keywords")
call ada#User_Complete (a:findstart, a:base)
endif
let l:Pattern  = '^' . a:base . '.*$'
let l:Tag_List = taglist (l:Pattern)
for Tag_Item in l:Tag_List
if l:Tag_Item['kind'] == ''
let l:Match_Item = {
\ 'word':  l:Tag_Item['name'],
\ 'menu':  l:Tag_Item['filename'],
\ 'info':  "Symbol from file " . l:Tag_Item['filename'] . " line " . l:Tag_Item['cmd'],
\ 'kind':  's',
\ 'icase': 1}
else
let l:Info	= 'Symbol		 : ' . l:Tag_Item['name']  . "\n"
let l:Info .= 'Of type		 : ' . g:ada#Ctags_Kinds[l:Tag_Item['kind']][1]  . "\n"
let l:Info .= 'Defined in File	 : ' . l:Tag_Item['filename'] . "\n"
if has_key( l:Tag_Item, 'package')
let l:Info .= 'Package		    : ' . l:Tag_Item['package'] . "\n"
let l:Menu  = l:Tag_Item['package']
elseif has_key( l:Tag_Item, 'separate')
let l:Info .= 'Separate from Package : ' . l:Tag_Item['separate'] . "\n"
let l:Menu  = l:Tag_Item['separate']
elseif has_key( l:Tag_Item, 'packspec')
let l:Info .= 'Package Specification : ' . l:Tag_Item['packspec'] . "\n"
let l:Menu  = l:Tag_Item['packspec']
elseif has_key( l:Tag_Item, 'type')
let l:Info .= 'Datetype		    : ' . l:Tag_Item['type'] . "\n"
let l:Menu  = l:Tag_Item['type']
else
let l:Menu  = l:Tag_Item['filename']
endif
let l:Match_Item = {
\ 'word':  l:Tag_Item['name'],
\ 'menu':  l:Menu,
\ 'info':  l:Info,
\ 'kind':  l:Tag_Item['kind'],
\ 'icase': 1}
endif
if complete_add (l:Match_Item) == 0
return []
endif
if complete_check ()
return []
endif
endfor
return []
endif
endfunction adacomplete#Complete
finish " 1}}}
