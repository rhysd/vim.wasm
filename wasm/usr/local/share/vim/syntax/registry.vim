if exists("b:current_syntax")
finish
endif
syn case ignore
syn match registryHead		"^REGEDIT[0-9]*\s*$\|^Windows Registry Editor Version \d*\.\d*\s*$"
syn match  registryComment	"^;.*$"
syn keyword registryHKEY	HKEY_LOCAL_MACHINE HKEY_CLASSES_ROOT HKEY_CURRENT_USER
syn keyword registryHKEY	HKEY_USERS HKEY_CURRENT_CONFIG HKEY_DYN_DATA
syn keyword registryHKEY	HKLM HKCR HKCU HKU HKCC HKDD
syn match   registryGUID	"{[0-9A-Fa-f]\{8}\-[0-9A-Fa-f]\{4}\-[0-9A-Fa-f]\{4}\-[0-9A-Fa-f]\{4}\-[0-9A-Fa-f]\{12}}" contains=registrySpecial
syn match   registrySpecial	"\\"
syn match   registrySpecial	"\\\\"
syn match   registrySpecial	"\\\""
syn match   registrySpecial	"\."
syn match   registrySpecial	","
syn match   registrySpecial	"\/"
syn match   registrySpecial	":"
syn match   registrySpecial	"-"
syn match   registryString	"\".*\"" contains=registryGUID,registrySpecial
syn region  registryPath		start="\[" end="\]" contains=registryHKEY,registryGUID,registrySpecial
syn region registryRemove	start="\[\-" end="\]" contains=registryHKEY,registryGUID,registrySpecial
syn match  registrySubKey		"^\".*\"="
syn match  registrySubKey		"^@="
syn match registryHex		"hex\(([0-9]\{0,2})\)\=:\([0-9a-fA-F]\{2},\)*\([0-9a-fA-F]\{2}\|\\\)$" contains=registrySpecial
syn match registryHex		"^\s*\([0-9a-fA-F]\{2},\)\{0,999}\([0-9a-fA-F]\{2}\|\\\)$" contains=registrySpecial
syn match registryDword		"dword:[0-9a-fA-F]\{8}$" contains=registrySpecial
hi def link registryComment	Comment
hi def link registryHead		Constant
hi def link registryHKEY		Constant
hi def link registryPath		Special
hi def link registryRemove	PreProc
hi def link registryGUID		Identifier
hi def link registrySpecial	Special
hi def link registrySubKey	Type
hi def link registryString	String
hi def link registryHex		Number
hi def link registryDword		Number
let b:current_syntax = "registry"
