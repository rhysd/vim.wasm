if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
if exists("nroff_space_errors")
syn match nroffError /\s\+$/
syn match nroffSpaceError /[.,:;!?]\s\{2,}/
endif
setlocal paragraphs+=XP
if exists("b:preprocs_as_sections")
setlocal sections=EQTSPS[\ G1GS
endif
syn match nroffEscChar /\\[CN]/ nextgroup=nroffEscCharArg
syn match nroffEscape /\\[*fgmnYV]/ nextgroup=nroffEscRegPar,nroffEscRegArg
syn match nroffEscape /\\s[+-]\=/ nextgroup=nroffSize
syn match nroffEscape /\\[$AbDhlLRvxXZ]/ nextgroup=nroffEscPar,nroffEscArg
syn match nroffEscRegArg /./ contained
syn match nroffEscRegArg2 /../ contained
syn match nroffEscRegPar /(/ contained nextgroup=nroffEscRegArg2
syn match nroffEscArg /./ contained
syn match nroffEscArg2 /../ contained
syn match nroffEscPar /(/ contained nextgroup=nroffEscArg2
syn match nroffSize /\((\d\)\=\d/ contained
syn region nroffEscCharArg start=/'/ end=/'/ contained
syn region nroffEscArg start=/'/ end=/'/ contained contains=nroffEscape,@nroffSpecial
if exists("b:nroff_is_groff")
syn region nroffEscRegArg matchgroup=nroffEscape start=/\[/ end=/\]/ contained oneline
syn region nroffSize matchgroup=nroffEscape start=/\[/ end=/\]/ contained
endif
syn match nroffEscape /\\[adprtu{}]/
syn match nroffEscape /\\$/
syn match nroffEscape /\\\$[@*]/
syn match nroffSpecialChar /\\[\\eE?!-]/
syn match nroffSpace "\\[&%~|^0)/,]"
syn match nroffSpecialChar /\\(../
if exists("b:nroff_is_groff")
syn match nroffSpecialChar /\\\[[^]]*]/
syn region nroffPreserve  matchgroup=nroffSpecialChar start=/\\?/ end=/\\?/ oneline
endif
syn region nroffPreserve matchgroup=nroffSpecialChar start=/\\!/ end=/$/ oneline
syn cluster nroffSpecial contains=nroffSpecialChar,nroffSpace
syn region nroffString start=/"/ end=/"/ skip=/\\$/ contains=nroffEscape,@nroffSpecial contained
syn region nroffString start=/'/ end=/'/ skip=/\\$/ contains=nroffEscape,@nroffSpecial contained
syn match nroffNumBlock /[0-9.]\a\=/ contained contains=nroffNumber
syn match nroffNumber /\d\+\(\.\d*\)\=/ contained nextgroup=nroffUnit,nroffBadChar
syn match nroffNumber /\.\d\+)/ contained nextgroup=nroffUnit,nroffBadChar
syn match nroffBadChar /./ contained
syn match nroffUnit /[icpPszmnvMu]/ contained
syn match nroffReqLeader /^[.']/	nextgroup=nroffReqName skipwhite
syn match nroffReqLeader /[.']/	contained nextgroup=nroffReqName skipwhite
if exists("b:nroff_is_groff")
syn match nroffReqName /[^\t \\\[?]\+/ contained nextgroup=nroffReqArg
else
syn match nroffReqName /[^\t \\\[?]\{1,2}/ contained nextgroup=nroffReqArg
endif
syn region nroffReqArg start=/\S/ skip=/\\$/ end=/$/ contained contains=nroffEscape,@nroffSpecial,nroffString,nroffError,nroffSpaceError,nroffNumBlock,nroffComment
syn match nroffReqName /\(if\|ie\)/ contained nextgroup=nroffCond skipwhite
syn match nroffReqName /el/ contained nextgroup=nroffReqLeader skipwhite
syn match nroffCond /\S\+/ contained nextgroup=nroffReqLeader skipwhite
syn match nroffReqname /[da]s/ contained nextgroup=nroffDefIdent skipwhite
syn match nroffDefIdent /\S\+/ contained nextgroup=nroffDefinition skipwhite
syn region nroffDefinition matchgroup=nroffSpecialChar start=/"/ matchgroup=NONE end=/\\"/me=e-2 skip=/\\$/ start=/\S/ end=/$/ contained contains=nroffDefSpecial
syn match nroffDefSpecial /\\$/ contained
syn match nroffDefSpecial /\\\((.\)\=./ contained
if exists("b:nroff_is_groff")
syn match nroffDefSpecial /\\\[[^]]*]/ contained
endif
syn match nroffReqName /\(d[ei]\|am\)/ contained nextgroup=nroffIdent skipwhite
syn match nroffIdent /[^[?( \t]\+/ contained
if exists("b:nroff_is_groff")
syn match nroffReqName /als/ contained nextgroup=nroffIdent skipwhite
endif
syn match nroffReqName /[rn]r/ contained nextgroup=nroffIdent skipwhite
if exists("b:nroff_is_groff")
syn match nroffReqName /\(rnn\|aln\)/ contained nextgroup=nroffIdent skipwhite
endif
syn region nroffEquation start=/^\.\s*EQ\>/ end=/^\.\s*EN\>/
syn region nroffTable start=/^\.\s*TS\>/ end=/^\.\s*TE\>/
syn region nroffPicture start=/^\.\s*PS\>/ end=/^\.\s*PE\>/
syn region nroffRefer start=/^\.\s*\[\>/ end=/^\.\s*\]\>/
syn region nroffGrap start=/^\.\s*G1\>/ end=/^\.\s*G2\>/
syn region nroffGremlin start=/^\.\s*GS\>/ end=/^\.\s*GE|GF\>/
syn region nroffIgnore start=/^[.']\s*ig/ end=/^['.]\s*\./
syn match nroffComment /\(^[.']\s*\)\=\\".*/ contains=nroffTodo
syn match nroffComment /^'''.*/  contains=nroffTodo
if exists("b:nroff_is_groff")
syn match nroffComment "\\#.*$" contains=nroffTodo
endif
syn keyword nroffTodo TODO XXX FIXME contained
hi def link nroffEscChar nroffSpecialChar
hi def link nroffEscCharAr nroffSpecialChar
hi def link nroffSpecialChar SpecialChar
hi def link nroffSpace Delimiter
hi def link nroffEscRegArg2 nroffEscRegArg
hi def link nroffEscRegArg nroffIdent
hi def link nroffEscArg2 nroffEscArg
hi def link nroffEscPar nroffEscape
hi def link nroffEscRegPar nroffEscape
hi def link nroffEscArg nroffEscape
hi def link nroffSize nroffEscape
hi def link nroffEscape Preproc
hi def link nroffIgnore Comment
hi def link nroffComment Comment
hi def link nroffTodo Todo
hi def link nroffReqLeader nroffRequest
hi def link nroffReqName nroffRequest
hi def link nroffRequest Statement
hi def link nroffCond PreCondit
hi def link nroffDefIdent nroffIdent
hi def link nroffIdent Identifier
hi def link nroffEquation PreProc
hi def link nroffTable PreProc
hi def link nroffPicture PreProc
hi def link nroffRefer PreProc
hi def link nroffGrap PreProc
hi def link nroffGremlin PreProc
hi def link nroffNumber Number
hi def link nroffBadChar nroffError
hi def link nroffSpaceError nroffError
hi def link nroffError Error
hi def link nroffPreserve String
hi def link nroffString String
hi def link nroffDefinition String
hi def link nroffDefSpecial Special
let b:current_syntax = "nroff"
let &cpo = s:cpo_save
unlet s:cpo_save
