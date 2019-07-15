if exists("b:current_syntax")
finish
endif
syn case ignore
syn region  virataComment	start="^%" start="\s%"lc=1 keepend end="$" contains=@virataGrpInComments
syn region  virataSpclComment	start="^%%" start="\s%%"lc=1 keepend end="$" contains=@virataGrpInComments
syn keyword virataInCommentTodo	contained TODO FIXME XXX[XXXXX] REVIEW TBD
syn cluster virataGrpInComments	contains=virataInCommentTodo
syn cluster virataGrpComments	contains=@virataGrpInComments,virataComment,virataSpclComment
syn match   virataStringError	+["]+
syn region  virataString	start=+"+ skip=+\(\\\\\|\\"\)+ end=+"+ oneline contains=virataSpclCharError,virataSpclChar,@virataGrpDefSubsts
syn match   virataCharacter	+'[^']\{-}'+ contains=virataSpclCharError,virataSpclChar
syn match   virataSpclChar	contained +\\\(x\x\+\|\o\{1,3}\|['\"?\\abefnrtv]\)+
syn match   virataNumberError	"\<\d\{-1,}\I\{-1,}\>"
syn match   virataNumberError	"\<0x\x*\X\x*\>"
syn match   virataNumberError	"\<\d\+\.\d*\(e[+-]\=\d\+\)\=\>"
syn match   virataDecNumber	"\<\d\+U\=L\=\>"
syn match   virataHexNumber	"\<0x\x\+U\=L\=\>"
syn match   virataSizeNumber	"\<\d\+[BKM]\>"he=e-1
syn match   virataSizeNumber	"\<\d\+[KM]B\>"he=e-2
syn cluster virataGrpNumbers	contains=virataNumberError,virataDecNumber,virataHexNumber,virataSizeNumber
syn cluster virataGrpConstants	contains=@virataGrpNumbers,virataStringError,virataString,virataCharacter,virataSpclChar
syn match   virataIdentError	contained "\<\D\S*\>"
syn match   virataIdentifier	contained "\<\I\i\{-}\(\-\i\{-1,}\)*\>" contains=@virataGrpDefSubsts
syn match   virataFileIdent	contained "\F\f*" contains=@virataGrpDefSubsts
syn cluster virataGrpIdents	contains=virataIdentifier,virataIdentError
syn cluster virataGrpFileIdents	contains=virataFileIdent,virataIdentError
syn match   virataStatement	"^\s*Config\(\(/Kernel\)\=\.\(hs\=\|s\)\)\=\>"
syn match   virataStatement	"^\s*Config\s\+\I\i\{-}\(\-\i\{-1,}\)*\.\(hs\=\|s\)\>"
syn match   virataStatement	"^\s*Make\.\I\i\{-}\(\-\i\{-1}\)*\>" skipwhite nextgroup=@virataGrpIdents
syn match   virataStatement	"^\s*Make\.c\(at\)\=++\s"me=e-1 skipwhite nextgroup=@virataGrpIdents
syn match   virataStatement	"^\s*\(Architecture\|GetEnv\|Reserved\|\(Un\)\=Define\|Version\)\>" skipwhite nextgroup=@virataGrpIdents
syn match   virataStatement	"^\s*\(Hardware\|ModuleSource\|\(Release\)\=Path\|Software\)\>" skipwhite nextgroup=@virataGrpFileIdents
syn match   virataStatement	"^\s*\(DefaultPri\|Hydrogen\)\>" skipwhite nextgroup=virataDecNumber,virataNumberError
syn match   virataStatement	"^\s*\(NoInit\|PCI\|SysLink\)\>"
syn match   virataStatement	"^\s*Allow\s\+\(ModuleConfig\)\>"
syn match   virataStatement	"^\s*NoWarn\s\+\(Export\|Parse\=able\|Relative]\)\>"
syn match   virataStatement	"^\s*Debug\s\+O\(ff\|n\)\>"
syn region  virataImportDef	transparent matchgroup=virataStatement start="^\s*Import\>" keepend end="$" contains=virataInImport,virataModuleDef,virataNumberError,virataStringError,@virataGrpDefSubsts
syn match   virataInImport	contained "\<\(Module\|Package\|from\)\>" skipwhite nextgroup=@virataGrpFileIdents
syn region  virataExportDef	transparent matchgroup=virataStatement start="^\s*Export\>" keepend end="$" contains=virataInExport,virataNumberError,virataStringError,@virataGrpDefSubsts
syn match   virataInExport	contained "\<\(Header\|[SU]Library\)\>" skipwhite nextgroup=@virataGrpFileIdents
syn region  virataProcessDef	transparent matchgroup=virataStatement start="^\s*Process\>" keepend end="$" contains=virataInProcess,virataInExec,virataNumberError,virataStringError,@virataGrpDefSubsts,@virataGrpIdents
syn match   virataInProcess	contained "\<is\>"
syn region  virataInstanceDef	transparent matchgroup=virataStatement start="^\s*Instance\>" keepend end="$" contains=virataInInstance,virataNumberError,virataStringError,@virataGrpDefSubsts,@virataGrpIdents
syn match   virataInInstance	contained "\<of\>"
syn region  virataModuleDef	transparent matchgroup=virataStatement start="^\s*\(Package\|Module\)\>" keepend end="$" contains=virataInModule,virataNumberError,virataStringError,@virataGrpDefSubsts
syn match   virataInModule	contained "^\s*Package\>"hs=e-7 skipwhite nextgroup=@virataGrpIdents
syn match   virataInModule	contained "^\s*Module\>"hs=e-6 skipwhite nextgroup=@virataGrpIdents
syn match   virataInModule	contained "\<from\>" skipwhite nextgroup=@virataGrpFileIdents
syn region  virataColourDef	transparent matchgroup=virataStatement start="^\s*Colour\>" keepend end="$" contains=virataInColour,virataNumberError,virataStringError,@virataGrpDefSubsts
syn match   virataInColour	contained "^\s*Colour\>"hs=e-6 skipwhite nextgroup=@virataGrpIdents
syn match   virataInColour	contained "\<from\>" skipwhite nextgroup=@virataGrpFileIdents
syn match   virataStatement	"^\s*\(Link\|Object\)"
syn region  virataExecDef	transparent matchgroup=virataStatement start="^\s*Executable\>" keepend end="$" contains=virataInExec,virataNumberError,virataStringError
syn match   virataInExec	contained "^\s*Executable\>" skipwhite nextgroup=@virataGrpDefSubsts,@virataGrpIdents
syn match   virataInExec	contained "\<\(epilogue\|pro\(logue\|cess\)\|qhandler\)\>" skipwhite nextgroup=@virataGrpDefSubsts,@virataGrpIdents
syn match   virataInExec	contained "\<\(priority\|stack\)\>" skipwhite nextgroup=@virataGrpDefSubsts,@virataGrpNumbers
syn match   virataStatement	"^\s*Message\(Id\)\=\>" skipwhite nextgroup=@virataGrpNumbers
syn region  virataMakeDef	transparent matchgroup=virataStatement start="^\s*MakeRule\>" keepend end="$" contains=virataInMake,@virataGrpDefSubsts
syn case match
syn match   virataInMake	contained "\<N\>"
syn case ignore
syn match   virataStatement	"^\s*\(Append\|Copy\|Edit\)Rule\>"
syn region  virataAlterDef	transparent matchgroup=virataStatement start="^\s*AlterRules\>" keepend end="$" contains=virataInAlter,@virataGrpDefSubsts
syn match   virataInAlter	contained "\<in\>" skipwhite nextgroup=@virataGrpIdents
syn cluster virataGrpInStatmnts	contains=virataInImport,virataInExport,virataInExec,virataInProcess,virataInAlter,virataInInstance,virataInModule,virataInColour
syn cluster virataGrpStatements	contains=@virataGrpInStatmnts,virataStatement,virataImportDef,virataExportDef,virataExecDef,virataProcessDef,virataAlterDef,virataInstanceDef,virataModuleDef,virataColourDef
syn region  virataCfgFileDef	transparent matchgroup=virataCfgStatement start="^\s*Dir\>" start="^\s*\a\{-}File\>" start="^\s*OutputFile\d\d\=\>" start="^\s*\a\w\{-}[NP]PFile\>" keepend end="$" contains=@virataGrpFileIdents
syn region  virataCfgSizeDef	transparent matchgroup=virataCfgStatement start="^\s*\a\{-}Size\>" start="^\s*ConfigInfo\>" keepend end="$" contains=@virataGrpNumbers,@virataGrpDefSubsts,virataIdentError
syn region  virataCfgNumberDef	transparent matchgroup=virataCfgStatement start="^\s*FlashchipNum\(b\(er\=\)\=\)\=\>" start="^\s*Granularity\>" keepend end="$" contains=@virataGrpNumbers,@virataGrpDefSubsts
syn region  virataCfgMacAddrDef	transparent matchgroup=virataCfgStatement start="^\s*MacAddress\>" keepend end="$" contains=virataNumberError,virataStringError,virataIdentError,virataInMacAddr,@virataGrpDefSubsts
syn match   virataInMacAddr	contained "\x[:]\x\{1,2}\>"lc=2
syn match   virataInMacAddr	contained "\s\x\{1,2}[:]\x"lc=1,me=e-1,he=e-2 nextgroup=virataInMacAddr
syn match   virataCfgStatement	"^\s*Target\>" skipwhite nextgroup=@virataGrpIdents
syn cluster virataGrpCfgs	contains=virataCfgStatement,virataCfgFileDef,virataCfgSizeDef,virataCfgNumberDef,virataCfgMacAddrDef,virataInMacAddr
syn match   virataDefine	"^\s*\(Un\)\=Set\>" skipwhite nextgroup=@virataGrpIdents
syn match   virataInclude	"^\s*Include\>" skipwhite nextgroup=@virataGrpFileIdents
syn match   virataDefSubstError	"[^$]\$"lc=1
syn match   virataDefSubstError	"\$\(\w\|{\(.\{-}}\)\=\)"
syn case match
syn match   virataDefSubst	"\$\(\d\|[DINORS]\|{\I\i\{-}\(\-\i\{-1,}\)*}\)"
syn case ignore
syn cluster virataGrpCntnPreCon	contains=ALLBUT,@virataGrpInComments,@virataGrpFileIdents,@virataGrpInStatmnts
syn region  virataPreConDef	transparent matchgroup=virataPreCondit start="^\s*If\>" end="^\s*Endif\>" contains=@virataGrpCntnPreCon
syn match   virataPreCondit	contained "^\s*Else\(\s\+If\)\=\>"
syn region  virataPreConDef	transparent matchgroup=virataPreCondit start="^\s*ForEach\>" end="^\s*Done\>" contains=@virataGrpCntnPreCon
syn region  virataPreProc	start="^\s*Error\>" start="^\s*Warning\>" oneline end="$" contains=@virataGrpConstants,@virataGrpDefSubsts
syn cluster virataGrpDefSubsts	contains=virataDefSubstError,virataDefSubst
syn cluster virataGrpPreProcs	contains=@virataGrpDefSubsts,virataDefine,virataInclude,virataPreConDef,virataPreCondit,virataPreProc
syn sync clear
syn sync minlines=50		"for multiple region nesting
hi def link virataDefSubstError	virataPreProcError
hi def link virataDefSubst		virataPreProc
hi def link virataInAlter		virataOperator
hi def link virataInExec		virataOperator
hi def link virataInExport		virataOperator
hi def link virataInImport		virataOperator
hi def link virataInInstance	virataOperator
hi def link virataInMake		virataOperator
hi def link virataInModule		virataOperator
hi def link virataInProcess	virataOperator
hi def link virataInMacAddr	virataHexNumber
hi def link virataComment		Comment
hi def link virataSpclComment	SpecialComment
hi def link virataInCommentTodo	Todo
hi def link virataString		String
hi def link virataStringError	Error
hi def link virataCharacter	Character
hi def link virataSpclChar		Special
hi def link virataDecNumber	Number
hi def link virataHexNumber	Number
hi def link virataSizeNumber	Number
hi def link virataNumberError	Error
hi def link virataIdentError	Error
hi def link virataPreProc		PreProc
hi def link virataDefine		Define
hi def link virataInclude		Include
hi def link virataPreCondit	PreCondit
hi def link virataPreProcError	Error
hi def link virataPreProcWarn	Todo
hi def link virataStatement	Statement
hi def link virataCfgStatement	Statement
hi def link virataOperator		Operator
hi def link virataDirective	Keyword
let b:current_syntax = "virata"
