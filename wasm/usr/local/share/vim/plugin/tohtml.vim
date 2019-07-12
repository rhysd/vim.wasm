if exists('g:loaded_2html_plugin')
finish
endif
let g:loaded_2html_plugin = 'vim8.1_v1'
if !&cp && !exists(":TOhtml") && has("user_commands")
command -range=% -bar TOhtml :call tohtml#Convert2HTML(<line1>, <line2>)
endif "}}}
