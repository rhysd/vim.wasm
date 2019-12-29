if exists('b:current_syntax')
finish
endif
let s:save_cpo = &cpo
set cpo&vim
syntax case match
syntax sync minlines=100
syntax cluster jStdlibItems contains=jStdlibNoun,jStdlibAdverb,jStdlibConjunction,jStdlibVerb
syntax cluster jPrimitiveItems contains=jNoun,jAdverb,jConjunction,jVerb,jCopula
syntax match jControl /\<\%(assert\|break\|case\|catch[dt]\=\|continue\|do\|else\%(if\)\=\|end\|fcase\|for\|if\|return\|select\|throw\|try\|whil\%(e\|st\)\)\./
syntax match jControl /\<\%(for\|goto\|label\)_\a\k*\./
syntax keyword jStdlibNoun ARGV BINPATH CR CRLF DEL Debug EAV EMPTY FF FHS IF64 IFBE IFIOS IFJA IFJHS IFJNET IFQT IFRASPI IFUNIX IFWIN IFWINCE IFWINE IFWOW64 JB01 JBOXED JCHAR JCHAR2 JCHAR4 JCMPX JFL JINT JLIB JPTR JSB JSIZES JSTR JSTR2 JSTR4 JTYPES JVERSION LF LF2 LIBFILE TAB UNAME UNXLIB dbhelp libjqt
syntax keyword jStdlibAdverb define each every fapplylines inv inverse items leaf rows rxapply rxmerge table
syntax keyword jStdlibConjunction bind cuts def on
syntax keyword jStdlibVerb AND Endian IFDEF OR XOR abspath anddf android_exec_am android_exec_host android_getdisplaymetrics andunzip apply boxopen boxxopen bx calendar cd cdcb cder cderx cdf charsub chopstring clear coclass cocreate cocurrent codestroy coerase cofind cofindv cofullname coinfo coinsert compare coname conames conew conl conouns conounsx copath copathnl copathnlx coreset costate cut cutLF cutopen cutpara datatype dbctx dbcut dberm dberr dbg dbinto dbjmp dblocals dblxq dblxs dbnxt dbout dbover dbq dbr dbret dbrr dbrrx dbrun dbs dbsig dbsq dbss dbst dbstack dbstk dbstop dbstopme dbstopnext dbstops dbtrace dbview deb debc delstring detab dfh dir dircompare dircompares dirfind dirpath dirss dirssrplc dirtree dirused dlb dltb dltbs dquote drop dropafter dropto dtb dtbs echo empty endian erase evtloop exit expand f2utf8 fappend fappends fboxname fc fcompare fcompares fcopynew fdir ferase fetch fexist fexists fgets file2url fixdotdot fliprgb fmakex foldpara foldtext fpathcreate fpathname fputs fread freadblock freadr freads frename freplace fsize fss fssrplc fstamp fstringreplace ftype fview fwrite fwritenew fwrites getalpha getargs getdate getenv getqtbin hfd hostpathsep ic install iospath isatty isotimestamp isutf16 isutf8 jcwdpath joinstring jpath jpathsep jsystemdefs launch list ljust load loadd mema memf memr memu memw nameclass namelist names nc nl pick quote require rjust rplc rxE rxall rxcomp rxcut rxeq rxerror rxfirst rxfree rxfrom rxhandles rxin rxindex rxinfo rxmatch rxmatches rxrplc rxutf8 script scriptd scripts setalpha setbreak shell show sign sminfo smoutput sort split splitnostring splitstring ss startupandroid stderr stdin stdout stringreplace symdat symget symset take takeafter taketo timespacex timestamp timex tmoutput toCRLF toHOST toJ todate todayno tolist tolower topara toupper tsdiff tsrep tstamp type ucp ucpcount undquote unxlib usleep utf8 uucp valdate wcsize weekday weeknumber weeksinyear winpathsep xedit
syntax match jStdlibNoun /\<\%(adverb\|conjunction\|dyad\|monad\|noun\|verb\)\>/
syntax match jStdlibVerb /\<\%(Note\|\%(assert\|break\|do\)\.\@!\)\>/
syntax match jNumber /\<_\.[0-9A-Za-z_.]\@!/
syntax match jNumber /\<_\=\d\+x[0-9A-Za-z_.]\@!/
syntax match jNumber /\<\%(__\=r_\=\d\+\|_\=\d\+r__\=\)[0-9A-Za-z_.]\@!/
syntax match jNumber /\<\%(\%(_\=\d\+\%(\.\d*\)\=\|_\.\d\+\)\%([eE]_\=\d\+\)\=\%(r\%(_\=\d\+\%(\.\d*\)\=\|_\.\d\+\|\.\d\+\)\%([eE]_\=\d\+\)\=\)\=\|__\=\)\%(\%(j\|a[dr]\)\%(\%(_\=\d\+\%(\.\d*\)\=\|_\.\d\+\|\.\d\+\)\%([eE]_\=\d\+\)\=\%(r\%(_\=\d\+\%(\.\d*\)\=\|_\.\d\+\|\.\d\+\)\%([eE]_\=\d\+\)\=\)\=\|__\=\)\)\=\%([px]\%(\%(_\=\d\+\%(\.\d*\)\=\|_\.\d\+\|\.\d\+\)\%([eE]_\=\d\+\)\=\%(r\%(_\=\d\+\%(\.\d*\)\=\|_\.\d\+\|\.\d\+\)\%([eE]_\=\d\+\)\=\)\=\|__\=\)\%(\%(j\|a[dr]\)\%(\%(_\=\d\+\%(\.\d*\)\=\|_\.\d\+\|\.\d\+\)\%([eE]_\=\d\+\)\=\%(r\%(_\=\d\+\%(\.\d*\)\=\|_\.\d\+\|\.\d\+\)\%([eE]_\=\d\+\)\=\)\=\|__\=\)\)\=\)\=\%(b\%(_\=[0-9a-z]\+\%(\.[0-9a-z]*\)\=\|_\=\.[0-9a-z]\+\)\)\=[0-9A-Za-z_.]\@!/
syntax region jString oneline start=/'/ skip=/''/ end=/'/
syntax keyword jArgument contained x y u v m n
syntax match jNoun /\<a[.:]/
syntax match jAdverb /[}~]\|[/\\]\.\=\|\<\%([Mbft]\.\|t:\)/
syntax match jConjunction /"\|`:\=\|[.:@&][.:]\=\|&\.:\|\<\%([dDHT]\.\|[DLS]:\)/
syntax match jVerb /[=!\]]\|[\^?]\.\=\|[;[]:\=\|{\.\|[_/\\]:\|[<>+*\-%$|,#][.:]\=\|[~}"][.:]\|{\%[::]\|\<\%([ACeEiIjLor]\.\|p\.\.\=\|[ipqsux]:\|0:\|_\=[1-9]:\)/
syntax match jCopula /=[.:]/
syntax match jConjunction /;\.\|\^:\|![.:]/
syntax region jNounDefineFold
\ matchgroup=NONE start=/\%(\%(\%(^\s*Note\)\|\<\%(0\|noun\)\s\+\%(\:\s*0\|def\s\+0\|define\)\)\>\)\@=/
\ keepend matchgroup=NONE end=/^\s*)\s*$/
\ contains=jNounDefineStart
\ fold
syntax region jNounDefineStart
\ matchgroup=jDefineExpression start=/\%(\%(^\s*Note\)\|\<\%(0\|noun\)\s\+\%(\:\s*0\|def\s\+0\|define\)\)\>/
\ keepend matchgroup=NONE end=/$/
\ contains=@jStdlibItems,@jPrimitiveItems,jNumber,jString,jParenGroup,jParen,jComment
\ contained oneline skipempty nextgroup=jDefineEnd,jNounDefine
syntax region jNounDefine
\ matchgroup=NONE start=/^/
\ matchgroup=jDefineEnd end=/^\s*)\s*$/
\ contained
syntax match jDefineEnd contained /^\s*)\s*$/
syntax region jDefine
\ matchgroup=jDefineExpression start=/\<\%([1-4]\|13\|adverb\|conjunction\|verb\|monad\|dyad\)\s\+\%(:\s*0\|def\s\+0\|define\)\>/
\ matchgroup=jDefineEnd end=/^\s*)\s*$/
\ contains=jControl,@jStdlibItems,@jPrimitiveItems,jNumber,jString,jArgument,jParenGroup,jParen,jComment,jDefineMonadDyad
\ fold
syntax match jDefineMonadDyad contained /^\s*:\s*$/
syntax match jParen /(\%(\s*\%([0-4]\|13\|noun\|adverb\|conjunction\|verb\|monad\|dyad\)\s\+\%(:\s*0\|def\s\+0\|define\)\s*)\)\@=/
syntax match jParen contained /\%((\s*\%([0-4]\|13\|noun\|adverb\|conjunction\|verb\|monad\|dyad\)\s\+\%(:\s*0\|def\s\+0\|define\)\s*\)\@<=)/
syntax region jParenGroup
\ matchgroup=jParen start=/(\%(\s*\%([0-4]\|13\|noun\|adverb\|conjunction\|verb\|monad\|dyad\)\s\+\%(:\s*0\|def\s\+0\|define\)\>\)\@!/
\ matchgroup=jParen end=/)/
\ oneline transparent
syntax keyword jTodo contained TODO FIXME XXX
syntax match jComment /\<NB\..*$/ contains=jTodo,@Spell
syntax match jSharpBang /\%^#!.*$/
highlight default link jControl           Statement
highlight default link jStdlibNoun        Identifier
highlight default link jStdlibAdverb      Function
highlight default link jStdlibConjunction Function
highlight default link jStdlibVerb        Function
highlight default link jString            String
highlight default link jNumber            Number
highlight default link jNoun              Constant
highlight default link jAdverb            Normal
highlight default link jConjunction       Normal
highlight default link jVerb              Normal
highlight default link jCopula            Normal
highlight default link jArgument          Identifier
highlight default link jParen             Delimiter
highlight default link jDefineExpression  Define
highlight default link jDefineMonadDyad   Delimiter
highlight default link jDefineEnd         Delimiter
highlight default link jNounDefine        Normal
highlight default link jTodo              Todo
highlight default link jComment           Comment
highlight default link jSharpBang         PreProc
let b:current_syntax = 'j'
let &cpo = s:save_cpo
unlet s:save_cpo
