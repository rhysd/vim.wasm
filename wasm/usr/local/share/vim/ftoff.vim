if exists("did_load_filetypes")
unlet did_load_filetypes
endif
silent! au! filetypedetect *
