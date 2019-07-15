if exists("b:current_syntax")
finish
endif
syn match hgcommitComment "^HG:.*$"             contains=@NoSpell
syn match hgcommitUser    "^HG: user: \zs.*$"   contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitBranch  "^HG: branch \zs.*$"  contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitAdded   "^HG: \zsadded .*$"   contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitChanged "^HG: \zschanged .*$" contains=@NoSpell contained containedin=hgcommitComment
syn match hgcommitRemoved "^HG: \zsremoved .*$" contains=@NoSpell contained containedin=hgcommitComment
hi def link hgcommitComment Comment
hi def link hgcommitUser    String
hi def link hgcommitBranch  String
hi def link hgcommitAdded   Identifier
hi def link hgcommitChanged Special
hi def link hgcommitRemoved Constant
let b:current_syntax = "hgcommit"
