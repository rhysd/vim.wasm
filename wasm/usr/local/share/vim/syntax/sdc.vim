if exists("b:current_syntax")
finish
endif
runtime! syntax/tcl.vim
syn keyword sdcCollections	foreach_in_collection
syn keyword sdcObjectsQuery	get_clocks get_ports
syn keyword sdcObjectsInfo	get_point_info get_node_info get_path_info
syn keyword sdcObjectsInfo	get_timing_paths set_attribute
syn keyword sdcConstraints	set_false_path
syn keyword sdcNonIdealities	set_min_delay set_max_delay
syn keyword sdcNonIdealities	set_input_delay set_output_delay
syn keyword sdcNonIdealities	set_load set_min_capacitance set_max_capacitance
syn keyword sdcCreateOperations	create_clock create_timing_netlist update_timing_netlist
syn match sdcFlags		"[[:space:]]-[[:alpha:]]*\>"
hi def link sdcCollections      Repeat
hi def link sdcObjectsInfo      Operator
hi def link sdcCreateOperations	Operator
hi def link sdcObjectsQuery	Operator
hi def link sdcConstraints	Operator
hi def link sdcNonIdealities	Operator
hi def link sdcFlags		Special
let b:current_syntax = "sdc"
