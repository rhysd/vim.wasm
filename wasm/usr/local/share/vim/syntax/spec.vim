if exists("b:current_syntax")
finish
endif
syn sync minlines=1000
syn match specSpecialChar contained '[][!$()\\|>^;:{}]'
syn match specColon       contained ':'
syn match specPercent     contained '%'
syn match specVariables   contained '\$\h\w*' contains=specSpecialVariablesNames,specSpecialChar
syn match specVariables   contained '\${\w*}' contains=specSpecialVariablesNames,specSpecialChar
syn match specMacroIdentifier contained '%\h\w*' contains=specMacroNameLocal,specMacroNameOther,specPercent
syn match specMacroIdentifier contained '%{\w*}' contains=specMacroNameLocal,specMacroNameOther,specPercent,specSpecialChar
syn match specSpecialVariables contained '\$[0-9]\|\${[0-9]}'
syn match specCommandOpts      contained '\s\(-\w\+\|--\w[a-zA-Z_-]\+\)'ms=s+1
syn match specComment '^\s*#.*$'
syn case match
syn match specNoNumberHilite 'X11\|X11R6\|[a-zA-Z]*\.\d\|[a-zA-Z][-/]\d'
syn match specManpageFile '[a-zA-Z]\.1'
syn keyword specLicense contained GPL LGPL BSD MIT GNU
syn keyword specWeekday contained Mon Tue Wed Thu Fri Sat Sun
syn keyword specMonth   contained Jan Feb Mar Apr Jun Jul Aug Sep Oct Nov Dec
syn keyword specMonth   contained January February March April May June July August September October November December
syn match specNumber '\(^-\=\|[ \t]-\=\|-\)[0-9.-]*[0-9]'
syn match specEmail contained "<\=\<[A-Za-z0-9_.-]\+@\([A-Za-z0-9_-]\+\.\)\+[A-Za-z]\+\>>\="
syn match specURL      contained '\<\(\(https\{0,1}\|ftp\)://\|\(www[23]\{0,1}\.\|ftp\.\)\)[A-Za-z0-9._/~:,#-]\+\>'
syn match specURLMacro contained '\<\(\(https\{0,1}\|ftp\)://\|\(www[23]\{0,1}\.\|ftp\.\)\)[A-Za-z0-9._/~:,#%{}-]\+\>' contains=specMacroIdentifier
syn match specListedFilesPrefix contained '/\(usr\|local\|opt\|X11R6\|X11\)/'me=e-1
syn match specListedFilesBin    contained '/s\=bin/'me=e-1
syn match specListedFilesLib    contained '/\(lib\|include\)/'me=e-1
syn match specListedFilesDoc    contained '/\(man\d*\|doc\|info\)\>'
syn match specListedFilesEtc    contained '/etc/'me=e-1
syn match specListedFilesShare  contained '/share/'me=e-1
syn cluster specListedFiles contains=specListedFilesBin,specListedFilesLib,specListedFilesDoc,specListedFilesEtc,specListedFilesShare,specListedFilesPrefix,specVariables,specSpecialChar
syn match   specConfigure  contained '\./configure'
syn match   specTarCommand contained '\<tar\s\+[cxvpzIf]\{,5}\s*'
syn keyword specCommandSpecial contained root
syn keyword specCommand		contained make xmkmf mkdir chmod ln find sed rm strip moc echo grep ls rm mv mkdir install cp pwd cat tail then else elif cd gzip rmdir ln eval export touch
syn cluster specCommands contains=specCommand,specTarCommand,specConfigure,specCommandSpecial
syn keyword specSpecialVariablesNames contained RPM_BUILD_ROOT RPM_BUILD_DIR RPM_SOURCE_DIR RPM_OPT_FLAGS LDFLAGS CC CC_FLAGS CPPNAME CFLAGS CXX CXXFLAGS CPPFLAGS
syn keyword specMacroNameOther contained buildroot buildsubdir distribution disturl ix86 name nil optflags perl_sitearch release requires_eq vendor version
syn match   specMacroNameOther contained '\<\(PATCH\|SOURCE\)\d*\>'
syn keyword specMacroNameLocal contained _arch _binary_payload _bindir _build _build_alias _build_cpu _builddir _build_os _buildshell _buildsubdir _build_vendor _bzip2bin _datadir _dbpath _dbpath_rebuild _defaultdocdir _docdir _excludedocs _exec_prefix _fixgroup _fixowner _fixperms _ftpport _ftpproxy _gpg_path _gzipbin _host _host_alias _host_cpu _host_os _host_vendor _httpport _httpproxy _includedir _infodir _install_langs _install_script_path _instchangelog _langpatt _lib _libdir _libexecdir _localstatedir _mandir _netsharedpath _oldincludedir _os _pgpbin _pgp_path _prefix _preScriptEnvironment _provides _rpmdir _rpmfilename _sbindir _sharedstatedir _signature _sourcedir _source_payload _specdir _srcrpmdir _sysconfdir _target _target_alias _target_cpu _target_os _target_platform _target_vendor _timecheck _tmppath _topdir _usr _usrsrc _var _vendor
syn region specSectionMacroArea oneline matchgroup=specSectionMacro start='^%\(define\|global\|patch\d*\|setup\|autosetup\|autopatch\|configure\|GNUconfigure\|find_lang\|make_build\|makeinstall\|make_install\|include\)\>' end='$' contains=specCommandOpts,specMacroIdentifier
syn region specSectionMacroBracketArea oneline matchgroup=specSectionMacro start='^%{\(configure\|GNUconfigure\|find_lang\|make_build\|makeinstall\|make_install\)}' end='$' contains=specCommandOpts,specMacroIdentifier
syn region specFilesArea matchgroup=specSection start='^%[Ff][Ii][Ll][Ee][Ss]\>' skip='%\(attrib\|defattr\|attr\|dir\|config\|docdir\|doc\|lang\|license\|verify\|ghost\|exclude\)\>' end='^%[a-zA-Z]'me=e-2 contains=specFilesOpts,specFilesDirective,@specListedFiles,specComment,specCommandSpecial,specMacroIdentifier
syn match  specFilesDirective contained '%\(attrib\|defattr\|attr\|dir\|config\|docdir\|doc\|lang\|license\|verify\|ghost\|exclude\)\>'
syn match specDescriptionOpts contained '\s-[ln]\s*\a'ms=s+1,me=e-1
syn match specPackageOpts     contained    '\s-n\s*\w'ms=s+1,me=e-1
syn match specFilesOpts       contained    '\s-f\s*\w'ms=s+1,me=e-1
syn case ignore
syn region specPreAmbleDeprecated oneline matchgroup=specError start='^\(Copyright\|Serial\)' end='$' contains=specEmail,specURL,specURLMacro,specLicense,specColon,specVariables,specSpecialChar,specMacroIdentifier
syn region specPreAmble oneline matchgroup=specCommand start='^\(Prereq\|Summary\|Name\|Version\|Packager\|Requires\|Recommends\|Suggests\|Supplements\|Enhances\|Icon\|URL\|Source\d*\|Patch\d*\|Prefix\|Packager\|Group\|License\|Release\|BuildRoot\|Distribution\|Vendor\|Provides\|ExclusiveArch\|ExcludeArch\|ExclusiveOS\|Obsoletes\|BuildArch\|BuildArchitectures\|BuildRequires\|BuildConflicts\|BuildPreReq\|Conflicts\|AutoRequires\|AutoReq\|AutoReqProv\|AutoProv\|Epoch\)' end='$' contains=specEmail,specURL,specURLMacro,specLicense,specColon,specVariables,specSpecialChar,specMacroIdentifier
syn region specDescriptionArea matchgroup=specSection start='^%description' end='^%'me=e-1 contains=specDescriptionOpts,specEmail,specURL,specNumber,specMacroIdentifier,specComment
syn region specPackageArea matchgroup=specSection start='^%package' end='^%'me=e-1 contains=specPackageOpts,specPreAmble,specComment
syn region specScriptArea matchgroup=specSection start='^%\(prep\|build\|install\|clean\|pre\|postun\|preun\|post\|posttrans\)\>' skip='^%{\|^%\(define\|patch\d*\|configure\|GNUconfigure\|setup\|autosetup\|autopatch\|find_lang\|make_build\|makeinstall\|make_install\)\>' end='^%'me=e-1 contains=specSpecialVariables,specVariables,@specCommands,specVariables,shDo,shFor,shCaseEsac,specNoNumberHilite,specCommandOpts,shComment,shIf,specSpecialChar,specMacroIdentifier,specSectionMacroArea,specSectionMacroBracketArea,shOperator,shQuote1,shQuote2
syn region specChangelogArea matchgroup=specSection start='^%changelog' end='^%'me=e-1 contains=specEmail,specURL,specWeekday,specMonth,specNumber,specComment,specLicense
syn case match
syn match shComment contained '#.*$'
syn region shQuote1 contained matchgroup=shQuoteDelim start=+'+ skip=+\\'+ end=+'+ contains=specMacroIdentifier
syn region shQuote2 contained matchgroup=shQuoteDelim start=+"+ skip=+\\"+ end=+"+ contains=specVariables,specMacroIdentifier
syn match shOperator contained '[><|!&;]\|[!=]='
syn region shDo transparent matchgroup=specBlock start="\<do\>" end="\<done\>" contains=ALLBUT,shFunction,shDoError,shCase,specPreAmble,@specListedFiles
syn region specIf  matchgroup=specBlock start="%ifosf\|%ifos\|%ifnos\|%ifarch\|%ifnarch\|%else"  end='%endif'  contains=ALLBUT, specIfError, shCase
syn region  shIf transparent matchgroup=specBlock start="\<if\>" end="\<fi\>" contains=ALLBUT,shFunction,shIfError,shCase,@specListedFiles
syn region  shFor  matchgroup=specBlock start="\<for\>" end="\<in\>" contains=ALLBUT,shFunction,shInError,shCase,@specListedFiles
syn region shCaseEsac transparent matchgroup=specBlock start="\<case\>" matchgroup=NONE end="\<in\>"me=s-1 contains=ALLBUT,shFunction,shCaseError,@specListedFiles nextgroup=shCaseEsac
syn region shCaseEsac matchgroup=specBlock start="\<in\>" end="\<esac\>" contains=ALLBUT,shFunction,shCaseError,@specListedFilesBin
syn region shCase matchgroup=specBlock contained start=")"  end=";;" contains=ALLBUT,shFunction,shCaseError,shCase,@specListedFiles
syn sync match shDoSync       grouphere  shDo       "\<do\>"
syn sync match shDoSync       groupthere shDo       "\<done\>"
syn sync match shIfSync       grouphere  shIf       "\<if\>"
syn sync match shIfSync       groupthere shIf       "\<fi\>"
syn sync match specIfSync     grouphere  specIf     "%ifarch\|%ifos\|%ifnos"
syn sync match specIfSync     groupthere specIf     "%endIf"
syn sync match shForSync      grouphere  shFor      "\<for\>"
syn sync match shForSync      groupthere shFor      "\<in\>"
syn sync match shCaseEsacSync grouphere  shCaseEsac "\<case\>"
syn sync match shCaseEsacSync groupthere shCaseEsac "\<esac\>"
hi def link specSection			Structure
hi def link specSectionMacro		Macro
hi def link specWWWlink			PreProc
hi def link specOpts			Operator
if &background == "dark"
hi def specGlobalMacro		ctermfg=white
else
hi def link specGlobalMacro		Identifier
endif
hi def link shComment			Comment
hi def link shIf				Statement
hi def link shOperator			Special
hi def link shQuote1			String
hi def link shQuote2			String
hi def link shQuoteDelim			Statement
hi def link specBlock			Function
hi def link specColon			Special
hi def link specCommand			Statement
hi def link specCommandOpts		specOpts
hi def link specCommandSpecial		Special
hi def link specComment			Comment
hi def link specConfigure			specCommand
hi def link specDate			String
hi def link specDescriptionOpts		specOpts
hi def link specEmail			specWWWlink
hi def link specError			Error
hi def link specFilesDirective		specSectionMacro
hi def link specFilesOpts			specOpts
hi def link specLicense			String
hi def link specMacroNameLocal		specGlobalMacro
hi def link specMacroNameOther		specGlobalMacro
hi def link specManpageFile		NONE
hi def link specMonth			specDate
hi def link specNoNumberHilite		NONE
hi def link specNumber			Number
hi def link specPackageOpts		specOpts
hi def link specPercent			Special
hi def link specSpecialChar		Special
hi def link specSpecialVariables		specGlobalMacro
hi def link specSpecialVariablesNames	specGlobalMacro
hi def link specTarCommand			specCommand
hi def link specURL			specWWWlink
hi def link specURLMacro			specWWWlink
hi def link specVariables			Identifier
hi def link specWeekday			specDate
hi def link specListedFilesBin		Statement
hi def link specListedFilesDoc		Statement
hi def link specListedFilesEtc		Statement
hi def link specListedFilesLib		Statement
hi def link specListedFilesPrefix		Statement
hi def link specListedFilesShare		Statement
let b:current_syntax = "spec"
