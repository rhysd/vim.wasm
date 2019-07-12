if exists("b:current_syntax")
finish
endif
syn case ignore
setlocal iskeyword+=.
setlocal iskeyword+=!
setlocal iskeyword+=?
syn match rexxOperator "[=|\/\\\+\*\[\],;:<>&\~%\-]"
syn match rexxIdentifier        "\<\K\k*\>"
syn match rexxEnvironmentSymbol "\<\.\k\+\>"
syn match rexxClause "\(^\|;\|:\|then \|else \|when \|otherwise \)\s*\S*" contains=ALLBUT,rexxParse2,rexxRaise2,rexxForward2
syn match rexxParse "\<parse\s*\(\(upper\|lower\|caseless\)\s*\)\?\(arg\|linein\|pull\|source\|var\|\<value\>\|version\)\>" containedin=rexxClause contains=rexxParse2
syn match rexxParse2 "\<with\>" containedin=rexxParse
syn match rexxKeyword contained "\<numeric \(digits\|form \(scientific\|engineering\|value\)\|fuzz\)\>"
syn match rexxKeyword contained "\<\(address\|trace\)\( value\)\?\>"
syn match rexxKeyword contained "\<procedure\(\s*expose\)\?\>"
syn match rexxKeyword contained "\<\(do\|loop\)\>\(\s\+label\s\+\k*\)\?\(\s\+forever\)\?\>"
syn match rexxKeyword contained "\<use\>\s*\(strict\s*\)\?\<arg\>"
syn match rexxRegularCallSignal contained "\<\(call\|signal\)\s\(\s*on\>\|\s*off\>\)\@!\(\k\+\ze\|\ze(\)\(\s*\|;\|$\|(\)"
syn region rexxLabel contained start="\<\(call\|signal\)\>\s*\zs\(\k*\|(\)" end="\ze\(\s*\|;\|$\|(\)" containedin=rexxRegularCallSignal
syn match rexxExceptionHandling contained "\<\(call\|signal\)\>\s\+\<\(on\|off\)\>.*\(;\|$\)" contains=rexxComment
syn match rexxLabel "name\s\+\zs\k\+\ze" containedin=rexxExceptionHandling
syn match rexxLabel "\<\(call\|signal\)\>\s\+\<\(on\|off\)\>\s*\zs\k\+\ze\s*\(;\|$\)" containedin=rexxExceptionHandling
syn region rexxLabel contained start="user\s\+\zs\k" end="\ze\(\s\|;\|$\)" containedin=rexxExceptionHandling
syn match rexxKeywordStatements "\<\(arg\|catch\|do\|drop\|end\|exit\|expose\|finally\|forward\|if\|interpret\|iterate\|leave\|loop\|nop\)\>"
syn match rexxKeywordStatements "\<\(options\|pull\|push\|queue\|raise\|reply\|return\|say\|select\|trace\)\>"
syn match rexxConditional "\<\(then\|else\|when\|otherwise\)\(\s*\|;\|\_$\|\)\>" contains=rexxKeywordStatements
syn match rexxLoopKeywords "\<\(to\|by\|for\|until\|while\|over\)\>" containedin=doLoopSelectLabelRegion
syn match doLoopSelectLabelRegion "\<\(do\|loop\|select\)\>\s\+\(label\s\+\)\?\(\s\+\k\+\s\+\zs\<over\>\)\?\k*\(\s\+forever\)\?\(\s\|;\|$\)" contains=doLoopSelectLabelRegion,rexxStartValueAssignment,rexxLoopKeywords
syn match rexxLabel2 "\<\(do\|loop\|select\)\>\s\+label\s\+\zs\k*\ze" containedin=doLoopSelectLabelRegion
syn match rexxStartValueAssignment       "\<\(do\|loop\)\>\(\s\+label\s\+\k*\)\?\s\+\zs.*\ze\(=.*\)\?\s\+\<to\>" containedin=doLoopSelectLabelRegion
syn match endIterateLeaveLabelRegion "\<\(end\|leave\|iterate\)\>\(\s\+\K\k*\)" contains=rexxLabel2
syn match rexxLabel2 "\<\(end\|leave\|iterate\)\>\s\+\zs\k*\ze" containedin=endIterateLeaveLabelRegion
syn match rexxGuard "\(^\|;\|:\)\s*\<guard\>\s\+\<\(on\|off\)\>"
syn match rexxTrace "\(^\|;\|:\)\s*\<trace\>\s\+\<\K\k*\>"
syn match rexxRaise "\(^\|;\|:\)\s*\<raise\>\s*\<\(propagate\|error\|failure\|syntax\|user\)\>\?" contains=rexxRaise2
syn match rexxRaise2 "\<\(additional\|array\|description\|exit\|propagate\|return\)\>" containedin=rexxRaise
syn match rexxForward  "\(^\|;\|:\)\<forward\>\s*" contains=rexxForward2
syn match rexxForward2 "\<\(arguments\|array\|continue\|message\|class\|to\)\>" contained
syn match rexxFunction 	"\<\<[a-zA-Z\!\?_]\k*\>("me=e-1
syn match rexxFunction "[()]"
syn region rexxString	start=+"+ skip=+""+ end=+"\(x\|b\)\?+ oneline
syn region rexxString	start=+'+ skip=+''+ end=+'\(x\|b\)\?+ oneline
syn region rexxParen transparent start='(' end=')' contains=ALLBUT,rexxParenError,rexxTodo,rexxLabel,rexxKeyword
syn match rexxParenError	 ")"
syn match rexxInParen		"[\\[\\]{}]"
syn region	rexxComment	start="/\*"	end="\*/" contains=rexxTodo,rexxComment
syn match	rexxCommentError "\*/"
syn region	rexxLineComment	start="--"	end="\_$" oneline
syn match rexxLabel		 "\(\_^\|;\)\s*\(\/\*.*\*\/\)*\s*\k\+\s*\(\/\*.*\*\/\)*\s*:"me=e-1 contains=rexxTodo,rexxComment
syn keyword rexxTodo contained	TODO FIXME XXX
syn region rexxMessageOperator start="\(\~\|\~\~\)" end="\(\S\|\s\)"me=e-1
syn match rexxMessage "\(\~\|\~\~\)\s*\<\.*[a-zA-Z]\([a-zA-Z0-9._?!]\)*\>" contains=rexxMessageOperator
syn match rexxLineContinue ",\ze\s*\(--.*\|\/\*.*\)*$"
syn match rexxLineContinue "-\ze-\@!\s*\(--.*\|\s*\/\*.*\)\?$"
syn keyword rexxSpecialVariable  sigl rc result self super
syn keyword rexxSpecialVariable  .environment .error .input .local .methods .output .rs .stderr .stdin .stdout .stdque
syn keyword rexxConst .true .false .nil .endOfLine .line .context
syn match rexxNumber '\d\+' contained
syn match rexxNumber '[-+]\s*\d\+' contained
syn match rexxNumber '\d\+\.\d*' contained
syn match rexxNumber '[-+]\s*\d\+\.\d*' contained
syn match rexxNumber '[-+]\s*\d*[eE][\-+]\d\+' contained
syn match rexxNumber '\d*[eE][\-+]\d\+' contained
syn match rexxNumber '[-+]\s*\d*\.\d*[eE][\-+]\d\+' contained
syn match rexxNumber '\d*\.\d*[eE][\-+]\d\+' contained
syn keyword rexxBuiltinClass .Alarm .ArgUtil .Array .Bag .CaselessColumnComparator
syn keyword rexxBuiltinClass .CaselessComparator .CaselessDescendingComparator .CircularQueue
syn keyword rexxBuiltinClass .Class .Collection .ColumnComparator .Comparable .Comparator
syn keyword rexxBuiltinClass .DateTime .DescendingComparator .Directory .File .InputOutputStream
syn keyword rexxBuiltinClass .InputStream .InvertingComparator .List .MapCollection
syn keyword rexxBuiltinClass .Message .Method .Monitor .MutableBuffer .Object
syn keyword rexxBuiltinClass .OrderedCollection .OutputStream .Package .Properties .Queue
syn keyword rexxBuiltinClass .RegularExpression .Relation .RexxContext .RexxQueue .Routine
syn keyword rexxBuiltinClass .Set .SetCollection .Stem .Stream
syn keyword rexxBuiltinClass .StreamSupplier .String .Supplier .Table .TimeSpan
syn keyword rexxBuiltinClass .AdvancedControls .AnimatedButton .BaseDialog .ButtonControl
syn keyword rexxBuiltinClass .CategoryDialog .CheckBox .CheckList .ComboBox .DialogControl
syn keyword rexxBuiltinClass .DialogExtensions .DlgArea .DlgAreaU .DynamicDialog
syn keyword rexxBuiltinClass .EditControl .InputBox .IntegerBox .ListBox .ListChoice
syn keyword rexxBuiltinClass .ListControl .MenuObject .MessageExtensions .MultiInputBox
syn keyword rexxBuiltinClass .MultiListChoice .OLEObject .OLEVariant
syn keyword rexxBuiltinClass .PasswordBox .PlainBaseDialog .PlainUserDialog
syn keyword rexxBuiltinClass .ProgressBar .ProgressIndicator .PropertySheet .RadioButton
syn keyword rexxBuiltinClass .RcDialog .ResDialog .ScrollBar .SingleSelection .SliderControl
syn keyword rexxBuiltinClass .StateIndicator .StaticControl .TabControl .TimedMessage
syn keyword rexxBuiltinClass .TreeControl .UserDialog .VirtualKeyCodes .WindowBase
syn keyword rexxBuiltinClass .WindowExtensions .WindowObject .WindowsClassesBase .WindowsClipboard
syn keyword rexxBuiltinClass .WindowsEventLog .WindowsManager .WindowsProgramManager .WindowsRegistry
syn keyword rexxBuiltinClass .BSF .bsf.dialog .bsf_proxy
syn keyword rexxBuiltinClass .UNO .UNO_ENUM .UNO_CONSTANTS .UNO_PROPERTIES
syn region rexxClassDirective     start="::\s*class\s*"ms=e+1    end="\ze\(\s\|;\|$\)"
syn region rexxMethodDirective    start="::\s*method\s*"ms=e+1   end="\ze\(\s\|;\|$\)"
syn region rexxRequiresDirective  start="::\s*requires\s*"ms=e+1 end="\ze\(\s\|;\|$\)"
syn region rexxRoutineDirective   start="::\s*routine\s*"ms=e+1  end="\ze\(\s\|;\|$\)"
syn region rexxAttributeDirective start="::\s*attribute\s*"ms=e+1  end="\ze\(\s\|;\|$\)"
syn region rexxOptionsDirective   start="::\s*options\s*"ms=e+1  end="\ze\(\s\|;\|$\)"
syn region rexxConstantDirective  start="::\s*constant\s*"ms=e+1  end="\ze\(\s\|;\|$\)"
syn region rexxDirective start="\(^\|;\)\s*::\s*\w\+"  end="\($\|;\)" contains=rexxString,rexxNumber,rexxComment,rexxLineComment,rexxClassDirective,rexxMethodDirective,rexxRoutineDirective,rexxRequiresDirective,rexxAttributeDirective,rexxOptionsDirective,rexxConstantDirective keepend
syn match rexxOptionsDirective2 "\<\(digits\|form\|fuzz\|trace\)\>" containedin = rexxOptionsDirective3
syn region rexxOptionsDirective3 start="\(^\|;\)\s*::\s*options\s"ms=e+1  end="\($\|;\)" contains=rexxString,rexxNumber,rexxVariable,rexxComment,rexxLineComment containedin = rexxDirective
syn region rexxVariable start="\zs\<\(\.\)\@!\K\k\+\>\ze\s*\(=\|,\|)\|%\|\]\|\\\||\|&\|+=\|-=\|<\|>\)" end="\(\_$\|.\)"me=e-1
syn match rexxVariable "\(=\|,\|)\|%\|\]\|\\\||\|&\|+=\|-=\|<\|>\)\s*\zs\K\k*\ze"
hi par1 ctermfg=red 		guifg=red          "guibg=grey
hi par2 ctermfg=blue 		guifg=blue         "guibg=grey
hi par3 ctermfg=darkgreen 	guifg=darkgreen    "guibg=grey
hi par4 ctermfg=darkyellow	guifg=darkyellow   "guibg=grey
hi par5 ctermfg=darkgrey 	guifg=darkgrey     "guibg=grey
syn sync linecont "\(,\|-\ze-\@!\)\ze\s*\(--.*\|\/\*.*\)*$"
exec "syn sync fromstart"
hi rexxStringConstant term=bold,underline ctermfg=5 cterm=bold guifg=darkMagenta gui=bold
hi def link rexxLabel2		Function
hi def link doLoopSelectLabelRegion	rexxKeyword
hi def link endIterateLeaveLabelRegion	rexxKeyword
hi def link rexxLoopKeywords	rexxKeyword " Todo
hi def link rexxNumber		Normal "DiffChange
hi def link rexxRegularCallSignal	Statement
hi def link rexxExceptionHandling	Statement
hi def link rexxLabel		Function
hi def link rexxCharacter		Character
hi def link rexxParenError		rexxError
hi def link rexxInParen		rexxError
hi def link rexxCommentError	rexxError
hi def link rexxError		Error
hi def link rexxKeyword		Statement
hi def link rexxKeywordStatements	Statement
hi def link rexxFunction		Function
hi def link rexxString		String
hi def link rexxComment		Comment
hi def link rexxTodo		Todo
hi def link rexxSpecialVariable	Special
hi def link rexxConditional	rexxKeyword
hi def link rexxOperator		Operator
hi def link rexxMessageOperator	rexxOperator
hi def link rexxLineComment	Comment
hi def link rexxLineContinue	WildMenu
hi def link rexxDirective		rexxKeyword
hi def link rexxClassDirective	Type
hi def link rexxMethodDirective	rexxFunction
hi def link rexxAttributeDirective	rexxFunction
hi def link rexxRequiresDirective	Include
hi def link rexxRoutineDirective	rexxFunction
hi def link rexxOptionsDirective	rexxFunction
hi def link rexxOptionsDirective2  rexxOptionsDirective
hi def link rexxOptionsDirective3  Normal " rexxOptionsDirective
hi def link rexxConstantDirective	rexxFunction
hi def link rexxConst		Constant
hi def link rexxTypeSpecifier	Type
hi def link rexxBuiltinClass	rexxTypeSpecifier
hi def link rexxEnvironmentSymbol  rexxConst
hi def link rexxMessage		rexxFunction
hi def link rexxParse              rexxKeyword
hi def link rexxParse2             rexxParse
hi def link rexxGuard              rexxKeyword
hi def link rexxTrace              rexxKeyword
hi def link rexxRaise              rexxKeyword
hi def link rexxRaise2             rexxRaise
hi def link rexxForward            rexxKeyword
hi def link rexxForward2           rexxForward
let b:current_syntax = "rexx"
