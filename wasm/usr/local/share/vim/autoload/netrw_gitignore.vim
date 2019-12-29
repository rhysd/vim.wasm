function! netrw_gitignore#Hide(...)
return substitute(substitute(system('git ls-files --other --ignored --exclude-standard --directory'), '\n', ',', 'g'), ',$', '', '')
endfunction
