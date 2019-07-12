if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword mmixType	byte wyde tetra octa
syn match decNumber		"[0-9]*"
syn match octNumber		"0[0-7][0-7]\+"
syn match hexNumber		"#[0-9a-fA-F]\+"
syn region mmixString		start=+"+ skip=+\\"+ end=+"+ contains=@Spell
syn match mmixChar		"'.'"
syn match mmixAt		"@"
syn keyword mmixSegments	Data_Segment Pool_Segment Stack_Segment
syn match mmixIdentifier	"[a-z_][a-z0-9_]*"
syn match mmixLabel		"^[a-z0-9_:][a-z0-9_]*"
syn match mmixLabel		"[0-9][HBF]"
syn keyword mmixPseudo		is loc greg
syn match mmixComment		"%.*" contains=@Spell
syn match mmixComment		"//.*" contains=@Spell
syn match mmixComment		"^\*.*" contains=@Spell
syn keyword mmixOpcode	trap fcmp fun feql fadd fix fsub fixu
syn keyword mmixOpcode	fmul fcmpe fune feqle fdiv fsqrt frem fint
syn keyword mmixOpcode	floti flotui sfloti sflotui i
syn keyword mmixOpcode	muli mului divi divui
syn keyword mmixOpcode	addi addui subi subui
syn keyword mmixOpcode	2addui 4addui 8addui 16addui
syn keyword mmixOpcode	cmpi cmpui negi negui
syn keyword mmixOpcode	sli slui sri srui
syn keyword mmixOpcode	bnb bzb bpb bodb
syn keyword mmixOpcode	bnnb bnzb bnpb bevb
syn keyword mmixOpcode	pbnb pbzb pbpb pbodb
syn keyword mmixOpcode	pbnnb pbnzb pbnpb pbevb
syn keyword mmixOpcode	csni cszi cspi csodi
syn keyword mmixOpcode	csnni csnzi csnpi csevi
syn keyword mmixOpcode	zsni zszi zspi zsodi
syn keyword mmixOpcode	zsnni zsnzi zsnpi zsevi
syn keyword mmixOpcode	ldbi ldbui ldwi ldwui
syn keyword mmixOpcode	ldti ldtui ldoi ldoui
syn keyword mmixOpcode	ldsfi ldhti cswapi ldunci
syn keyword mmixOpcode	ldvtsi preldi pregoi goi
syn keyword mmixOpcode	stbi stbui stwi stwui
syn keyword mmixOpcode	stti sttui stoi stoui
syn keyword mmixOpcode	stsfi sthti stcoi stunci
syn keyword mmixOpcode	syncdi presti syncidi pushgoi
syn keyword mmixOpcode	ori orni nori xori
syn keyword mmixOpcode	andi andni nandi nxori
syn keyword mmixOpcode	bdifi wdifi tdifi odifi
syn keyword mmixOpcode	muxi saddi mori mxori
syn keyword mmixOpcode	muli mului divi divui
syn keyword mmixOpcode	flot flotu sflot sflotu
syn keyword mmixOpcode	mul mulu div divu
syn keyword mmixOpcode	add addu sub subu
syn keyword mmixOpcode	2addu 4addu 8addu 16addu
syn keyword mmixOpcode	cmp cmpu neg negu
syn keyword mmixOpcode	sl slu sr sru
syn keyword mmixOpcode	bn bz bp bod
syn keyword mmixOpcode	bnn bnz bnp bev
syn keyword mmixOpcode	pbn pbz pbp pbod
syn keyword mmixOpcode	pbnn pbnz pbnp pbev
syn keyword mmixOpcode	csn csz csp csod
syn keyword mmixOpcode	csnn csnz csnp csev
syn keyword mmixOpcode	zsn zsz zsp zsod
syn keyword mmixOpcode	zsnn zsnz zsnp zsev
syn keyword mmixOpcode	ldb ldbu ldw ldwu
syn keyword mmixOpcode	ldt ldtu ldo ldou
syn keyword mmixOpcode	ldsf ldht cswap ldunc
syn keyword mmixOpcode	ldvts preld prego go
syn keyword mmixOpcode	stb stbu stw stwu
syn keyword mmixOpcode	stt sttu sto stou
syn keyword mmixOpcode	stsf stht stco stunc
syn keyword mmixOpcode	syncd prest syncid pushgo
syn keyword mmixOpcode	or orn nor xor
syn keyword mmixOpcode	and andn nand nxor
syn keyword mmixOpcode	bdif wdif tdif odif
syn keyword mmixOpcode	mux sadd mor mxor
syn keyword mmixOpcode	seth setmh setml setl inch incmh incml incl
syn keyword mmixOpcode	orh ormh orml orl andh andmh andml andnl
syn keyword mmixOpcode	jmp pushj geta put
syn keyword mmixOpcode	pop resume save unsave sync swym get trip
syn keyword mmixOpcode	set lda
syn case match
syn match mmixRegister		"$[0-9]*"
syn match mmixRegister		"r[A-Z]"
syn keyword mmixRegister	rBB rTT rWW rXX rYY rZZ
hi def link mmixAt		Type
hi def link mmixPseudo	Type
hi def link mmixRegister	Special
hi def link mmixSegments	Type
hi def link mmixLabel	Special
hi def link mmixComment	Comment
hi def link mmixOpcode	Keyword
hi def link hexNumber	Number
hi def link decNumber	Number
hi def link octNumber	Number
hi def link mmixString	String
hi def link mmixChar	String
hi def link mmixType	Type
hi def link mmixIdentifier	Normal
hi def link mmixSpecialComment Comment
let b:current_syntax = "mmix"
