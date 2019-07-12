if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn cluster	lpcKeywdGrp	contains=lpcConditional,lpcLabel,lpcOperator,lpcRepeat,lpcStatement,lpcModifier,lpcReserved
syn keyword	lpcConditional	if else switch
syn keyword	lpcLabel	case default
syn keyword	lpcOperator	catch efun in inherit
syn keyword	lpcRepeat	do for foreach while
syn keyword	lpcStatement	break continue return
syn match	lpcEfunError	/efun[^:]/ display
syn keyword	lpcKeywdError	contained if for foreach return switch while
syn keyword	lpcKeywdFunc	new parse_command sscanf time_expression
syn keyword	lpcType		void mixed unknown
syn keyword	lpcType		int float string
syn keyword	lpcType		array buffer class function mapping object
if exists("lpc_compat_32")
syn keyword     lpcType	    closure status funcall
else
syn keyword     lpcError	    closure status
syn keyword     lpcType	    multiset
endif
syn keyword	lpcModifier	nomask private public
syn keyword	lpcModifier	varargs virtual
if exists("lpc_pre_v22")
syn keyword	lpcReserved	nosave protected ref
syn keyword	lpcModifier	static
else
syn keyword	lpcError	static
syn keyword	lpcModifier	nosave protected ref
endif
syn match	lpcApplyDecl	excludenl /->\h\w*(/me=e-1 contains=lpcApplies transparent display
syn match	lpcLongDecl	excludenl /\(\s\|\*\)\h\+\s\h\+(/me=e-1 contains=@lpcEfunGroup,lpcType,@lpcKeywdGrp transparent display
syn match	lpcFuncDecl	excludenl /\h\w*(/me=e-1 contains=lpcApplies,@lpcEfunGroup,lpcKeywdError transparent display
syn match	lpcFuncName	/(:\s*\h\+\s*:)/me=e-1 contains=lpcApplies,@lpcEfunGroup transparent display contained
syn match	lpcFuncName	/(:\s*\h\+,/ contains=lpcApplies,@lpcEfunGroup transparent display contained
syn match	lpcFuncName	/\$(\h\+)/ contains=lpcApplies,@lpcEfunGroup transparent display contained
syn keyword     lpcApplies      contained __INIT clean_up create destructor heart_beat id init move_or_destruct reset
syn keyword     lpcApplies      contained catch_tell logon net_dead process_input receive_message receive_snoop telnet_suboption terminal_type window_size write_prompt
syn keyword     lpcApplies      contained author_file compile_object connect crash creator_file domain_file epilog error_handler flag get_bb_uid get_root_uid get_save_file_name log_error make_path_absolute object_name preload privs_file retrieve_ed_setup save_ed_setup slow_shutdown
syn keyword     lpcApplies      contained valid_asm valid_bind valid_compile_to_c valid_database valid_hide valid_link valid_object valid_override valid_read valid_save_binary valid_seteuid valid_shadow valid_socket valid_write
syn keyword     lpcApplies      contained inventory_accessible inventory_visible is_living parse_command_adjectiv_id_list parse_command_adjective_id_list parse_command_all_word parse_command_id_list parse_command_plural_id_list parse_command_prepos_list parse_command_users parse_get_environment parse_get_first_inventory parse_get_next_inventory parser_error_message
syn cluster	lpcEfunGroup	contains=lpc_efuns,lpcOldEfuns,lpcNewEfuns,lpcKeywdFunc
if exists("lpc_compat_32")
syn keyword lpc_efuns	contained closurep heart_beat_info m_delete m_values m_indices query_once_interactive strstr
else
syn match   lpcErrFunc	/#`\h\w*/
syn region	lpcCommentFunc	start=/^#!/ end=/$/
endif
syn keyword     lpcOldEfuns     contained tail dump_socket_status
syn keyword     lpcNewEfuns     contained socket_status
syn keyword     lpc_efuns       contained acos add_action all_inventory all_previous_objects allocate allocate_buffer allocate_mapping apply arrayp asin atan author_stats
syn keyword     lpc_efuns       contained bind break_string bufferp
syn keyword     lpc_efuns       contained cache_stats call_other call_out call_out_info call_stack capitalize catch ceil check_memory children classp clear_bit clone_object clonep command commands copy cos cp crc32 crypt ctime
syn keyword     lpc_efuns       contained db_close db_commit db_connect db_exec db_fetch db_rollback db_status debug_info debugmalloc debug_message deep_inherit_list deep_inventory destruct disable_commands disable_wizard domain_stats dumpallobj dump_file_descriptors dump_prog
syn keyword     lpc_efuns       contained each ed ed_cmd ed_start enable_commands enable_wizard environment error errorp eval_cost evaluate exec exp explode export_uid external_start
syn keyword     lpc_efuns       contained fetch_variable file_length file_name file_size filter filter_array filter_mapping find_call_out find_living find_object find_player first_inventory floatp floor flush_messages function_exists function_owner function_profile functionp functions
syn keyword     lpc_efuns       contained generate_source get_char get_config get_dir geteuid getuid
syn keyword     lpc_efuns       contained heart_beats
syn keyword     lpc_efuns       contained id_matrix implode in_edit in_input inherit_list inherits input_to interactive intp
syn keyword     lpc_efuns       contained keys
syn keyword     lpc_efuns       contained link living livings load_object localtime log log10 lookat_rotate lower_case lpc_info
syn keyword     lpc_efuns       contained malloc_check malloc_debug malloc_status map map_array map_delete map_mapping mapp master match_path max_eval_cost member_array memory_info memory_summary message mkdir moncontrol move_object mud_status
syn keyword     lpc_efuns       contained named_livings network_stats next_bit next_inventory notify_fail nullp
syn keyword     lpc_efuns       contained objectp objects oldcrypt opcprof origin
syn keyword     lpc_efuns       contained parse_add_rule parse_add_synonym parse_command parse_dump parse_init parse_my_rules parse_refresh parse_remove parse_sentence pluralize pointerp pow present previous_object printf process_string process_value program_info
syn keyword     lpc_efuns       contained query_ed_mode query_heart_beat query_host_name query_idle query_ip_name query_ip_number query_ip_port query_load_average query_notify_fail query_privs query_replaced_program query_shadowing query_snoop query_snooping query_verb
syn keyword     lpc_efuns       contained random read_buffer read_bytes read_file receive reclaim_objects refs regexp reg_assoc reload_object remove_action remove_call_out remove_interactive remove_shadow rename repeat_string replace_program replace_string replaceable reset_eval_cost resolve restore_object restore_variable rm rmdir rotate_x rotate_y rotate_z rusage
syn keyword     lpc_efuns       contained save_object save_variable say scale set_author set_bit set_eval_limit set_heart_beat set_hide set_light set_living_name set_malloc_mask set_privs set_reset set_this_player set_this_user seteuid shadow shallow_inherit_list shout shutdown sin sizeof snoop socket_accept socket_acquire socket_address socket_bind socket_close socket_connect socket_create socket_error socket_listen socket_release socket_write sort_array sprintf sqrt stat store_variable strcmp stringp strlen strsrch
syn keyword     lpc_efuns       contained tan tell_object tell_room terminal_colour test_bit this_interactive this_object this_player this_user throw time to_float to_int trace traceprefix translate typeof
syn keyword     lpc_efuns       contained undefinedp unique_array unique_mapping upper_case uptime userp users
syn keyword     lpc_efuns       contained values variables virtualp
syn keyword     lpc_efuns       contained wizardp write write_buffer write_bytes write_file
syn keyword     lpcConstant     __ARCH__ __COMPILER__ __DIR__ __FILE__ __OPTIMIZATION__ __PORT__ __VERSION__
syn keyword     lpcConstant     __SAVE_EXTENSION__ __HEARTBEAT_INTERVAL__
syn keyword     lpcConstant     HAS_ED HAS_PRINTF HAS_RUSAGE HAS_DEBUG_LEVEL
syn keyword     lpcConstant     MUD_NAME F__THIS_OBJECT
syn match	lpcSpecial	display contained "\\\(x\x\+\|\o\{1,3}\|.\|$\)"
if !exists("c_no_utf")
syn match	lpcSpecial	display contained "\\\(u\x\{4}\|U\x\{8}\)"
endif
syn match	lpcFormat	display "%\(\d\+\)\=[-+ |=#@:.]*\(\d\+\)\=\('\I\+'\|'\I*\\'\I*'\)\=[OsdicoxXf]" contained
syn match	lpcFormat	display "%%" contained
syn region	lpcString	start=+L\="+ skip=+\\\\\|\\"+ end=+"+ contains=lpcSpecial,lpcFormat
syn region	lpcCppString	start=+L\="+ skip=+\\\\\|\\"\|\\$+ excludenl end=+"+ end='$' contains=lpcSpecial,lpcFormat
syn region	lpcTextString	start=/@\z(\h\w*\)$/ end=/^\z1/ contains=lpcSpecial
syn region	lpcArrayString	start=/@@\z(\h\w*\)$/ end=/^\z1/ contains=lpcSpecial
syn match	lpcCharacter	"L\='[^\\]'"
syn match	lpcCharacter	"L'[^']*'" contains=lpcSpecial
syn match	lpcSpecialError	"L\='\\[^'\"?\\abefnrtv]'"
syn match	lpcSpecialCharacter "L\='\\['\"?\\abefnrtv]'"
syn match	lpcSpecialCharacter display "L\='\\\o\{1,3}'"
syn match	lpcSpecialCharacter display "'\\x\x\{1,2}'"
syn match	lpcSpecialCharacter display "L'\\x\x\+'"
if exists("c_space_errors")
if !exists("c_no_trail_space_error")
syn match	lpcSpaceError	display excludenl "\s\+$"
endif
if !exists("c_no_tab_space_error")
syn match	lpcSpaceError	display " \+\t"me=e-1
endif
endif
syn cluster	lpcParenGroup	contains=lpcParenError,lpcIncluded,lpcSpecial,lpcCommentSkip,lpcCommentString,lpcComment2String,@lpcCommentGroup,lpcCommentStartError,lpcUserCont,lpcUserLabel,lpcBitField,lpcCommentSkip,lpcOctalZero,lpcCppOut,lpcCppOut2,lpcCppSkip,lpcFormat,lpcNumber,lpcFloat,lpcOctal,lpcOctalError,lpcNumbersCom
syn region	lpcParen	transparent start='(' end=')' contains=ALLBUT,@lpcParenGroup,lpcCppParen,lpcErrInBracket,lpcCppBracket,lpcCppString,@lpcEfunGroup,lpcApplies,lpcKeywdError
syn region	lpcCppParen	transparent start='(' skip='\\$' excludenl end=')' end='$' contained contains=ALLBUT,@lpcParenGroup,lpcErrInBracket,lpcParen,lpcBracket,lpcString,@lpcEfunGroup,lpcApplies,lpcKeywdError
syn match	lpcParenError	display ")"
syn match	lpcParenError	display "\]"
syn match	lpcErrInParen	display contained "[^^]{"ms=s+1
syn match	lpcErrInParen	display contained "\(}\|\]\)[^)]"me=e-1
syn region	lpcBracket	transparent start='\[' end=']' contains=ALLBUT,@lpcParenGroup,lpcErrInParen,lpcCppParen,lpcCppBracket,lpcCppString,@lpcEfunGroup,lpcApplies,lpcFuncName,lpcKeywdError
syn region	lpcCppBracket	transparent start='\[' skip='\\$' excludenl end=']' end='$' contained contains=ALLBUT,@lpcParenGroup,lpcErrInParen,lpcParen,lpcBracket,lpcString,@lpcEfunGroup,lpcApplies,lpcFuncName,lpcKeywdError
syn match	lpcErrInBracket	display contained "[);{}]"
syn case ignore
syn match	lpcNumbers	display transparent "\<\d\|\.\d" contains=lpcNumber,lpcFloat,lpcOctalError,lpcOctal
syn match	lpcNumbersCom	display contained transparent "\<\d\|\.\d" contains=lpcNumber,lpcFloat,lpcOctal
syn match	lpcNumber	display contained "\d\+\(u\=l\{0,2}\|ll\=u\)\>"
syn match	lpcNumber	display contained "0x\x\+\(u\=l\{0,2}\|ll\=u\)\>"
syn match	lpcOctal	display contained "0\o\+\(u\=l\{0,2}\|ll\=u\)\>" contains=lpcOctalZero
syn match	lpcOctalZero	display contained "\<0"
syn match	lpcFloat	display contained "\d\+f"
syn match	lpcFloat	display contained "\d\+\.\d*\(e[-+]\=\d\+\)\=[fl]\="
syn match	lpcFloat	display contained "\.\d\+\(e[-+]\=\d\+\)\=[fl]\=\>"
syn match	lpcFloat	display contained "\d\+e[-+]\=\d\+[fl]\=\>"
syn match	lpcOctalError	display contained "0\o*[89]\d*"
syn case match
syn keyword	lpcTodo		contained TODO FIXME XXX
syn cluster	lpcCommentGroup	contains=lpcTodo
if exists("c_comment_strings")
syntax match	lpcCommentSkip	contained "^\s*\*\($\|\s\+\)"
syntax region lpcCommentString	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end=+\*/+me=s-1 contains=lpcSpecial,lpcCommentSkip
syntax region lpcComment2String	contained start=+L\=\\\@<!"+ skip=+\\\\\|\\"+ end=+"+ end="$" contains=lpcSpecial
syntax region  lpcCommentL	start="//" skip="\\$" end="$" keepend contains=@lpcCommentGroup,lpcComment2String,lpcCharacter,lpcNumbersCom,lpcSpaceError
syntax region lpcComment	matchgroup=lpcCommentStart start="/\*" matchgroup=NONE end="\*/" contains=@lpcCommentGroup,lpcCommentStartError,lpcCommentString,lpcCharacter,lpcNumbersCom,lpcSpaceError
else
syn region	lpcCommentL	start="//" skip="\\$" end="$" keepend contains=@lpcCommentGroup,lpcSpaceError
syn region	lpcComment	matchgroup=lpcCommentStart start="/\*" matchgroup=NONE end="\*/" contains=@lpcCommentGroup,lpcCommentStartError,lpcSpaceError
endif
syntax match	lpcCommentError	display "\*/"
syntax match	lpcCommentStartError display "/\*"me=e-1 contained
syn region	lpcPreCondit	start="^\s*#\s*\(if\|ifdef\|ifndef\|elif\)\>" skip="\\$" end="$" end="//"me=s-1 contains=lpcComment,lpcCppString,lpcCharacter,lpcCppParen,lpcParenError,lpcNumbers,lpcCommentError,lpcSpaceError
syn match	lpcPreCondit	display "^\s*#\s*\(else\|endif\)\>"
if !exists("c_no_if0")
syn region	lpcCppOut		start="^\s*#\s*if\s\+0\+\>" end=".\|$" contains=lpcCppOut2
syn region	lpcCppOut2	contained start="0" end="^\s*#\s*\(endif\>\|else\>\|elif\>\)" contains=lpcSpaceError,lpcCppSkip
syn region	lpcCppSkip	contained start="^\s*#\s*\(if\>\|ifdef\>\|ifndef\>\)" skip="\\$" end="^\s*#\s*endif\>" contains=lpcSpaceError,lpcCppSkip
endif
syn region	lpcIncluded	display contained start=+"+ skip=+\\\\\|\\"+ end=+"+
syn match	lpcIncluded	display contained "<[^>]*>"
syn match	lpcInclude	display "^\s*#\s*include\>\s*["<]" contains=lpcIncluded
syn match lpcLineSkip	"\\$"
syn cluster	lpcPreProcGroup	contains=lpcPreCondit,lpcIncluded,lpcInclude,lpcDefine,lpcErrInParen,lpcErrInBracket,lpcUserLabel,lpcSpecial,lpcOctalZero,lpcCppOut,lpcCppOut2,lpcCppSkip,lpcFormat,lpcNumber,lpcFloat,lpcOctal,lpcOctalError,lpcNumbersCom,lpcString,lpcCommentSkip,lpcCommentString,lpcComment2String,@lpcCommentGroup,lpcCommentStartError,lpcParen,lpcBracket,lpcMulti,lpcKeywdError
syn region	lpcDefine	start="^\s*#\s*\(define\|undef\)\>" skip="\\$" end="$" end="//"me=s-1 contains=ALLBUT,@lpcPreProcGroup
if exists("lpc_pre_v22")
syn region	lpcPreProc	start="^\s*#\s*\(pragma\>\|echo\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@lpcPreProcGroup
else
syn region	lpcPreProc	start="^\s*#\s*\(pragma\>\|echo\>\|warn\>\|error\>\)" skip="\\$" end="$" keepend contains=ALLBUT,@lpcPreProcGroup
endif
syn cluster	lpcMultiGroup	contains=lpcIncluded,lpcSpecial,lpcCommentSkip,lpcCommentString,lpcComment2String,@lpcCommentGroup,lpcCommentStartError,lpcUserCont,lpcUserLabel,lpcBitField,lpcOctalZero,lpcCppOut,lpcCppOut2,lpcCppSkip,lpcFormat,lpcNumber,lpcFloat,lpcOctal,lpcOctalError,lpcNumbersCom,lpcCppParen,lpcCppBracket,lpcCppString,lpcKeywdError
syn region	lpcMulti		transparent start='\(case\|default\|public\|protected\|private\)' skip='::' end=':' contains=ALLBUT,@lpcMultiGroup
syn cluster	lpcLabelGroup	contains=lpcUserLabel
syn match	lpcUserCont	display "^\s*lpc:$" contains=@lpcLabelGroup
syn match	lpcUserLabel	display "lpc" contained
if exists("c_minlines")
let b:c_minlines = c_minlines
else
if !exists("c_no_if0")
let b:c_minlines = 50	" #if 0 constructs can be long
else
let b:c_minlines = 15	" mostly for () constructs
endif
endif
exec "syn sync ccomment lpcComment minlines=" . b:c_minlines
setlocal cindent
setlocal fo-=t fo+=croql
setlocal comments=sO:*\ -,mO:*\ \ ,exO:*/,s1:/*,mb:*,ex:*/,://
if has("gui_win32") && !exists("b:browsefilter")
let b:browsefilter = "LPC Source Files (*.c *.d *.h)\t*.c;*.d;*.h\n" .
\ "LPC Data Files (*.scr *.o *.dat)\t*.scr;*.o;*.dat\n" .
\ "Text Documentation (*.txt)\t*.txt\n" .
\ "All Files (*.*)\t*.*\n"
endif
hi def link lpcModifier		lpcStorageClass
hi def link lpcQuotedFmt		lpcFormat
hi def link lpcFormat		lpcSpecial
hi def link lpcCppString		lpcString	" Cpp means
hi def link lpcCommentL		lpcComment
hi def link lpcCommentStart	lpcComment
hi def link lpcUserLabel		lpcLabel
hi def link lpcSpecialCharacter	lpcSpecial
hi def link lpcOctal		lpcPreProc
hi def link lpcOctalZero		lpcSpecial  " LPC will treat octal numbers
hi def link lpcEfunError		lpcError
hi def link lpcKeywdError		lpcError
hi def link lpcOctalError		lpcError
hi def link lpcParenError		lpcError
hi def link lpcErrInParen		lpcError
hi def link lpcErrInBracket	lpcError
hi def link lpcCommentError	lpcError
hi def link lpcCommentStartError	lpcError
hi def link lpcSpaceError		lpcError
hi def link lpcSpecialError	lpcError
hi def link lpcErrFunc		lpcError
if exists("lpc_pre_v22")
hi def link lpcOldEfuns	lpc_efuns
hi def link lpcNewEfuns	lpcError
else
hi def link lpcOldEfuns	lpcReserved
hi def link lpcNewEfuns	lpc_efuns
endif
hi def link lpc_efuns		lpcFunction
hi def link lpcReserved		lpcPreProc
hi def link lpcTextString		lpcString   " This should be preprocessors, but
hi def link lpcArrayString		lpcPreProc  " let's make some difference
hi def link lpcIncluded		lpcString
hi def link lpcCommentString	lpcString
hi def link lpcComment2String	lpcString
hi def link lpcCommentSkip		lpcComment
hi def link lpcCommentFunc		lpcComment
hi def link lpcCppSkip		lpcCppOut
hi def link lpcCppOut2		lpcCppOut
hi def link lpcCppOut		lpcComment
hi def link lpcApplies		Special
hi def link lpcCharacter		Character
hi def link lpcComment		Comment
hi def link lpcConditional		Conditional
hi def link lpcConstant		Constant
hi def link lpcDefine		Macro
hi def link lpcError		Error
hi def link lpcFloat		Float
hi def link lpcFunction		Function
hi def link lpcIdentifier		Identifier
hi def link lpcInclude		Include
hi def link lpcLabel		Label
hi def link lpcNumber		Number
hi def link lpcOperator		Operator
hi def link lpcPreCondit		PreCondit
hi def link lpcPreProc		PreProc
hi def link lpcRepeat		Repeat
hi def link lpcStatement		Statement
hi def link lpcStorageClass	StorageClass
hi def link lpcString		String
hi def link lpcStructure		Structure
hi def link lpcSpecial		LineNr
hi def link lpcTodo		Todo
hi def link lpcType		Type
let b:current_syntax = "lpc"
let &cpo = s:cpo_save
unlet s:cpo_save
