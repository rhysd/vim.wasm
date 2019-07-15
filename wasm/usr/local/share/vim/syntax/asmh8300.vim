if exists("b:current_syntax")
finish
endif
syn case ignore
syn match asmDirective "\.h8300[h]*"
syn match asmReg	"e\=r[0-7][lh]\="
syn match asmOpcode "add\.[lbw]"
syn match asmOpcode "add[sx :]"
syn match asmOpcode "and\.[lbw]"
syn match asmOpcode "bl[deots]"
syn match asmOpcode "cmp\.[lbw]"
syn match asmOpcode "dec\.[lbw]"
syn match asmOpcode "divx[us].[bw]"
syn match asmOpcode "ext[su]\.[lw]"
syn match asmOpcode "inc\.[lw]"
syn match asmOpcode "mov\.[lbw]"
syn match asmOpcode "mulx[su]\.[bw]"
syn match asmOpcode "neg\.[lbw]"
syn match asmOpcode "not\.[lbw]"
syn match asmOpcode "or\.[lbw]"
syn match asmOpcode "pop\.[wl]"
syn match asmOpcode "push\.[wl]"
syn match asmOpcode "rotx\=[lr]\.[lbw]"
syn match asmOpcode "sha[lr]\.[lbw]"
syn match asmOpcode "shl[lr]\.[lbw]"
syn match asmOpcode "sub\.[lbw]"
syn match asmOpcode "xor\.[lbw]"
syn keyword asmOpcode "andc" "band" "bcc" "bclr" "bcs" "beq" "bf" "bge" "bgt"
syn keyword asmOpcode "bhi" "bhs" "biand" "bild" "bior" "bist" "bixor" "bmi"
syn keyword asmOpcode "bne" "bnot" "bnp" "bor" "bpl" "bpt" "bra" "brn" "bset"
syn keyword asmOpcode "bsr" "btst" "bst" "bt" "bvc" "bvs" "bxor" "cmp" "daa"
syn keyword asmOpcode "das" "eepmov" "eepmovw" "inc" "jmp" "jsr" "ldc" "movfpe"
syn keyword asmOpcode "movtpe" "mov" "nop" "orc" "rte" "rts" "sleep" "stc"
syn keyword asmOpcode "sub" "trapa" "xorc"
syn case match
runtime! syntax/asm.vim
hi def link asmOpcode  Statement
hi def link asmRegister  Identifier
let b:current_syntax = "asmh8300"
