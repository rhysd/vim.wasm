if !exists("b:tt2_syn_tags")
let b:tt2_syn_tags = '\[% %]'
endif
if !exists("b:tt2_syn_inc_perl")
let b:tt2_syn_inc_perl = 1
endif
if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn case match
syn cluster tt2_top_cluster contains=tt2_perlcode,tt2_tag_region
if exists("b:tt2_syn_tags")
let s:str = b:tt2_syn_tags . ' '
let s:str = substitute(s:str,'^ \+','','g')
let s:str = substitute(s:str,' \+',' ','g')
while stridx(s:str,' ') > 0
let s:st = strpart(s:str,0,stridx(s:str,' '))
let s:str = substitute(s:str,'[^ ]* ','',"")
let s:ed = strpart(s:str,0,stridx(s:str,' '))
let s:str = substitute(s:str,'[^ ]* ','',"")
exec 'syn region  tt2_tag_region '.
\ 'matchgroup=tt2_tag '.
\ 'start=+\(' . s:st .'\)[-]\=+ '.
\ 'end=+[-]\=\(' . s:ed . '\)+ '.
\ 'contains=@tt2_statement_cluster keepend extend'
exec 'syn region  tt2_commentblock_region '.
\ 'matchgroup=tt2_tag '.
\ 'start=+\(' . s:st .'\)[-]\=\(#\)\@=+ '.
\ 'end=+[-]\=\(' . s:ed . '\)+ '.
\ 'keepend extend'
if b:tt2_syn_inc_perl
syn include @Perl $VIMRUNTIME/syntax/perl.vim
exec 'syn region tt2_perlcode '.
\ 'start=+\(\(RAW\)\=PERL\s*[-]\=' . s:ed . '\(\n\)\=\)\@<=+ ' .
\ 'end=+' . s:st . '[-]\=\s*END+me=s-1 contains=@Perl keepend'
endif
unlet s:st
unlet s:ed
endwhile
else
syn region  tt2_tag_region
\ matchgroup=tt2_tag
\ start=+\(\[%\)[-]\=+
\ end=+[-]\=%\]+
\ contains=@tt2_statement_cluster keepend extend
syn region  tt2_commentblock_region
\ matchgroup=tt2_tag
\ start=+\(\[%\)[-]\=#+
\ end=+[-]\=%\]+
\ keepend extend
if b:tt2_syn_inc_perl
syn include @Perl $VIMRUNTIME/syntax/perl.vim
syn region tt2_perlcode
\ start=+\(\(RAW\)\=PERL\s*[-]\=%]\(\n\)\=\)\@<=+
\ end=+\[%[-]\=\s*END+me=s-1
\ contains=@Perl keepend
endif
endif
syn keyword tt2_directive contained
\ GET CALL SET DEFAULT DEBUG
\ LAST NEXT BREAK STOP BLOCK
\ IF IN UNLESS ELSIF FOR FOREACH WHILE SWITCH CASE
\ USE PLUGIN MACRO META
\ TRY FINAL RETURN LAST
\ CLEAR TO STEP AND OR NOT MOD DIV
\ ELSE PERL RAWPERL END
syn match   tt2_directive +|+ contained
syn keyword tt2_directive contained nextgroup=tt2_string_q,tt2_string_qq,tt2_blockname skipwhite skipempty
\ INSERT INCLUDE PROCESS WRAPPER FILTER
\ THROW CATCH
syn keyword tt2_directive contained nextgroup=tt2_def_tag skipwhite skipempty
\ TAGS
syn match   tt2_def_tag "\S\+\s\+\S\+\|\<\w\+\>" contained
syn match   tt2_variable  +\I\w*+                           contained
syn match   tt2_operator  "[+*/%:?-]"                       contained
syn match   tt2_operator  "\<\(mod\|div\|or\|and\|not\)\>"  contained
syn match   tt2_operator  "[!=<>]=\=\|&&\|||"               contained
syn match   tt2_operator  "\(\s\)\@<=_\(\s\)\@="            contained
syn match   tt2_operator  "=>\|,"                           contained
syn match   tt2_deref     "\([[:alnum:]_)\]}]\s*\)\@<=\."   contained
syn match   tt2_comment   +#.*$+                            contained extend
syn match   tt2_func      +\<\I\w*\(\s*(\)\@=+              contained nextgroup=tt2_bracket_r skipempty skipwhite
syn region  tt2_bracket_r  start=+(+ end=+)+                contained contains=@tt2_statement_cluster keepend extend
syn region  tt2_bracket_b start=+\[+ end=+]+                contained contains=@tt2_statement_cluster keepend extend
syn region  tt2_bracket_b start=+{+  end=+}+                contained contains=@tt2_statement_cluster keepend extend
syn region  tt2_string_qq start=+"+ end=+"+ skip=+\\"+      contained contains=tt2_ivariable keepend extend
syn region  tt2_string_q  start=+'+ end=+'+ skip=+\\'+      contained keepend extend
syn match   tt2_ivariable  +\$\I\w*\>\(\.\I\w*\>\)*+        contained
syn match   tt2_ivariable  +\${\I\w*\>\(\.\I\w*\>\)*}+      contained
syn match   tt2_number    "\d\+"        contained
syn match   tt2_number    "\d\+\.\d\+"  contained
syn match   tt2_number    "0x\x\+"      contained
syn match   tt2_number    "0\o\+"       contained
syn match   tt2_blockname "\f\+"                       contained                        nextgroup=tt2_blockname_joint skipwhite skipempty
syn match   tt2_blockname "$\w\+"                      contained contains=tt2_ivariable nextgroup=tt2_blockname_joint skipwhite skipempty
syn region  tt2_blockname start=+"+ end=+"+ skip=+\\"+ contained contains=tt2_ivariable nextgroup=tt2_blockname_joint keepend skipwhite skipempty
syn region  tt2_blockname start=+'+ end=+'+ skip=+\\'+ contained                        nextgroup=tt2_blockname_joint keepend skipwhite skipempty
syn match   tt2_blockname_joint "+"                    contained                        nextgroup=tt2_blockname skipwhite skipempty
syn cluster tt2_statement_cluster contains=tt2_directive,tt2_variable,tt2_operator,tt2_string_q,tt2_string_qq,tt2_deref,tt2_comment,tt2_func,tt2_bracket_b,tt2_bracket_r,tt2_number
syn sync minlines=50
hi def link tt2_tag         Type
hi def link tt2_tag_region  Type
hi def link tt2_commentblock_region Comment
hi def link tt2_directive   Statement
hi def link tt2_variable    Identifier
hi def link tt2_ivariable   Identifier
hi def link tt2_operator    Statement
hi def link tt2_string_qq   String
hi def link tt2_string_q    String
hi def link tt2_blockname   String
hi def link tt2_comment     Comment
hi def link tt2_func        Function
hi def link tt2_number      Number
if exists("b:tt2_syn_tags")
unlet b:tt2_syn_tags
endif
let b:current_syntax = "tt2"
let &cpo = s:cpo_save
unlet s:cpo_save
