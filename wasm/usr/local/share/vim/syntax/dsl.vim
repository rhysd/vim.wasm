if exists("b:current_syntax") | finish | endif
runtime syntax/xml.vim
syn cluster xmlRegionHook add=dslRegion,dslComment
syn cluster xmlCommentHook add=dslCond
syn region  dslCond matchgroup=dslCondDelim start="\[\_[^[]\+\[" end="]]" contains=xmlCdata,@xmlRegionCluster,xmlComment,xmlEntity,xmlProcessing,@xmlRegionHook
syn region dslRegion matchgroup=Delimiter start=+(+ end=+)+ contains=dslRegion,dslString,dslComment
syn match dslString +"\_[^"]*"+ contained
syn match dslComment +;.*$+ contains=dslTodo
syn keyword dslTodo contained TODO FIXME XXX display
hi def link dslTodo		Todo
hi def link dslString		String
hi def link dslComment		Comment
hi def link dslCondDelim	Type
let b:current_syntax = "dsl"
