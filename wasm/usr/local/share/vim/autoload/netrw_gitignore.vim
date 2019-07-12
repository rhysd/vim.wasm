function! netrw_gitignore#Hide(...)
let additional_files = a:000
let default_files = ['.gitignore', '.git/info/exclude']
let global_gitignore = expand(substitute(system("git config --global core.excludesfile"), '\n', '', 'g'))
if global_gitignore !=# ''
let default_files = add(default_files, global_gitignore)
endif
let system_gitignore = expand(substitute(system("git config --system core.excludesfile"), '\n', '', 'g'))
if system_gitignore !=# ''
let default_files = add(default_files, system_gitignore)
endif
if additional_files !=# []
let files = extend(default_files, additional_files)
else
let files = default_files
endif
let gitignore_files = []
for file in files
if filereadable(file)
let gitignore_files = add(gitignore_files, file)
endif
endfor
let gitignore_lines = []
for file in gitignore_files
for line in readfile(file)
if line !~# '^#' && line !~# '^$'
let gitignore_lines = add(gitignore_lines, line)
endif
endfor
endfor
let escaped_lines = []
for line in gitignore_lines
let escaped = line
let escaped = substitute(escaped, '\*\*', '*', 'g')
let escaped = substitute(escaped, '\.', '\\.', 'g')
let escaped = substitute(escaped, '\$', '\\$', 'g')
let escaped = substitute(escaped, '*', '.*', 'g')
let escaped = substitute(escaped, '\(\[[^]]*\)\zs\\\.', '\.', 'g')
let escaped = substitute(escaped, '\(\[[^]]*\)\zs\\\$', '\$', 'g')
let escaped = substitute(escaped, '\(\[[^]]*\)\zs\.\*', '*', 'g')
let escaped_lines = add(escaped_lines, escaped)
endfor
return join(escaped_lines, ',')
endfunction
