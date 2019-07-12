if exists("b:current_syntax")
finish
endif
let s:cpo_save=&cpo
set cpo-=C
sy sync fromstart
sy case ignore
sy include @sqlSyntax $VIMRUNTIME/syntax/sql.vim
sy match cfmlNumber
\ "\v<\d+>"
sy match cfmlEqualSign
\ "\v\="
sy match cfmlBoolean
\ "\v<(true|false)>"
sy region cfmlHashSurround
\ keepend
\ oneline
\ start="#"
\ end="#"
\ skip="##"
\ contains=
\@cfmlOperator,
\@cfmlPunctuation,
\cfmlBoolean,
\cfmlCoreKeyword,
\cfmlCoreScope,
\cfmlCustomKeyword,
\cfmlCustomScope,
\cfmlEqualSign,
\cfmlFunctionName,
\cfmlNumber
sy match cfmlArithmeticOperator
\ "\v
\(\+|-)\ze\d
\|(\+\+|--)\ze\w
\|\w\zs(\+\+|--)
\|(\s(
\(\+|-|\*|\/|\%){1}\={,1}
\|\^
\|mod
\)\s)
\"
sy match cfmlBooleanOperator
\ "\v\s
\(not|and|or|xor|eqv|imp
\|\!|\&\&|\|\|
\)(\s|\))
\|\s\!\ze\w
\"
sy match cfmlDecisionOperator
\ "\v\s
\(is|equal|eq
\|is not|not equal|neq
\|contains|does not contain
\|greater than|gt
\|less than|lt
\|greater than or equal to|gte|ge
\|less than or equal to|lte|le
\|(!|\<|\>|\=){1}\=
\|\<
\|\>
\)\s"
sy match cfmlStringOperator
\ "\v\s\&\={,1}\s"
sy match cfmlTernaryOperator
\ "\v\s
\\?|\:
\\s"
sy cluster cfmlOperator
\ contains=
\cfmlArithmeticOperator,
\cfmlBooleanOperator,
\cfmlDecisionOperator,
\cfmlStringOperator,
\cfmlTernaryOperator
sy cluster cfmlParenthesisRegionContains
\ contains=
\@cfmlAttribute,
\@cfmlComment,
\@cfmlFlowStatement,
\@cfmlOperator,
\@cfmlPunctuation,
\cfmlBoolean,
\cfmlBrace,
\cfmlCoreKeyword,
\cfmlCoreScope,
\cfmlCustomKeyword,
\cfmlCustomScope,
\cfmlEqualSign,
\cfmlFunctionName,
\cfmlNumber,
\cfmlStorageKeyword,
\cfmlStorageType
sy region cfmlParenthesisRegion1
\ extend
\ matchgroup=cfmlParenthesis1
\ transparent
\ start=/(/
\ end=/)/
\ contains=
\cfmlParenthesisRegion2,
\@cfmlParenthesisRegionContains
sy region cfmlParenthesisRegion2
\ matchgroup=cfmlParenthesis2
\ transparent
\ start=/(/
\ end=/)/
\ contains=
\cfmlParenthesisRegion3,
\@cfmlParenthesisRegionContains
sy region cfmlParenthesisRegion3
\ matchgroup=cfmlParenthesis3
\ transparent
\ start=/(/
\ end=/)/
\ contains=
\cfmlParenthesisRegion1,
\@cfmlParenthesisRegionContains
sy cluster cfmlParenthesisRegion
\ contains=
\cfmlParenthesisRegion1,
\cfmlParenthesisRegion2,
\cfmlParenthesisRegion3
sy match cfmlBrace
\ "{\|}"
sy region cfmlBraceRegion
\ extend
\ fold
\ keepend
\ transparent
\ start="{"
\ end="}"
sy match cfmlBracket
\ "\(\[\|\]\)"
\ contained
sy match cfmlComma ","
sy match cfmlDot "\."
sy match cfmlSemiColon ";"
sy region cfmlSingleQuotedValue
\ matchgroup=cfmlSingleQuote
\ start=/'/
\ skip=/''/
\ end=/'/
\ contains=
\cfmlHashSurround
sy region cfmlDoubleQuotedValue
\ matchgroup=cfmlDoubleQuote
\ start=/"/
\ skip=/""/
\ end=/"/
\ contains=
\cfmlHashSurround
sy cluster cfmlQuotedValue
\ contains=
\cfmlDoubleQuotedValue,
\cfmlSingleQuotedValue
sy cluster cfmlQuote
\ contains=
\cfmlDoubleQuote,
\cfmlSingleQuote
sy cluster cfmlPunctuation
\ contains=
\@cfmlQuote,
\@cfmlQuotedValue,
\cfmlBracket,
\cfmlComma,
\cfmlDot,
\cfmlSemiColon
sy region cfmlTagStart
\ keepend
\ transparent
\ start="\c<cf_*"
\ end=">"
\ contains=
\@cfmlAttribute,
\@cfmlComment,
\@cfmlOperator,
\@cfmlParenthesisRegion,
\@cfmlPunctuation,
\@cfmlQuote,
\@cfmlQuotedValue,
\cfmlAttrEqualSign,
\cfmlBoolean,
\cfmlBrace,
\cfmlCoreKeyword,
\cfmlCoreScope,
\cfmlCustomKeyword,
\cfmlCustomScope,
\cfmlEqualSign,
\cfmlFunctionName,
\cfmlNumber,
\cfmlStorageKeyword,
\cfmlStorageType,
\cfmlTagBracket,
\cfmlTagName
sy match cfmlTagEnd
\ transparent
\ "\c</cf_*[^>]*>"
\ contains=
\cfmlTagBracket,
\cfmlTagName
sy match cfmlTagBracket
\ contained
\ "\(<\|>\|\/\)"
sy match cfmlTagName
\ contained
\ "\v<\/*\zs\ccf\w*"
sy match cfmlAttrName
\ contained
\ "\v(var\s)@<!\w+\ze\s*\=([^\=])+"
sy match cfmlAttrValue
\ contained
\ "\v(\=\"*)\zs\s*\w*"
sy match cfmlAttrEqualSign
\ contained
\ "\v\="
sy cluster cfmlAttribute
\ contains=
\@cfmlQuotedValue,
\cfmlAttrEqualSign,
\cfmlAttrName,
\cfmlAttrValue,
\cfmlCoreKeyword,
\cfmlCoreScope
sy region cfmlComponentTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cfcomponent"
\ end="\c</cfcomponent>"
sy region cfmlFunctionTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cffunction"
\ end="\c</cffunction>"
sy region cfmlIfTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cfif"
\ end="\c</cfif>"
sy region cfmlLoopTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cfloop"
\ end="\c</cfloop>"
sy region cfmlOutputTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cfoutput"
\ end="\c</cfoutput>"
sy region cfmlQueryTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cfquery"
\ end="\c</cfquery>"
\ contains=
\@cfmlSqlStatement,
\cfmlTagStart,
\cfmlTagEnd,
\cfmlTagComment
sy region cfmlSavecontentTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cfsavecontent"
\ end="\c</cfsavecontent>"
sy region cfmlScriptTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cfscript>"
\ end="\c</cfscript>"
\ contains=
\@cfmlComment,
\@cfmlFlowStatement,
\cfmlHashSurround,
\@cfmlOperator,
\@cfmlParenthesisRegion,
\@cfmlPunctuation,
\cfmlBoolean,
\cfmlBrace,
\cfmlCoreKeyword,
\cfmlCoreScope,
\cfmlCustomKeyword,
\cfmlCustomScope,
\cfmlEqualSign,
\cfmlFunctionDefinition,
\cfmlFunctionName,
\cfmlNumber,
\cfmlOddFunction,
\cfmlStorageKeyword,
\cfmlTagEnd,
\cfmlTagStart
sy region cfmlSwitchTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cfswitch"
\ end="\c</cfswitch>"
sy region cfmlTransactionTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cftransaction"
\ end="\c</cftransaction>"
sy region cfmlCustomTagRegion
\ fold
\ keepend
\ transparent
\ start="\c<cf_[^>]*>"
\ end="\c</cf_[^>]*>"
sy region cfmlCommentBlock
\ keepend
\ start="/\*"
\ end="\*/"
\ contains=
\cfmlMetaData
sy match cfmlCommentLine
\ "\/\/.*"
sy cluster cfmlComment
\ contains=
\cfmlCommentBlock,
\cfmlCommentLine
sy region cfmlTagComment
\ keepend
\ start="<!---"
\ end="--->"
\ contains=
\cfmlTagComment
sy keyword cfmlBranchFlowKeyword
\ break
\ continue
\ return
sy keyword cfmlDecisionFlowKeyword
\ case
\ defaultcase
\ else
\ if
\ switch
sy keyword cfmlLoopFlowKeyword
\ do
\ for
\ in
\ while
sy keyword cfmlTryFlowKeyword
\ catch
\ finally
\ rethrow
\ throw
\ try
sy cluster cfmlFlowStatement
\ contains=
\cfmlBranchFlowKeyword,
\cfmlDecisionFlowKeyword,
\cfmlLoopFlowKeyword,
\cfmlTryFlowKeyword
sy keyword cfmlStorageKeyword
\ var
sy match cfmlStorageType
\ contained
\ "\v<
\(any
\|array
\|binary
\|boolean
\|date
\|numeric
\|query
\|string
\|struct
\|uuid
\|void
\|xml
\){1}\ze(\s*\=)@!"
sy match cfmlCoreKeyword
\ "\v<
\(new
\|required
\)\ze\s"
sy match cfmlCoreScope
\ "\v<
\(application
\|arguments
\|attributes
\|caller
\|cfcatch
\|cffile
\|cfhttp
\|cgi
\|client
\|cookie
\|form
\|local
\|request
\|server
\|session
\|super
\|this
\|thisTag
\|thread
\|variables
\|url
\){1}\ze(,|\.|\[|\)|\s)"
sy cluster cfmlSqlStatement
\ contains=
\@cfmlParenthesisRegion,
\@cfmlQuote,
\@cfmlQuotedValue,
\@sqlSyntax,
\cfmlBoolean,
\cfmlDot,
\cfmlEqualSign,
\cfmlFunctionName,
\cfmlHashSurround,
\cfmlNumber
sy match cfmlTagNameInScript
\ "\vcf_*\w+\s*\ze\("
sy region cfmlMetaData
\ contained
\ keepend
\ start="@\w\+"
\ end="$"
\ contains=
\cfmlMetaDataName
sy match cfmlMetaDataName
\ contained
\ "@\w\+"
sy region cfmlComponentDefinition
\ start="component"
\ end="{"me=e-1
\ contains=
\@cfmlAttribute,
\cfmlComponentKeyword
sy match cfmlComponentKeyword
\ contained
\ "\v<component>"
sy match cfmlInterfaceDefinition
\ "interface\s.*{"me=e-1
\ contains=
\cfmlInterfaceKeyword
sy match cfmlInterfaceKeyword
\ contained
\ "\v<interface>"
sy region cfmlProperty
\ transparent
\ start="\v<property>"
\ end=";"me=e-1
\ contains=
\@cfmlQuotedValue,
\cfmlAttrEqualSign,
\cfmlAttrName,
\cfmlAttrValue,
\cfmlPropertyKeyword
sy match cfmlPropertyKeyword
\ contained
\ "\v<property>"
sy match cfmlFunctionDefinition
\ "\v
\(<(public|private|package)\s){,1}
\(<
\(any
\|array
\|binary
\|boolean
\|date
\|numeric
\|query
\|string
\|struct
\|uuid
\|void
\|xml
\)\s){,1}
\<function\s\w+\s*\("me=e-1
\ contains=
\cfmlFunctionKeyword,
\cfmlFunctionModifier,
\cfmlFunctionName,
\cfmlFunctionReturnType
sy match cfmlFunctionKeyword
\ contained
\ "\v<function>"
sy match cfmlFunctionModifier
\ contained
\ "\v<
\(public
\|private
\|package
\)>"
sy match cfmlFunctionReturnType
\ contained
\ "\v
\(any
\|array
\|binary
\|boolean
\|date
\|numeric
\|query
\|string
\|struct
\|uuid
\|void
\|xml
\)"
sy match cfmlFunctionName
\ "\v<(cf|if|elseif|throw)@!\w+\s*\ze\("
sy region cfmlOddFunction
\ transparent
\ start="\v<
\(abort
\|exit
\|import
\|include
\|lock
\|pageencoding
\|param
\|savecontent
\|thread
\|transaction
\){1}"
\ end="\v(\{|;)"me=e-1
\ contains=
\@cfmlQuotedValue,
\cfmlAttrEqualSign,
\cfmlAttrName,
\cfmlAttrValue,
\cfmlCoreKeyword,
\cfmlOddFunctionKeyword,
\cfmlCoreScope
sy match cfmlOddFunctionKeyword
\ contained
\ "\v<
\(abort
\|exit
\|import
\|include
\|lock
\|pageencoding
\|param
\|savecontent
\|thread
\|transaction
\)\ze(\s|$|;)"
sy match cfmlCustomKeyword
\ contained
\ "\v<
\(customKeyword1
\|customKeyword2
\|customKeyword3
\)>"
sy match cfmlCustomScope
\ contained
\ "\v<
\(prc
\|rc
\|event
\|(\w+Service)
\){1}\ze(\.|\[)"
sy region cfmlSGMLTagStart
\ keepend
\ transparent
\ start="\v(\<cf)@!\zs\<\w+"
\ end=">"
\ contains=
\@cfmlAttribute,
\@cfmlComment,
\@cfmlOperator,
\@cfmlParenthesisRegion,
\@cfmlPunctuation,
\@cfmlQuote,
\@cfmlQuotedValue,
\cfmlAttrEqualSign,
\cfmlBoolean,
\cfmlBrace,
\cfmlCoreKeyword,
\cfmlCoreScope,
\cfmlCustomKeyword,
\cfmlCustomScope,
\cfmlEqualSign,
\cfmlFunctionName,
\cfmlNumber,
\cfmlStorageKeyword,
\cfmlStorageType,
\cfmlTagBracket,
\cfmlSGMLTagName
sy match cfmlSGMLTagEnd
\ transparent
\ "\v(\<\/cf)@!\zs\<\/\w+\>"
\ contains=
\cfmlTagBracket,
\cfmlSGMLTagName
sy match cfmlSGMLTagName
\ contained
\ "\v(\<\/*)\zs\w+"
hi link cfmlNumber Number
hi link cfmlBoolean Boolean
hi link cfmlEqualSign Keyword
hi link cfmlHash PreProc
hi link cfmlHashSurround PreProc
hi link cfmlArithmeticOperator Function
hi link cfmlBooleanOperator Function
hi link cfmlDecisionOperator Function
hi link cfmlStringOperator Function
hi link cfmlTernaryOperator Function
hi link cfmlParenthesis1 Statement
hi link cfmlParenthesis2 String
hi link cfmlParenthesis3 Delimiter
hi link cfmlBrace PreProc
hi link cfmlBracket Statement
hi link cfmlComma Comment
hi link cfmlDot Comment
hi link cfmlSemiColon Comment
hi link cfmlDoubleQuote String
hi link cfmlDoubleQuotedValue String
hi link cfmlSingleQuote String
hi link cfmlSingleQuotedValue String
hi link cfmlTagName Function
hi link cfmlTagBracket Comment
hi link cfmlAttrName Type
hi link cfmlAttrValue Special
hi link cfmlCommentBlock Comment
hi link cfmlCommentLine Comment
hi link cfmlTagComment Comment
hi link cfmlDecisionFlowKeyword Conditional
hi link cfmlLoopFlowKeyword Repeat
hi link cfmlTryFlowKeyword Exception
hi link cfmlBranchFlowKeyword Keyword
hi link cfmlStorageKeyword Keyword
hi link cfmlStorageType Keyword
hi link cfmlCoreKeyword PreProc
hi link cfmlCoreScope Keyword
hi link cfmlTagNameInScript Function
hi link cfmlMetaData String
hi link cfmlMetaDataName Type
hi link cfmlComponentKeyword Keyword
hi link cfmlInterfaceKeyword Keyword
hi link cfmlPropertyKeyword Keyword
hi link cfmlFunctionKeyword Keyword
hi link cfmlFunctionModifier Keyword
hi link cfmlFunctionReturnType Keyword
hi link cfmlFunctionName Function
hi link cfmlOddFunctionKeyword Function
hi link cfmlCustomKeyword Keyword
hi link cfmlCustomScope Structure
hi link cfmlSGMLTagName Ignore
let b:current_syntax = "cfml"
let &cpo = s:cpo_save
unlet s:cpo_save
