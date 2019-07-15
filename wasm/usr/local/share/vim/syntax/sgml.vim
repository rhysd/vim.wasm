if exists("b:current_syntax")
finish
endif
let s:sgml_cpo_save = &cpo
set cpo&vim
syn case match
syn match sgmlError "[<&]"
syn match   sgmlUnicodeNumberAttr    +\\u\x\{4}+ contained contains=sgmlUnicodeSpecifierAttr
syn match   sgmlUnicodeSpecifierAttr +\\u+ contained
syn match   sgmlUnicodeNumberData    +\\u\x\{4}+ contained contains=sgmlUnicodeSpecifierData
syn match   sgmlUnicodeSpecifierData +\\u+ contained
syn region  sgmlString contained start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=sgmlEntity,sgmlUnicodeNumberAttr display
syn region  sgmlString contained start=+'+ skip=+\\\\\|\\'+ end=+'+ contains=sgmlEntity,sgmlUnicodeNumberAttr display
syn match   sgmlAttribPunct +[:.]+ contained display
syn match   sgmlEqual +=+
syn match   sgmlAttrib
\ +[^-'"<]\@<=\<[a-zA-Z0-9.:]\+\>\([^'">]\@=\|$\)+
\ contained
\ contains=sgmlAttribPunct,@sgmlAttribHook
\ display
syn match   sgmlValue
\ +[^"' =/!?<>][^ =/!?<>]*+
\ contained
\ contains=sgmlEntity,sgmlUnicodeNumberAttr,@sgmlValueHook
\ display
syn region  sgmlValue contained start=+"+ skip=+\\\\\|\\"+ end=+"+
\ contains=sgmlEntity,sgmlUnicodeNumberAttr,@sgmlValueHook
syn region  sgmlValue contained start=+'+ skip=+\\\\\|\\'+ end=+'+
\ contains=sgmlEntity,sgmlUnicodeNumberAttr,@sgmlValueHook
syn match   sgmlEqualValue
\ +=\s*[^ =/!?<>]\++
\ contained
\ contains=sgmlEqual,sgmlString,sgmlValue
\ display
syn region   sgmlTag
\ matchgroup=sgmlTag start=+<[^ /!?"']\@=+
\ matchgroup=sgmlTag end=+>+
\ contained
\ contains=sgmlError,sgmlAttrib,sgmlEqualValue,@sgmlTagHook
syn region   sgmlEmptyTag
\ matchgroup=sgmlTag start=+<[^ /!?"']\@=+
\ matchgroup=sgmlEndTag end=+/>+
\ contained
\ contains=sgmlError,sgmlAttrib,sgmlEqualValue,@sgmlTagHook
syn match   sgmlEndTag
\ +</[^ /!?>"']\+>+
\ contained
\ contains=@sgmlTagHook
syn region   sgmlAbbrTag
\ matchgroup=sgmlTag start=+<[^ /!?"']\@=+
\ matchgroup=sgmlTag end=+/+
\ contained
\ contains=sgmlError,sgmlAttrib,sgmlEqualValue,@sgmlTagHook
syn match   sgmlAbbrEndTag +/+
syn match   sgmlAbbrRegion
\ +<[^/!?>"']\+/\_[^/]\+/+
\ contains=sgmlAbbrTag,sgmlAbbrEndTag,sgmlCdata,sgmlComment,sgmlEntity,sgmlUnicodeNumberData,@sgmlRegionHook
syn region   sgmlRegion
\ start=+<\z([^ /!?>"']\+\)\(\(\_[^/>]*[^/!?]>\)\|>\)+
\ end=+</\z1>+
\ contains=sgmlTag,sgmlEndTag,sgmlCdata,@sgmlRegionCluster,sgmlComment,sgmlEntity,sgmlUnicodeNumberData,@sgmlRegionHook
\ keepend
\ extend
syn match    sgmlEmptyRegion
\ +<[^ /!?>"']\(\_[^"'<>]\|"\_[^"]*"\|'\_[^']*'\)*/>+
\ contains=sgmlEmptyTag
syn cluster sgmlRegionCluster contains=sgmlRegion,sgmlEmptyRegion,sgmlAbbrRegion
syn match   sgmlEntity		       "&[^; \t]*;" contains=sgmlEntityPunct
syn match   sgmlEntityPunct  contained "[&.;]"
syn region  sgmlComment                start=+<!+        end=+>+ contains=sgmlCommentPart,sgmlString,sgmlCommentError,sgmlTodo
syn keyword sgmlTodo         contained TODO FIXME XXX display
syn match   sgmlCommentError contained "[^><!]"
syn region  sgmlCommentPart  contained start=+--+        end=+--+
syn region    sgmlCdata
\ start=+<!\[CDATA\[+
\ end=+]]>+
\ contains=sgmlCdataStart,sgmlCdataEnd,@sgmlCdataHook
\ keepend
\ extend
syn match    sgmlCdataStart +<!\[CDATA\[+  contained contains=sgmlCdataCdata
syn keyword  sgmlCdataCdata CDATA          contained
syn match    sgmlCdataEnd   +]]>+          contained
syn region  sgmlProcessing matchgroup=sgmlProcessingDelim start="<?" end="?>" contains=sgmlAttrib,sgmlEqualValue
syn region  sgmlDocType matchgroup=sgmlDocTypeDecl start="\c<!DOCTYPE"he=s+2,rs=s+2 end=">" contains=sgmlDocTypeKeyword,sgmlInlineDTD,sgmlString
syn keyword sgmlDocTypeKeyword contained DOCTYPE PUBLIC SYSTEM
syn region  sgmlInlineDTD contained start="\[" end="]" contains=@sgmlDTD
syn include @sgmlDTD <sfile>:p:h/dtd.vim
syn sync match sgmlSyncDT grouphere  sgmlDocType +\_.\(<!DOCTYPE\)\@=+
syn sync match sgmlSync grouphere   sgmlRegion  +\_.\(<[^ /!?>"']\+\)\@=+
syn sync match sgmlSync groupthere  sgmlRegion  +</[^ /!?>"']\+>+
syn sync minlines=100
hi def link sgmlTodo			Todo
hi def link sgmlTag			Function
hi def link sgmlEndTag			Identifier
hi def link sgmlAbbrEndTag		Identifier
hi def link sgmlEmptyTag		Function
hi def link sgmlEntity			Statement
hi def link sgmlEntityPunct		Type
hi def link sgmlAttribPunct		Comment
hi def link sgmlAttrib			Type
hi def link sgmlValue			String
hi def link sgmlString			String
hi def link sgmlComment			Comment
hi def link sgmlCommentPart		Comment
hi def link sgmlCommentError		Error
hi def link sgmlError			Error
hi def link sgmlProcessingDelim		Comment
hi def link sgmlProcessing		Type
hi def link sgmlCdata			String
hi def link sgmlCdataCdata		Statement
hi def link sgmlCdataStart		Type
hi def link sgmlCdataEnd		Type
hi def link sgmlDocTypeDecl		Function
hi def link sgmlDocTypeKeyword		Statement
hi def link sgmlInlineDTD		Function
hi def link sgmlUnicodeNumberAttr	Number
hi def link sgmlUnicodeSpecifierAttr	SpecialChar
hi def link sgmlUnicodeNumberData	Number
hi def link sgmlUnicodeSpecifierData	SpecialChar
let b:current_syntax = "sgml"
let &cpo = s:sgml_cpo_save
unlet s:sgml_cpo_save
