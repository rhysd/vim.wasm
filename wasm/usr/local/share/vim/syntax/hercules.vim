if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword   herculesType	  header assign_property alias assign
syn keyword   herculesType	  options preprocess_options
syn keyword   herculesType	  explode_options technology_options
syn keyword   herculesType	  drc_options database_options
syn keyword   herculesType	  text_options lpe_options evaccess_options
syn keyword   herculesType	  check_point compare_group environment
syn keyword   herculesType	  grid_check include layer_stats load_group
syn keyword   herculesType	  restart run_only self_intersect set snap
syn keyword   herculesType	  system variable waiver
syn keyword   herculesStatement   attach_property boolean cell_extent
syn keyword   herculesStatement   common_hierarchy connection_points
syn keyword   herculesStatement   copy data_filter alternate delete
syn keyword   herculesStatement   explode explode_all fill_pattern find_net
syn keyword   herculesStatement   flatten
syn keyword   herculesStatement   level negate polygon_features push
syn keyword   herculesStatement   rectangles relocate remove_overlap reverse select
syn keyword   herculesStatement   select_cell select_contains select_edge select_net size
syn keyword   herculesStatement   text_polygon text_property vertex area cut
syn keyword   herculesStatement   density enclose external inside_edge
syn keyword   herculesStatement   internal notch vectorize center_to_center
syn keyword   herculesStatement   length mask_align moscheck rescheck
syn keyword   herculesStatement   analysis buildsub init_lpe_db capacitor
syn keyword   herculesStatement   device gendev nmos pmos diode npn pnp
syn keyword   herculesStatement   resistor set_param save_property
syn keyword   herculesStatement   connect disconnect text  text_boolean
syn keyword   herculesStatement   replace_text create_ports label graphics
syn keyword   herculesStatement   save_netlist_database lpe_stats netlist
syn keyword   herculesStatement   spice graphics_property graphics_netlist
syn keyword   herculesStatement   write_milkyway multi_rule_enclose
syn keyword   herculesStatement   if error_property equate compare
syn keyword   herculesStatement   antenna_fix c_thru dev_connect_check
syn keyword   herculesStatement   dev_net_count device_count net_filter
syn keyword   herculesStatement   net_path_check ratio process_text_opens
syn keyword   herculesStatement   black_box_file block compare_dir equivalence
syn keyword   herculesStatement   format gdsin_dir group_dir group_dir_usage
syn keyword   herculesStatement   inlib layout_path outlib output_format
syn keyword   herculesStatement   output_layout_path schematic schematic_format
syn keyword   herculesStatement   scheme_file output_block else
syn keyword   herculesStatement   and or not xor andoverlap inside outside by to
syn keyword   herculesStatement   with connected connected_all texted_with texted
syn keyword   herculesStatement   by_property cutting edge_touch enclosing inside
syn keyword   herculesStatement   inside_hole interact touching vertex
syn region    herculesComment		start="/\*" skip="/\*" end="\*/" contains=herculesTodo
syn match     herculesComment		"//.*" contains=herculesTodo
syn match     herculesPreProc "^#.*"
syn match     herculesPreProc "^@.*"
syn match     herculesPreProc "macros"
syn match     herculesCmdCmnt "comment.*=.*"
syn match     herculesNumber	      "-\=\<[0-9]\+L\=\>\|0[xX][0-9]\+\>"
syn region    herculesZone       matchgroup=Delimiter start="(" matchgroup=Delimiter end=")" transparent contains=ALLBUT,herculesError,herculesBraceError,herculesCurlyError
syn region    herculesZone       matchgroup=Delimiter start="{" matchgroup=Delimiter end="}" transparent contains=ALLBUT,herculesError,herculesBraceError,herculesParenError
syn region    herculesZone       matchgroup=Delimiter start="\[" matchgroup=Delimiter end="]" transparent contains=ALLBUT,herculesError,herculesCurlyError,herculesParenError
syn match     herculesError      "[)\]}]"
syn match     herculesBraceError "[)}]"  contained
syn match     herculesCurlyError "[)\]]" contained
syn match     herculesParenError "[\]}]" contained
syn match     herculesOutput "perm\s*=.*(.*)"
syn match     herculesOutput "temp\s*=\s*"
syn match     herculesOutput "error\s*=\s*(.*)"
syn sync      lines=100
hi def link herculesStatement  Statement
hi def link herculesType       Type
hi def link herculesComment    Comment
hi def link herculesPreProc    PreProc
hi def link herculesTodo       Todo
hi def link herculesOutput     Include
hi def link herculesCmdCmnt    Identifier
hi def link herculesNumber     Number
hi def link herculesBraceError herculesError
hi def link herculesCurlyError herculesError
hi def link herculesParenError herculesError
hi def link herculesError      Error
let b:current_syntax = "hercules"
