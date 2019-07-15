if !exists("main_syntax")
if version < 600
syntax clear
elseif exists("b:current_syntax")
finish
endif
let main_syntax = "typescript"
endif
if version < 600 && exists("typescript_fold")
unlet typescript_fold
endif
setlocal iskeyword+=$
syntax sync fromstart
syn match shebang "^#!.*/bin/env\s\+node\>"
hi link shebang Comment
syn keyword typescriptCommentTodo TODO FIXME XXX TBD contained
syn match typescriptLineComment "\/\/.*" contains=@Spell,typescriptCommentTodo,typescriptRef
syn match typescriptRefComment /\/\/\/<\(reference\|amd-\(dependency\|module\)\)\s\+.*\/>$/ contains=typescriptRefD,typescriptRefS
syn region typescriptRefD start=+"+ skip=+\\\\\|\\"+ end=+"\|$+
syn region typescriptRefS start=+'+ skip=+\\\\\|\\'+ end=+'\|$+
syn match typescriptCommentSkip "^[ \t]*\*\($\|[ \t]\+\)"
syn region typescriptComment start="/\*" end="\*/" contains=@Spell,typescriptCommentTodo extend
if !exists("typescript_ignore_typescriptdoc")
syntax case ignore
syntax region typescriptDocComment start="/\*\*\s*$" end="\*/" contains=typescriptDocTags,typescriptCommentTodo,typescriptCvsTag,@typescriptHtml,@Spell fold extend
syntax match typescriptDocTags contained "@\(param\|argument\|requires\|exception\|throws\|type\|class\|extends\|see\|link\|member\|module\|method\|title\|namespace\|optional\|default\|base\|file\|returns\=\)\>" nextgroup=typescriptDocParam,typescriptDocSeeTag skipwhite
syntax match typescriptDocTags contained "@\(beta\|deprecated\|description\|fileoverview\|author\|license\|version\|constructor\|private\|protected\|final\|ignore\|addon\|exec\)\>"
syntax match typescriptDocParam contained "\%(#\|\w\|\.\|:\|\/\)\+"
syntax region typescriptDocSeeTag contained matchgroup=typescriptDocSeeTag start="{" end="}" contains=typescriptDocTags
syntax case match
endif "" JSDoc end
syntax case match
syn match typescriptSpecial "\\\d\d\d\|\\x\x\{2\}\|\\u\x\{4\}" contained containedin=typescriptStringD,typescriptStringS,typescriptStringB display
syn region typescriptStringD start=+"+ skip=+\\\\\|\\"+ end=+"\|$+  contains=typescriptSpecial,@htmlPreproc extend
syn region typescriptStringS start=+'+ skip=+\\\\\|\\'+ end=+'\|$+  contains=typescriptSpecial,@htmlPreproc extend
syn region typescriptStringB start=+`+ skip=+\\\\\|\\`+ end=+`+  contains=typescriptInterpolation,typescriptSpecial,@htmlPreproc extend
syn region typescriptInterpolation matchgroup=typescriptInterpolationDelimiter
\ start=/${/ end=/}/ contained
\ contains=@typescriptExpression
syn match typescriptNumber "-\=\<\d[0-9_]*L\=\>" display
syn match typescriptNumber "-\=\<0[xX][0-9a-fA-F][0-9a-fA-F_]*\>" display
syn match typescriptNumber "-\=\<0[bB][01][01_]*\>" display
syn match typescriptNumber "-\=\<0[oO]\o[0-7_]*\>" display
syn region typescriptRegexpString start=+/[^/*]+me=e-1 skip=+\\\\\|\\/+ end=+/[gi]\{0,2\}\s*$+ end=+/[gi]\{0,2\}\s*[;.,)\]}]+me=e-1 contains=@htmlPreproc oneline
syntax match typescriptFloat /\<-\=\%(\d[0-9_]*\.\d[0-9_]*\|\d[0-9_]*\.\|\.\d[0-9]*\)\%([eE][+-]\=\d[0-9_]*\)\=\>/
syn match typescriptDecorators /@\([_$a-zA-Z][_$a-zA-Z0-9]*\.\)*[_$a-zA-Z][_$a-zA-Z0-9]*\>/
syntax keyword typescriptPrototype contained prototype
if get(g:, 'typescript_ignore_browserwords', 0)
syntax keyword typescriptBrowserObjects window navigator screen history location
syntax keyword typescriptDOMObjects document event HTMLElement Anchor Area Base Body Button Form Frame Frameset Image Link Meta Option Select Style Table TableCell TableRow Textarea
syntax keyword typescriptDOMMethods contained createTextNode createElement insertBefore replaceChild removeChild appendChild hasChildNodes cloneNode normalize isSupported hasAttributes getAttribute setAttribute removeAttribute getAttributeNode setAttributeNode removeAttributeNode getElementsByTagName hasAttribute getElementById adoptNode close compareDocumentPosition createAttribute createCDATASection createComment createDocumentFragment createElementNS createEvent createExpression createNSResolver createProcessingInstruction createRange createTreeWalker elementFromPoint evaluate getBoxObjectFor getElementsByClassName getSelection getUserData hasFocus importNode
syntax keyword typescriptDOMProperties contained nodeName nodeValue nodeType parentNode childNodes firstChild lastChild previousSibling nextSibling attributes ownerDocument namespaceURI prefix localName tagName
syntax keyword typescriptAjaxObjects XMLHttpRequest
syntax keyword typescriptAjaxProperties contained readyState responseText responseXML statusText
syntax keyword typescriptAjaxMethods contained onreadystatechange abort getAllResponseHeaders getResponseHeader open send setRequestHeader
syntax keyword typescriptPropietaryObjects ActiveXObject
syntax keyword typescriptPropietaryMethods contained attachEvent detachEvent cancelBubble returnValue
syntax keyword typescriptHtmlElemProperties contained className clientHeight clientLeft clientTop clientWidth dir href id innerHTML lang length offsetHeight offsetLeft offsetParent offsetTop offsetWidth scrollHeight scrollLeft scrollTop scrollWidth style tabIndex target title
syntax keyword typescriptEventListenerKeywords contained blur click focus mouseover mouseout load item
syntax keyword typescriptEventListenerMethods contained scrollIntoView addEventListener dispatchEvent removeEventListener preventDefault stopPropagation
endif
syntax keyword typescriptSource import export from as
syntax keyword typescriptIdentifier arguments this void
syntax keyword typescriptStorageClass let var const
syntax keyword typescriptOperator delete new instanceof typeof
syntax keyword typescriptBoolean true false
syntax keyword typescriptNull null undefined
syntax keyword typescriptMessage alert confirm prompt status
syntax keyword typescriptGlobal self top parent
syntax keyword typescriptDeprecated escape unescape all applets alinkColor bgColor fgColor linkColor vlinkColor xmlEncoding
syntax keyword typescriptConditional if else switch
syntax keyword typescriptRepeat do while for in of
syntax keyword typescriptBranch break continue yield await
syntax keyword typescriptLabel case default async readonly
syntax keyword typescriptStatement return with
syntax keyword typescriptGlobalObjects Array Boolean Date Function Infinity JSON Math Number NaN Object Packages RegExp String Symbol netscape
syntax keyword typescriptExceptions try catch throw finally Error EvalError RangeError ReferenceError SyntaxError TypeError URIError
syntax keyword typescriptReserved constructor declare as interface module abstract enum int short export interface static byte extends long super char final native synchronized class float package throws goto private transient debugger implements protected volatile double import public type namespace from get set keyof
syn match typescriptFunction "(super\s*|constructor\s*)" contained nextgroup=typescriptVars
syn region typescriptVars start="(" end=")" contained contains=typescriptParameters transparent keepend
syn match typescriptParameters "([a-zA-Z0-9_?.$][\w?.$]*)\s*:\s*([a-zA-Z0-9_?.$][\w?.$]*)" contained skipwhite
syntax keyword typescriptType DOMImplementation DocumentFragment Node NodeList NamedNodeMap CharacterData Attr Element Text Comment CDATASection DocumentType Notation Entity EntityReference ProcessingInstruction void any string boolean number symbol never object unknown
syntax keyword typescriptExceptions DOMException
syntax keyword typescriptDomErrNo INDEX_SIZE_ERR DOMSTRING_SIZE_ERR HIERARCHY_REQUEST_ERR WRONG_DOCUMENT_ERR INVALID_CHARACTER_ERR NO_DATA_ALLOWED_ERR NO_MODIFICATION_ALLOWED_ERR NOT_FOUND_ERR NOT_SUPPORTED_ERR INUSE_ATTRIBUTE_ERR INVALID_STATE_ERR SYNTAX_ERR INVALID_MODIFICATION_ERR NAMESPACE_ERR INVALID_ACCESS_ERR
syntax keyword typescriptDomNodeConsts ELEMENT_NODE ATTRIBUTE_NODE TEXT_NODE CDATA_SECTION_NODE ENTITY_REFERENCE_NODE ENTITY_NODE PROCESSING_INSTRUCTION_NODE COMMENT_NODE DOCUMENT_NODE DOCUMENT_TYPE_NODE DOCUMENT_FRAGMENT_NODE NOTATION_NODE
syntax case ignore
syntax keyword typescriptHtmlEvents onblur onclick oncontextmenu ondblclick onfocus onkeydown onkeypress onkeyup onmousedown onmousemove onmouseout onmouseover onmouseup onresize onload onsubmit
syntax case match
if exists("typescript_enable_domhtmlcss")
syntax match typescriptDomElemAttrs contained /\%(nodeName\|nodeValue\|nodeType\|parentNode\|childNodes\|firstChild\|lastChild\|previousSibling\|nextSibling\|attributes\|ownerDocument\|namespaceURI\|prefix\|localName\|tagName\)\>/
syntax match typescriptDomElemFuncs contained /\%(insertBefore\|replaceChild\|removeChild\|appendChild\|hasChildNodes\|cloneNode\|normalize\|isSupported\|hasAttributes\|getAttribute\|setAttribute\|removeAttribute\|getAttributeNode\|setAttributeNode\|removeAttributeNode\|getElementsByTagName\|getAttributeNS\|setAttributeNS\|removeAttributeNS\|getAttributeNodeNS\|setAttributeNodeNS\|getElementsByTagNameNS\|hasAttribute\|hasAttributeNS\)\>/ nextgroup=typescriptParen skipwhite
syntax match typescriptHtmlElemAttrs contained /\%(className\|clientHeight\|clientLeft\|clientTop\|clientWidth\|dir\|id\|innerHTML\|lang\|length\|offsetHeight\|offsetLeft\|offsetParent\|offsetTop\|offsetWidth\|scrollHeight\|scrollLeft\|scrollTop\|scrollWidth\|style\|tabIndex\|title\)\>/
syntax match typescriptHtmlElemFuncs contained /\%(blur\|click\|focus\|scrollIntoView\|addEventListener\|dispatchEvent\|removeEventListener\|item\)\>/ nextgroup=typescriptParen skipwhite
syntax keyword typescriptCssStyles contained color font fontFamily fontSize fontSizeAdjust fontStretch fontStyle fontVariant fontWeight letterSpacing lineBreak lineHeight quotes rubyAlign rubyOverhang rubyPosition
syntax keyword typescriptCssStyles contained textAlign textAlignLast textAutospace textDecoration textIndent textJustify textJustifyTrim textKashidaSpace textOverflowW6 textShadow textTransform textUnderlinePosition
syntax keyword typescriptCssStyles contained unicodeBidi whiteSpace wordBreak wordSpacing wordWrap writingMode
syntax keyword typescriptCssStyles contained bottom height left position right top width zIndex
syntax keyword typescriptCssStyles contained border borderBottom borderLeft borderRight borderTop borderBottomColor borderLeftColor borderTopColor borderBottomStyle borderLeftStyle borderRightStyle borderTopStyle borderBottomWidth borderLeftWidth borderRightWidth borderTopWidth borderColor borderStyle borderWidth borderCollapse borderSpacing captionSide emptyCells tableLayout
syntax keyword typescriptCssStyles contained margin marginBottom marginLeft marginRight marginTop outline outlineColor outlineStyle outlineWidth padding paddingBottom paddingLeft paddingRight paddingTop
syntax keyword typescriptCssStyles contained listStyle listStyleImage listStylePosition listStyleType
syntax keyword typescriptCssStyles contained background backgroundAttachment backgroundColor backgroundImage backgroundPosition backgroundPositionX backgroundPositionY backgroundRepeat
syntax keyword typescriptCssStyles contained clear clip clipBottom clipLeft clipRight clipTop content counterIncrement counterReset cssFloat cursor direction display filter layoutGrid layoutGridChar layoutGridLine layoutGridMode layoutGridType
syntax keyword typescriptCssStyles contained marks maxHeight maxWidth minHeight minWidth opacity MozOpacity overflow overflowX overflowY verticalAlign visibility zoom cssText
syntax keyword typescriptCssStyles contained scrollbar3dLightColor scrollbarArrowColor scrollbarBaseColor scrollbarDarkShadowColor scrollbarFaceColor scrollbarHighlightColor scrollbarShadowColor scrollbarTrackColor
endif "DOM/HTML/CSS
syntax match typescriptDotNotation "\."        nextgroup=typescriptPrototype,typescriptDomElemAttrs,typescriptDomElemFuncs,typescriptDOMMethods,typescriptDOMProperties,typescriptHtmlElemAttrs,typescriptHtmlElemFuncs,typescriptHtmlElemProperties,typescriptAjaxProperties,typescriptAjaxMethods,typescriptPropietaryMethods,typescriptEventListenerMethods skipwhite skipnl
syntax match typescriptDotNotation "\.style\." nextgroup=typescriptCssStyles
syntax cluster typescriptAll contains=typescriptComment,typescriptLineComment,typescriptDocComment,typescriptStringD,typescriptStringS,typescriptStringB,typescriptRegexpString,typescriptNumber,typescriptFloat,typescriptDecorators,typescriptLabel,typescriptSource,typescriptType,typescriptOperator,typescriptBoolean,typescriptNull,typescriptFuncKeyword,typescriptConditional,typescriptGlobal,typescriptRepeat,typescriptBranch,typescriptStatement,typescriptGlobalObjects,typescriptMessage,typescriptIdentifier,typescriptStorageClass,typescriptExceptions,typescriptReserved,typescriptDeprecated,typescriptDomErrNo,typescriptDomNodeConsts,typescriptHtmlEvents,typescriptDotNotation,typescriptBrowserObjects,typescriptDOMObjects,typescriptAjaxObjects,typescriptPropietaryObjects,typescriptDOMMethods,typescriptHtmlElemProperties,typescriptDOMProperties,typescriptEventListenerKeywords,typescriptEventListenerMethods,typescriptAjaxProperties,typescriptAjaxMethods,typescriptFuncArg
if main_syntax == "typescript"
syntax sync clear
syntax sync ccomment typescriptComment minlines=200
endif
syntax keyword typescriptFuncKeyword function
syn match typescriptBraces "[{}\[\]]"
syn match typescriptParens "[()]"
syn match typescriptOpSymbols "=\{1,3}\|!==\|!=\|<\|>\|>=\|<=\|++\|+=\|--\|-="
syn match typescriptEndColons "[;,]"
syn match typescriptLogicSymbols "\(&&\)\|\(||\)\|\(!\)"
syn region foldBraces start=/{/ skip=/\(\/\/.*\)\|\(\/.*\/\)/ end=/}/ transparent fold keepend extend
if version >= 508 || !exists("did_typescript_syn_inits")
if version < 508
let did_typescript_syn_inits = 1
command -nargs=+ HiLink hi link <args>
else
command -nargs=+ HiLink hi def link <args>
endif
HiLink typescriptParameters Operator
HiLink typescriptSuperBlock Operator
HiLink typescriptEndColons Exception
HiLink typescriptOpSymbols Operator
HiLink typescriptLogicSymbols Boolean
HiLink typescriptBraces Function
HiLink typescriptParens Operator
HiLink typescriptComment Comment
HiLink typescriptLineComment Comment
HiLink typescriptRefComment Include
HiLink typescriptRefS String
HiLink typescriptRefD String
HiLink typescriptDocComment Comment
HiLink typescriptCommentTodo Todo
HiLink typescriptCvsTag Function
HiLink typescriptDocTags Special
HiLink typescriptDocSeeTag Function
HiLink typescriptDocParam Function
HiLink typescriptStringS String
HiLink typescriptStringD String
HiLink typescriptStringB String
HiLink typescriptInterpolationDelimiter Delimiter
HiLink typescriptRegexpString String
HiLink typescriptGlobal Constant
HiLink typescriptCharacter Character
HiLink typescriptPrototype Type
HiLink typescriptConditional Conditional
HiLink typescriptBranch Conditional
HiLink typescriptIdentifier Identifier
HiLink typescriptStorageClass StorageClass
HiLink typescriptRepeat Repeat
HiLink typescriptStatement Statement
HiLink typescriptFuncKeyword Function
HiLink typescriptMessage Keyword
HiLink typescriptDeprecated Exception
HiLink typescriptError Error
HiLink typescriptParensError Error
HiLink typescriptParensErrA Error
HiLink typescriptParensErrB Error
HiLink typescriptParensErrC Error
HiLink typescriptReserved Keyword
HiLink typescriptOperator Operator
HiLink typescriptType Type
HiLink typescriptNull Type
HiLink typescriptNumber Number
HiLink typescriptFloat Number
HiLink typescriptDecorators Special
HiLink typescriptBoolean Boolean
HiLink typescriptLabel Label
HiLink typescriptSpecial Special
HiLink typescriptSource Special
HiLink typescriptGlobalObjects Special
HiLink typescriptExceptions Special
HiLink typescriptDomErrNo Constant
HiLink typescriptDomNodeConsts Constant
HiLink typescriptDomElemAttrs Label
HiLink typescriptDomElemFuncs PreProc
HiLink typescriptHtmlElemAttrs Label
HiLink typescriptHtmlElemFuncs PreProc
HiLink typescriptCssStyles Label
HiLink typescriptBrowserObjects Constant
HiLink typescriptDOMObjects Constant
HiLink typescriptDOMMethods Function
HiLink typescriptDOMProperties Special
HiLink typescriptAjaxObjects Constant
HiLink typescriptAjaxMethods Function
HiLink typescriptAjaxProperties Special
HiLink typescriptFuncDef Title
HiLink typescriptFuncArg Special
HiLink typescriptFuncComma Operator
HiLink typescriptHtmlEvents Special
HiLink typescriptHtmlElemProperties Special
HiLink typescriptEventListenerKeywords Keyword
HiLink typescriptNumber Number
HiLink typescriptPropietaryObjects Constant
delcommand HiLink
endif
syntax cluster htmltypescript contains=@typescriptAll,typescriptBracket,typescriptParen,typescriptBlock,typescriptParenError
syntax cluster typescriptExpression contains=@typescriptAll,typescriptBracket,typescriptParen,typescriptBlock,typescriptParenError,@htmlPreproc
let b:current_syntax = "typescript"
if main_syntax == 'typescript'
unlet main_syntax
endif
