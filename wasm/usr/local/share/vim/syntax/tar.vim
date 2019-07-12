if exists("b:current_syntax")
finish
endif
syn match tarComment '^".*' contains=tarFilename
syn match tarFilename 'tarfile \zs.*' contained
syn match tarDirectory '.*/$'
hi def link tarComment	Comment
hi def link tarFilename	Constant
hi def link tarDirectory Type
