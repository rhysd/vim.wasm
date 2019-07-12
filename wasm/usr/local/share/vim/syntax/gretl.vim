if exists("b:current_syntax")
finish
endif
setlocal iskeyword=@,48-57,_,.
syn case match
syn region gString start=/"/ skip=/\\\\\|\\"/ end=/"/
syn match gNumber /\d\+/
syn match gFloat /\d\+\.\d*\([Ee][-+]\=\d\+\)\=/
syn match gFloat /\.\d\+\([Ee][-+]\=\d\+\)\=/
syn match gFloat /\d\+[Ee][-+]\=\d\+/
syn keyword gCommands add addobs addto adf append ar arch arma break boxplot chow coeffsum coint coint2 corc corr corrgm criteria critical cusum data delete diff else end endif endloop eqnprint equation estimate fcast fcasterr fit freq function funcerr garch genr gnuplot graph hausman hccm help hilu hsk hurst if import include info kpss label labels lad lags ldiff leverage lmtest logistic logit logs loop mahal meantest mle modeltab mpols multiply nls nulldata ols omit omitfrom open outfile panel pca pergm plot poisson pooled print printf probit pvalue pwe quit remember rename reset restrict rhodiff rmplot run runs scatters sdiff set setobs setmiss shell sim smpl spearman square store summary system tabprint testuhat tobit transpos tsls var varlist vartest vecm vif wls 
syn keyword gGenrFunc log exp sin cos tan atan diff ldiff sdiff mean sd min max sort int ln coeff abs rho sqrt sum nobs firstobs lastobs normal uniform stderr cum missing ok misszero corr vcv var sst cov median zeromiss pvalue critical obsnum mpow dnorm cnorm gamma lngamma resample hpfilt bkfilt fracdiff varnum isvector islist nelem 
syn match gIdentifier /\a\k*/
syn match gVariable /\$\k*/
syn match gArrow /<-/
syn match gDelimiter /[,;:]/
syn region gRegion matchgroup=Delimiter start=/(/ matchgroup=Delimiter end=/)/ transparent contains=ALLBUT,rError,rBraceError,rCurlyError,gBCstart,gBCend
syn region gRegion matchgroup=Delimiter start=/{/ matchgroup=Delimiter end=/}/ transparent contains=ALLBUT,rError,rBraceError,rParenError
syn region gRegion matchgroup=Delimiter start=/\[/ matchgroup=Delimiter end=/]/ transparent contains=ALLBUT,rError,rCurlyError,rParenError
syn match gError      /[)\]}]/
syn match gBraceError /[)}]/ contained
syn match gCurlyError /[)\]]/ contained
syn match gParenError /[\]}]/ contained
syn match gComment /#.*/
syn match gBCstart /(\*/
syn match gBCend /\*)/
syn region gBlockComment matchgroup=gCommentStart start="(\*" end="\*)"
hi def link gComment      Comment
hi def link gCommentStart Comment
hi def link gBlockComment Comment
hi def link gString       String
hi def link gNumber       Number
hi def link gBoolean      Boolean
hi def link gFloat        Float
hi def link gCommands     Repeat	
hi def link gGenrFunc     Type
hi def link gDelimiter    Delimiter
hi def link gError        Error
hi def link gBraceError   Error
hi def link gCurlyError   Error
hi def link gParenError   Error
hi def link gIdentifier   Normal
hi def link gVariable     Identifier
hi def link gArrow	       Repeat
let b:current_syntax="gretl"
