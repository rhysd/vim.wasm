if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn case match
syn match ninjaComment /\(\$\n\)\@<!\_^\s*#.*$/  contains=@Spell
syn match ninjaKeyword "^build\>"
syn match ninjaKeyword "^rule\>"
syn match ninjaKeyword "^pool\>"
syn match ninjaKeyword "^default\>"
syn match ninjaKeyword "^include\>"
syn match ninjaKeyword "^subninja\>"
syn region ninjaRule start="^rule" end="^\ze\S" contains=TOP transparent
syn keyword ninjaRuleCommand contained containedin=ninjaRule command
\ deps depfile description generator
\ pool restat rspfile rspfile_content
syn region ninjaPool start="^pool" end="^\ze\S" contains=TOP transparent
syn keyword ninjaPoolCommand contained containedin=ninjaPool  depth
syn match   ninjaDollar "\$\$"
syn match   ninjaWrapLineOperator "\$$"
syn match   ninjaSimpleVar "\$[a-zA-Z0-9_-]\+"
syn match   ninjaVar       "\${[a-zA-Z0-9_.-]\+}"
syn match ninjaOperator "\(=\|:\||\|||\)\ze\s"
hi def link ninjaComment Comment
hi def link ninjaKeyword Keyword
hi def link ninjaRuleCommand Statement
hi def link ninjaPoolCommand Statement
hi def link ninjaDollar ninjaOperator
hi def link ninjaWrapLineOperator ninjaOperator
hi def link ninjaOperator Operator
hi def link ninjaSimpleVar ninjaVar
hi def link ninjaVar Identifier
let b:current_syntax = "ninja"
let &cpo = s:cpo_save
unlet s:cpo_save
