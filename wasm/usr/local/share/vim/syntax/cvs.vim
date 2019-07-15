if exists("b:current_syntax")
finish
endif
syn region cvsLine start="^CVS: " end="$" contains=cvsFile,cvsCom,cvsFiles,cvsTag
syn match cvsFile  contained " \t\(\(\S\+\) \)\+"
syn match cvsTag   contained " Tag:"
syn match cvsFiles contained "\(Added\|Modified\|Removed\) Files:"
syn region cvsCom start="Committing in" end="$" contains=cvsDir contained extend keepend
syn match cvsDir   contained "\S\+$"
hi def link cvsLine		Comment
hi def link cvsDir		cvsFile
hi def link cvsFile		Constant
hi def link cvsFiles		cvsCom
hi def link cvsTag		cvsCom
hi def link cvsCom		Statement
let b:current_syntax = "cvs"
