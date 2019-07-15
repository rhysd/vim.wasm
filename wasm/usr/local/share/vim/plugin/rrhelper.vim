if exists("loaded_rrhelper") || !has("clientserver")
finish
endif
let loaded_rrhelper = 1
function SetupRemoteReplies()
let cnt = 0
let max = argc()
let id = expand("<client>")
if id == 0
return
endif
while cnt < max
let uniqueGroup = "RemoteReply_".id."_".cnt
let f = substitute(argv(cnt), '\\', '/', "g")
if exists('*fnameescape')
let f = fnameescape(f)
else
let f = escape(f, " \t\n*?[{`$\\%#'\"|!<")
endif
execute "augroup ".uniqueGroup
execute "autocmd ".uniqueGroup." BufUnload ". f ."  call DoRemoteReply('".id."', '".cnt."', '".uniqueGroup."', '". f ."')"
let cnt = cnt + 1
endwhile
augroup END
endfunc
function DoRemoteReply(id, cnt, group, file)
call server2client(a:id, a:cnt)
execute 'autocmd! '.a:group.' BufUnload '.a:file
execute 'augroup! '.a:group
endfunc
