if exists("did_load_ftplugin")
unlet did_load_ftplugin
endif
if exists("#filetypeplugin")
silent! au! filetypeplugin *
endif
