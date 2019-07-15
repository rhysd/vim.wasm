if !exists("main_syntax")
if exists("b:current_syntax")
finish
endif
let main_syntax = 'smarty'
endif
syn case ignore
runtime! syntax/html.vim
syn match smartyBlock contained "[\[\]]"
syn keyword smartyTagName capture config_load include include_php
syn keyword smartyTagName insert if elseif else ldelim rdelim literal
syn keyword smartyTagName php section sectionelse foreach foreachelse
syn keyword smartyTagName strip assign counter cycle debug eval fetch
syn keyword smartyTagName html_options html_select_date html_select_time
syn keyword smartyTagName math popup_init popup html_checkboxes html_image
syn keyword smartyTagName html_radios html_table mailto textformat
syn keyword smartyModifier cat capitalize count_characters count_paragraphs
syn keyword smartyModifier count_sentences count_words date_format default
syn keyword smartyModifier escape indent lower nl2br regex_replace replace
syn keyword smartyModifier spacify string_format strip strip_tags truncate
syn keyword smartyModifier upper wordwrap
syn keyword smartyInFunc neq eq
syn keyword smartyProperty contained "file="
syn keyword smartyProperty contained "loop="
syn keyword smartyProperty contained "name="
syn keyword smartyProperty contained "include="
syn keyword smartyProperty contained "skip="
syn keyword smartyProperty contained "section="
syn keyword smartyConstant "\$smarty"
syn keyword smartyDot .
syn region smartyZone matchgroup=Delimiter start="{" end="}" contains=smartyProperty, smartyString, smartyBlock, smartyTagName, smartyConstant, smartyInFunc, smartyModifier
syn region  htmlString   contained start=+"+ end=+"+ contains=htmlSpecialChar,javaScriptExpression,@htmlPreproc,smartyZone
syn region  htmlString   contained start=+'+ end=+'+ contains=htmlSpecialChar,javaScriptExpression,@htmlPreproc,smartyZone
syn region htmlLink start="<a\>\_[^>]*\<href\>" end="</a>"me=e-4 contains=@Spell,htmlTag,htmlEndTag,htmlSpecialChar,htmlPreProc,htmlComment,javaScript,@htmlPreproc,smartyZone
hi def link smartyTagName Identifier
hi def link smartyProperty Constant
hi def link smartyInFunc Function
hi def link smartyBlock Constant
hi def link smartyDot SpecialChar
hi def link smartyModifier Function
let b:current_syntax = "smarty"
if main_syntax == 'smarty'
unlet main_syntax
endif
