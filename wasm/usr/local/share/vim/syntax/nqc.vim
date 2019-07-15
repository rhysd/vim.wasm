if exists("b:current_syntax")
finish
endif
syn keyword	nqcStatement	break return continue start stop abs sign
syn keyword     nqcStatement	sub task
syn keyword     nqcLabel	case default
syn keyword	nqcConditional	if else switch
syn keyword	nqcRepeat	while for do until repeat
syn keyword	nqcEvents	acquire catch monitor
syn keyword	nqcType		int true false void
syn keyword	nqcStorageClass	asm const inline
syn keyword     nqcConstant	SENSOR_1 SENSOR_2 SENSOR_3
syn keyword     nqcConstant	SENSOR_TYPE_TOUCH SENSOR_TYPE_TEMPERATURE
syn keyword     nqcConstant	SENSOR_TYPE_LIGHT SENSOR_TYPE_ROTATION
syn keyword     nqcConstant	SENSOR_LIGHT SENSOR_TOUCH
syn keyword     nqcConstant	SENSOR_MODE_RAW SENSOR_MODE_BOOL
syn keyword     nqcConstant	SENSOR_MODE_EDGE SENSOR_MODE_PULSE
syn keyword     nqcConstant	SENSOR_MODE_PERCENT SENSOR_MODE_CELSIUS
syn keyword     nqcConstant	SENSOR_MODE_FAHRENHEIT SENSOR_MODE_ROTATION
syn keyword     nqcConstant	SENSOR_TOUCH SENSOR_LIGHT SENSOR_ROTATION
syn keyword     nqcConstant	SENSOR_CELSIUS SENSOR_FAHRENHEIT SENSOR_PULSE
syn keyword     nqcConstant	SENSOR_EDGE
syn keyword	nqcFunction	ClearSensor
syn keyword	nqcFunction	SensorValue SensorType
syn keyword	nqcFunction	SetSensor SetSensorType
syn keyword	nqcFunction	SensorValueBool
syn keyword	nqcFunction	SetSensorMode SensorMode
syn keyword	nqcFunction	SensorValueRaw
syn keyword	nqcFunction	SetSensorLowerLimit SetSensorUpperLimit
syn keyword	nqcFunction	SetSensorHysteresis CalibrateSensor
syn keyword     nqcConstant	OUT_A OUT_B OUT_C
syn keyword     nqcConstant	OUT_ON OUT_OFF OUT_FLOAT
syn keyword     nqcConstant	OUT_FWD OUT_REV OUT_TOGGLE
syn keyword     nqcConstant	OUT_LOW OUT_HALF OUT_FULL
syn keyword	nqcFunction	SetOutput SetDirection SetPower OutputStatus
syn keyword	nqcFunction	On Off Float Fwd Rev Toggle
syn keyword	nqcFunction	OnFwd OnRev OnFor
syn keyword	nqcFunction	SetGlobalOutput SetGlobalDirection SetMaxPower
syn keyword	nqcFunction	GlobalOutputStatus
syn keyword     nqcConstant	SOUND_CLICK SOUND_DOUBLE_BEEP SOUND_DOWN
syn keyword     nqcConstant	SOUND_UP SOUND_LOW_BEEP SOUND_FAST_UP
syn keyword	nqcFunction	PlaySound PlayTone
syn keyword	nqcFunction	MuteSound UnmuteSound ClearSound
syn keyword	nqcFunction	SelectSounds
syn keyword     nqcConstant	DISPLAY_WATCH DISPLAY_SENSOR_1 DISPLAY_SENSOR_2
syn keyword     nqcConstant	DISPLAY_SENSOR_3 DISPLAY_OUT_A DISPLAY_OUT_B
syn keyword     nqcConstant	DISPLAY_OUT_C
syn keyword     nqcConstant	DISPLAY_USER
syn keyword	nqcFunction	SelectDisplay
syn keyword	nqcFunction	SetUserDisplay
syn keyword     nqcConstant	TX_POWER_LO TX_POWER_HI
syn keyword	nqcFunction	Message ClearMessage SendMessage SetTxPower
syn keyword     nqcConstant	SERIAL_COMM_DEFAULT SERIAL_COMM_4800
syn keyword     nqcConstant	SERIAL_COMM_DUTY25 SERIAL_COMM_76KHZ
syn keyword     nqcConstant	SERIAL_PACKET_DEFAULT SERIAL_PACKET_PREAMBLE
syn keyword     nqcConstant	SERIAL_PACKET_NEGATED SERIAL_PACKET_CHECKSUM
syn keyword     nqcConstant	SERIAL_PACKET_RCX
syn keyword	nqcFunction	SetSerialComm SetSerialPacket SetSerialData
syn keyword	nqcFunction	SerialData SendSerial
syn keyword	nqcFunction	SendVLL
syn keyword	nqcFunction	ClearTimer Timer
syn keyword	nqcFunction	SetTimer FastTimer
syn keyword	nqcFunction	ClearCounter IncCounter DecCounter Counter
syn keyword     nqcConstant	ACQUIRE_OUT_A ACQUIRE_OUT_B ACQUIRE_OUT_C
syn keyword     nqcConstant	ACQUIRE_SOUND
syn keyword     nqcConstant	ACQUIRE_USER_1 ACQUIRE_USER_2 ACQUIRE_USER_3
syn keyword     nqcConstant	ACQUIRE_USER_4
syn keyword	nqcFunction	SetPriority
syn keyword     nqcConstant	EVENT_TYPE_PRESSED EVENT_TYPE_RELEASED
syn keyword     nqcConstant	EVENT_TYPE_PULSE EVENT_TYPE_EDGE
syn keyword     nqcConstant	EVENT_TYPE_FAST_CHANGE EVENT_TYPE_LOW
syn keyword     nqcConstant	EVENT_TYPE_NORMAL EVENT_TYPE_HIGH
syn keyword     nqcConstant	EVENT_TYPE_CLICK EVENT_TYPE_DOUBLECLICK
syn keyword     nqcConstant	EVENT_TYPE_MESSAGE
syn keyword     nqcConstant	EVENT_1_PRESSED EVENT_1_RELEASED
syn keyword     nqcConstant	EVENT_2_PRESSED EVENT_2_RELEASED
syn keyword     nqcConstant	EVENT_LIGHT_HIGH EVENT_LIGHT_NORMAL
syn keyword     nqcConstant	EVENT_LIGHT_LOW EVENT_LIGHT_CLICK
syn keyword     nqcConstant	EVENT_LIGHT_DOUBLECLICK EVENT_COUNTER_0
syn keyword     nqcConstant	EVENT_COUNTER_1 EVENT_TIMER_0 EVENT_TIMER_1
syn keyword     nqcConstant	EVENT_TIMER_2 EVENT_MESSAGE
syn keyword	nqcFunction	ActiveEvents Event
syn keyword	nqcFunction	CurrentEvents
syn keyword	nqcFunction	SetEvent ClearEvent ClearAllEvents EventState
syn keyword	nqcFunction	CalibrateEvent SetUpperLimit UpperLimit
syn keyword	nqcFunction	SetLowerLimit LowerLimit SetHysteresis
syn keyword	nqcFunction	Hysteresis
syn keyword	nqcFunction	SetClickTime ClickTime SetClickCounter
syn keyword	nqcFunction	ClickCounter
syn keyword	nqcFunction	SetSensorClickTime SetCounterLimit
syn keyword	nqcFunction	SetTimerLimit
syn keyword	nqcFunction	CreateDatalog AddToDatalog
syn keyword	nqcFunction	UploadDatalog
syn keyword	nqcFunction	Wait StopAllTasks Random
syn keyword	nqcFunction	SetSleepTime SleepNow
syn keyword	nqcFunction	Program Watch SetWatch
syn keyword	nqcFunction	SetRandomSeed SelectProgram
syn keyword	nqcFunction	BatteryLevel FirmwareVersion
syn keyword     nqcConstant	LIGHT_ON LIGHT_OFF
syn keyword	nqcFunction	SetScoutRules ScoutRules SetScoutMode
syn keyword	nqcFunction	SetEventFeedback EventFeedback SetLight
syn keyword     nqcConstant	OUT_L OUT_R OUT_X
syn keyword     nqcConstant	SENSOR_L SENSOR_M SENSOR_R
syn keyword	nqcFunction	Drive OnWait OnWaitDifferent
syn keyword	nqcFunction	ClearTachoCounter TachoCount TachoSpeed
syn keyword	nqcFunction	ExternalMotorRunning AGC
syn keyword	nqcTodo		contained TODO FIXME XXX
syn cluster	nqcCommentGroup	contains=nqcTodo
if exists("nqc_space_errors")
if !exists("nqc_no_trail_space_error")
syn match	nqcSpaceError	display excludenl "\s\+$"
endif
if !exists("nqc_no_tab_space_error")
syn match	nqcSpaceError	display " \+\t"me=e-1
endif
endif
syn cluster	nqcParenGroup	contains=nqcParenError,nqcIncluded,nqcCommentSkip,@nqcCommentGroup,nqcCommentStartError,nqcCommentSkip,nqcCppOut,nqcCppOut2,nqcCppSkip,nqcNumber,nqcFloat,nqcNumbers
if exists("nqc_no_bracket_error")
syn region	nqcParen	transparent start='(' end=')' contains=ALLBUT,@nqcParenGroup,nqcCppParen
syn region	nqcCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@nqcParenGroup,nqcParen
syn match	nqcParenError	display ")"
syn match	nqcErrInParen	display contained "[{}]"
else
syn region	nqcParen		transparent start='(' end=')' contains=ALLBUT,@nqcParenGroup,nqcCppParen,nqcErrInBracket,nqcCppBracket
syn region	nqcCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@nqcParenGroup,nqcErrInBracket,nqcParen,nqcBracket
syn match	nqcParenError	display "[\])]"
syn match	nqcErrInParen	display contained "[\]{}]"
syn region	nqcBracket	transparent start='\[' end=']' contains=ALLBUT,@nqcParenGroup,nqcErrInParen,nqcCppParen,nqcCppBracket
syn region	nqcCppBracket	transparent start='\[' skip='\\$' excludenl end=']' end='$' contained contains=ALLBUT,@nqcParenGroup,nqcErrInParen,nqcParen,nqcBracket
syn match	nqcErrInBracket	display contained "[);{}]"
endif
syn case ignore
syn match	nqcNumbers	display transparent "\<\d\|\.\d" contains=nqcNumber,nqcFloat
syn match	nqcNumber	display contained "\d\+\(u\=l\{0,2}\|ll\=u\)\>"
syn match	nqcNumber	display contained "0x\x\+\(u\=l\{0,2}\|ll\=u\)\>"
syn match	nqcFloat	display contained "\d\+f"
syn match	nqcFloat	display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\="
syn match	nqcFloat	display contained "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match	nqcFloat	display contained "\d\+e[-+]\=\d\+[fl]\=\>"
syn case match
syn region	nqcCommentL	start="//" skip="\\$" end="$" keepend contains=@nqcCommentGroup,nqcSpaceError
syn region	nqcComment	matchgroup=nqcCommentStart start="/\*" matchgroup=NONE end="\*/" contains=@nqcCommentGroup,nqcCommentStartError,nqcSpaceError
syntax match	nqcCommentError	display "\*/"
syntax match	nqcCommentStartError display "/\*" contained
syn region	nqcPreCondit	start="^\s*#\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$" end="//"me=s-1 contains=nqcComment,nqcCharacter,nqcCppParen,nqcParenError,nqcNumbers,nqcCommentError,nqcSpaceError
syn match	nqcPreCondit	display "^\s*#\s*\(else\|endif\)\>"
if !exists("nqc_no_if0")
syn region	nqcCppOut		start="^\s*#\s*if\s\+0\>" end=".\|$" contains=nqcCppOut2
syn region	nqcCppOut2	contained start="0" end="^\s*#\s*\(endif\>\|else\>\|elif\>\)" contains=nqcSpaceError,nqcCppSkip
syn region	nqcCppSkip	contained start="^\s*#\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*#\s*endif\>" contains=nqcSpaceError,nqcCppSkip
endif
syn region	nqcIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	nqcInclude	display "^\s*#\s*include\>\s*["]" contains=nqcIncluded
syn cluster	nqcPreProcGroup	contains=nqcPreCondit,nqcIncluded,nqcInclude,nqcDefine,nqcErrInParen,nqcErrInBracket,nqcCppOut,nqcCppOut2,nqcCppSkip,nqcNumber,nqcFloat,nqcNumbers,nqcCommentSkip,@nqcCommentGroup,nqcCommentStartError,nqcParen,nqcBracket
syn region	nqcDefine	start="^\s*#\s*\(define\|undef\)\>" skip="\\$" end="$" contains=ALLBUT,@nqcPreProcGroup
syn region	nqcPreProc	start="^\s*#\s*\(pragma\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@nqcPreProcGroup
if !exists("nqc_minlines")
if !exists("nqc_no_if0")
let nqc_minlines = 50	    " #if 0 constructs can be long
else
let nqc_minlines = 15	    " mostly for () constructs
endif
endif
exec "syn sync ccomment nqcComment minlines=" . nqc_minlines
hi def link nqcLabel		Label
hi def link nqcConditional		Conditional
hi def link nqcRepeat		Repeat
hi def link nqcCharacter		Character
hi def link nqcNumber		Number
hi def link nqcFloat		Float
hi def link nqcFunction		Function
hi def link nqcParenError		nqcError
hi def link nqcErrInParen		nqcError
hi def link nqcErrInBracket	nqcError
hi def link nqcCommentL		nqcComment
hi def link nqcCommentStart	nqcComment
hi def link nqcCommentError	nqcError
hi def link nqcCommentStartError	nqcError
hi def link nqcSpaceError		nqcError
hi def link nqcStorageClass	StorageClass
hi def link nqcInclude		Include
hi def link nqcPreProc		PreProc
hi def link nqcDefine		Macro
hi def link nqcIncluded		String
hi def link nqcError		Error
hi def link nqcStatement		Statement
hi def link nqcEvents		Statement
hi def link nqcPreCondit		PreCondit
hi def link nqcType		Type
hi def link nqcConstant		Constant
hi def link nqcCommentSkip		nqcComment
hi def link nqcComment		Comment
hi def link nqcTodo		Todo
hi def link nqcCppSkip		nqcCppOut
hi def link nqcCppOut2		nqcCppOut
hi def link nqcCppOut		Comment
let b:current_syntax = "nqc"
