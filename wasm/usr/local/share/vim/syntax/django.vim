if exists("b:current_syntax")
finish
endif
syntax case match
syn match djangoError "%}\|}}\|#}"
syn keyword djangoStatement contained autoescape csrf_token empty
syn keyword djangoStatement contained and as block endblock by cycle debug else elif
syn keyword djangoStatement contained extends filter endfilter firstof for
syn keyword djangoStatement contained endfor if endif ifchanged endifchanged
syn keyword djangoStatement contained ifequal endifequal ifnotequal
syn keyword djangoStatement contained endifnotequal in include load not now or
syn keyword djangoStatement contained parsed regroup reversed spaceless
syn keyword djangoStatement contained endspaceless ssi templatetag openblock
syn keyword djangoStatement contained closeblock openvariable closevariable
syn keyword djangoStatement contained openbrace closebrace opencomment
syn keyword djangoStatement contained closecomment widthratio url with endwith
syn keyword djangoStatement contained get_current_language trans noop blocktrans
syn keyword djangoStatement contained endblocktrans get_available_languages
syn keyword djangoStatement contained get_current_language_bidi plural
syn keyword djangoFilter contained add addslashes capfirst center cut date
syn keyword djangoFilter contained default default_if_none dictsort
syn keyword djangoFilter contained dictsortreversed divisibleby escape escapejs
syn keyword djangoFilter contained filesizeformat first fix_ampersands
syn keyword djangoFilter contained floatformat get_digit join last length length_is
syn keyword djangoFilter contained linebreaks linebreaksbr linenumbers ljust
syn keyword djangoFilter contained lower make_list phone2numeric pluralize
syn keyword djangoFilter contained pprint random removetags rjust slice slugify
syn keyword djangoFilter contained safe safeseq stringformat striptags
syn keyword djangoFilter contained time timesince timeuntil title truncatechars
syn keyword djangoFilter contained truncatewords truncatewords_html unordered_list upper urlencode
syn keyword djangoFilter contained urlize urlizetrunc wordcount wordwrap yesno
syn keyword djangoTodo contained TODO FIXME XXX
syn region djangoArgument contained start=/"/ skip=/\\"/ end=/"/
syn match djangoTagError contained "#}\|{{\|[^%]}}\|[&#]"
syn match djangoVarError contained "#}\|{%\|%}\|[<>!&#%]"
syn region djangoTagBlock start="{%" end="%}" contains=djangoStatement,djangoFilter,djangoArgument,djangoTagError display
syn region djangoVarBlock start="{{" end="}}" contains=djangoFilter,djangoArgument,djangoVarError display
syn region djangoComment start="{%\s*comment\(\s\+.\{-}\)\?%}" end="{%\s*endcomment\s*%}" contains=djangoTodo
syn region djangoComBlock start="{#" end="#}" contains=djangoTodo
hi def link djangoTagBlock PreProc
hi def link djangoVarBlock PreProc
hi def link djangoStatement Statement
hi def link djangoFilter Identifier
hi def link djangoArgument Constant
hi def link djangoTagError Error
hi def link djangoVarError Error
hi def link djangoError Error
hi def link djangoComment Comment
hi def link djangoComBlock Comment
hi def link djangoTodo Todo
let b:current_syntax = "django"
