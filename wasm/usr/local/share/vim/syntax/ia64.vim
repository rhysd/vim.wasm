if exists("b:current_syntax")
finish
endif
syn case ignore
setlocal iskeyword=@,48-57,#,$,.,:,?,@-@,_,~
syn sync minlines=5
source <sfile>:p:h/masm.vim
syn region ia64Comment start="//" end="$" contains=ia64Todo
syn region ia64Comment start="/\*" end="\*/" contains=ia64Todo
syn match ia64Identifier	"[a-zA-Z_$][a-zA-Z0-9_$]*"
syn match ia64Directive		"\.[a-zA-Z_$][a-zA-Z_$.]\+"
syn match ia64Label		"[a-zA-Z_$.][a-zA-Z0-9_$.]*\s\=:\>"he=e-1
syn match ia64Label		"[a-zA-Z_$.][a-zA-Z0-9_$.]*\s\=::\>"he=e-2
syn match ia64Label		"[a-zA-Z_$.][a-zA-Z0-9_$.]*\s\=#\>"he=e-1
syn region ia64string		start=+L\="+ skip=+\\\\\|\\"+ end=+"+
syn match ia64Octal		"0[0-7_]*\>"
syn match ia64Binary		"0[bB][01_]*\>"
syn match ia64Hex		"0[xX][0-9a-fA-F_]*\>"
syn match ia64Decimal		"[1-9_][0-9_]*\>"
syn match ia64Float		"[0-9_]*\.[0-9_]*\([eE][+-]\=[0-9_]*\)\=\>"
syn keyword ia64opcode add adds addl addp4 alloc and andcm cover epc
syn keyword ia64opcode fabs fand fandcm fc flushrs fneg fnegabs for
syn keyword ia64opcode fpabs fpack fpneg fpnegabs fselect fand fabdcm
syn keyword ia64opcode fc fwb fxor loadrs movl mux1 mux2 or padd4
syn keyword ia64opcode pavgsub1 pavgsub2 popcnt psad1 pshl2 pshl4 pshladd2
syn keyword ia64opcode pshradd2 psub4 rfi rsm rum shl shladd shladdp4
syn keyword ia64opcode shrp ssm sub sum sync.i tak thash
syn keyword ia64opcode tpa ttag xor
syn match   ia64Directive       "\.186"
syn match   ia64Directive       "\.286"
syn match   ia64Directive       "\.286c"
syn match   ia64Directive       "\.286p"
syn match   ia64Directive       "\.287"
syn match   ia64Directive       "\.386"
syn match   ia64Directive       "\.386c"
syn match   ia64Directive       "\.386p"
syn match   ia64Directive       "\.387"
syn match   ia64Directive       "\.486"
syn match   ia64Directive       "\.486c"
syn match   ia64Directive       "\.486p"
syn match   ia64Directive       "\.8086"
syn match   ia64Directive       "\.8087"
syn match ia64delimiter ";;"
syn match ia64operators "[\[\]()#,]"
syn match ia64operators "\(+\|-\|=\)"
syn match ia64Todo      "\(TODO\|XXX\|FIXME\|NOTE\)"
syn match ia64opcode "br\(\(\.\(cond\|call\|ret\|ia\|cloop\|ctop\|cexit\|wtop\|wexit\)\)\=\(\.\(spnt\|dpnt\|sptk\|dptk\)\)\=\(\.few\|\.many\)\=\(\.clr\)\=\)\=\>"
syn match ia64opcode "break\(\.[ibmfx]\)\=\>"
syn match ia64opcode "brp\(\.\(sptk\|dptk\|loop\|exit\)\)\(\.imp\)\=\>"
syn match ia64opcode "brp\.ret\(\.\(sptk\|dptk\)\)\{1}\(\.imp\)\=\>"
syn match ia64opcode "bsw\.[01]\>"
syn match ia64opcode "chk\.\(s\(\.[im]\)\=\)\>"
syn match ia64opcode "chk\.a\.\(clr\|nc\)\>"
syn match ia64opcode "clrrrb\(\.pr\)\=\>"
syn match ia64opcode "cmp4\=\.\(eq\|ne\|l[te]\|g[te]\|[lg]tu\|[lg]eu\)\(\.unc\)\=\>"
syn match ia64opcode "cmp4\=\.\(eq\|[lgn]e\|[lg]t\)\.\(\(or\(\.andcm\|cm\)\=\)\|\(and\(\(\.or\)\=cm\)\=\)\)\>"
syn match ia64opcode "cmpxchg[1248]\.\(acq\|rel\)\(\.nt1\|\.nta\)\=\>"
syn match ia64opcode "czx[12]\.[lr]\>"
syn match ia64opcode "dep\(\.z\)\=\>"
syn match ia64opcode "extr\(\.u\)\=\>"
syn match ia64opcode "fadd\(\.[sd]\)\=\(\.s[0-3]\)\=\>"
syn match ia64opcode "fa\(max\|min\)\(\.s[0-3]\)\=\>"
syn match ia64opcode "f\(chkf\|max\|min\)\(\.s[0-3]\)\=\>"
syn match ia64opcode "fclass\(\.n\=m\)\(\.unc\)\=\>"
syn match ia64opcode "f\(clrf\|pamax\|pamin\)\(\.s[0-3]\)\=\>"
syn match ia64opcode "fcmp\.\(n\=[lg][te]\|n\=eq\|\(un\)\=ord\)\(\.unc\)\=\(\.s[0-3]\)\=\>"
syn match ia64opcode "fcvt\.\(\(fxu\=\(\.trunc\)\=\(\.s[0-3]\)\=\)\|\(xf\|xuf\(\.[sd]\)\=\(\.s[0-3]\)\=\)\)\>"
syn match ia64opcode "fetchadd[48]\.\(acq\|rel\)\(\.nt1\|\.nta\)\=\>"
syn match ia64opcode "fm\([as]\|py\)\(\.[sd]\)\=\(\.s[0-3]\)\=\>"
syn match ia64opcode "fp\=merge\.\(ns\|se\=\)\>"
syn match ia64opcode "fmix\.\(lr\|[lr]\)\>"
syn match ia64opcode "fn\(ma\|mpy\|orm\)\(\.[sd]\)\=\(\.s[0-3]\)\=\>"
syn match ia64opcode "fpcmp\.\(n\=[lg][te]\|n\=eq\|\(un\)\=ord\)\(\.s[0-3]\)\=\>"
syn match ia64opcode "fpcvt\.fxu\=\(\(\.trunc\)\=\(\.s[0-3]\)\=\)\>"
syn match ia64opcode "fp\(max\=\|min\|n\=mpy\|ms\|nma\|rcpa\|sqrta\)\(\.s[0-3]\)\=\>"
syn match ia64opcode "fr\(cpa\|sqrta\)\(\.s[0-3]\)\=\>"
syn match ia64opcode "f\(setc\|amin\|chkf\)\(\.s[0-3]\)\=\>"
syn match ia64opcode "fsub\(\.[sd]\)\=\(\.s[0-3]\)\=\>"
syn match ia64opcode "fswap\(\.n[lr]\=\)\=\>"
syn match ia64opcode "fsxt\.[lr]\>"
syn match ia64opcode "getf\.\([sd]\|exp\|sig\)\>"
syn match ia64opcode "invala\(\.[ae]\)\=\>"
syn match ia64opcode "it[cr]\.[id]\>"
syn match ia64opcode "ld[1248]\>\|ld[1248]\(\.\(sa\=\|a\|c\.\(nc\|clr\(\.acq\)\=\)\|acq\|bias\)\)\=\(\.nt[1a]\)\=\>"
syn match ia64opcode "ld8\.fill\(\.nt[1a]\)\=\>"
syn match ia64opcode "ldf[sde8]\(\(\.\(sa\=\|a\|c\.\(nc\|clr\)\)\)\=\(\.nt[1a]\)\=\)\=\>"
syn match ia64opcode "ldf\.fill\(\.nt[1a]\)\=\>"
syn match ia64opcode "ldfp[sd8]\(\(\.\(sa\=\|a\|c\.\(nc\|clr\)\)\)\=\(\.nt[1a]\)\=\)\=\>"
syn match ia64opcode "lfetch\(\.fault\(\.excl\)\=\|\.excl\)\=\(\.nt[12a]\)\=\>"
syn match ia64opcode "mf\(\.a\)\=\>"
syn match ia64opcode "mix[124]\.[lr]\>"
syn match ia64opcode "mov\(\.[im]\)\=\>"
syn match ia64opcode "mov\(\.ret\)\=\(\(\.sptk\|\.dptk\)\=\(\.imp\)\=\)\=\>"
syn match ia64opcode "nop\(\.[ibmfx]\)\=\>"
syn match ia64opcode "pack\(2\.[su]ss\|4\.sss\)\>"
syn match ia64opcode "padd[12]\(\.\(sss\|uus\|uuu\)\)\=\>"
syn match ia64opcode "pavg[12]\(\.raz\)\=\>"
syn match ia64opcode "pcmp[124]\.\(eq\|gt\)\>"
syn match ia64opcode "pm\(ax\|in\)\(\(1\.u\)\|2\)\>"
syn match ia64opcode "pmpy2\.[rl]\>"
syn match ia64opcode "pmpyshr2\(\.u\)\=\>"
syn match ia64opcode "probe\.[rw]\>"
syn match ia64opcode "probe\.\(\(r\|w\|rw\)\.fault\)\>"
syn match ia64opcode "pshr[24]\(\.u\)\=\>"
syn match ia64opcode "psub[12]\(\.\(sss\|uu[su]\)\)\=\>"
syn match ia64opcode "ptc\.\(l\|e\|ga\=\)\>"
syn match ia64opcode "ptr\.\(d\|i\)\>"
syn match ia64opcode "setf\.\(s\|d\|exp\|sig\)\>"
syn match ia64opcode "shr\(\.u\)\=\>"
syn match ia64opcode "srlz\(\.[id]\)\>"
syn match ia64opcode "st[1248]\(\.rel\)\=\(\.nta\)\=\>"
syn match ia64opcode "st8\.spill\(\.nta\)\=\>"
syn match ia64opcode "stf[1248]\(\.nta\)\=\>"
syn match ia64opcode "stf\.spill\(\.nta\)\=\>"
syn match ia64opcode "sxt[124]\>"
syn match ia64opcode "t\(bit\|nat\)\(\.nz\|\.z\)\=\(\.\(unc\|or\(\.andcm\|cm\)\=\|and\(\.orcm\|cm\)\=\)\)\=\>"
syn match ia64opcode "unpack[124]\.[lh]\>"
syn match ia64opcode "xchg[1248]\(\.nt[1a]\)\=\>"
syn match ia64opcode "xm\(a\|py\)\.[lh]u\=\>"
syn match ia64opcode "zxt[124]\>"
syn match ia64registers "\([fr]\|cr\)\([0-9]\|[1-9][0-9]\|1[0-1][0-9]\|12[0-7]\)\{1}\>"
syn match ia64registers "b[0-7]\>"
syn match ia64registers "p\([0-9]\|[1-5][0-9]\|6[0-3]\)\>"
syn match ia64registers "ar\.\(fpsr\|mat\|unat\|rnat\|pfs\|bsp\|bspstore\|rsc\|lc\|ec\|ccv\|itc\|k[0-7]\)\>"
syn match ia64registers "ar\.\(eflag\|fcr\|csd\|ssd\|cflg\|fsr\|fir\|fdr\)\>"
syn keyword ia64registers sp gp pr pr.rot rp ip tp
syn match ia64registers "\(in\|out\|loc\)\([0-9]\|[1-8][0-9]\|9[0-5]\)\>"
syn match ia64registers "farg[0-7]\>"
syn match ia64registers "fret[0-7]\>"
syn match ia64registers "psr\(\.\(l\|um\)\)\=\>"
syn match ia64registers "cr\.\(dcr\|itm\|iva\|pta\|ipsr\|isr\|ifa\|iip\|itir\|iipa\|ifs\|iim\|iha\|lid\|ivr\|tpr\|eoi\|irr[0-3]\|itv\|pmv\|lrr[01]\|cmcv\)\>"
syn match ia64registers "\(cpuid\|dbr\|ibr\|pkr\|pmc\|pmd\|rr\|itr\|dtr\)\>"
syn match ia64registers "\(@rev\|@mix\|@shuf\|@alt\|@brcst\)\>"
syn match ia64registers "\(@nat\|@qnan\|@snan\|@pos\|@neg\|@zero\|@unorm\|@norm\|@inf\)\>"
syn match ia64registers "\(@\(\(\(gp\|sec\|seg\|image\)rel\)\|ltoff\|fptr\|ptloff\|ltv\|section\)\)\>"
syn match ia64data "data[1248]\(\(\(\.ua\)\=\(\.msb\|\.lsb\)\=\)\|\(\(\.msb\|\.lsb\)\=\(\.ua\)\=\)\)\=\>"
syn match ia64data "real\([48]\|1[06]\)\(\(\(\.ua\)\=\(\.msb\|\.lsb\)\=\)\|\(\(\.msb\|\.lsb\)\=\(\.ua\)\=\)\)\=\>"
syn match ia64data "stringz\=\(\(\(\.ua\)\=\(\.msb\|\.lsb\)\=\)\|\(\(\.msb\|\.lsb\)\=\(\.ua\)\=\)\)\=\>"
hi def link masmOperator	ia64operator
hi def link masmDirective	ia64Directive
hi def link masmOpcode	ia64Opcode
hi def link masmIdentifier	ia64Identifier
hi def link masmFloat	ia64Float
hi def link ia64Label	Define
hi def link ia64Comment	Comment
hi def link ia64Directive	Type
hi def link ia64opcode	Statement
hi def link ia64registers	Operator
hi def link ia64string	String
hi def link ia64Hex		Number
hi def link ia64Binary	Number
hi def link ia64Octal	Number
hi def link ia64Float	Float
hi def link ia64Decimal	Number
hi def link ia64Identifier	Identifier
hi def link ia64data		Type
hi def link ia64delimiter	Delimiter
hi def link ia64operator	Operator
hi def link ia64Todo		Todo
let b:current_syntax = "ia64"
