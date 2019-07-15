if exists("b:current_syntax")
finish
endif
runtime! syntax/python.vim
unlet b:current_syntax
syn keyword pyrexStatement      cdef typedef ctypedef sizeof
syn keyword pyrexType		int long short float double char object void
syn keyword pyrexType		signed unsigned
syn keyword pyrexStructure	struct union enum
syn keyword pyrexInclude	include cimport
syn keyword pyrexAccess		public private property readonly extern
if exists("python_highlight_builtins") || exists("pyrex_highlight_builtins")
syn keyword pyrexBuiltin    NULL
endif
syn clear   pythonInclude
syn keyword pythonInclude     import
syn match   pythonInclude     "from"
syn match   pyrexForFrom        "\(for[^:]*\)\@<=from"
hi def link pyrexStatement		Statement
hi def link pyrexType		Type
hi def link pyrexStructure		Structure
hi def link pyrexInclude		PreCondit
hi def link pyrexAccess		pyrexStatement
if exists("python_highlight_builtins") || exists("pyrex_highlight_builtins")
hi def link pyrexBuiltin	Function
endif
hi def link pyrexForFrom		Statement
let b:current_syntax = "pyrex"
