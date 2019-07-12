if exists("b:current_syntax")
finish
endif
let filename = 'sqloracle'
if exists("b:sql_type_override")
if globpath(&runtimepath, 'syntax/'.b:sql_type_override.'.vim') != ''
let filename = b:sql_type_override
endif
elseif exists("g:sql_type_default")
if globpath(&runtimepath, 'syntax/'.g:sql_type_default.'.vim') != ''
let filename = g:sql_type_default
endif
endif
exec 'runtime syntax/'.filename.'.vim'
