if exists("b:current_syntax")
finish
endif
if !exists("main_syntax")
let main_syntax = 'mason'
endif
runtime! syntax/html.vim
unlet b:current_syntax
syn cluster htmlPreproc add=@masonTop
syn include @perlTop syntax/perl.vim
unlet b:current_syntax
syn include @podTop syntax/pod.vim
syn region masonPod start="^=[a-z]" end="^=cut" keepend contained contains=@podTop
syn cluster perlTop remove=perlBraces
syn region masonLine matchgroup=Delimiter start="^%" end="$" keepend contains=@perlTop
syn region masonPerlComment start="#" end="\%(%>\)\@=\|$" contained contains=perlTodo,@Spell
syn region masonExpr matchgroup=Delimiter start="<%" end="%>" contains=@perlTop,masonPerlComment
syn region masonPerl matchgroup=Delimiter start="<%perl>" end="</%perl>" contains=masonPod,@perlTop
syn region masonComp keepend matchgroup=Delimiter start="<&\s*\%([-._/[:alnum:]]\+:\)\?[-._/[:alnum:]]*" end="&>" contains=@perlTop
syn region masonComp keepend matchgroup=Delimiter skipnl start="<&|\s*\%([-._/[:alnum:]]\+:\)\?[-._/[:alnum:]]*" end="&>" contains=@perlTop nextgroup=masonCompContent
syn region masonCompContent matchgroup=Delimiter start="" end="</&>" contained contains=@masonTop
syn region masonArgs matchgroup=Delimiter start="<%args>" end="</%args>" contains=masonPod,@perlTop
syn region masonInit matchgroup=Delimiter start="<%init>" end="</%init>" contains=masonPod,@perlTop
syn region masonCleanup matchgroup=Delimiter start="<%cleanup>" end="</%cleanup>" contains=masonPod,@perlTop
syn region masonOnce matchgroup=Delimiter start="<%once>" end="</%once>" contains=masonPod,@perlTop
syn region masonClass matchgroup=Delimiter start="<%class>" end="</%class>" contains=masonPod,@perlTop
syn region masonShared matchgroup=Delimiter start="<%shared>" end="</%shared>" contains=masonPod,@perlTop
syn region masonDef matchgroup=Delimiter start="<%def\s*[-._/[:alnum:]]\+\s*>" end="</%def>" contains=@htmlTop
syn region masonMethod matchgroup=Delimiter start="<%method\s*[-._/[:alnum:]]\+\s*>" end="</%method>" contains=@htmlTop
syn region masonFlags matchgroup=Delimiter start="<%flags>" end="</%flags>" contains=masonPod,@perlTop
syn region masonAttr matchgroup=Delimiter start="<%attr>" end="</%attr>" contains=masonPod,@perlTop
syn region masonFilter matchgroup=Delimiter start="<%filter>" end="</%filter>" contains=masonPod,@perlTop
syn region masonDoc matchgroup=Delimiter start="<%doc>" end="</%doc>"
syn region masonText matchgroup=Delimiter start="<%text>" end="</%text>"
syn cluster masonTop contains=masonLine,masonExpr,masonPerl,masonComp,masonArgs,masonInit,masonCleanup,masonOnce,masonShared,masonDef,masonMethod,masonFlags,masonAttr,masonFilter,masonDoc,masonText
hi def link masonDoc Comment
hi def link masonPod Comment
hi def link masonPerlComment perlComment
let b:current_syntax = "mason"
if main_syntax == 'mason'
unlet main_syntax
endif
