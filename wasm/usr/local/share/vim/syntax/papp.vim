if exists("b:current_syntax")
finish
endif
runtime! syntax/xml.vim
unlet b:current_syntax
if exists("papp_include_html")
syn include @PAppHtml syntax/html.vim
unlet b:current_syntax
syntax spell default  " added by Bram
endif
syn include @PAppPerl syntax/perl.vim
syn cluster xmlFoldCluster add=papp_perl,papp_xperl,papp_phtml,papp_pxml,papp_perlPOD
syn region papp_prep matchgroup=papp_prep start="^#\s*\(if\|elsif\)" end="$" keepend contains=@perlExpr contained
syn match papp_prep /^#\s*\(else\|endif\|??\).*$/ contained
syn region papp_gettext start=/__"/ end=/"/ contained contains=@papp_perlInterpDQ
syn cluster PAppHtml add=papp_gettext,papp_prep
syn region papp_perl  matchgroup=xmlTag start="<perl>"  end="</perl>"  contains=papp_CDATAp,@PAppPerl keepend
syn region papp_xperl matchgroup=xmlTag start="<xperl>" end="</xperl>" contains=papp_CDATAp,@PAppPerl keepend
syn region papp_phtml matchgroup=xmlTag start="<phtml>" end="</phtml>" contains=papp_CDATAh,papp_ph_perl,papp_ph_html,papp_ph_hint,@PAppHtml keepend
syn region papp_pxml  matchgroup=xmlTag start="<pxml>"	end="</pxml>"  contains=papp_CDATAx,papp_ph_perl,papp_ph_xml,papp_ph_xint	     keepend
syn region papp_perlPOD start="^=[a-z]" end="^=cut" contains=@Pod,perlTodo keepend
syn region papp_CDATAp matchgroup=xmlCdataDecl start="<!\[CDATA\[" end="\]\]>" contains=@PAppPerl					 contained keepend
syn region papp_CDATAh matchgroup=xmlCdataDecl start="<!\[CDATA\[" end="\]\]>" contains=papp_ph_perl,papp_ph_html,papp_ph_hint,@PAppHtml contained keepend
syn region papp_CDATAx matchgroup=xmlCdataDecl start="<!\[CDATA\[" end="\]\]>" contains=papp_ph_perl,papp_ph_xml,papp_ph_xint		 contained keepend
syn region papp_ph_perl matchgroup=Delimiter start="<[:?]" end="[:?]>"me=e-2 nextgroup=papp_ph_html contains=@PAppPerl		     contained keepend
syn region papp_ph_html matchgroup=Delimiter start=":>"    end="<[:?]"me=e-2 nextgroup=papp_ph_perl contains=@PAppHtml		     contained keepend
syn region papp_ph_hint matchgroup=Delimiter start="?>"    end="<[:?]"me=e-2 nextgroup=papp_ph_perl contains=@perlInterpDQ,@PAppHtml contained keepend
syn region papp_ph_xml	matchgroup=Delimiter start=":>"    end="<[:?]"me=e-2 nextgroup=papp_ph_perl contains=			     contained keepend
syn region papp_ph_xint matchgroup=Delimiter start="?>"    end="<[:?]"me=e-2 nextgroup=papp_ph_perl contains=@perlInterpDQ	     contained keepend
syn sync clear
syn sync match pappSync grouphere papp_CDATAh "</\(perl\|xperl\|phtml\|macro\|module\)>"
syn sync match pappSync grouphere papp_CDATAh "^# *\(if\|elsif\|else\|endif\)"
syn sync match pappSync grouphere papp_CDATAh "</\(tr\|td\|table\|hr\|h1\|h2\|h3\)>"
syn sync match pappSync grouphere NONE	      "</\=\(module\|state\|macro\)>"
syn sync maxlines=300
syn sync minlines=5
hi def link papp_prep		preCondit
hi def link papp_gettext	String
let b:current_syntax = "papp"
