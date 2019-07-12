if version < 700
finish
endif 
let s:keepcpo= &cpo
set cpo&vim
let g:ada#DotWordRegex	   = '\a\w*\(\_s*\.\_s*\a\w*\)*'
let g:ada#WordRegex	   = '\a\w*'
let g:ada#Comment	   = "\\v^(\"[^\"]*\"|'.'|[^\"']){-}\\zs\\s*--.*"
let g:ada#Keywords	   = []
for Item in ['abort', 'else', 'new', 'return', 'abs', 'elsif', 'not', 'reverse', 'abstract', 'end', 'null', 'accept', 'entry', 'select', 'access', 'exception', 'of', 'separate', 'aliased', 'exit', 'or', 'subtype', 'all', 'others', 'synchronized', 'and', 'for', 'out', 'array', 'function', 'overriding', 'tagged', 'at', 'task', 'generic', 'package', 'terminate', 'begin', 'goto', 'pragma', 'then', 'body', 'private', 'type', 'if', 'procedure', 'case', 'in', 'protected', 'until', 'constant', 'interface', 'use', 'is', 'raise', 'declare', 'range', 'when', 'delay', 'limited', 'record', 'while', 'delta', 'loop', 'rem', 'with', 'digits', 'renames', 'do', 'mod', 'requeue', 'xor']
let g:ada#Keywords += [{
\ 'word':  Item,
\ 'menu':  'keyword',
\ 'info':  'Ada keyword.',
\ 'kind':  'k',
\ 'icase': 1}]
endfor
if exists ('g:ada_with_gnat_project_files')
for Item in ['project']
let g:ada#Keywords += [{
\ 'word':  Item,
\ 'menu':  'keyword',
\ 'info':  'GNAT projectfile keyword.',
\ 'kind':  'k',
\ 'icase': 1}]
endfor
endif
for Item in ['Constraint_Error', 'Program_Error', 'Storage_Error', 'Tasking_Error', 'Status_Error', 'Mode_Error', 'Name_Error', 'Use_Error', 'Device_Error', 'End_Error', 'Data_Error', 'Layout_Error', 'Length_Error', 'Pattern_Error', 'Index_Error', 'Translation_Error', 'Time_Error', 'Argument_Error', 'Tag_Error', 'Picture_Error', 'Terminator_Error', 'Conversion_Error', 'Pointer_Error', 'Dereference_Error', 'Update_Error']
let g:ada#Keywords += [{
\ 'word':  Item,
\ 'menu':  'exception',
\ 'info':  'Ada standart exception.',
\ 'kind':  'x',
\ 'icase': 1}]
endfor
if exists ('g:ada_gnat_extensions')
for Item in ['Assert_Failure']
let g:ada#Keywords += [{
\ 'word':  Item,
\ 'menu':  'exception',
\ 'info':  'GNAT exception.',
\ 'kind':  'x',
\ 'icase': 1}]
endfor
endif
for Item in ['Boolean', 'Integer', 'Natural', 'Positive', 'Float', 'Character', 'Wide_Character', 'Wide_Wide_Character', 'String', 'Wide_String', 'Wide_Wide_String', 'Duration']
let g:ada#Keywords += [{
\ 'word':  Item,
\ 'menu':  'type',
\ 'info':  'Ada buildin type.',
\ 'kind':  't',
\ 'icase': 1}]
endfor
if exists ('g:ada_gnat_extensions')
for Item in ['Short_Integer', 'Short_Short_Integer', 'Long_Integer', 'Long_Long_Integer', 'Short_Float', 'Short_Short_Float', 'Long_Float', 'Long_Long_Float']
let g:ada#Keywords += [{
\ 'word':  Item,
\ 'menu':  'type',
\ 'info':  'GNAT buildin type.',
\ 'kind':  't',
\ 'icase': 1}]
endfor
endif
for Item in ['''Access', '''Address', '''Adjacent', '''Aft', '''Alignment', '''Base', '''Bit_Order', '''Body_Version', '''Callable', '''Caller', '''Ceiling', '''Class', '''Component_Size', '''Compose', '''Constrained', '''Copy_Sign', '''Count', '''Definite', '''Delta', '''Denorm', '''Digits', '''Emax', '''Exponent', '''External_Tag', '''Epsilon', '''First', '''First_Bit', '''Floor', '''Fore', '''Fraction', '''Identity', '''Image', '''Input', '''Large', '''Last', '''Last_Bit', '''Leading_Part', '''Length', '''Machine', '''Machine_Emax', '''Machine_Emin', '''Machine_Mantissa', '''Machine_Overflows', '''Machine_Radix', '''Machine_Rounding', '''Machine_Rounds', '''Mantissa', '''Max', '''Max_Size_In_Storage_Elements', '''Min', '''Mod', '''Model', '''Model_Emin', '''Model_Epsilon', '''Model_Mantissa', '''Model_Small', '''Modulus', '''Output', '''Partition_ID', '''Pos', '''Position', '''Pred', '''Priority', '''Range', '''Read', '''Remainder', '''Round', '''Rounding', '''Safe_Emax', '''Safe_First', '''Safe_Large', '''Safe_Last', '''Safe_Small', '''Scale', '''Scaling', '''Signed_Zeros', '''Size', '''Small', '''Storage_Pool', '''Storage_Size', '''Stream_Size', '''Succ', '''Tag', '''Terminated', '''Truncation', '''Unbiased_Rounding', '''Unchecked_Access', '''Val', '''Valid', '''Value', '''Version', '''Wide_Image', '''Wide_Value', '''Wide_Wide_Image', '''Wide_Wide_Value', '''Wide_Wide_Width', '''Wide_Width', '''Width', '''Write']
let g:ada#Keywords += [{
\ 'word':  Item,
\ 'menu':  'attribute',
\ 'info':  'Ada attribute.',
\ 'kind':  'a',
\ 'icase': 1}]
endfor
if exists ('g:ada_gnat_extensions')
for Item in ['''Abort_Signal', '''Address_Size', '''Asm_Input', '''Asm_Output', '''AST_Entry', '''Bit', '''Bit_Position', '''Code_Address', '''Default_Bit_Order', '''Elaborated', '''Elab_Body', '''Elab_Spec', '''Emax', '''Enum_Rep', '''Epsilon', '''Fixed_Value', '''Has_Access_Values', '''Has_Discriminants', '''Img', '''Integer_Value', '''Machine_Size', '''Max_Interrupt_Priority', '''Max_Priority', '''Maximum_Alignment', '''Mechanism_Code', '''Null_Parameter', '''Object_Size', '''Passed_By_Reference', '''Range_Length', '''Storage_Unit', '''Target_Name', '''Tick', '''To_Address', '''Type_Class', '''UET_Address', '''Unconstrained_Array', '''Universal_Literal_String', '''Unrestricted_Access', '''VADS_Size', '''Value_Size', '''Wchar_T_Size', '''Word_Size']
let g:ada#Keywords += [{
\ 'word':  Item,
\ 'menu':  'attribute',
\ 'info':  'GNAT attribute.',
\ 'kind':  'a',
\ 'icase': 1}]
endfor
endif
for Item in ['All_Calls_Remote', 'Assert', 'Assertion_Policy', 'Asynchronous', 'Atomic', 'Atomic_Components', 'Attach_Handler', 'Controlled', 'Convention', 'Detect_Blocking', 'Discard_Names', 'Elaborate', 'Elaborate_All', 'Elaborate_Body', 'Export', 'Import', 'Inline', 'Inspection_Point', 'Interface (Obsolescent)', 'Interrupt_Handler', 'Interrupt_Priority', 'Linker_Options', 'List', 'Locking_Policy', 'Memory_Size (Obsolescent)', 'No_Return', 'Normalize_Scalars', 'Optimize', 'Pack', 'Page', 'Partition_Elaboration_Policy', 'Preelaborable_Initialization', 'Preelaborate', 'Priority', 'Priority_Specific_Dispatching', 'Profile', 'Pure', 'Queueing_Policy', 'Relative_Deadline', 'Remote_Call_Interface', 'Remote_Types', 'Restrictions', 'Reviewable', 'Shared (Obsolescent)', 'Shared_Passive', 'Storage_Size', 'Storage_Unit (Obsolescent)', 'Suppress', 'System_Name (Obsolescent)', 'Task_Dispatching_Policy', 'Unchecked_Union', 'Unsuppress', 'Volatile', 'Volatile_Components']
let g:ada#Keywords += [{
\ 'word':  Item,
\ 'menu':  'pragma',
\ 'info':  'Ada pragma.',
\ 'kind':  'p',
\ 'icase': 1}]
endfor
if exists ('g:ada_gnat_extensions')
for Item in ['Abort_Defer', 'Ada_83', 'Ada_95', 'Ada_05', 'Annotate', 'Ast_Entry', 'C_Pass_By_Copy', 'Comment', 'Common_Object', 'Compile_Time_Warning', 'Complex_Representation', 'Component_Alignment', 'Convention_Identifier', 'CPP_Class', 'CPP_Constructor', 'CPP_Virtual', 'CPP_Vtable', 'Debug', 'Elaboration_Checks', 'Eliminate', 'Export_Exception', 'Export_Function', 'Export_Object', 'Export_Procedure', 'Export_Value', 'Export_Valued_Procedure', 'Extend_System', 'External', 'External_Name_Casing', 'Finalize_Storage_Only', 'Float_Representation', 'Ident', 'Import_Exception', 'Import_Function', 'Import_Object', 'Import_Procedure', 'Import_Valued_Procedure', 'Initialize_Scalars', 'Inline_Always', 'Inline_Generic', 'Interface_Name', 'Interrupt_State', 'Keep_Names', 'License', 'Link_With', 'Linker_Alias', 'Linker_Section', 'Long_Float', 'Machine_Attribute', 'Main_Storage', 'Obsolescent', 'Passive', 'Polling', 'Profile_Warnings', 'Propagate_Exceptions', 'Psect_Object', 'Pure_Function', 'Restriction_Warnings', 'Source_File_Name', 'Source_File_Name_Project', 'Source_Reference', 'Stream_Convert', 'Style_Checks', 'Subtitle', 'Suppress_All', 'Suppress_Exception_Locations', 'Suppress_Initialization', 'Task_Info', 'Task_Name', 'Task_Storage', 'Thread_Body', 'Time_Slice', 'Title', 'Unimplemented_Unit', 'Universal_Data', 'Unreferenced', 'Unreserve_All_Interrupts', 'Use_VADS_Size', 'Validity_Checks', 'Warnings', 'Weak_External']
let g:ada#Keywords += [{
\ 'word':  Item,
\ 'menu':  'pragma',
\ 'info':  'GNAT pragma.',
\ 'kind':  'p',
\ 'icase': 1}]
endfor
endif
let g:ada#Ctags_Kinds = {
\ 'P': ["packspec",	  "package specifications"],
\ 'p': ["package",	  "packages"],
\ 'T': ["typespec",	  "type specifications"],
\ 't': ["type",	  "types"],
\ 'U': ["subspec",	  "subtype specifications"],
\ 'u': ["subtype",	  "subtypes"],
\ 'c': ["component",   "record type components"],
\ 'l': ["literal",	  "enum type literals"],
\ 'V': ["varspec",	  "variable specifications"],
\ 'v': ["variable",	  "variables"],
\ 'f': ["formal",	  "generic formal parameters"],
\ 'n': ["constant",	  "constants"],
\ 'x': ["exception",   "user defined exceptions"],
\ 'R': ["subprogspec", "subprogram specifications"],
\ 'r': ["subprogram",  "subprograms"],
\ 'K': ["taskspec",	  "task specifications"],
\ 'k': ["task",	  "tasks"],
\ 'O': ["protectspec", "protected data specifications"],
\ 'o': ["protected",   "protected data"],
\ 'E': ["entryspec",   "task/protected data entry specifications"],
\ 'e': ["entry",	  "task/protected data entries"],
\ 'b': ["label",	  "labels"],
\ 'i': ["identifier",  "loop/declare identifiers"],
\ 'a': ["autovar",	  "automatic variables"],
\ 'y': ["annon",	  "loops and blocks with no identifier"]}
function ada#Word (...)
if a:0 > 1
let l:Line_Nr    = a:1
let l:Column_Nr  = a:2 - 1
else
let l:Line_Nr    = line('.')
let l:Column_Nr  = col('.') - 1
endif
let l:Line = substitute (getline (l:Line_Nr), g:ada#Comment, '', '' )
if l:Column_Nr > strlen(l:Line)
let l:Line = getline(l:Line_Nr)
let l:Search_Prev_Lines = 0
else
let l:Search_Prev_Lines = 1
endif
let l:New_Column = l:Column_Nr + 1
while 1
let l:New_Column = l:New_Column - 1
if l:New_Column < 0
let l:Line_Nr = l:Line_Nr - 1
if l:Line_Nr < 1  ||  !l:Search_Prev_Lines
let l:Line_Nr     = 1
let l:New_Column  = 0
let l:Our_Match   = match (l:Line, g:ada#WordRegex )
break
endif
let l:New_Line    = substitute (getline (l:Line_Nr), g:ada#Comment, '', '' )
let l:New_Column  = strlen (l:New_Line) - 1
let l:Column_Nr   = l:Column_Nr + l:New_Column
let l:Line	   = l:New_Line . l:Line
endif
let l:Match_End = l:New_Column +
\ matchend (strpart (l:Line,l:New_Column), g:ada#WordRegex ) - 1
if l:Match_End >= l:New_Column  &&
\ l:Match_End < l:Column_Nr
let l:Our_Match = l:Match_End+1 +
\ match (strpart (l:Line,l:Match_End+1), g:ada#WordRegex )
break
endif
endwhile
if l:Our_Match < 0
return ''
else
let l:Line = strpart (l:Line, l:Our_Match)
endif
let l:Match_String = matchstr (l:Line, g:ada#WordRegex)
let l:Last_Line    = line ('$')
let l:Line_Nr      = line ('.') + 1
while l:Line_Nr <= l:Last_Line
let l:Last_Match = l:Match_String
let l:Line = l:Line .
\ substitute (getline (l:Line_Nr), g:ada#Comment, '', '')
let l:Match_String = matchstr (l:Line, g:ada#WordRegex)
if l:Match_String == l:Last_Match
break
endif
endwhile
return substitute (l:Match_String, '\s\+', '', 'g')
endfunction ada#Word
function ada#List_Tag (...)
if a:0 > 1
let l:Tag_Word = ada#Word (a:1, a:2)
elseif a:0 > 0
let l:Tag_Word = a:1
else
let l:Tag_Word = ada#Word ()
endif
echo "Searching for" l:Tag_Word
let l:Pattern = '^' . l:Tag_Word . '$'
let l:Tag_List = taglist (l:Pattern)
let l:Error_List = []
for Tag_Item in l:Tag_List
if l:Tag_Item['kind'] == ''
let l:Tag_Item['kind'] = 's'
endif
let l:Error_List += [
\ l:Tag_Item['filename'] . '|' .
\ l:Tag_Item['cmd']	  . '|' .
\ l:Tag_Item['kind']	  . "\t" .
\ l:Tag_Item['name'] ]
endfor
set errorformat=%f\|%l\|%m
cexpr l:Error_List
cwindow
endfunction ada#List_Tag
function ada#Jump_Tag (Word, Mode)
if a:Word == ''
let l:Word = ada#Word()
if l:Word == ''
throw "NOT_FOUND: no identifier found."
endif
else
let l:Word = a:Word
endif
echo "Searching for " . l:Word
try
execute a:Mode l:Word
catch /.*:E426:.*/
let ignorecase = &ignorecase
set ignorecase
execute a:Mode l:Word
let &ignorecase = ignorecase
endtry
return
endfunction ada#Jump_Tag
function ada#Insert_Backspace ()
let l:Line = getline ('.')
if col ('.') > strlen (l:Line) &&
\ match (l:Line, '-- $') != -1 &&
\ match (&comments,'--') != -1
return "\<bs>\<bs>\<bs>"
else
return "\<bs>"
endif
return
endfunction ada#InsertBackspace
function! ada#User_Complete(findstart, base)
if a:findstart == 1
let line = getline ('.')
let start = col ('.') - 1
while start > 0 && line[start - 1] =~ '\i\|'''
let start -= 1
endwhile
return start
else
let l:Pattern = '^' . a:base . '.*$'
for Tag_Item in g:ada#Keywords
if l:Tag_Item['word'] =~? l:Pattern
if complete_add (l:Tag_Item) == 0
return []
endif
if complete_check ()
return []
endif
endif
endfor
return []
endif
endfunction ada#User_Complete
function ada#Completion (cmd)
set iskeyword+=46
return a:cmd . "\<C-R>=ada#Completion_End ()\<CR>"
endfunction ada#Completion
function ada#Completion_End ()
set iskeyword-=46
return ''
endfunction ada#Completion_End
function ada#Create_Tags (option)
if a:option == 'file'
let l:Filename = fnamemodify (bufname ('%'), ':p')
elseif a:option == 'dir'
let l:Filename =
\ fnamemodify (bufname ('%'), ':p:h') . "*.ada " .
\ fnamemodify (bufname ('%'), ':p:h') . "*.adb " .
\ fnamemodify (bufname ('%'), ':p:h') . "*.ads"
else
let l:Filename = a:option
endif
execute '!ctags --excmd=number ' . l:Filename
endfunction ada#Create_Tags
function ada#Switch_Session (New_Session)
let l:sessionoptions=&sessionoptions
try
set sessionoptions=buffers,curdir,folds,globals,resize,slash,tabpages,tabpages,unix,winpos,winsize
if a:New_Session != v:this_session
if strlen (v:this_session) > 0
execute 'mksession! ' . v:this_session
endif
let v:this_session = a:New_Session
augroup ada_session
autocmd!
autocmd VimLeavePre * execute 'mksession! ' . v:this_session
augroup END
endif
finally
let &sessionoptions=l:sessionoptions
endtry
return
endfunction ada#Switch_Session	
if exists('g:ada_folding') && g:ada_folding[0] == 'g'
let s:Fold_Collate = '^\([;)]*$\|'
if stridx (g:ada_folding, 'i') >= 0
let s:Fold_Collate .= '\s\+\<is\>$\|'
endif
if stridx (g:ada_folding, 'b') >= 0
let s:Fold_Collate .= '\s\+\<begin\>$\|'
endif
if stridx (g:ada_folding, 'p') >= 0
let s:Fold_Collate .= '\s\+\<private\>$\|'
endif
if stridx (g:ada_folding, 'x') >= 0
let s:Fold_Collate .= '\s\+\<exception\>$\|'
endif
let s:Fold_Collate .= '--\)'
function ada#Pretty_Print_Folding (Line)			     " {{{2
let l:Text = getline (a:Line)
if l:Text =~ s:Fold_Collate
let l:Level = "="
elseif l:Text =~ '^\s\+('
let l:Level = (indent (a:Line) + 1) / &shiftwidth
else
let l:Level = indent (a:Line) / &shiftwidth
endif
return l:Level
endfunction ada#Pretty_Print_Folding				     " }}}2
endif
function ada#Switch_Syntax_Option (option)
syntax off
if exists ('g:ada_' . a:option)
unlet g:ada_{a:option}
echo  a:option . 'now off'
else
let g:ada_{a:option}=1
echo  a:option . 'now on'
endif
syntax on
endfunction ada#Switch_Syntax_Option
function ada#Map_Menu (Text, Keys, Command)
if a:Keys[0] == ':'
execute
\ "50amenu " .
\ "Ada."     . escape(a:Text, ' ') .
\ "<Tab>"    . a:Keys .
\ " :"	     . a:Command . "<CR>"
execute
\ "command -buffer " .
\ a:Keys[1:] .
\" :" . a:Command . "<CR>"
elseif a:Keys[0] == '<'
execute
\ "50amenu " .
\ "Ada."     . escape(a:Text, ' ') .
\ "<Tab>"    . a:Keys .
\ " :"	     . a:Command . "<CR>"
execute
\ "nnoremap <buffer> "	 .
\ a:Keys		 .
\" :" . a:Command . "<CR>"
execute
\ "inoremap <buffer> "	 .
\ a:Keys		 .
\" <C-O>:" . a:Command . "<CR>"
else
if exists("g:mapleader")
let l:leader = g:mapleader
else
let l:leader = '\'
endif
execute
\ "50amenu " .
\ "Ada."  . escape(a:Text, ' ') .
\ "<Tab>" . escape(l:leader . "a" . a:Keys , '\') .
\ " :"	  . a:Command . "<CR>"
execute
\ "nnoremap <buffer>" .
\ " <Leader>a" . a:Keys .
\" :" . a:Command
execute
\ "inoremap <buffer>" .
\ " <Leader>a" . a:Keys .
\" <C-O>:" . a:Command
endif
return
endfunction
function ada#Map_Popup (Text, Keys, Command)
if exists("g:mapleader")
let l:leader = g:mapleader
else
let l:leader = '\'
endif
execute
\ "50amenu " .
\ "PopUp."   . escape(a:Text, ' ') .
\ "<Tab>"	  . escape(l:leader . "a" . a:Keys , '\') .
\ " :"	  . a:Command . "<CR>"
call ada#Map_Menu (a:Text, a:Keys, a:Command)
return
endfunction ada#Map_Popup
lockvar  g:ada#WordRegex
lockvar  g:ada#DotWordRegex
lockvar  g:ada#Comment
lockvar! g:ada#Keywords
lockvar! g:ada#Ctags_Kinds
let &cpo = s:keepcpo
unlet s:keepcpo
finish " 1}}}
