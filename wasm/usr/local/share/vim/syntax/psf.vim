if exists("b:current_syntax")
finish
endif
syn case match
syn keyword psfObject bundle category control_file depot distribution
syn keyword psfObject end file fileset host installed_software media
syn keyword psfObject product root subproduct vendor
syn match  psfUnquotString +[^"# 	][^#]*+ contained
syn region psfQuotString   start=+"+ skip=+\\"+ end=+"+ contained
syn match  psfObjTag    "\<[-_+A-Z0-9a-z]\+\(\.[-_+A-Z0-9a-z]\+\)*" contained
syn match  psfAttAbbrev ",\<\(fa\|fr\|[aclqrv]\)\(<\|>\|<=\|>=\|=\|==\)[^,]\+" contained
syn match  psfObjTags   "\<[-_+A-Z0-9a-z]\+\(\.[-_+A-Z0-9a-z]\+\)*\(\s\+\<[-_+A-Z0-9a-z]\+\(\.[-_+A-Z0-9a-z]\+\)*\)*" contained
syn match  psfNumber    "\<\d\+\>" contained
syn match  psfFloat     "\<\d\+\>\(\.\<\d\+\>\)*" contained
syn match  psfLongDate  "\<\d\d\d\d\d\d\d\d\d\d\d\d\.\d\d\>" contained
syn keyword psfState    available configured corrupt installed transient contained
syn keyword psfPState   applied committed superseded contained
syn keyword psfBoolean  false true contained
syn region psfAttUnquotString matchgroup=psfAttrib start=~^\s*[^# 	]\+\s\+[^#" 	]~rs=e-1 contains=psfUnquotString,psfComment end=~$~ keepend oneline
syn region psfAttQuotString matchgroup=psfAttrib start=~^\s*[^# 	]\+\s\+"~rs=e-1 contains=psfQuotString,psfComment skip=~\\"~ matchgroup=psfQuotString end=~"~ keepend
syn region psfAttTag matchgroup=psfAttrib start="^\s*tag\s\+" contains=psfObjTag,psfComment end="$" keepend oneline
syn region psfAttSpec matchgroup=psfAttrib start="^\s*\(ancestor\|applied_patches\|applied_to\|contents\|corequisites\|exrequisites\|prerequisites\|software_spec\|supersedes\|superseded_by\)\s\+" contains=psfObjTag,psfAttAbbrev,psfComment end="$" keepend
syn region psfAttTags matchgroup=psfAttrib start="^\s*all_filesets\s\+" contains=psfObjTags,psfComment end="$" keepend
syn region psfAttNumber matchgroup=psfAttrib start="^\s*\(compressed_size\|instance_id\|media_sequence_number\|sequence_number\|size\)\s\+" contains=psfNumber,psfComment end="$" keepend oneline
syn region psfAttTime matchgroup=psfAttrib start="^\s*\(create_time\|ctime\|mod_time\|mtime\|timestamp\)\s\+" contains=psfNumber,psfComment end="$" keepend oneline
syn region psfAttFloat matchgroup=psfAttrib start="^\s*\(data_model_revision\|layout_version\)\s\+" contains=psfFloat,psfComment end="$" keepend oneline
syn region psfAttLongDate matchgroup=psfAttrib start="^\s*install_date\s\+" contains=psfLongDate,psfComment end="$" keepend oneline
syn region psfAttState matchgroup=psfAttrib start="^\s*\(state\)\s\+" contains=psfState,psfComment end="$" keepend oneline
syn region psfAttPState matchgroup=psfAttrib start="^\s*\(patch_state\)\s\+" contains=psfPState,psfComment end="$" keepend oneline
syn region psfAttBoolean matchgroup=psfAttrib start="^\s*\(is_kernel\|is_locatable\|is_patch\|is_protected\|is_reboot\|is_reference\|is_secure\|is_sparse\)\s\+" contains=psfBoolean,psfComment end="$" keepend oneline
syn match  psfComment "#.*$"
hi def link psfObject       Statement
hi def link psfAttrib       Type
hi def link psfQuotString   String
hi def link psfObjTag       Identifier
hi def link psfAttAbbrev    PreProc
hi def link psfObjTags      Identifier
hi def link psfComment      Comment
syn sync lines=100
let b:current_syntax = "psf"
