if exists("b:current_syntax")
finish
endif
runtime! syntax/c.vim
unlet b:current_syntax
syn clear cCommentL  " dtrace doesn't support // style comments
syn match dtraceComment "\%^#!.*-s.*"
let s:oneProbe = '\%(BEGIN\|END\|ERROR\|\S\{-}:\S\{-}:\S\{-}:\S\{-}\)\_s*'
exec 'syn match dtraceProbe "'.s:oneProbe.'\%(,\_s*'.s:oneProbe.'\)*\ze\_s\%({\|\/[^*]\|\%$\)"'
syn match dtracePredicate "/\*\@!\_[^/]*/\ze\_s*\%({\|;\|\%$\)"
syn match dtraceOption contained "bufresize=\%(auto\|manual\)\s*$"
syn match dtraceOption contained "\%(cpu\|jstackframes\|jstackstrsize\|nspec\|stackframes\|stackindent\|ustackframes\)=\d\+\s*$"
syn match dtraceOption contained "\%(aggsize\|bufsize\|dynvarsize\|specsize\|strsize\)=\d\+\%(k\|m\|g\|t\|K\|M\|G\|T\)\=\s*$"
syn match dtraceOption contained "\%(aggrate\|cleanrate\|statusrate\|switchrate\)=\d\+\%(hz\|Hz\|ns\|us\|ms\|s\)\=\s*$"
syn match dtraceOption contained "\%(defaultargs\|destructive\|flowindent\|grabanon\|quiet\|rawbytes\)\s*$"
syn keyword dtraceReservedKeyword auto break case continue counter default do
syn keyword dtraceReservedKeyword else for goto if import probe provider
syn keyword dtraceReservedKeyword register restrict return static switch while
syn keyword dtraceOperator   sizeof offsetof stringof xlate
syn keyword dtraceStatement  self inline xlate this translator
syn keyword dtraceIdentifier arg0 arg1 arg2 arg3 arg4 arg5 arg6 arg7 arg8 arg9 
syn keyword dtraceIdentifier args caller chip cpu curcpu curlwpsinfo curpsinfo
syn keyword dtraceIdentifier curthread cwd epid errno execname gid id ipl lgrp
syn keyword dtraceIdentifier pid ppid probefunc probemod probename probeprov
syn keyword dtraceIdentifier pset root stackdepth tid timestamp uid uregs
syn keyword dtraceIdentifier vtimestamp walltimestamp
syn keyword dtraceIdentifier ustackdepth
syn match dtraceConstant     "$[0-9]\+"
syn match dtraceConstant     "$\(egid\|euid\|gid\|pgid\|ppid\)"
syn match dtraceConstant     "$\(projid\|sid\|target\|taskid\|uid\)"
syn keyword dtraceFunction   trace tracemem printf printa stack ustack jstack
syn keyword dtraceFunction   stop raise copyout copyoutstr system
syn keyword dtraceFunction   breakpoint panic chill
syn keyword dtraceFunction   speculate commit discard exit
syn keyword dtraceFunction   alloca basename bcopy cleanpath copyin copyinstr
syn keyword dtraceFunction   copyinto dirname msgdsize msgsize mutex_owned
syn keyword dtraceFunction   mutex_owner mutex_type_adaptive progenyof
syn keyword dtraceFunction   rand rw_iswriter rw_write_held speculation
syn keyword dtraceFunction   strjoin strlen
syn keyword dtraceAggregatingFunction count sum avg min max lquantize quantize
syn keyword dtraceType int8_t int16_t int32_t int64_t intptr_t
syn keyword dtraceType uint8_t uint16_t uint32_t uint64_t uintptr_t
syn keyword dtraceType string
syn keyword dtraceType pid_t id_t
hi def link dtraceReservedKeyword Error
hi def link dtracePredicate String
hi def link dtraceProbe dtraceStatement
hi def link dtraceStatement Statement
hi def link dtraceConstant Constant
hi def link dtraceIdentifier Identifier
hi def link dtraceAggregatingFunction dtraceFunction
hi def link dtraceFunction Function
hi def link dtraceType Type
hi def link dtraceOperator Operator
hi def link dtraceComment Comment
hi def link dtraceNumber Number
hi def link dtraceOption Identifier
let b:current_syntax = "dtrace"
