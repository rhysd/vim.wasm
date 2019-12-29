if &cpo =~ 'C'
let s:cpo_save = &cpo
set cpo&vim
endif
syntax sync fromstart
setlocal iskeyword-=$
if main_syntax == 'typescript' || main_syntax == 'typescriptreact'
setlocal iskeyword+=$
endif
syntax match   typescriptLabel                /[a-zA-Z_$]\k*:/he=e-1 contains=typescriptReserved nextgroup=@typescriptStatement skipwhite skipempty
syntax region  typescriptBlock                 matchgroup=typescriptBraces start=/{/ end=/}/ contains=@typescriptStatement,@typescriptComments fold
syntax cluster afterIdentifier contains=
\ typescriptDotNotation,
\ typescriptFuncCallArg,
\ typescriptTemplate,
\ typescriptIndexExpr,
\ @typescriptSymbols,
\ typescriptTypeArguments
syntax match   typescriptIdentifierName        /\<\K\k*/
\ nextgroup=@afterIdentifier
\ transparent
\ contains=@_semantic
\ skipnl skipwhite
syntax match   typescriptProp contained /\K\k*!\?/
\ transparent
\ contains=@props
\ nextgroup=@afterIdentifier
\ skipwhite skipempty
syntax region  typescriptIndexExpr      contained matchgroup=typescriptProperty start=/\[/rs=s+1 end=/]/he=e-1 contains=@typescriptValue nextgroup=@typescriptSymbols,typescriptDotNotation,typescriptFuncCallArg skipwhite skipempty
syntax match   typescriptDotNotation           /\.\|?\.\|!\./ nextgroup=typescriptProp skipnl
syntax match   typescriptDotStyleNotation      /\.style\./ nextgroup=typescriptDOMStyle transparent
syntax region  typescriptParenExp              matchgroup=typescriptParens start=/(/ end=/)/ contains=@typescriptComments,@typescriptValue,typescriptCastKeyword nextgroup=@typescriptSymbols skipwhite skipempty
syntax region  typescriptFuncCallArg           contained matchgroup=typescriptParens start=/(/ end=/)/ contains=@typescriptValue,@typescriptComments nextgroup=@typescriptSymbols,typescriptDotNotation skipwhite skipempty skipnl
syntax region  typescriptEventFuncCallArg      contained matchgroup=typescriptParens start=/(/ end=/)/ contains=@typescriptEventExpression
syntax region  typescriptEventString           contained start=/\z(["']\)/  skip=/\\\\\|\\\z1\|\\\n/  end=/\z1\|$/ contains=typescriptASCII,@events
syntax match   typescriptASCII                 contained /\\\d\d\d/
syntax region  typescriptTemplateSubstitution matchgroup=typescriptTemplateSB
\ start=/\${/ end=/}/
\ contains=@typescriptValue
\ contained
syntax region  typescriptString 
\ start=+\z(["']\)+  skip=+\\\%(\z1\|$\)+  end=+\z1+ end=+$+
\ contains=typescriptSpecial,@Spell
\ extend
syntax match   typescriptSpecial            contained "\v\\%(x\x\x|u%(\x{4}|\{\x{4,5}})|c\u|.)"
syntax region  typescriptRegexpString          start=+/[^/*]+me=e-1 skip=+\\\\\|\\/+ end=+/[gimuy]\{0,5\}\s*$+ end=+/[gimuy]\{0,5\}\s*[;.,)\]}]+me=e-1 nextgroup=typescriptDotNotation oneline
syntax region  typescriptTemplate
\ start=/`/  skip=/\\\\\|\\`\|\n/  end=/`\|$/
\ contains=typescriptTemplateSubstitution
\ nextgroup=@typescriptSymbols
\ skipwhite skipempty
syntax region  typescriptArray matchgroup=typescriptBraces
\ start=/\[/ end=/]/
\ contains=@typescriptValue,@typescriptComments
\ nextgroup=@typescriptSymbols,typescriptDotNotation
\ skipwhite skipempty fold
syntax match typescriptNumber /\<0[bB][01][01_]*\>/        nextgroup=@typescriptSymbols skipwhite skipempty
syntax match typescriptNumber /\<0[oO][0-7][0-7_]*\>/       nextgroup=@typescriptSymbols skipwhite skipempty
syntax match typescriptNumber /\<0[xX][0-9a-fA-F][0-9a-fA-F_]*\>/ nextgroup=@typescriptSymbols skipwhite skipempty
syntax match typescriptNumber /\d[0-9_]*\.\d[0-9_]*\|\d[0-9_]*\|\.\d[0-9]*/
\ nextgroup=typescriptExponent,@typescriptSymbols skipwhite skipempty
syntax match typescriptExponent /[eE][+-]\=\d[0-9]*\>/
\ nextgroup=@typescriptSymbols skipwhite skipempty contained
syntax region  typescriptObjectLiteral         matchgroup=typescriptBraces
\ start=/{/ end=/}/
\ contains=@typescriptComments,typescriptObjectLabel,typescriptStringProperty,typescriptComputedPropertyName
\ fold contained
syntax match   typescriptObjectLabel  contained /\k\+\_s*/
\ nextgroup=typescriptObjectColon,@typescriptCallImpl
\ skipwhite skipempty
syntax region  typescriptStringProperty   contained
\ start=/\z(["']\)/  skip=/\\\\\|\\\z1\|\\\n/  end=/\z1/
\ nextgroup=typescriptObjectColon,@typescriptCallImpl
\ skipwhite skipempty
syntax region  typescriptComputedPropertyName  contained matchgroup=typescriptBraces
\ start=/\[/rs=s+1 end=/]/
\ contains=@typescriptValue
\ nextgroup=typescriptObjectColon,@typescriptCallImpl
\ skipwhite skipempty
syntax match typescriptRestOrSpread /\.\.\./ contained
syntax match typescriptObjectSpread /\.\.\./ contained containedin=typescriptObjectLiteral,typescriptArray nextgroup=@typescriptValue
syntax match typescriptObjectColon contained /:/ nextgroup=@typescriptValue skipwhite skipempty
syntax match typescriptUnaryOp /[+\-~!]/
\ nextgroup=@typescriptValue
\ skipwhite
syntax region typescriptTernary matchgroup=typescriptTernaryOp start=/?[.?]\@!/ end=/:/ contained contains=@typescriptValue,@typescriptComments nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptAssign  /=/ nextgroup=@typescriptValue
\ skipwhite skipempty
syntax match   typescriptBinaryOp contained /===\?/ nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptBinaryOp contained />\(>>=\|>>\|>=\|>\|=\)\?/ nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptBinaryOp contained /<\(<=\|<\|=\)\?/ nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptBinaryOp contained /|\(|\|=\)\?/ nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptBinaryOp contained /&\(&\|=\)\?/ nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptBinaryOp contained /\*=\?/ nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptBinaryOp contained /%=\?/ nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptBinaryOp contained +/\(=\|[^\*/]\@=\)+ nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptBinaryOp contained /!==\?/ nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptBinaryOp contained /+\(+\|=\)\?/ nextgroup=@typescriptValue skipwhite skipempty
syntax match   typescriptBinaryOp contained /-\(-\|=\)\?/ nextgroup=@typescriptValue skipwhite skipempty
syntax match typescriptBinaryOp contained /\*\*=\?/ nextgroup=@typescriptValue
syntax cluster typescriptSymbols               contains=typescriptBinaryOp,typescriptKeywordOp,typescriptTernary,typescriptAssign,typescriptCastKeyword
syntax keyword typescriptImport                from as import
syntax keyword typescriptExport                export
syntax keyword typescriptModule                namespace module
syntax keyword typescriptPrototype             prototype
\ nextgroup=@afterIdentifier
syntax keyword typescriptCastKeyword           as
\ nextgroup=@typescriptType
\ skipwhite
syntax keyword typescriptIdentifier            arguments this super
\ nextgroup=@afterIdentifier
syntax keyword typescriptVariable              let var
\ nextgroup=typescriptVariableDeclaration
\ skipwhite skipempty skipnl
syntax keyword typescriptVariable const
\ nextgroup=typescriptEnum,typescriptVariableDeclaration
\ skipwhite
syntax match typescriptVariableDeclaration /[A-Za-z_$]\k*/
\ nextgroup=typescriptTypeAnnotation,typescriptAssign
\ contained skipwhite skipempty skipnl
syntax region typescriptEnum matchgroup=typescriptEnumKeyword start=/enum / end=/\ze{/
\ nextgroup=typescriptBlock
\ skipwhite
syntax keyword typescriptKeywordOp
\ contained in instanceof nextgroup=@typescriptValue
syntax keyword typescriptOperator              delete new typeof void
\ nextgroup=@typescriptValue
\ skipwhite skipempty
syntax keyword typescriptForOperator           contained in of
syntax keyword typescriptBoolean               true false nextgroup=@typescriptSymbols skipwhite skipempty
syntax keyword typescriptNull                  null undefined nextgroup=@typescriptSymbols skipwhite skipempty
syntax keyword typescriptMessage               alert confirm prompt status
\ nextgroup=typescriptDotNotation,typescriptFuncCallArg
syntax keyword typescriptGlobal                self top parent
\ nextgroup=@afterIdentifier
syntax keyword typescriptConditional           if else switch
\ nextgroup=typescriptConditionalParen
\ skipwhite skipempty skipnl
syntax keyword typescriptConditionalElse       else
syntax keyword typescriptRepeat                do while for nextgroup=typescriptLoopParen skipwhite skipempty
syntax keyword typescriptRepeat                for nextgroup=typescriptLoopParen,typescriptAsyncFor skipwhite skipempty
syntax keyword typescriptBranch                break continue containedin=typescriptBlock
syntax keyword typescriptCase                  case nextgroup=@typescriptPrimitive skipwhite containedin=typescriptBlock
syntax keyword typescriptDefault               default containedin=typescriptBlock nextgroup=@typescriptValue,typescriptClassKeyword,typescriptInterfaceKeyword skipwhite oneline
syntax keyword typescriptStatementKeyword      with
syntax keyword typescriptStatementKeyword      yield skipwhite nextgroup=@typescriptValue containedin=typescriptBlock
syntax keyword typescriptStatementKeyword      return skipwhite contained nextgroup=@typescriptValue containedin=typescriptBlock
syntax keyword typescriptTry                   try
syntax keyword typescriptExceptions            catch throw finally
syntax keyword typescriptDebugger              debugger
syntax keyword typescriptAsyncFor              await nextgroup=typescriptLoopParen skipwhite skipempty contained
syntax region  typescriptLoopParen             contained matchgroup=typescriptParens
\ start=/(/ end=/)/
\ contains=typescriptVariable,typescriptForOperator,typescriptEndColons,@typescriptValue,@typescriptComments
\ nextgroup=typescriptBlock
\ skipwhite skipempty
syntax region  typescriptConditionalParen             contained matchgroup=typescriptParens
\ start=/(/ end=/)/
\ contains=@typescriptValue,@typescriptComments
\ nextgroup=typescriptBlock
\ skipwhite skipempty
syntax match   typescriptEndColons             /[;,]/ contained
syntax keyword typescriptAmbientDeclaration declare nextgroup=@typescriptAmbients
\ skipwhite skipempty
syntax cluster typescriptAmbients contains=
\ typescriptVariable,
\ typescriptFuncKeyword,
\ typescriptClassKeyword,
\ typescriptAbstract,
\ typescriptEnumKeyword,typescriptEnum,
\ typescriptModule
syntax match   shellbang "^#!.*node\>"
syntax match   shellbang "^#!.*iojs\>"
syntax keyword typescriptCommentTodo TODO FIXME XXX TBD
syntax match   typescriptLineComment "//.*"
\ contains=@Spell,typescriptCommentTodo,typescriptRef
syntax region  typescriptComment
\ start="/\*"  end="\*/"
\ contains=@Spell,typescriptCommentTodo extend
syntax cluster typescriptComments
\ contains=typescriptDocComment,typescriptComment,typescriptLineComment
syntax match   typescriptRef  +///\s*<reference\s\+.*\/>$+
\ contains=typescriptString
syntax match   typescriptRef  +///\s*<amd-dependency\s\+.*\/>$+
\ contains=typescriptString
syntax match   typescriptRef  +///\s*<amd-module\s\+.*\/>$+
\ contains=typescriptString
syntax case ignore
syntax region  typescriptDocComment            matchgroup=typescriptComment
\ start="/\*\*"  end="\*/"
\ contains=typescriptDocNotation,typescriptCommentTodo,@Spell
\ fold keepend
syntax match   typescriptDocNotation           contained /@/ nextgroup=typescriptDocTags
syntax keyword typescriptDocTags               contained constant constructor constructs function ignore inner private public readonly static
syntax keyword typescriptDocTags               contained const dict expose inheritDoc interface nosideeffects override protected struct internal
syntax keyword typescriptDocTags               contained example global
syntax keyword typescriptDocTags               contained alpha beta defaultValue eventProperty experimental label
syntax keyword typescriptDocTags               contained packageDocumentation privateRemarks remarks sealed typeParam
syntax keyword typescriptDocTags               contained ngdoc scope priority animations
syntax keyword typescriptDocTags               contained ngdoc restrict methodOf propertyOf eventOf eventType nextgroup=typescriptDocParam skipwhite
syntax keyword typescriptDocNGDirective        contained overview service object function method property event directive filter inputType error
syntax keyword typescriptDocTags               contained abstract virtual access augments
syntax keyword typescriptDocTags               contained arguments callback lends memberOf name type kind link mixes mixin tutorial nextgroup=typescriptDocParam skipwhite
syntax keyword typescriptDocTags               contained variation nextgroup=typescriptDocNumParam skipwhite
syntax keyword typescriptDocTags               contained author class classdesc copyright default defaultvalue nextgroup=typescriptDocDesc skipwhite
syntax keyword typescriptDocTags               contained deprecated description external host nextgroup=typescriptDocDesc skipwhite
syntax keyword typescriptDocTags               contained file fileOverview overview namespace requires since version nextgroup=typescriptDocDesc skipwhite
syntax keyword typescriptDocTags               contained summary todo license preserve nextgroup=typescriptDocDesc skipwhite
syntax keyword typescriptDocTags               contained borrows exports nextgroup=typescriptDocA skipwhite
syntax keyword typescriptDocTags               contained param arg argument property prop module nextgroup=typescriptDocNamedParamType,typescriptDocParamName skipwhite
syntax keyword typescriptDocTags               contained define enum extends implements this typedef nextgroup=typescriptDocParamType skipwhite
syntax keyword typescriptDocTags               contained return returns throws exception nextgroup=typescriptDocParamType,typescriptDocParamName skipwhite
syntax keyword typescriptDocTags               contained see nextgroup=typescriptDocRef skipwhite
syntax keyword typescriptDocTags               contained function func method nextgroup=typescriptDocName skipwhite
syntax match   typescriptDocName               contained /\h\w*/
syntax keyword typescriptDocTags               contained fires event nextgroup=typescriptDocEventRef skipwhite
syntax match   typescriptDocEventRef           contained /\h\w*#\(\h\w*\:\)\?\h\w*/
syntax match   typescriptDocNamedParamType     contained /{.\+}/ nextgroup=typescriptDocParamName skipwhite
syntax match   typescriptDocParamName          contained /\[\?0-9a-zA-Z_\.]\+\]\?/ nextgroup=typescriptDocDesc skipwhite
syntax match   typescriptDocParamType          contained /{.\+}/ nextgroup=typescriptDocDesc skipwhite
syntax match   typescriptDocA                  contained /\%(#\|\w\|\.\|:\|\/\)\+/ nextgroup=typescriptDocAs skipwhite
syntax match   typescriptDocAs                 contained /\s*as\s*/ nextgroup=typescriptDocB skipwhite
syntax match   typescriptDocB                  contained /\%(#\|\w\|\.\|:\|\/\)\+/
syntax match   typescriptDocParam              contained /\%(#\|\w\|\.\|:\|\/\|-\)\+/
syntax match   typescriptDocNumParam           contained /\d\+/
syntax match   typescriptDocRef                contained /\%(#\|\w\|\.\|:\|\/\)\+/
syntax region  typescriptDocLinkTag            contained matchgroup=typescriptDocLinkTag start=/{/ end=/}/ contains=typescriptDocTags
syntax cluster typescriptDocs                  contains=typescriptDocParamType,typescriptDocNamedParamType,typescriptDocParam
if main_syntax == "typescript"
syntax sync clear
syntax sync ccomment typescriptComment minlines=200
endif
syntax case match
syntax match typescriptOptionalMark /?/ contained
syntax region typescriptTypeParameters matchgroup=typescriptTypeBrackets
\ start=/</ end=/>/
\ contains=typescriptTypeParameter
\ contained
syntax match typescriptTypeParameter /\K\k*/
\ nextgroup=typescriptConstraint,typescriptGenericDefault
\ contained skipwhite skipnl
syntax keyword typescriptConstraint extends
\ nextgroup=@typescriptType
\ contained skipwhite skipnl
syntax match typescriptGenericDefault /=/
\ nextgroup=@typescriptType
\ contained skipwhite
syntax region typescriptTypeArguments matchgroup=typescriptTypeBrackets
\ start=/\></ end=/>/
\ contains=@typescriptType
\ nextgroup=typescriptFuncCallArg,@typescriptTypeOperator
\ contained skipwhite
syntax cluster typescriptType contains=
\ @typescriptPrimaryType,
\ typescriptUnion,
\ @typescriptFunctionType,
\ typescriptConstructorType
syntax region typescriptTypeBracket contained
\ start=/\[/ end=/\]/
\ contains=typescriptString,typescriptNumber
\ nextgroup=@typescriptTypeOperator
\ skipwhite skipempty
syntax cluster typescriptPrimaryType contains=
\ typescriptParenthesizedType,
\ typescriptPredefinedType,
\ typescriptTypeReference,
\ typescriptObjectType,
\ typescriptTupleType,
\ typescriptTypeQuery,
\ typescriptStringLiteralType,
\ typescriptReadonlyArrayKeyword,
\ typescriptAssertType
syntax region  typescriptStringLiteralType contained
\ start=/\z(["']\)/  skip=/\\\\\|\\\z1\|\\\n/  end=/\z1\|$/
\ nextgroup=typescriptUnion
\ skipwhite skipempty
syntax region typescriptParenthesizedType matchgroup=typescriptParens
\ start=/(/ end=/)/
\ contains=@typescriptType
\ nextgroup=@typescriptTypeOperator
\ contained skipwhite skipempty fold
syntax match typescriptTypeReference /\K\k*\(\.\K\k*\)*/
\ nextgroup=typescriptTypeArguments,@typescriptTypeOperator,typescriptUserDefinedType
\ skipwhite contained skipempty
syntax keyword typescriptPredefinedType any number boolean string void never undefined null object unknown
\ nextgroup=@typescriptTypeOperator
\ contained skipwhite skipempty
syntax match typescriptPredefinedType /unique symbol/
\ nextgroup=@typescriptTypeOperator
\ contained skipwhite skipempty
syntax region typescriptObjectType matchgroup=typescriptBraces
\ start=/{/ end=/}/
\ contains=@typescriptTypeMember,typescriptEndColons,@typescriptComments,typescriptAccessibilityModifier,typescriptReadonlyModifier
\ nextgroup=@typescriptTypeOperator
\ contained skipwhite fold
syntax cluster typescriptTypeMember contains=
\ @typescriptCallSignature,
\ typescriptConstructSignature,
\ typescriptIndexSignature,
\ @typescriptMembers
syntax region typescriptTupleType matchgroup=typescriptBraces
\ start=/\[/ end=/\]/
\ contains=@typescriptType,@typescriptComments
\ contained skipwhite
syntax cluster typescriptTypeOperator
\ contains=typescriptUnion,typescriptTypeBracket
syntax match typescriptUnion /|\|&/ contained nextgroup=@typescriptPrimaryType skipwhite skipempty
syntax cluster typescriptFunctionType contains=typescriptGenericFunc,typescriptFuncType
syntax region typescriptGenericFunc matchgroup=typescriptTypeBrackets
\ start=/</ end=/>/
\ contains=typescriptTypeParameter
\ nextgroup=typescriptFuncType
\ containedin=typescriptFunctionType
\ contained skipwhite skipnl
syntax region typescriptFuncType matchgroup=typescriptParens
\ start=/(/ end=/)\s*=>/me=e-2
\ contains=@typescriptParameterList
\ nextgroup=typescriptFuncTypeArrow
\ contained skipwhite skipnl oneline
syntax match typescriptFuncTypeArrow /=>/
\ nextgroup=@typescriptType
\ containedin=typescriptFuncType
\ contained skipwhite skipnl
syntax keyword typescriptConstructorType new
\ nextgroup=@typescriptFunctionType
\ contained skipwhite skipnl
syntax keyword typescriptUserDefinedType is
\ contained nextgroup=@typescriptType skipwhite skipempty
syntax keyword typescriptTypeQuery typeof keyof
\ nextgroup=typescriptTypeReference
\ contained skipwhite skipnl
syntax keyword typescriptAssertType asserts
\ nextgroup=typescriptTypeReference
\ contained skipwhite skipnl
syntax cluster typescriptCallSignature contains=typescriptGenericCall,typescriptCall
syntax region typescriptGenericCall matchgroup=typescriptTypeBrackets
\ start=/</ end=/>/
\ contains=typescriptTypeParameter
\ nextgroup=typescriptCall
\ contained skipwhite skipnl
syntax region typescriptCall matchgroup=typescriptParens
\ start=/(/ end=/)/
\ contains=typescriptDecorator,@typescriptParameterList,@typescriptComments
\ nextgroup=typescriptTypeAnnotation,typescriptBlock
\ contained skipwhite skipnl
syntax match typescriptTypeAnnotation /:/
\ nextgroup=@typescriptType
\ contained skipwhite skipnl
syntax cluster typescriptParameterList contains=
\ typescriptTypeAnnotation,
\ typescriptAccessibilityModifier,
\ typescriptOptionalMark,
\ typescriptRestOrSpread,
\ typescriptFuncComma,
\ typescriptDefaultParam
syntax match typescriptFuncComma /,/ contained
syntax match typescriptDefaultParam /=/
\ nextgroup=@typescriptValue
\ contained skipwhite
syntax keyword typescriptConstructSignature new
\ nextgroup=@typescriptCallSignature
\ contained skipwhite
syntax region typescriptIndexSignature matchgroup=typescriptBraces
\ start=/\[/ end=/\]/
\ contains=typescriptPredefinedType,typescriptMappedIn,typescriptString
\ nextgroup=typescriptTypeAnnotation
\ contained skipwhite oneline
syntax keyword typescriptMappedIn in
\ nextgroup=@typescriptType
\ contained skipwhite skipnl skipempty
syntax keyword typescriptAliasKeyword type
\ nextgroup=typescriptAliasDeclaration
\ skipwhite skipnl skipempty
syntax region typescriptAliasDeclaration matchgroup=typescriptUnion
\ start=/ / end=/=/
\ nextgroup=@typescriptType
\ contains=typescriptConstraint,typescriptTypeParameters
\ contained skipwhite skipempty
syntax keyword typescriptReadonlyArrayKeyword readonly
\ nextgroup=@typescriptPrimaryType
\ skipwhite
syntax keyword typescriptGlobal Promise
\ nextgroup=typescriptGlobalPromiseDot,typescriptFuncCallArg,typescriptTypeArguments oneline
syntax keyword typescriptGlobal Map WeakMap
\ nextgroup=typescriptGlobalPromiseDot,typescriptFuncCallArg,typescriptTypeArguments oneline
syntax keyword typescriptConstructor           contained constructor
\ nextgroup=@typescriptCallSignature
\ skipwhite skipempty
syntax cluster memberNextGroup contains=typescriptMemberOptionality,typescriptTypeAnnotation,@typescriptCallSignature
syntax match typescriptMember /\K\k*/
\ nextgroup=@memberNextGroup
\ contained skipwhite
syntax match typescriptMethodAccessor contained /\v(get|set)\s\K/me=e-1
\ nextgroup=@typescriptMembers
syntax cluster typescriptPropertyMemberDeclaration contains=
\ typescriptClassStatic,
\ typescriptAccessibilityModifier,
\ typescriptReadonlyModifier,
\ typescriptMethodAccessor,
\ @typescriptMembers
syntax match typescriptMemberOptionality /?\|!/ contained
\ nextgroup=typescriptTypeAnnotation,@typescriptCallSignature
\ skipwhite skipempty
syntax cluster typescriptMembers contains=typescriptMember,typescriptStringMember,typescriptComputedMember
syntax keyword typescriptClassStatic static
\ nextgroup=@typescriptMembers,typescriptAsyncFuncKeyword,typescriptReadonlyModifier
\ skipwhite contained
syntax keyword typescriptAccessibilityModifier public private protected contained
syntax keyword typescriptReadonlyModifier readonly contained
syntax region  typescriptStringMember   contained
\ start=/\z(["']\)/  skip=/\\\\\|\\\z1\|\\\n/  end=/\z1/
\ nextgroup=@memberNextGroup
\ skipwhite skipempty
syntax region  typescriptComputedMember   contained matchgroup=typescriptProperty
\ start=/\[/rs=s+1 end=/]/
\ contains=@typescriptValue,typescriptMember,typescriptMappedIn
\ nextgroup=@memberNextGroup
\ skipwhite skipempty
syntax keyword typescriptAbstract              abstract
\ nextgroup=typescriptClassKeyword
\ skipwhite skipnl
syntax keyword typescriptClassKeyword          class
\ nextgroup=typescriptClassName,typescriptClassExtends,typescriptClassBlock
\ skipwhite
syntax match   typescriptClassName             contained /\K\k*/
\ nextgroup=typescriptClassBlock,typescriptClassExtends,typescriptClassTypeParameter
\ skipwhite skipnl
syntax region typescriptClassTypeParameter
\ start=/</ end=/>/
\ contains=typescriptTypeParameter
\ nextgroup=typescriptClassBlock,typescriptClassExtends
\ contained skipwhite skipnl
syntax keyword typescriptClassExtends          contained extends implements nextgroup=typescriptClassHeritage skipwhite skipnl
syntax match   typescriptClassHeritage         contained /\v(\k|\.|\(|\))+/
\ nextgroup=typescriptClassBlock,typescriptClassExtends,typescriptMixinComma,typescriptClassTypeArguments
\ contains=@typescriptValue
\ skipwhite skipnl
\ contained
syntax region typescriptClassTypeArguments matchgroup=typescriptTypeBrackets
\ start=/</ end=/>/
\ contains=@typescriptType
\ nextgroup=typescriptClassExtends,typescriptClassBlock,typescriptMixinComma
\ contained skipwhite skipnl
syntax match typescriptMixinComma /,/ contained nextgroup=typescriptClassHeritage skipwhite skipnl
syntax region  typescriptClassBlock matchgroup=typescriptBraces start=/{/ end=/}/
\ contains=@typescriptPropertyMemberDeclaration,typescriptAbstract,@typescriptComments,typescriptBlock,typescriptAssign,typescriptDecorator,typescriptAsyncFuncKeyword,typescriptArrowFunc
\ contained fold
syntax keyword typescriptInterfaceKeyword          interface nextgroup=typescriptInterfaceName skipwhite
syntax match   typescriptInterfaceName             contained /\k\+/
\ nextgroup=typescriptObjectType,typescriptInterfaceExtends,typescriptInterfaceTypeParameter
\ skipwhite skipnl
syntax region typescriptInterfaceTypeParameter
\ start=/</ end=/>/
\ contains=typescriptTypeParameter
\ nextgroup=typescriptObjectType,typescriptInterfaceExtends
\ contained
\ skipwhite skipnl
syntax keyword typescriptInterfaceExtends          contained extends nextgroup=typescriptInterfaceHeritage skipwhite skipnl
syntax match typescriptInterfaceHeritage contained /\v(\k|\.)+/
\ nextgroup=typescriptObjectType,typescriptInterfaceComma,typescriptInterfaceTypeArguments
\ skipwhite
syntax region typescriptInterfaceTypeArguments matchgroup=typescriptTypeBrackets
\ start=/</ end=/>/ skip=/\s*,\s*/
\ contains=@typescriptType
\ nextgroup=typescriptObjectType,typescriptInterfaceComma
\ contained skipwhite
syntax match typescriptInterfaceComma /,/ contained nextgroup=typescriptInterfaceHeritage skipwhite skipnl
syntax cluster typescriptStatement
\ contains=typescriptBlock,typescriptVariable,
\ @typescriptTopExpression,typescriptAssign,
\ typescriptConditional,typescriptRepeat,typescriptBranch,
\ typescriptLabel,typescriptStatementKeyword,
\ typescriptFuncKeyword,
\ typescriptTry,typescriptExceptions,typescriptDebugger,
\ typescriptExport,typescriptInterfaceKeyword,typescriptEnum,
\ typescriptModule,typescriptAliasKeyword,typescriptImport
syntax cluster typescriptPrimitive  contains=typescriptString,typescriptTemplate,typescriptRegexpString,typescriptNumber,typescriptBoolean,typescriptNull,typescriptArray
syntax cluster typescriptEventTypes            contains=typescriptEventString,typescriptTemplate,typescriptNumber,typescriptBoolean,typescriptNull
syntax cluster typescriptTopExpression
\ contains=@typescriptPrimitive,
\ typescriptIdentifier,typescriptIdentifierName,
\ typescriptOperator,typescriptUnaryOp,
\ typescriptParenExp,typescriptRegexpString,
\ typescriptGlobal,typescriptAsyncFuncKeyword,
\ typescriptClassKeyword,typescriptTypeCast
syntax cluster typescriptExpression
\ contains=@typescriptTopExpression,
\ typescriptArrowFuncDef,
\ typescriptFuncImpl
syntax cluster typescriptValue
\ contains=@typescriptExpression,typescriptObjectLiteral
syntax cluster typescriptEventExpression       contains=typescriptArrowFuncDef,typescriptParenExp,@typescriptValue,typescriptRegexpString,@typescriptEventTypes,typescriptOperator,typescriptGlobal,jsxRegion
syntax keyword typescriptAsyncFuncKeyword      async
\ nextgroup=typescriptFuncKeyword,typescriptArrowFuncDef
\ skipwhite
syntax keyword typescriptAsyncFuncKeyword      await
\ nextgroup=@typescriptValue
\ skipwhite
syntax keyword typescriptFuncKeyword           function
\ nextgroup=typescriptAsyncFunc,typescriptFuncName,@typescriptCallSignature
\ skipwhite skipempty
syntax match   typescriptAsyncFunc             contained /*/
\ nextgroup=typescriptFuncName,@typescriptCallSignature
\ skipwhite skipempty
syntax match   typescriptFuncName              contained /\K\k*/
\ nextgroup=@typescriptCallSignature
\ skipwhite
syntax match   typescriptArrowFuncDef          contained /({\_[^}]*}\(:\_[^)]\)\?)\s*=>/
\ contains=typescriptArrowFuncArg,typescriptArrowFunc
\ nextgroup=@typescriptExpression,typescriptBlock
\ skipwhite skipempty
syntax match   typescriptArrowFuncDef          contained /(\(\_s*[a-zA-Z\$_\[.]\_[^)]*\)*)\s*=>/
\ contains=typescriptArrowFuncArg,typescriptArrowFunc
\ nextgroup=@typescriptExpression,typescriptBlock
\ skipwhite skipempty
syntax match   typescriptArrowFuncDef          contained /\K\k*\s*=>/
\ contains=typescriptArrowFuncArg,typescriptArrowFunc
\ nextgroup=@typescriptExpression,typescriptBlock
\ skipwhite skipempty
syntax region   typescriptArrowFuncDef          contained start=/(\_[^)]*):/ end=/=>/
\ contains=typescriptArrowFuncArg,typescriptArrowFunc,typescriptTypeAnnotation
\ nextgroup=@typescriptExpression,typescriptBlock
\ skipwhite skipempty keepend
syntax match   typescriptArrowFunc             /=>/
syntax match   typescriptArrowFuncArg          contained /\K\k*/
syntax region  typescriptArrowFuncArg          contained start=/<\|(/ end=/\ze=>/ contains=@typescriptCallSignature
syntax region typescriptReturnAnnotation contained start=/:/ end=/{/me=e-1 contains=@typescriptType nextgroup=typescriptBlock
syntax region typescriptFuncImpl contained start=/function/ end=/{/me=e-1
\ contains=typescriptFuncKeyword
\ nextgroup=typescriptBlock
syntax cluster typescriptCallImpl contains=typescriptGenericImpl,typescriptParamImpl
syntax region typescriptGenericImpl matchgroup=typescriptTypeBrackets
\ start=/</ end=/>/ skip=/\s*,\s*/
\ contains=typescriptTypeParameter
\ nextgroup=typescriptParamImpl
\ contained skipwhite
syntax region typescriptParamImpl matchgroup=typescriptParens
\ start=/(/ end=/)/
\ contains=typescriptDecorator,@typescriptParameterList,@typescriptComments
\ nextgroup=typescriptReturnAnnotation,typescriptBlock
\ contained skipwhite skipnl
syntax match typescriptDecorator /@\([_$a-zA-Z][_$a-zA-Z0-9]*\.\)*[_$a-zA-Z][_$a-zA-Z0-9]*\>/
\ nextgroup=typescriptArgumentList,typescriptTypeArguments
\ contains=@_semantic,typescriptDotNotation
hi def link typescriptReserved             Error
hi def link typescriptEndColons            Exception
hi def link typescriptSymbols              Normal
hi def link typescriptBraces               Function
hi def link typescriptParens               Normal
hi def link typescriptComment              Comment
hi def link typescriptLineComment          Comment
hi def link typescriptDocComment           Comment
hi def link typescriptCommentTodo          Todo
hi def link typescriptRef                  Include
hi def link typescriptDocNotation          SpecialComment
hi def link typescriptDocTags              SpecialComment
hi def link typescriptDocNGParam           typescriptDocParam
hi def link typescriptDocParam             Function
hi def link typescriptDocNumParam          Function
hi def link typescriptDocEventRef          Function
hi def link typescriptDocNamedParamType    Type
hi def link typescriptDocParamName         Type
hi def link typescriptDocParamType         Type
hi def link typescriptString               String
hi def link typescriptSpecial              Special
hi def link typescriptStringLiteralType    String
hi def link typescriptStringMember         String
hi def link typescriptTemplate             String
hi def link typescriptEventString          String
hi def link typescriptASCII                Special
hi def link typescriptTemplateSB           Label
hi def link typescriptRegexpString         String
hi def link typescriptGlobal               Constant
hi def link typescriptTestGlobal           Function
hi def link typescriptPrototype            Type
hi def link typescriptConditional          Conditional
hi def link typescriptConditionalElse      Conditional
hi def link typescriptCase                 Conditional
hi def link typescriptDefault              typescriptCase
hi def link typescriptBranch               Conditional
hi def link typescriptIdentifier           Structure
hi def link typescriptVariable             Identifier
hi def link typescriptEnumKeyword          Identifier
hi def link typescriptRepeat               Repeat
hi def link typescriptForOperator          Repeat
hi def link typescriptStatementKeyword     Statement
hi def link typescriptMessage              Keyword
hi def link typescriptOperator             Identifier
hi def link typescriptKeywordOp            Identifier
hi def link typescriptCastKeyword          Special
hi def link typescriptType                 Type
hi def link typescriptNull                 Boolean
hi def link typescriptNumber               Number
hi def link typescriptExponent             Number
hi def link typescriptBoolean              Boolean
hi def link typescriptObjectLabel          typescriptLabel
hi def link typescriptLabel                Label
hi def link typescriptStringProperty       String
hi def link typescriptImport               Special
hi def link typescriptAmbientDeclaration   Special
hi def link typescriptExport               Special
hi def link typescriptModule               Special
hi def link typescriptTry                  Special
hi def link typescriptExceptions           Special
hi def link typescriptMember              Function
hi def link typescriptMethodAccessor       Operator
hi def link typescriptAsyncFuncKeyword     Keyword
hi def link typescriptAsyncFor             Keyword
hi def link typescriptFuncKeyword          Keyword
hi def link typescriptAsyncFunc            Keyword
hi def link typescriptArrowFunc            Type
hi def link typescriptFuncName             Function
hi def link typescriptFuncArg              PreProc
hi def link typescriptArrowFuncArg         PreProc
hi def link typescriptFuncComma            Operator
hi def link typescriptClassKeyword         Keyword
hi def link typescriptClassExtends         Keyword
hi def link typescriptAbstract             Special
hi def link typescriptClassStatic          StorageClass
hi def link typescriptReadonlyModifier     Keyword
hi def link typescriptInterfaceKeyword     Keyword
hi def link typescriptInterfaceExtends     Keyword
hi def link typescriptInterfaceName        Function
hi def link shellbang                      Comment
hi def link typescriptTypeParameter         Identifier
hi def link typescriptConstraint            Keyword
hi def link typescriptPredefinedType        Type
hi def link typescriptReadonlyArrayKeyword  Keyword
hi def link typescriptUnion                 Operator
hi def link typescriptFuncTypeArrow         Function
hi def link typescriptConstructorType       Function
hi def link typescriptTypeQuery             Keyword
hi def link typescriptAccessibilityModifier Keyword
hi def link typescriptOptionalMark          PreProc
hi def link typescriptFuncType              Special
hi def link typescriptMappedIn              Special
hi def link typescriptCall                  PreProc
hi def link typescriptParamImpl             PreProc
hi def link typescriptConstructSignature    Identifier
hi def link typescriptAliasDeclaration      Identifier
hi def link typescriptAliasKeyword          Keyword
hi def link typescriptUserDefinedType       Keyword
hi def link typescriptTypeReference         Identifier
hi def link typescriptConstructor           Keyword
hi def link typescriptDecorator             Special
hi def link typescriptAssertType            Keyword
hi link typeScript             NONE
if exists('s:cpo_save')
let &cpo = s:cpo_save
unlet s:cpo_save
endif
