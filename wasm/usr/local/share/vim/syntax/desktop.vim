if exists("b:current_syntax")
finish
endif
if exists("enforce_freedesktop_standard")
let b:enforce_freedesktop_standard = 1
else
let b:enforce_freedesktop_standard = 0
endif
syn case match
if b:enforce_freedesktop_standard == 0
syn match  dtNotStLabel	"^.\{-}=\@=" nextgroup=dtDelim
endif
syn match  dtGroup	/^\s*\[.*\]/
syn match  dtComment	/^\s*#.*$/
syn match  dtDelim	/=/ contained
syn match   dtLocale /^\s*\<\(Name\|GenericName\|Comment\|SwallowTitle\|Icon\|UnmountIcon\)\>.*/ contains=dtLocaleKey,dtLocaleName,dtDelim transparent
syn keyword dtLocaleKey Name GenericName Comment SwallowTitle Icon UnmountIcon nextgroup=dtLocaleName containedin=dtLocale
syn match   dtLocaleName /\(\[.\{-}\]\s*=\@=\|\)/ nextgroup=dtDelim containedin=dtLocale contained
syn match   dtNumeric /^\s*\<Version\>/ contains=dtNumericKey,dtDelim
syn keyword dtNumericKey Version nextgroup=dtDelim containedin=dtNumeric contained
syn match   dtBoolean /^\s*\<\(StartupNotify\|ReadOnly\|Terminal\|Hidden\|NoDisplay\)\>.*/ contains=dtBooleanKey,dtDelim,dtBooleanValue transparent
syn keyword dtBooleanKey StartupNotify ReadOnly Terminal Hidden NoDisplay nextgroup=dtDelim containedin=dtBoolean contained
syn keyword dtBooleanValue true false containedin=dtBoolean contained
syn match   dtString /^\s*\<\(Encoding\|Icon\|Path\|Actions\|FSType\|MountPoint\|UnmountIcon\|URL\|Keywords\|Categories\|OnlyShowIn\|NotShowIn\|StartupWMClass\|FilePattern\|MimeType\)\>.*/ contains=dtStringKey,dtDelim transparent
syn keyword dtStringKey Type Encoding TryExec Exec Path Actions FSType MountPoint URL Keywords Categories OnlyShowIn NotShowIn StartupWMClass FilePattern MimeType nextgroup=dtDelim containedin=dtString contained
syn match   dtExec /^\s*\<\(Exec\|TryExec\|SwallowExec\)\>.*/ contains=dtExecKey,dtDelim,dtExecParam transparent
syn keyword dtExecKey Exec TryExec SwallowExec nextgroup=dtDelim containedin=dtExec contained
syn match   dtExecParam  /%[fFuUnNdDickv]/ containedin=dtExec contained
syn match   dtType /^\s*\<Type\>.*/ contains=dtTypeKey,dtDelim,dtTypeValue transparent
syn keyword dtTypeKey Type nextgroup=dtDelim containedin=dtType contained
syn keyword dtTypeValue Application Link FSDevice Directory containedin=dtType contained
syn match   dtXAdd    /^\s*X-.*/ contains=dtXAddKey,dtDelim transparent
syn match   dtXAddKey /^\s*X-.\{-}\s*=\@=/ nextgroup=dtDelim containedin=dtXAdd contains=dtXLocale contained
syn match   dtXLocale /\[.\{-}\]\s*=\@=/ containedin=dtXAddKey contained
syn match   dtALocale /\[.\{-}\]\s*=\@=/ containedin=ALL
hi def link dtGroup		 Special
hi def link dtComment	 Comment
hi def link dtDelim		 String
hi def link dtLocaleKey	 Type
hi def link dtLocaleName	 Identifier
hi def link dtXLocale	 Identifier
hi def link dtALocale	 Identifier
hi def link dtNumericKey	 Type
hi def link dtBooleanKey	 Type
hi def link dtBooleanValue	 Constant
hi def link dtStringKey	 Type
hi def link dtExecKey	 Type
hi def link dtExecParam	 Special
hi def link dtTypeKey	 Type
hi def link dtTypeValue	 Constant
hi def link dtNotStLabel	 Type
hi def link dtXAddKey	 Type
let b:current_syntax = "desktop"
