if exists("b:did_indent")
finish
endif
let filename = 'sqlanywhere'
if exists("b:sql_type_override")
if globpath(&runtimepath, 'indent/'.b:sql_type_override.'.vim') != ''
let filename = b:sql_type_override
endif
elseif exists("g:sql_type_default")
if globpath(&runtimepath, 'indent/'.g:sql_type_default.'.vim') != ''
let filename = g:sql_type_default
endif
endif
exec 'runtime indent/'.filename.'.vim'
