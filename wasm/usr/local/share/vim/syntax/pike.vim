if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn include @pikeSQL <sfile>:p:h/sqloracle.vim
unlet b:current_syntax
syn include @pikeAutodoc <sfile>:p:h/autodoc.vim
unlet b:current_syntax
syn case match
packadd! matchit
let b:match_words = "({:}\\@1<=),(\\[:]\\@1<=),(<:>\\@1<=),^\s*#\s*\%(if\%(n\?def\)\|else\|el\%(se\)\?if\|endif\)\>"
syn keyword	pikeDebug	gauge backtrace describe_backtrace werror _Static_assert static_assert
syn keyword	pikeException	error catch throw
syn keyword	pikeLabel	case default break return continue
syn keyword	pikeConditional	if else switch
syn keyword	pikeRepeat	while for foreach do
syn keyword pikePredef RegGetKeyNames RegGetValue RegGetValues
syn keyword pikePredef __automap__ __empty_program
syn keyword pikePredef __handle_sprintf_format __parse_pike_type _disable_threads
syn keyword pikePredef _do_call_outs _exit _gdb_breakpoint
syn keyword pikePredef abs access acos acosh add_constant alarm all_constants
syn keyword pikePredef array_sscanf asin asinh atan atan2 atanh atexit
syn keyword pikePredef basetype call_function call_out call_out_info cd ceil
syn keyword pikePredef combine_path combine_path_nt
syn keyword pikePredef combine_path_unix compile copy_value cos cosh cpp crypt
syn keyword pikePredef ctime decode_value delay encode_value encode_value_canonic
syn keyword pikePredef enumerate errno exece exit exp file_stat file_truncate
syn keyword pikePredef filesystem_stat find_call_out floor fork function_name
syn keyword pikePredef function_object function_program gc
syn keyword pikePredef get_active_compilation_handler get_active_error_handler
syn keyword pikePredef get_all_groups get_all_users get_dir get_groups_for_user
syn keyword pikePredef get_iterator get_profiling_info get_weak_flag getcwd
syn keyword pikePredef getgrgid getgrnam gethrdtime gethrtime gethrvtime getpid
syn keyword pikePredef getpwnam getpwuid getxattr glob gmtime has_index has_prefix
syn keyword pikePredef has_suffix has_value hash hash_7_0 hash_7_4 hash_8_0
syn keyword pikePredef hash_value kill limit listxattr load_module localtime
syn keyword pikePredef log lower_case master max min mkdir mktime mv
syn keyword pikePredef object_program pow query_num_arg random_seed
syn keyword pikePredef remove_call_out removexattr replace_master rm round
syn keyword pikePredef set_priority set_weak_flag setxattr sgn signal signame
syn keyword pikePredef signum sin sinh sleep sort sprintf sqrt sscanf strerror
syn keyword pikePredef string_filter_non_unicode string_to_unicode string_to_utf8
syn keyword pikePredef tan tanh time trace types ualarm unicode_to_string
syn keyword pikePredef upper_case utf8_to_string version
syn keyword pikePredef write lock try_lock
syn keyword pikePredef MutexKey Timestamp Date Time TimeTZ Interval Inet Range
syn keyword pikePredef Null null inf nan
syn keyword	pikeTodo		contained TODO FIXME XXX
syn cluster	pikePreShort	contains=pikeDefine,pikePreProc,pikeCppOutWrapper,pikeCppInWrapper,pikePreCondit,pikePreConditMatch
syn cluster	pikeExprGroup	contains=pikeMappIndex,@pikeStmt,pikeNest,@pikeBadGroup,pikeSoftCast
syn match	pikeWord	transparent contained /[^()'"[\]{},;:]\+/ contains=ALLBUT,@pikePreProcGroup,@pikeExprGroup
syn match	pikeFirstWord	transparent display contained /^\s*#[^()'"[\]{},;:]\+/ contains=@pikePreShort
syn cluster	pikeMappElm	contains=pikeMappIndex,@pikeStmt
syn cluster	pikeStmt	contains=pikeFirstWord,pikeCharacter,pikeString,pikeMlString,pikeWord,pikeNest
syn cluster     pikeBadGroup	contains=pikeBadPClose,pikeBadAClose,pikeBadBClose,pikeBadSPClose,pikeBadSAClose,pikeBadSBClose,pikeBadSClose,pikeBadSPAClose,pikeBadSBAClose
syn match	pikeBadPClose	display contained "[}\]]"
syn match	pikeBadAClose	display contained "[)\]]"
syn match	pikeBadBClose	display contained "[)}]"
syn match	pikeBadSPClose	display contained "[;}\]]"
syn match	pikeBadSAClose	display contained "[;)\]]"
syn match	pikeBadSPAClose	display contained "[;\]]"
syn match	pikeBadSBAClose	display contained "[;}]"
syn match	pikeBadSClose	display contained "[;)}\]]"
syn region	pikeNest	transparent start="(\@1<!{" end="}" contains=@pikeStmt,pikeUserLabel,pikeBadAClose
syn region	pikeNest	transparent start="\%(\<for\%(each\)\?\s\?\)\@8<!([[{<]\@!" end=")" contains=@pikeStmt,pikeBadSPClose
syn region	pikeNest	transparent start="\%(\<for\%(each\)\?\s\?\)\@8<=(" end=")" contains=@pikeStmt,pikeBadPClose
syn region	pikeNest	transparent start="(\@1<!\[" end="]" contains=@pikeStmt,pikeBadSBClose
syn region	pikeNest	transparent start="(\zs\[" end="])" contains=@pikeMappElm,pikeBadSBAClose
syn region	pikeNest	transparent matchgroup=pikeSoftCast start=%(\zs\[[ \t\v\r\n.a-zA-Z0-9_():,|]\+])\@!% end=")" contains=@pikeStmt
syn region	pikeNest	transparent start="(\zs{" end="})" contains=@pikeStmt,pikeBadSPAClose
syn region	pikeNest	transparent start="(\zs<" end=">)" contains=@pikeStmt,pikeBadSPClose keepend
syn match	pikeBadContinuation contained "\\\s\+$"
syn cluster	pikeCommentGroup	contains=pikeTodo,pikeBadContinuation
syn match	pikeSpecial	display contained "\\\%(x\x*\|d\d*\|\o\+\|u\x\{4}\|U\x\{8}\|[abefnrtv]\|$\)"
if !exists("c_no_cformat")
syn match	pikeFormat		display "%\%(\d\+\$\)\=[-+' #0*]*\%(\d*\|\*\|\*\d\+\$\)\%(\.\%(\d*\|\*\|\*\d\+\$\)\)\=\%([hlLjzt]\|ll\|hh\)\=\%([aAbdiuoxXDOUfFeEgGcCsSpn]\|\[\^\=.[^]]*\]\)" contained
syn match	pikeFormat		display "%%" contained
syn region 	pikeString		start=+"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=pikeSpecial,pikeDelimiterDQ,pikeFormat,@Spell keepend
syn region	pikeMlString	start=+#"+ skip=+\\\\\|\\"+ end=+"+ contains=pikeSpecial,pikeFormat,pikeDelimiterDQ,@Spell,pikeEmbeddedString keepend
else
syn region 	pikeString		start=+"+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=pikeSpecial,pikeDelimiterDQ,@Spell
syn region	pikeMlString	transparent start=+#"+ skip=+\\\\\|\\"+ end=+"+ contains=pikeSpecial,pikeDelimiterDQ,@Spell,pikeEmbeddedString keepend
endif
syn case ignore
syn region	pikeEmbeddedString	contained start=+\%(#"\n\?\)\@2<=\_s*\%(SELECT\|INSERT\|UPDATE\|DELETE\|WITH\|CREATE\|DROP\|ALTER\)\>+ skip=+\\\\\|\\"+ end=+[\\#]\@1<!"+ contains=@pikeSQL,pikeBindings keepend
syn case match
syn match	pikeBindings	display contained ":\@1<!:\I\i*"
syn match	pikeCharacter	"'[^\\']'" contains=pikeDelimiterSQ
syn match	pikeCharacter	"'[^']*'" contains=pikeSpecial,pikeDelimiterSQ
syn match	pikeSpecialError	"'\\[^'\"?\\abefnrtv]'"
syn match	pikeDelimiterDQ	display +"+ contained
syn match	pikeDelimiterSQ	display +'+ contained
if exists("c_space_errors")
if !exists("c_no_trail_space_error")
syn match	pikeSpaceError	display excludenl "\s\+$"
endif
if !exists("c_no_tab_space_error")
syn match	pikeSpaceError	display " \+\ze\t"
endif
endif
syn case ignore
syn match	pikeNumbers	display transparent "\<\d\|\.\d" contains=pikeNumber,pikeFloat,pikeOctalError,pikeOctal
syn match	pikeNumbersCom	display contained transparent "\<\d\|\.\d" contains=pikeNumber,pikeFloat,pikeOctal
syn match	pikeNumber		display contained "\<\d\+\%(u\=l\{0,2}\|ll\=u\)\>"
syn match	pikeNumber		display contained "\<0x\x\+\%(u\=l\{0,2}\|ll\=u\)\>"
syn match	pikeOctal		display contained "\<0\o\+\%(u\=l\{0,2}\|ll\=u\)\>" contains=pikeOctalZero
syn match	pikeOctalZero	display contained "\<0"
syn match	pikeFloat		display contained "\<\d\+\%(f\|\.[0-9.]\@!\d*\%(e[-+]\=\d\+\)\=[fl]\=\)"
syn match	pikeFloat		display contained "[0-9.]\@1<!\.\d\+\%(e[-+]\=\d\+\)\=[fl]\=\>"
syn match	pikeFloat		display contained "\<\d\+e[-+]\=\d\+[fl]\=\>"
syn match	pikeFloat		display contained "\<0x\%(\x\+\.\?\|\x*\.\x\+\)p[-+]\=\d\+[fl]\=\>"
syn match	pikeOctalError	display contained "\<0\o*[89]\d*"
syn case match
if exists("c_comment_strings")
syn match	pikeCommentSkip	contained "^\s*\*\%($\|\s\+\)"
syn region pikeCommentString	contained start=+\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\ze\*/+ contains=pikeSpecial,pikeCommentSkip
syn region pikeComment2String	contained start=+\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=pikeSpecial
syn region  pikeCommentL	start="//" skip="\\$" end="$" keepend contains=@pikeCommentGroup,pikeComment2String,pikeCharacter,pikeNumbersCom,pikeSpaceError,@Spell containedin=pikeWord,pikeFirstWord
if exists("c_no_comment_fold")
syn region pikeComment	matchgroup=pikeCommentStart start="/\*" end="\*/" contains=@pikeCommentGroup,pikeCommentStartError,pikeCommentString,pikeCharacter,pikeNumbersCom,pikeSpaceError,@Spell extend containedin=pikeWord,pikeFirstWord
else
syn region pikeComment	matchgroup=pikeCommentStart start="/\*" end="\*/" contains=@pikeCommentGroup,pikeCommentStartError,pikeCommentString,pikeCharacter,pikeNumbersCom,pikeSpaceError,@Spell fold extend containedin=pikeWord,pikeFirstWord
endif
else
syn region	pikeCommentL	start="//" skip="\\$" end="$" keepend contains=@pikeCommentGroup,pikeSpaceError,@Spell containedin=pikeWord,pikeFirstWord
if exists("c_no_comment_fold")
syn region	pikeComment	matchgroup=pikeCommentStart start="/\*" end="\*/" contains=@pikeCommentGroup,pikeCommentStartError,pikeSpaceError,@Spell extend containedin=pikeWord,pikeFirstWord
else
syn region	pikeComment	matchgroup=pikeCommentStart start="/\*" end="\*/" contains=@pikeCommentGroup,pikeCommentStartError,pikeSpaceError,@Spell fold extend containedin=pikeWord,pikeFirstWord
endif
endif
syn match	pikeCommentError	display "\*/"
syn match	pikeCommentStartError display "/\ze\*" contained
syn keyword	pikeOperator	sizeof
syn keyword	pikeOperator	typeof _typeof _refs
syn keyword	pikeOperator	zero_type intp stringp arrayp mappingp multisetp
syn keyword	pikeOperator	objectp functionp programp callablep destructedp
syn keyword	pikeOperator	object_variablep undefinedp
syn keyword	pikeOperator	allocate equal
syn keyword	pikeOperator	aggregate aggregate_mapping aggregate_multiset
syn keyword	pikeOperator	map filter search replace reverse column rows
syn keyword	pikeOperator	indices values mkmapping mkmultiset m_delete sort
syn keyword	pikeOperator	m_delete destruct
syn keyword	pikeOperator	create _destruct _sprintf cast _encode _decode
syn keyword     pikeOperator    __hash _sizeof _values _indices __INIT _equal
syn keyword     pikeOperator    _is_type _m_delete _get_iterator _search
syn keyword     pikeOperator    _serialize _deserialize _sqrt _types _random
syn keyword     pikeOperator    _size_object
syn keyword	pikeType		int void
syn keyword	pikeType		float
syn keyword	pikeType		bool string array mapping multiset mixed
syn keyword	pikeType		object function program auto
syn keyword	pikeType		this this_object this_program
syn keyword	pikeType		sprintf_args sprintf_format sprintf_result
syn keyword	pikeType		strict_sprintf_format
syn keyword	pikeStructure		class enum typedef inherit import
syn keyword	pikeTypedef		typedef
syn keyword	pikeStorageClass	private protected public constant final variant
syn keyword	pikeStorageClass	optional inline extern static __deprecated__ lambda
syn keyword pikeConstant __LINE__ __FILE__ __DIR__ __DATE__ __TIME__
syn keyword pikeConstant __AUTO_BIGNUM__ __NT__
syn keyword pikeConstant __BUILD__ __COUNTER__ _MAJOR__ __MINOR__ __VERSION__
syn keyword pikeConstant __REAL_BUILD__ _REAL_MAJOR__ __REAL_MINOR__
syn keyword pikeConstant __REAL_VERSION__ __PIKE__ UNDEFINED
syn keyword pikeCppOperator contained defined constant efun _Pragma
syn keyword pikeBoolean true false
syn match       pikeCppPrefix	display "^\s*\zs#\s*[a-z]\+" contained
syn region	pikePreCondit	start="^\s*#\s*\%(if\%(n\?def\)\?\|el\%(se\)\?if\)\>" skip="\\$" end="$" transparent keepend contains=pikeString,pikeCharacter,pikeNumbers,pikeCommentError,pikeSpaceError,pikeCppOperator,pikeCppPrefix
syn match	pikePreConditMatch	display "^\s*\zs#\s*\%(else\|endif\)\>"
if !exists("c_no_if0")
syn cluster	pikeCppOutInGroup	contains=pikeCppInIf,pikeCppInElse,pikeCppInElse2,pikeCppOutIf,pikeCppOutIf2,pikeCppOutElse,pikeCppInSkip,pikeCppOutSkip
syn region	pikeCppOutWrapper	start="^\s*\zs#\s*if\s\+0\+\s*\%($\|//\|/\*\|&\)" end=".\@=\|$" contains=pikeCppOutIf,pikeCppOutElse,@NoSpell fold
syn region	pikeCppOutIf	contained start="0\+" matchgroup=pikeCppOutWrapper end="^\s*#\s*endif\>" contains=pikeCppOutIf2,pikeCppOutElse
if !exists("c_no_if0_fold")
syn region	pikeCppOutIf2	contained matchgroup=pikeCppOutWrapper start="0\+" end="^\ze\s*#\s*\%(else\>\|el\%(se\)\?if\s\+\%(0\+\s*\%($\|//\|/\*\|&\)\)\@!\|endif\>\)" contains=pikeSpaceError,pikeCppOutSkip,@Spell fold
else
syn region	pikeCppOutIf2	contained matchgroup=pikeCppOutWrapper start="0\+" end="^\ze\s*#\s*\%(else\>\|el\%(se\)\?if\s\+\%(0\+\s*\%($\|//\|/\*\|&\)\)\@!\|endif\>\)" contains=pikeSpaceError,pikeCppOutSkip,@Spell
endif
syn region	pikeCppOutElse	contained matchgroup=pikeCppOutWrapper start="^\s*#\s*\%(else\|el\%(se\)\?if\)" end="^\s*#\s*endif\>" contains=TOP,pikePreCondit
syn region	pikeCppInWrapper	start="^\s*\zs#\s*if\s\+0*[1-9]\d*\s*\%($\|//\|/\*\||\)" end=".\@=\|$" contains=pikeCppInIf,pikeCppInElse fold
syn region	pikeCppInIf	contained matchgroup=pikeCppInWrapper start="\d\+" end="^\s*#\s*endif\>" contains=TOP,pikePreCondit
if !exists("c_no_if0_fold")
syn region	pikeCppInElse	contained start="^\s*#\s*\%(else\>\|el\%(se\)\?if\s\+\%(0*[1-9]\d*\s*\%($\|//\|/\*\||\)\)\@!\)" end=".\@=\|$" containedin=pikeCppInIf contains=pikeCppInElse2 fold
else
syn region	pikeCppInElse	contained start="^\s*#\s*\%(else\>\|el\%(se\)\?if\s\+\%(0*[1-9]\d*\s*\%($\|//\|/\*\||\)\)\@!\)" end=".\@=\|$" containedin=pikeCppInIf contains=pikeCppInElse2
endif
syn region	pikeCppInElse2	contained matchgroup=pikeCppInWrapper start="^\s*#\s*\%(else\|el\%(se\)\?if\)\%([^/]\|/[^/*]\)*" end="^\ze\s*#\s*endif\>" contains=pikeSpaceError,pikeCppOutSkip,@Spell
syn region	pikeCppOutSkip	contained start="^\s*#\s*if\%(n\?def\)\?\>" skip="\\$" end="^\s*#\s*endif\>" contains=pikeSpaceError,pikeCppOutSkip
syn region	pikeCppInSkip	contained matchgroup=pikeCppInWrapper start="^\s*#\s*\%(if\s\+\%(\d\+\s*\%($\|//\|/\*\||\|&\)\)\@!\|ifn\?def\>\)" skip="\\$" end="^\s*#\s*endif\>" containedin=pikeCppOutElse,pikeCppInIf,pikeCppInSkip contains=TOP,pikePreProc
endif
syn region	pikeIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=pikeDelimiterDQ keepend
syn match	pikeIncluded	display contained "<[^>]*>"
syn match	pikeInclude	display "^\s*\zs#\s*include\>\s*["<]" contains=pikeIncluded
syn cluster	pikePreProcGroup	contains=pikeIncluded,pikeInclude,pikeEmbeddedString,pikeCppOutWrapper,pikeCppInWrapper,@pikeCppOutInGroup,pikeFormat,pikeMlString,pikeCommentStartError,@pikeBadGroup,pikeWord
syn region	pikeDefine		start="^\s*\zs#\s*\%(define\|undef\)\>" skip="\\$" end="$" keepend contains=@pikeStmt,@pikeBadGroup
syn region	pikePreProc	start="^\s*\zs#\s*\%(pragma\|charset\|pike\|require\|string\|line\|warning\|error\)\>" skip="\\$" end="$" transparent keepend contains=pikeString,pikeCharacter,pikeNumbers,pikeCommentError,pikeSpaceError,pikeCppOperator,pikeCppPrefix,@Spell,pikeConstant
syn match	pikeAutodocReal	display contained "\%(//\|[/ \t\v]\*\|^\*\)\@2<=!.*" contains=@pikeAutodoc containedin=pikeComment,pikeCommentL
syn cluster pikeCommentGroup add=pikeAutodocReal
syn cluster pikePreProcGroup add=pikeAutodocReal
syn match	pikeUserLabel	display "\%(^\|[{};]\)\zs\I\i*\s*\ze:\%([^:]\|$\)" contained contains=NONE
syn match	pikeUserLabel	display "\%(\<\%(break\|continue\)\_s\+\)\@10<=\I\i*" contained contains=NONE
syn match	pikeUserLabel	display "\%(\<case\)\@5<=\s\+[^<()[\]{},;:]\+\ze::\@!" contained contains=pikeDelimiterDQ,pikeDelimiterSQ
syn match	pikeMappIndex	display contained "[^<()[\]{},;:]\+\ze::\@!" contains=pikeDelimiterDQ,pikeDelimiterSQ
syn match	pikeSoftCast	display contained "\[[ \t\v\r\n.a-zA-Z0-9_():,|\+]" contains=NONE
if exists("c_minlines")
let b:c_minlines = c_minlines
else
if !exists("c_no_if0")
let b:c_minlines = 400	" #if 0 constructs can be long
else
let b:c_minlines = 200	" mostly for multiline strings
endif
endif
exec "syn sync ccomment pikeComment minlines=" . b:c_minlines
syn sync match pikeMlStringSync grouphere pikeMlString +^[^"#]\+#\"+
syn sync match pikeAutodocSync grouphere pikeCommentL "^\s*//!"
hi def link pikeFormat		SpecialChar
hi def link pikeMlString	String
hi def link pikeCommentL	Comment
hi def link pikeCommentStart	Comment
hi def link pikeLabel		Label
hi def link pikeUserLabel	Identifier
hi def link pikeConditional	Conditional
hi def link pikeRepeat		Repeat
hi def link pikeCharacter	Character
hi def link pikeDelimiterDQ	Delimiter
hi def link pikeDelimiterSQ	Delimiter
hi def link pikeNumber		Number
hi def link pikeOctal		Number
hi def link pikeOctalZero	PreProc	 " link this to Error if you want
hi def link pikeFloat		Float
hi def link pikeOctalError	Error
hi def link pikeCommentError	Error
hi def link pikeCommentStartError	Error
hi def link pikeSpaceError	Error
hi def link pikeSpecialError	Error
hi def link pikeOperator	Operator
hi def link pikeCppOperator	Operator
hi def link pikeStructure	Structure
hi def link pikeTypedef		Typedef
hi def link pikeStorageClass	StorageClass
hi def link pikeInclude		Include
hi def link pikeCppPrefix	PreCondit
hi def link pikePreProc		PreProc
hi def link pikeDefine		Macro
hi def link pikeIncluded	String
hi def link pikeError		Error
hi def link pikeDebug		Debug
hi def link pikeException	Exception
hi def link pikeStatement	Statement
hi def link pikeType		Type
hi def link pikeConstant	Constant
hi def link pikeBoolean		Boolean
hi def link pikeCommentString	String
hi def link pikeComment2String	String
hi def link pikeCommentSkip	Comment
hi def link pikeString		String
hi def link pikeComment		Comment
hi def link pikeSpecial		SpecialChar
hi def link pikeTodo		Todo
hi def link pikeBadContinuation	Error
hi def link pikeCppInWrapper	PreCondit
hi def link pikeCppOutWrapper	PreCondit
hi def link pikePreConditMatch	PreCondit
hi def link pikeCppOutSkip	Comment
hi def link pikeCppInElse2	Comment
hi def link pikeCppOutIf2	Comment
hi def link pikeCppOut		Comment
hi def link pikePredef		Statement
hi def link pikeBindings	Identifier
hi def link pikeMappIndex	Identifier
hi def link pikeSoftCast	Type
hi def link pikeBadGroup	Error
hi def link pikeBadPClose	Error
hi def link pikeBadAClose	Error
hi def link pikeBadBClose	Error
hi def link pikeBadSPClose	Error
hi def link pikeBadSAClose	Error
hi def link pikeBadSBClose	Error
hi def link pikeBadSPAClose	Error
hi def link pikeBadSBAClose	Error
hi def link pikeBadSClose	Error
let b:current_syntax = "pike"
let &cpo = s:cpo_save
unlet s:cpo_save
