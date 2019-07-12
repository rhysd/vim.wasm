if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword draculaStatement   indisk primary outdisk printfile system
syn keyword draculaStatement   mode scale resolution listerror keepdata
syn keyword draculaStatement   datatype by lt gt output label range touch
syn keyword draculaStatement   inside outside within overlap outlib
syn keyword draculaStatement   schematic model unit parset
syn match   draculaStatement   "flag-\(non45\|acuteangle\|offgrid\)"
syn match   draculaStatement   "text-pri-only"
syn match   draculaStatement   "[=&]"
syn match   draculaStatement   "\[[^,]*\]"
syn match   draculastatement   "^ *\(sel\|width\|ext\|enc\|area\|shrink\|grow\|length\)"
syn match   draculastatement   "^ *\(or\|not\|and\|select\|size\|connect\|sconnect\|int\)"
syn match   draculastatement   "^ *\(softchk\|stamp\|element\|parasitic cap\|attribute cap\)"
syn match   draculastatement   "^ *\(flagnon45\|lextract\|equation\|lpeselect\|lpechk\|attach\)"
syn match   draculaStatement   "\(temporary\|connect\)-layer"
syn match   draculaStatement   "program-dir"
syn match   draculaStatement   "status-command"
syn match   draculaStatement   "batch-queue"
syn match   draculaStatement   "cnames-csen"
syn match   draculaStatement   "filter-lay-opt"
syn match   draculaStatement   "filter-sch-opt"
syn match   draculaStatement   "power-node"
syn match   draculaStatement   "ground-node"
syn match   draculaStatement   "subckt-name"
syn match   draculaType		"\*description"
syn match   draculaType		"\*input-layer"
syn match   draculaType		"\*operation"
syn match   draculaType		"\*end"
syn match   draculaComment ";.*"
syn match   draculaPreProc "^#.*"
syn sync lines=50
hi def link draculaIdentifier Identifier
hi def link draculaStatement  Statement
hi def link draculaType       Type
hi def link draculaComment    Comment
hi def link draculaPreProc    PreProc
let b:current_syntax = "dracula"
