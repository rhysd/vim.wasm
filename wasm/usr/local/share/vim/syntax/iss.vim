if exists("b:current_syntax")
finish
endif
syn case ignore
syn region issPreProc start="^\s*#" end="$"
syn region issSection	start="\[" end="\]"
syn match  issDirective	"^[^=]\+="
syn match  issURL	"http[s]\=:\/\/.*$"
syn match  issParam	"Name:"
syn match  issParam	"MinVersion:\|OnlyBelowVersion:\|Languages:"
syn match  issParam	"Source:\|DestDir:\|DestName:\|CopyMode:"
syn match  issParam	"Attribs:\|Permissions:\|FontInstall:\|Flags:"
syn match  issParam	"FileName:\|Parameters:\|WorkingDir:\|HotKey:\|Comment:"
syn match  issParam	"IconFilename:\|IconIndex:"
syn match  issParam	"Section:\|Key:\|String:"
syn match  issParam	"Root:\|SubKey:\|ValueType:\|ValueName:\|ValueData:"
syn match  issParam	"RunOnceId:"
syn match  issParam	"Type:\|Excludes:"
syn match  issParam	"Components:\|Description:\|GroupDescription:\|Types:\|ExtraDiskSpaceRequired:"
syn match  issParam	"StatusMsg:\|RunOnceId:\|Tasks:"
syn match  issParam	"MessagesFile:\|LicenseFile:\|InfoBeforeFile:\|InfoAfterFile:"
syn match  issComment	"^\s*;.*$" contains=@Spell
syn match  issFolder	"{[^{]*}" contains=@NoSpell
syn region issString	start=+"+ end=+"+ contains=issFolder,@Spell
syn keyword issDirsFlags deleteafterinstall uninsalwaysuninstall uninsneveruninstall
syn keyword issFilesCopyMode normal onlyifdoesntexist alwaysoverwrite alwaysskipifsameorolder dontcopy
syn keyword issFilesAttribs readonly hidden system
syn keyword issFilesPermissions full modify readexec
syn keyword issFilesFlags allowunsafefiles comparetimestampalso confirmoverwrite deleteafterinstall
syn keyword issFilesFlags dontcopy dontverifychecksum external fontisnttruetype ignoreversion 
syn keyword issFilesFlags isreadme onlyifdestfileexists onlyifdoesntexist overwritereadonly 
syn keyword issFilesFlags promptifolder recursesubdirs regserver regtypelib restartreplace
syn keyword issFilesFlags sharedfile skipifsourcedoesntexist sortfilesbyextension touch 
syn keyword issFilesFlags uninsremovereadonly uninsrestartdelete uninsneveruninstall
syn keyword issFilesFlags replacesameversion nocompression noencryption noregerror
syn keyword issIconsFlags closeonexit createonlyiffileexists dontcloseonexit 
syn keyword issIconsFlags runmaximized runminimized uninsneveruninstall useapppaths
syn keyword issINIFlags createkeyifdoesntexist uninsdeleteentry uninsdeletesection uninsdeletesectionifempty
syn keyword issRegRootKey   HKCR HKCU HKLM HKU HKCC
syn keyword issRegValueType none string expandsz multisz dword binary
syn keyword issRegFlags createvalueifdoesntexist deletekey deletevalue dontcreatekey 
syn keyword issRegFlags preservestringtype noerror uninsclearvalue 
syn keyword issRegFlags uninsdeletekey uninsdeletekeyifempty uninsdeletevalue
syn keyword issRunFlags hidewizard nowait postinstall runhidden runmaximized
syn keyword issRunFlags runminimized shellexec skipifdoesntexist skipifnotsilent 
syn keyword issRunFlags skipifsilent unchecked waituntilidle
syn keyword issTypesFlags iscustom
syn keyword issComponentsFlags dontinheritcheck exclusive fixed restart disablenouninstallwarning
syn keyword issInstallDeleteType files filesandordirs dirifempty
syn keyword issTasksFlags checkedonce dontinheritcheck exclusive restart unchecked 
hi def link issSection	Special
hi def link issComment	Comment
hi def link issDirective	Type
hi def link issParam	Type
hi def link issFolder	Special
hi def link issString	String
hi def link issURL	Include
hi def link issPreProc	PreProc 
hi def link issDirsFlags		Keyword
hi def link issFilesCopyMode	Keyword
hi def link issFilesAttribs	Keyword
hi def link issFilesPermissions	Keyword
hi def link issFilesFlags		Keyword
hi def link issIconsFlags		Keyword
hi def link issINIFlags		Keyword
hi def link issRegRootKey		Keyword
hi def link issRegValueType	Keyword
hi def link issRegFlags		Keyword
hi def link issRunFlags		Keyword
hi def link issTypesFlags		Keyword
hi def link issComponentsFlags	Keyword
hi def link issInstallDeleteType	Keyword
hi def link issTasksFlags		Keyword
let b:current_syntax = "iss"
