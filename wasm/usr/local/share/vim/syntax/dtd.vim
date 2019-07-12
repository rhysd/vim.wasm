if exists("b:current_syntax")
finish
endif
let s:dtd_cpo_save = &cpo
set cpo&vim
if !exists("dtd_ignore_case")
syn case match
else
syn case ignore
endif
syn region dtdTag matchgroup=dtdFunction
\ start=+<!+ end=+>+ matchgroup=NONE
\ contains=dtdTag,dtdTagName,dtdError,dtdComment,dtdString,dtdAttrType,dtdAttrDef,dtdEnum,dtdParamEntityInst,dtdParamEntityDecl,dtdCard,@dtdTagHook
if !exists("dtd_no_tag_errors")
syn region dtdError contained start=+<!+lc=2 end=+>+
endif
syn region dtdComment		start=+<![ \t]*--+ end=+-->+ contains=dtdTodo,@Spell
syn region dtdComment contained start=+--+ end=+--+ contains=dtdTodo,@Spell
syn match dtdTagName contained +<!\(ATTLIST\|DOCTYPE\|ELEMENT\|ENTITY\|NOTATION\|SHORTREF\|USEMAP\|\[\)+lc=2,hs=s+2
syn match  dtdCard contained "|"
syn match  dtdCard contained ","
syn match  dtdCard contained "&"
syn match  dtdCard contained "?"
syn match  dtdCard contained "\*"
syn match  dtdCard contained "+"
syn match  dtdCard      "ANY"
syn match  dtdCard      "EMPTY"
if !exists("dtd_no_param_entities")
syn region dtdParamEntityInst oneline matchgroup=dtdParamEntityPunct
\ start="%[-_a-zA-Z0-9.]\+"he=s+1,rs=s+1
\ skip=+[-_a-zA-Z0-9.]+
\ end=";\|\>"
\ matchgroup=NONE contains=dtdParamEntityPunct
syn match  dtdParamEntityPunct contained "\."
syn match dtdParamEntityDecl +<!ENTITY % [-_a-zA-Z0-9.]*+lc=8 contains=dtdParamEntityDPunct
syn match  dtdParamEntityDPunct contained "%\|\."
endif
syn match   dtdEntity		      "&[^; \t]*;" contains=dtdEntityPunct
syn match   dtdEntityPunct  contained "[&.;]"
syn region dtdString    start=+"+ skip=+\\\\\|\\"+  end=+"+ contains=dtdAttrDef,dtdAttrType,dtdEnum,dtdParamEntityInst,dtdEntity,dtdCard
syn region dtdString    start=+'+ skip=+\\\\\|\\'+  end=+'+ contains=dtdAttrDef,dtdAttrType,dtdEnum,dtdParamEntityInst,dtdEntity,dtdCard
syn region dtdEnum matchgroup=dtdType start="(" end=")" matchgroup=NONE contains=dtdEnum,dtdParamEntityInst,dtdCard,@dtdEnumHook
syn keyword dtdAttrType NMTOKEN  ENTITIES  NMTOKENS  ID  CDATA
syn keyword dtdAttrType IDREF  IDREFS
syn match   dtdAttrType +[^!]\<ENTITY+
syn match  dtdAttrDef   "#REQUIRED"
syn match  dtdAttrDef   "#IMPLIED"
syn match  dtdAttrDef   "#FIXED"
syn case match
syn keyword dtdTodo contained TODO FIXME XXX
syn sync lines=250
hi def link dtdFunction		Function
hi def link dtdTag		Normal
hi def link dtdType		Type
hi def link dtdAttrType		dtdType
hi def link dtdAttrDef		dtdType
hi def link dtdConstant		Constant
hi def link dtdString		dtdConstant
hi def link dtdEnum		dtdConstant
hi def link dtdCard		dtdFunction
hi def link dtdEntity		Statement
hi def link dtdEntityPunct	dtdType
hi def link dtdParamEntityInst	dtdConstant
hi def link dtdParamEntityPunct	dtdType
hi def link dtdParamEntityDecl	dtdType
hi def link dtdParamEntityDPunct dtdComment
hi def link dtdComment		Comment
hi def link dtdTagName		Statement
hi def link dtdError		Error
hi def link dtdTodo		Todo
let &cpo = s:dtd_cpo_save
unlet s:dtd_cpo_save
let b:current_syntax = "dtd"
