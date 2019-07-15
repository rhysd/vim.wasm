if exists("b:current_syntax")
finish
endif
setlocal iskeyword=@,48-57,_,.
syn case match
syn match eComment /\'.*/
syn region eString start=/"/ skip=/\\\\\|\\"/ end=/"/
syn match eNumber /\d\+/
syn match eFloat /\d\+\.\d*\([Ee][-+]\=\d\+\)\=/
syn match eFloat /\.\d\+\([Ee][-+]\=\d\+\)\=/
syn match eFloat /\d\+[Ee][-+]\=\d\+/
syn match eIdentifier /\a\k*/
syn keyword eProgLang  @date else endif @errorcount @evpath exitloop for if @isobject next poff pon return statusline step stop  @temppath then @time to @toc wend while  include call subroutine endsub and or
syn keyword eOVP alpha coef equation graph group link logl matrix model pool rowvector sample scalar series sspace sym system table text valmap var vector
syn keyword eStdCmd 3sls add addassign addinit addtext align alpha append arch archtest area arlm arma arroots auto axis bar bdstest binary block boxplot boxplotby bplabel cause ccopy cd cdfplot cellipse censored cfetch checkderivs chow clabel cleartext close coef coefcov coint comment control copy cor correl correlsq count cov create cross data datelabel dates db dbcopy dbcreate dbdelete dbopen dbpack dbrebuild dbrename dbrepair decomp define delete derivs describe displayname do draw driconvert drop dtable ec edftest endog eqs equation errbar exclude exit expand fetch fill fiml fit forecast freeze freq frml garch genr gmm grads graph group hconvert hfetch hilo hist hlabel hpf impulse jbera kdensity kerfit label laglen legend line linefit link linkto load logit logl ls makecoint makederivs makeendog makefilter makegarch makegrads makegraph makegroup makelimits makemodel makeregs makeresids makesignals makestates makestats makesystem map matrix means merge metafile ml model msg name nnfit open options ordered output override pageappend pagecontract pagecopy pagecreate pagedelete pageload pagerename pagesave pageselect pagestack pagestruct pageunstack param pcomp pie pool predict print probit program qqplot qstats range read rename representations resample reset residcor residcov resids results rls rndint rndseed rowvector run sample save scalar scale scat scatmat scenario seas seasplot series set setbpelem setcell setcolwidth setconvert setelem setfillcolor setfont setformat setheight setindent setjust setline setlines setmerge settextcolor setwidth sheet show signalgraphs smooth smpl solve solveopt sort spec spike sspace statby statefinal stategraphs stateinit stats statusline stomna store structure sur svar sym system table template testadd testbtw testby testdrop testexog testfit testlags teststat text tic toc trace tramoseats tsls unlink update updatecoefs uroot usage valmap var vars vector wald wfcreate wfopen wfsave wfselect white wls workfile write wtsls x11 x12 xy xyline xypair 
syn match eConstant /\!\k*/
syn match eStringId /%\k*/
syn match eCommand /@\k*/
syn match eDelimiter /[,;:]/
syn region eRegion matchgroup=Delimiter start=/(/ matchgroup=Delimiter end=/)/ transparent contains=ALLBUT,rError,rBraceError,rCurlyError
syn region eRegion matchgroup=Delimiter start=/{/ matchgroup=Delimiter end=/}/ transparent contains=ALLBUT,rError,rBraceError,rParenError
syn region eRegion matchgroup=Delimiter start=/\[/ matchgroup=Delimiter end=/]/ transparent contains=ALLBUT,rError,rCurlyError,rParenError
syn match eError      /[)\]}]/
syn match eBraceError /[)}]/ contained
syn match eCurlyError /[)\]]/ contained
syn match eParenError /[\]}]/ contained
hi def link eComment     Comment
hi def link eConstant    Identifier
hi def link eStringId    Identifier
hi def link eCommand     Type
hi def link eString      String
hi def link eNumber      Number
hi def link eBoolean     Boolean
hi def link eFloat       Float
hi def link eConditional Conditional
hi def link eProgLang    Statement
hi def link eOVP	      Statement
hi def link eStdCmd      Statement
hi def link eIdentifier  Normal
hi def link eDelimiter   Delimiter
hi def link eError       Error
hi def link eBraceError  Error
hi def link eCurlyError  Error
hi def link eParenError  Error
let b:current_syntax="eviews"
