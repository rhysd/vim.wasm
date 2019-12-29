if exists("b:current_syntax")
finish
endif
let s:xml_cpo_save = &cpo
set cpo&vim
syn case match
syn spell toplevel
syn match xmlError "[<&]"
syn region  xmlString contained start=+"+ end=+"+ contains=xmlEntity,@Spell display
syn region  xmlString contained start=+'+ end=+'+ contains=xmlEntity,@Spell display
syn match   xmlAttribPunct +[:.]+ contained display
syn match   xmlEqual +=+ display
syn match   xmlAttrib
\ +[-'"<]\@1<!\<[a-zA-Z:_][-.0-9a-zA-Z:_]*\>\%(['"]\@!\|$\)+
\ contained
\ contains=xmlAttribPunct,@xmlAttribHook
\ display
if exists("g:xml_namespace_transparent")
syn match   xmlNamespace
\ +\(<\|</\)\@2<=[^ /!?<>"':]\+[:]\@=+
\ contained
\ contains=@xmlNamespaceHook
\ transparent
\ display
else
syn match   xmlNamespace
\ +\(<\|</\)\@2<=[^ /!?<>"':]\+[:]\@=+
\ contained
\ contains=@xmlNamespaceHook
\ display
endif
syn match   xmlTagName
\ +\%(<\|</\)\@2<=[^ /!?<>"']\++
\ contained
\ contains=xmlNamespace,xmlAttribPunct,@xmlTagHook
\ display
if exists('g:xml_syntax_folding')
syn region   xmlTag
\ matchgroup=xmlTag start=+<[^ /!?<>"']\@=+
\ matchgroup=xmlTag end=+>+
\ contained
\ contains=xmlError,xmlTagName,xmlAttrib,xmlEqual,xmlString,@xmlStartTagHook
syn region   xmlEndTag
\ matchgroup=xmlTag start=+</[^ /!?<>"']\@=+
\ matchgroup=xmlTag end=+>+
\ contained
\ contains=xmlTagName,xmlNamespace,xmlAttribPunct,@xmlTagHook
syn region   xmlRegion
\ start=+<\z([^ /!?<>"']\+\)+
\ skip=+<!--\_.\{-}-->+
\ end=+</\z1\_\s\{-}>+
\ end=+/>+
\ fold
\ contains=xmlTag,xmlEndTag,xmlCdata,xmlRegion,xmlComment,xmlEntity,xmlProcessing,@xmlRegionHook,@Spell
\ keepend
\ extend
else
syn region   xmlTag
\ matchgroup=xmlTag start=+<[^ /!?<>"']\@=+
\ matchgroup=xmlTag end=+>+
\ contains=xmlError,xmlTagName,xmlAttrib,xmlEqual,xmlString,@xmlStartTagHook
syn region   xmlEndTag
\ matchgroup=xmlTag start=+</[^ /!?<>"']\@=+
\ matchgroup=xmlTag end=+>+
\ contains=xmlTagName,xmlNamespace,xmlAttribPunct,@xmlTagHook
endif
syn match   xmlEntity                 "&[^; \t]*;" contains=xmlEntityPunct
syn match   xmlEntityPunct  contained "[&.;]"
if exists('g:xml_syntax_folding')
syn region  xmlComment
\ start=+<!+
\ end=+>+
\ contains=xmlCommentStart,xmlCommentError
\ extend
\ fold
else
syn region  xmlComment
\ start=+<!+
\ end=+>+
\ contains=xmlCommentStart,xmlCommentError
\ extend
endif
syn match xmlCommentStart   contained "<!" nextgroup=xmlCommentPart
syn keyword xmlTodo         contained TODO FIXME XXX
syn match   xmlCommentError contained "[^><!]"
syn region  xmlCommentPart
\ start=+--+
\ end=+--+
\ contained
\ contains=xmlTodo,@xmlCommentHook,@Spell
syn region    xmlCdata
\ start=+<!\[CDATA\[+
\ end=+]]>+
\ contains=xmlCdataStart,xmlCdataEnd,@xmlCdataHook,@Spell
\ keepend
\ extend
syn match    xmlCdataStart +<!\[CDATA\[+  contained contains=xmlCdataCdata
syn keyword  xmlCdataCdata CDATA          contained
syn match    xmlCdataEnd   +]]>+          contained
syn region  xmlProcessing matchgroup=xmlProcessingDelim start="<?" end="?>" contains=xmlAttrib,xmlEqual,xmlString
if exists('g:xml_syntax_folding')
syn region  xmlDocType matchgroup=xmlDocTypeDecl
\ start="<!DOCTYPE"he=s+2,rs=s+2 end=">"
\ fold
\ contains=xmlDocTypeKeyword,xmlInlineDTD,xmlString
else
syn region  xmlDocType matchgroup=xmlDocTypeDecl
\ start="<!DOCTYPE"he=s+2,rs=s+2 end=">"
\ contains=xmlDocTypeKeyword,xmlInlineDTD,xmlString
endif
syn keyword xmlDocTypeKeyword contained DOCTYPE PUBLIC SYSTEM
syn region  xmlInlineDTD contained matchgroup=xmlDocTypeDecl start="\[" end="]" contains=@xmlDTD
syn include @xmlDTD <sfile>:p:h/dtd.vim
unlet b:current_syntax
syn sync match xmlSyncDT grouphere  xmlDocType +\_.\(<!DOCTYPE\)\@=+
if exists('g:xml_syntax_folding')
syn sync match xmlSync grouphere   xmlRegion  +\_.\(<[^ /!?<>"']\+\)\@=+
syn sync match xmlSync groupthere  xmlRegion  +</[^ /!?<>"']\+>+
endif
syn sync minlines=100
hi def link xmlTodo		Todo
hi def link xmlTag		Function
hi def link xmlTagName		Function
hi def link xmlEndTag		Identifier
if !exists("g:xml_namespace_transparent")
hi def link xmlNamespace	Tag
endif
hi def link xmlEntity		Statement
hi def link xmlEntityPunct	Type
hi def link xmlAttribPunct	Comment
hi def link xmlAttrib		Type
hi def link xmlString		String
hi def link xmlComment		Comment
hi def link xmlCommentStart	xmlComment
hi def link xmlCommentPart	Comment
hi def link xmlCommentError	Error
hi def link xmlError		Error
hi def link xmlProcessingDelim	Comment
hi def link xmlProcessing	Type
hi def link xmlCdata		String
hi def link xmlCdataCdata	Statement
hi def link xmlCdataStart	Type
hi def link xmlCdataEnd		Type
hi def link xmlDocTypeDecl	Function
hi def link xmlDocTypeKeyword	Statement
hi def link xmlInlineDTD	Function
let b:current_syntax = "xml"
let &cpo = s:xml_cpo_save
unlet s:xml_cpo_save
