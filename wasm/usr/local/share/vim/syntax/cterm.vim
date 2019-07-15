if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword ctermFunction	abort addcr addlf answer at attr batch baud
syn keyword ctermFunction	break call capture cd cdelay charset cls color
syn keyword ctermFunction	combase config commect copy cread
syn keyword ctermFunction	creadint devprefix dialer dialog dimint
syn keyword ctermFunction	dimlog dimstr display dtimeout dwait edit
syn keyword ctermFunction	editor emulate erase escloop fcreate
syn keyword ctermFunction	fflush fillchar flags flush fopen fread
syn keyword ctermFunction	freadln fseek fwrite fwriteln get hangup
syn keyword ctermFunction	help hiwait htime ignore init itime
syn keyword ctermFunction	keyboard lchar ldelay learn lockfile
syn keyword ctermFunction	locktime log login logout lowait
syn keyword ctermFunction	lsend ltime memlist menu mkdir mode
syn keyword ctermFunction	modem netdialog netport noerror pages parity
syn keyword ctermFunction	pause portlist printer protocol quit rcv
syn keyword ctermFunction	read readint readn redial release
syn keyword ctermFunction	remote rename restart retries return
syn keyword ctermFunction	rmdir rtime run runx scrollback send
syn keyword ctermFunction	session set setcap setcolor setkey
syn keyword ctermFunction	setsym setvar startserver status
syn keyword ctermFunction	stime stopbits stopserver tdelay
syn keyword ctermFunction	terminal time trans type usend version
syn keyword ctermFunction	vi vidblink vidcard vidout vidunder wait
syn keyword ctermFunction	wildsize wclose wopen wordlen wru wruchar
syn keyword ctermFunction	xfer xmit xprot
syn match ctermFunction		"?"
syn keyword ctermIntFunction	asc atod eval filedate filemode filesize ftell
syn keyword ctermIntFunction	len termbits opsys pos sum time val mdmstat
syn keyword ctermStrFunction	cdate ctime chr chrdy chrin comin getenv
syn keyword ctermStrFunction	gethomedir left midstr right str tolower
syn keyword ctermStrFunction	toupper uniq comst exists feof hascolor
syn keyword ctermPreVarRW	f _escloop _filename _kermiteol _obufsiz
syn keyword ctermPreVarRW	_port _rcvsync _cbaud _reval _turnchar
syn keyword ctermPreVarRW	_txblksiz _txwindow _vmin _vtime _cparity
syn keyword ctermPreVarRW	_cnumber false t true _cwordlen _cstopbits
syn keyword ctermPreVarRW	_cmode _cemulate _cxprot _clogin _clogout
syn keyword ctermPreVarRW	_cstartsrv _cstopsrv _ccmdfile _cwru
syn keyword ctermPreVarRW	_cprotocol _captfile _cremark _combufsiz
syn keyword ctermPreVarRW	logfile
syn keyword ctermPreVarRO	_1 _2 _3 _4 _5 _6 _7 _8 _9 _cursess
syn keyword ctermPreVarRO	_lockfile _baud _errno _retval _sernum
syn keyword ctermPreVarRO	_timeout _row _col _version
syn keyword ctermOperator not mod eq ne gt le lt ge xor and or shr not shl
syn match   CtermSymbols	 "|"
syn keyword ctermStatement	off
syn keyword ctermStatement	disk overwrite append spool none
syn keyword ctermStatement	echo view wrap
syn keyword ctermLabel    case default
syn keyword ctermConditional on endon
syn keyword ctermConditional proc endproc
syn keyword ctermConditional for in do endfor
syn keyword ctermConditional if else elseif endif iferror
syn keyword ctermConditional switch endswitch
syn keyword ctermConditional repeat until
syn keyword ctermRepeat    while
syn match  ctermFuncArg	"\$[1-9]"
syn keyword ctermTodo contained TODO
syn match  ctermNumber		"\<\d\+\(u\=l\=\|lu\|f\)\>"
syn match  ctermNumber		"\<\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match  ctermNumber		"\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match  ctermNumber		"\<\d\+e[-+]\=\d\+[fl]\=\>"
syn match  ctermNumber		"0x[0-9a-f]\+\(u\=l\=\|lu\)\>"
syn match  ctermComment		"![^=].*$" contains=ctermTodo
syn match  ctermComment		"!$"
syn match  ctermComment		"\*.*$" contains=ctermTodo
syn region  ctermComment	start="comment" end="$" contains=ctermTodo
syn region  ctermComment	start="remark" end="$" contains=ctermTodo
syn region ctermVar		start="\$("  end=")"
syn match   ctermSpecial		contained "\\\d\d\d\|\\."
syn match   ctermSpecial		contained "\^."
syn region  ctermString			start=+"+  skip=+\\\\\|\\"+  end=+"+  contains=ctermSpecial,ctermVar,ctermSymbols
syn match   ctermCharacter		"'[^\\]'"
syn match   ctermSpecialCharacter	"'\\.'"
hi def link ctermStatement		Statement
hi def link ctermFunction		Statement
hi def link ctermStrFunction	Statement
hi def link ctermIntFunction	Statement
hi def link ctermLabel		Statement
hi def link ctermConditional	Statement
hi def link ctermRepeat		Statement
hi def link ctermLibFunc		UserDefFunc
hi def link ctermType		Type
hi def link ctermFuncArg		PreCondit
hi def link ctermPreVarRO		PreCondit
hi def link ctermPreVarRW		PreConditBold
hi def link ctermVar		Type
hi def link ctermComment		Comment
hi def link ctermCharacter		SpecialChar
hi def link ctermSpecial		Special
hi def link ctermSpecialCharacter	SpecialChar
hi def link ctermSymbols		Special
hi def link ctermString		String
hi def link ctermTodo		Todo
hi def link ctermOperator		Statement
hi def link ctermNumber		Number
let b:current_syntax = "cterm"
