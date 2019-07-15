if &cp || exists("g:loaded_zipPlugin")
finish
endif
let g:loaded_zipPlugin = "v28"
let s:keepcpo          = &cpo
set cpo&vim
if !exists("g:zipPlugin_ext")
let g:zipPlugin_ext='*.apk,*.celzip,*.crtx,*.docm,*.docx,*.dotm,*.dotx,*.ear,*.epub,*.gcsx,*.glox,*.gqsx,*.ja,*.jar,*.kmz,*.oxt,*.potm,*.potx,*.ppam,*.ppsm,*.ppsx,*.pptm,*.pptx,*.sldx,*.thmx,*.vdw,*.war,*.wsz,*.xap,*.xlam,*.xlam,*.xlsb,*.xlsm,*.xlsx,*.xltm,*.xltx,*.xpi,*.zip'
endif
augroup zip
au!
au BufReadCmd   zipfile:*	call zip#Read(expand("<amatch>"), 1)
au FileReadCmd  zipfile:*	call zip#Read(expand("<amatch>"), 0)
au BufWriteCmd  zipfile:*	call zip#Write(expand("<amatch>"))
au FileWriteCmd zipfile:*	call zip#Write(expand("<amatch>"))
if has("unix")
au BufReadCmd   zipfile:*/*	call zip#Read(expand("<amatch>"), 1)
au FileReadCmd  zipfile:*/*	call zip#Read(expand("<amatch>"), 0)
au BufWriteCmd  zipfile:*/*	call zip#Write(expand("<amatch>"))
au FileWriteCmd zipfile:*/*	call zip#Write(expand("<amatch>"))
endif
exe "au BufReadCmd ".g:zipPlugin_ext.' call zip#Browse(expand("<amatch>"))'
augroup END
let &cpo= s:keepcpo
unlet s:keepcpo
