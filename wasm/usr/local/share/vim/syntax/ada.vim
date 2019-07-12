if exists("b:current_syntax") || version < 700
finish
endif
let s:keepcpo= &cpo
set cpo&vim
let b:current_syntax = "ada"
syntax   case ignore
for b:Item in g:ada#Keywords
if b:Item['kind'] == "x"
execute "syntax keyword adaException " . b:Item['word']
endif
if b:Item['kind'] == "a"
execute 'syntax match adaAttribute "\V' . b:Item['word'] . '"'
endif
if b:Item['kind'] == "t" && exists ("g:ada_standard_types")
execute "syntax keyword adaBuiltinType " . b:Item['word']
endif
endfor
syntax keyword  adaLabel	others
syntax keyword  adaOperator abs mod not rem xor
syntax match    adaOperator "\<and\>"
syntax match    adaOperator "\<and\s\+then\>"
syntax match    adaOperator "\<or\>"
syntax match    adaOperator "\<or\s\+else\>"
syntax match    adaOperator "[-+*/<>&]"
syntax keyword  adaOperator **
syntax match    adaOperator "[/<>]="
syntax keyword  adaOperator =>
syntax match    adaOperator "\.\."
syntax match    adaOperator "="
syntax keyword  adaSpecial	    <>
if exists("g:ada_rainbow_color")
syntax match	adaSpecial	 "[:;.,]"
call rainbow_parenthsis#LoadRound ()
call rainbow_parenthsis#Activate ()
else
syntax match	adaSpecial	 "[:;().,]"
endif
syntax match adaAssignment		":="
syntax match   adaNumber		"\<\d[0-9_]*\(\.\d[0-9_]*\)\=\([Ee][+-]\=\d[0-9_]*\)\=\>"
syntax match   adaNumber		"\<\d\d\=#\x[0-9A-Fa-f_]*\(\.\x[0-9A-Fa-f_]*\)\=#\([Ee][+-]\=\d[0-9_]*\)\="
syntax match adaSign "[[:space:]<>=(,|:;&*/+-][+-]\d"lc=1,hs=s+1,he=e-1,me=e-1
syntax region  adaLabel		start="<<"  end=">>"
syntax keyword adaBoolean	true false
syntax match adaError "//"
syntax match adaError "/\*"
syntax match adaError "=="
if exists("g:ada_space_errors")
if !exists("g:ada_no_trail_space_error")
syntax match   adaSpaceError	 excludenl "\s\+$"
endif
if !exists("g:ada_no_tab_space_error")
syntax match   adaSpaceError	 " \+\t"me=e-1
endif
if !exists("g:ada_all_tab_usage")
syntax match   adaSpecial	 "\t"
endif
endif
syntax match    adaEnd	/\<end\>/
syntax keyword  adaPreproc		 pragma
syntax keyword  adaRepeat	 exit for loop reverse while
syntax match    adaRepeat		   "\<end\s\+loop\>"
syntax keyword  adaStatement accept delay goto raise requeue return
syntax keyword  adaStatement terminate
syntax match    adaStatement  "\<abort\>"
syntax match adaStructure   "\<record\>"	contains=adaRecord
syntax match adaStructure   "\<end\s\+record\>"	contains=adaRecord
syntax match adaKeyword	    "\<record;"me=e-1
syntax keyword adaStorageClass	abstract access aliased array at constant delta
syntax keyword adaStorageClass	digits limited of private range tagged
syntax keyword adaStorageClass	interface synchronized
syntax keyword adaTypedef	subtype type
syntax match    adaConditional  "\<then\>"
syntax match    adaConditional	"\<then\s\+abort\>"
syntax match    adaConditional	"\<else\>"
syntax match    adaConditional	"\<end\s\+if\>"
syntax match    adaConditional	"\<end\s\+case\>"
syntax match    adaConditional	"\<end\s\+select\>"
syntax keyword  adaConditional	if case select
syntax keyword  adaConditional	elsif when
syntax match    adaKeyword	    "\<is\>" contains=adaRecord
syntax keyword  adaKeyword	    all do exception in new null out
syntax keyword  adaKeyword	    separate until overriding
syntax keyword  adaBegin	begin body declare entry generic
syntax keyword  adaBegin	protected renames task
syntax match    adaBegin	"\<function\>" contains=adaFunction
syntax match    adaBegin	"\<procedure\>" contains=adaProcedure
syntax match    adaBegin	"\<package\>" contains=adaPackage
if exists("ada_with_gnat_project_files")
syntax keyword adaBegin	project
endif
if exists("ada_withuse_ordinary")
syntax keyword adaKeyword		with use
else
syntax match adaKeyword	"\<with\>"
syntax match adaKeyword	"\<use\>"
syntax match adaBeginWith	"^\s*\zs\(\(with\(\s\+type\)\=\)\|\(use\)\)\>" contains=adaInc
syntax match adaSemiWith	";\s*\zs\(\(with\(\s\+type\)\=\)\|\(use\)\)\>" contains=adaInc
syntax match adaInc		"\<with\>" contained contains=NONE
syntax match adaInc		"\<with\s\+type\>" contained contains=NONE
syntax match adaInc		"\<use\>" contained contains=NONE
syntax match adaKeyword	"\<with\s\+null\s\+record\>"
syntax match adaKeyword	";\s*\zswith\s\+\(function\|procedure\|package\)\>"
syntax match adaKeyword	"^\s*\zswith\s\+\(function\|procedure\|package\)\>"
endif
syntax region  adaString	contains=@Spell start=+"+ skip=+""+ end=+"+ 
syntax match   adaCharacter "'.'"
syntax keyword adaTodo contained TODO FIXME XXX NOTE
syntax region  adaComment 
\ oneline 
\ contains=adaTodo,adaLineError,@Spell
\ start="--" 
\ end="$"
if exists("g:ada_line_errors")
syntax match adaLineError "\(^.\{79}\)\@<=."  contains=ALL containedin=ALL
endif
if exists("g:ada_folding") && g:ada_folding[0] == 's'
if stridx (g:ada_folding, 'p') >= 0
syntax region adaPackage
\ start="\(\<package\s\+body\>\|\<package\>\)\s*\z(\k*\)"
\ end="end\s\+\z1\s*;"
\ keepend extend transparent fold contains=ALL
endif
if stridx (g:ada_folding, 'f') >= 0
syntax region adaProcedure
\ start="\<procedure\>\s*\z(\k*\)"
\ end="\<end\>\s\+\z1\s*;"
\ keepend extend transparent fold contains=ALL
syntax region adaFunction
\ start="\<procedure\>\s*\z(\k*\)"
\ end="end\s\+\z1\s*;"
\ keepend extend transparent fold contains=ALL
endif
if stridx (g:ada_folding, 'f') >= 0
syntax region adaRecord
\ start="\<is\s\+record\>"
\ end="\<end\s\+record\>"
\ keepend extend transparent fold contains=ALL
endif
endif
highlight def link adaCharacter	    Character
highlight def link adaComment	    Comment
highlight def link adaConditional   Conditional
highlight def link adaKeyword	    Keyword
highlight def link adaLabel	    Label
highlight def link adaNumber	    Number
highlight def link adaSign	    Number
highlight def link adaOperator	    Operator
highlight def link adaPreproc	    PreProc
highlight def link adaRepeat	    Repeat
highlight def link adaSpecial	    Special
highlight def link adaStatement	    Statement
highlight def link adaString	    String
highlight def link adaStructure	    Structure
highlight def link adaTodo	    Todo
highlight def link adaType	    Type
highlight def link adaTypedef	    Typedef
highlight def link adaStorageClass  StorageClass
highlight def link adaBoolean	    Boolean
highlight def link adaException	    Exception
highlight def link adaAttribute	    Tag
highlight def link adaInc	    Include
highlight def link adaError	    Error
highlight def link adaSpaceError    Error
highlight def link adaLineError	    Error
highlight def link adaBuiltinType   Type
highlight def link adaAssignment    Special
if exists ("ada_begin_preproc")
highlight def link adaBegin   PreProc
highlight def link adaEnd     PreProc
else
highlight def link adaBegin   Keyword
highlight def link adaEnd     Keyword
endif
syntax sync minlines=1 maxlines=1
let &cpo = s:keepcpo
unlet s:keepcpo
finish " 1}}}
