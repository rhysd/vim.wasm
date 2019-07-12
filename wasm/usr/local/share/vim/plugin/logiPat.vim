if &cp || exists("loaded_logiPat")
finish
endif
let g:loaded_logiPat = "v4"
let s:keepcpo        = &cpo
set cpo&vim
com!     -nargs=* LogiPat		call   LogiPat(<q-args>,1)
sil! com -nargs=* LP			call   LogiPat(<q-args>,1)
sil! com -nargs=* LPR			call   LogiPat(<q-args>,1,"r")
com!     -nargs=+ LPE			echomsg LogiPat(<q-args>)
com!     -nargs=+ LogiPatFlags	let  s:LogiPatFlags="<args>"
sil! com -nargs=+ LPF			let  s:LogiPatFlags="<args>"
fun! LogiPat(pat,...)
if a:0 > 0
let dosearch= a:1
else
let dosearch= 0
endif
if a:0 >= 3
let s:LogiPatFlags= a:3
endif
let s:npatstack = 0
let s:nopstack  = 0
let s:preclvl   = 0
let expr        = a:pat
while expr != ""
if expr =~ '^"'
let expr = substitute(expr,'^\s*"','','')
let pat  = substitute(expr,'^\(\%([^"]\|\"\"\)\{-}\)"\([^"].*$\|$\)','\1','')
let pat  = substitute(pat,'""','"','g')
let expr = substitute(expr,'^\(\%([^"]\|\"\"\)\{-}\)"\([^"].*$\|$\)','\2','')
let expr = substitute(expr,'^\s*','','')
call s:LP_PatPush('.*'.pat.'.*')
elseif expr =~ '^[!()|&]'
let op   = strpart(expr,0,1)
let expr = strpart(expr,strlen(op))
if op =~ '[|&]' && expr[0] == op
let expr = strpart(expr,strlen(op))
endif
call s:LP_OpPush(op)
elseif expr =~ '^\s'
let expr= strpart(expr,1)
else
echoerr "operator<".strpart(expr,0,1)."> not supported (yet)"
let expr= strpart(expr,1)
endif
endwhile
call s:LP_OpPush('Z')
let result= s:LP_PatPop(1)
if s:npatstack > 0
echoerr s:npatstack." patterns left on stack!"
let s:npatstack= 0
endif
if s:nopstack > 0
echoerr s:nopstack." operators left on stack!"
let s:nopstack= 0
endif
if dosearch
if exists("s:LogiPatFlags") && s:LogiPatFlags != ""
call search(result,s:LogiPatFlags)
else
call search(result)
endif
let @/= result
endif
return result
endfun
func! s:String(str)
return "'".escape(a:str, '"')."'"
endfunc
fun! s:LP_PatPush(pat)
let s:npatstack              = s:npatstack + 1
let s:patstack_{s:npatstack} = a:pat
endfun
fun! s:LP_PatPop(lookup)
if s:npatstack > 0
let ret         = s:patstack_{s:npatstack}
let s:npatstack = s:npatstack - 1
else
let ret= "---error---"
echoerr "(LogiPat) invalid expression"
endif
return ret
endfun
fun! s:LP_OpPush(op)
if a:op == '('
let s:preclvl= s:preclvl + 10
let preclvl  = s:preclvl
elseif a:op == ')'
let s:preclvl= s:preclvl - 10
if s:preclvl < 0
let s:preclvl= 0
echoerr "too many )s"
endif
let preclvl= s:preclvl
elseif a:op =~ '|'
let preclvl= s:preclvl + 2
elseif a:op =~ '&'
let preclvl= s:preclvl + 4
elseif a:op == '!'
let preclvl= s:preclvl + 6
elseif a:op == 'Z'
let preclvl= -1
else
echoerr "expr<".expr."> not supported (yet)"
let preclvl= s:preclvl
endif
call s:LP_Execute(preclvl)
if a:op =~ '!'
let s:nopstack             = s:nopstack + 1
let s:opprec_{s:nopstack}  = preclvl
let s:opstack_{s:nopstack} = a:op
elseif a:op =~ '|'
let s:nopstack             = s:nopstack + 1
let s:opprec_{s:nopstack}  = preclvl
let s:opstack_{s:nopstack} = a:op
elseif a:op == '&'
let s:nopstack             = s:nopstack + 1
let s:opprec_{s:nopstack}  = preclvl
let s:opstack_{s:nopstack} = a:op
endif
endfun
fun! s:LP_Execute(preclvl)
while s:nopstack > 0 && a:preclvl < s:opprec_{s:nopstack}
let op= s:opstack_{s:nopstack}
let s:nopstack = s:nopstack - 1
if     op == '!'
let n1= s:LP_PatPop(1)
call s:LP_PatPush(s:LP_Not(n1))
elseif op == '|'
let n1= s:LP_PatPop(1)
let n2= s:LP_PatPop(1)
call s:LP_PatPush(s:LP_Or(n2,n1))
elseif op =~ '&'
let n1= s:LP_PatPop(1)
let n2= s:LP_PatPop(1)
call s:LP_PatPush(s:LP_And(n2,n1))
endif
endwhile
endfun
fun! s:LP_Not(pat)
if a:pat =~ '^\.\*' && a:pat =~ '\.\*$'
let pat= substitute(a:pat,'^\.\*\(.*\)\.\*$','\1','')
let ret= '^\%(\%('.pat.'\)\@!.\)*$'
else
let ret= '^\%(\%('.a:pat.'\)\@!.\)*$'
endif
return ret
endfun
fun! s:LP_Or(pat1,pat2)
let ret= '\%('.a:pat1.'\|'.a:pat2.'\)'
return ret
endfun
fun! s:LP_And(pat1,pat2)
let ret= '\%('.a:pat1.'\&'.a:pat2.'\)'
return ret
endfun
fun! s:StackLook(description)
let iop = 1
let ifp = 1
while ifp <= s:npatstack && iop <= s:nopstack
let fp = s:patstack_{ifp}
let op = s:opstack_{iop}." (P".s:opprec_{s:nopstack}.')'
let fplen= strlen(fp)
if fplen < 30
let fp= fp.strpart("                              ",1,30-fplen)
endif
let ifp = ifp + 1
let iop = iop + 1
endwhile
while ifp <= s:npatstack
let fp  = s:patstack_{ifp}
let ifp = ifp + 1
endwhile
while iop <= s:nopstack
let op  = s:opstack_{iop}." (P".s:opprec_{s:nopstack}.')'
let iop = iop + 1
endwhile
endfun
let &cpo= s:keepcpo
unlet s:keepcpo
