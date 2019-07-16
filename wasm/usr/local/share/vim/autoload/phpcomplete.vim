if !exists('g:phpcomplete_relax_static_constraint')
let g:phpcomplete_relax_static_constraint = 0
endif
if !exists('g:phpcomplete_complete_for_unknown_classes')
let g:phpcomplete_complete_for_unknown_classes = 0
endif
if !exists('g:phpcomplete_search_tags_for_variables')
let g:phpcomplete_search_tags_for_variables = 0
endif
if !exists('g:phpcomplete_min_num_of_chars_for_namespace_completion')
let g:phpcomplete_min_num_of_chars_for_namespace_completion = 1
endif
if !exists('g:phpcomplete_parse_docblock_comments')
let g:phpcomplete_parse_docblock_comments = 0
endif
if !exists('g:phpcomplete_cache_taglists')
let g:phpcomplete_cache_taglists = 1
endif
if !exists('s:cache_classstructures')
let s:cache_classstructures = {}
endif
if !exists('s:cache_tags')
let s:cache_tags = {}
endif
if !exists('s:cache_tags_checksum')
let s:cache_tags_checksum = ''
endif
let s:script_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')
function! phpcomplete#CompletePHP(findstart, base) " {{{
if a:findstart
unlet! b:php_menu
let pos = getpos('.')
let phpbegin = searchpairpos('<?', '', '?>', 'bWn',
\ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment"')
let phpend = searchpairpos('<?', '', '?>', 'Wn',
\ 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment"')
if phpbegin == [0,0] && phpend == [0,0]
let htmlbegin = htmlcomplete#CompleteTags(1, '')
let cursor_col = pos[2]
let base = getline('.')[htmlbegin : cursor_col]
let b:php_menu = htmlcomplete#CompleteTags(0, base)
return htmlbegin
else
let line = getline('.')
let start = col('.') - 1
let compl_begin = col('.') - 2
while start >= 0 && line[start - 1] =~ '[\\a-zA-Z_0-9\x7f-\xff$]'
let start -= 1
endwhile
let b:phpbegin = phpbegin
let b:compl_context = phpcomplete#GetCurrentInstruction(line('.'), max([0, col('.') - 2]), phpbegin)
return start
endif
endif
if exists("b:php_menu")
return b:php_menu
endif
if !exists('g:php_builtin_functions')
call phpcomplete#LoadData()
endif
if exists("b:compl_context")
let context = b:compl_context
unlet! b:compl_context
if a:base != ""
let context = substitute(context, '\s*[$a-zA-Z_0-9\x7f-\xff]*$', '', '')
end
else
let context = ''
end
try
let eventignore = &eventignore
let &eventignore = 'all'
let winheight = winheight(0)
let winnr = winnr()
let [current_namespace, imports] = phpcomplete#GetCurrentNameSpace(getline(0, line('.')))
if context =~? '^use\s' || context ==? 'use'
return phpcomplete#CompleteUse(a:base)
endif
if context =~ '\(->\|::\)$'
let classname = phpcomplete#GetClassName(line('.'), context, current_namespace, imports)
if classname != ''
if classname =~ '\'
let classname_parts = split(classname, '\')
let namespace = join(classname_parts[0:-2], '\')
let classname = classname_parts[-1]
else
let namespace = '\'
endif
let classlocation = phpcomplete#GetClassLocation(classname, namespace)
else
let classlocation = ''
endif
if classlocation != ''
if classlocation == 'VIMPHP_BUILTINOBJECT' && has_key(g:php_builtin_classes, tolower(classname))
return phpcomplete#CompleteBuiltInClass(context, classname, a:base)
endif
if filereadable(classlocation)
let classfile = readfile(classlocation)
let classcontent = ''
let classcontent .= "\n".phpcomplete#GetClassContents(classlocation, classname)
let sccontent = split(classcontent, "\n")
let visibility = expand('%:p') == fnamemodify(classlocation, ':p') ? 'private' : 'public'
return phpcomplete#CompleteUserClass(context, a:base, sccontent, visibility)
endif
endif
return phpcomplete#CompleteUnknownClass(a:base, context)
elseif context =~? 'implements'
return phpcomplete#CompleteClassName(a:base, ['i'], current_namespace, imports)
elseif context =~? 'instanceof'
return phpcomplete#CompleteClassName(a:base, ['c', 'n'], current_namespace, imports)
elseif context =~? 'extends\s\+.\+$' && a:base == ''
return ['implements']
elseif context =~? 'extends'
let kinds = context =~? 'class\s' ? ['c'] : ['i']
return phpcomplete#CompleteClassName(a:base, kinds, current_namespace, imports)
elseif context =~? 'class [a-zA-Z_\x7f-\xff\\][a-zA-Z_0-9\x7f-\xff\\]*'
return filter(['extends', 'implements'], 'stridx(v:val, a:base) == 0')
elseif context =~? 'new'
return phpcomplete#CompleteClassName(a:base, ['c'], current_namespace, imports)
endif
if a:base =~ '^\$'
return phpcomplete#CompleteVariable(a:base)
else
return phpcomplete#CompleteGeneral(a:base, current_namespace, imports)
endif
finally
silent! exec winnr.'resize '.winheight
let &eventignore = eventignore
endtry
endfunction
function! phpcomplete#CompleteUse(base) " {{{
let res = []
if a:base =~? '^\'
let base = substitute(a:base, '^\', '', '')
else
let base = a:base
endif
let namespace_match_pattern  = substitute(base, '\\', '\\\\', 'g')
let classname_match_pattern = matchstr(base, '[^\\]\+$')
let namespace_for_class = substitute(substitute(namespace_match_pattern, '\\\\', '\\', 'g'), '\\*'.classname_match_pattern.'$', '', '')
if len(namespace_match_pattern) >= g:phpcomplete_min_num_of_chars_for_namespace_completion
if len(classname_match_pattern) >= g:phpcomplete_min_num_of_chars_for_namespace_completion
let tags = phpcomplete#GetTaglist('^\('.namespace_match_pattern.'\|'.classname_match_pattern.'\)')
else
let tags = phpcomplete#GetTaglist('^'.namespace_match_pattern)
endif
let patched_ctags_detected = 0
let namespaced_matches = []
let no_namespace_matches = []
for tag in tags
if has_key(tag, 'namespace')
let patched_ctags_detected = 1
endif
if tag.kind ==? 'n' && tag.name =~? '^'.namespace_match_pattern
let patched_ctags_detected = 1
call add(namespaced_matches, {'word': tag.name, 'kind': 'n', 'menu': tag.filename, 'info': tag.filename })
elseif has_key(tag, 'namespace') && (tag.kind ==? 'c' || tag.kind ==? 'i' || tag.kind ==? 't') && tag.namespace ==? namespace_for_class
call add(namespaced_matches, {'word': namespace_for_class.'\'.tag.name, 'kind': tag.kind, 'menu': tag.filename, 'info': tag.filename })
elseif (tag.kind ==? 'c' || tag.kind ==? 'i' || tag.kind ==? 't')
call add(no_namespace_matches, {'word': namespace_for_class.'\'.tag.name, 'kind': tag.kind, 'menu': tag.filename, 'info': tag.filename })
endif
endfor
if patched_ctags_detected
no_namespace_matches = []
endif
let res += namespaced_matches + no_namespace_matches
endif
if base !~ '\'
let builtin_classnames = filter(keys(copy(g:php_builtin_classnames)), 'v:val =~? "^'.classname_match_pattern.'"')
for classname in builtin_classnames
call add(res, {'word': g:php_builtin_classes[tolower(classname)].name, 'kind': 'c'})
endfor
let builtin_interfacenames = filter(keys(copy(g:php_builtin_interfacenames)), 'v:val =~? "^'.classname_match_pattern.'"')
for interfacename in builtin_interfacenames
call add(res, {'word': g:php_builtin_interfaces[tolower(interfacename)].name, 'kind': 'i'})
endfor
endif
for comp in res
let comp.word = substitute(comp.word, '^\\', '', '')
endfor
return res
endfunction
function! phpcomplete#CompleteGeneral(base, current_namespace, imports) " {{{
if a:base =~? '^\'
let leading_slash = '\'
else
let leading_slash = ''
endif
let file = getline(1, '$')
call filter(file,
\ 'v:val =~ "function\\s\\+&\\?[a-zA-Z_\\x7f-\\xff][a-zA-Z_0-9\\x7f-\\xff]*\\s*("')
let jfile = join(file, ' ')
let int_values = split(jfile, 'function\s\+')
let int_functions = {}
for i in int_values
let f_name = matchstr(i,
\ '^&\?\zs[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\ze')
if f_name =~? '^'.substitute(a:base, '\\', '\\\\', 'g')
let f_args = matchstr(i,
\ '^&\?[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\s*(\zs.\{-}\ze)\_s*\(;\|{\|$\)')
let int_functions[f_name.'('] = f_args.')'
endif
endfor
let file = getline(1, '$')
call filter(file, 'v:val =~ "define\\s*("')
let jfile = join(file, ' ')
let int_values = split(jfile, 'define\s*(\s*')
let int_constants = {}
for i in int_values
let c_name = matchstr(i, '\(["'']\)\zs[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\ze\1')
if c_name != '' && c_name =~# '^'.substitute(a:base, '\\', '\\\\', 'g')
let int_constants[leading_slash.c_name] = ''
endif
endfor
let ext_functions  = {}
let ext_constants  = {}
let ext_classes    = {}
let ext_traits     = {}
let ext_interfaces = {}
let ext_namespaces = {}
let base = substitute(a:base, '^\\', '', '')
let [tag_match_pattern, namespace_for_tag] = phpcomplete#ExpandClassName(a:base, a:current_namespace, a:imports)
let namespace_match_pattern  = substitute((namespace_for_tag == '' ? '' : namespace_for_tag.'\').tag_match_pattern, '\\', '\\\\', 'g')
let tags = []
if len(namespace_match_pattern) >= g:phpcomplete_min_num_of_chars_for_namespace_completion && len(tag_match_pattern) >= g:phpcomplete_min_num_of_chars_for_namespace_completion && tag_match_pattern != namespace_match_pattern
let tags = phpcomplete#GetTaglist('\c^\('.tag_match_pattern.'\|'.namespace_match_pattern.'\)')
elseif len(namespace_match_pattern) >= g:phpcomplete_min_num_of_chars_for_namespace_completion
let tags = phpcomplete#GetTaglist('\c^'.namespace_match_pattern)
elseif len(tag_match_pattern) >= g:phpcomplete_min_num_of_chars_for_namespace_completion
let tags = phpcomplete#GetTaglist('\c^'.tag_match_pattern)
endif
for tag in tags
if !has_key(tag, 'namespace') || tag.namespace ==? a:current_namespace || tag.namespace ==? namespace_for_tag
if has_key(tag, 'namespace')
let full_name = tag.namespace.'\'.tag.name " absolute namespaced name (without leading '\')
let base_parts = split(a:base, '\')
if len(base_parts) > 1
let namespace_part = join(base_parts[0:-2], '\')
else
let namespace_part = ''
endif
let relative_name = (namespace_part == '' ? '' : namespace_part.'\').tag.name
endif
if tag.kind ==? 'n' && tag.name =~? '^'.namespace_match_pattern
let info = tag.name.' - '.tag.filename
let full_name = tag.name
let base_parts = split(a:base, '\')
let full_name_parts = split(full_name, '\')
if len(base_parts) > 1
if has_key(a:imports, base_parts[0]) && a:imports[base_parts[0]].kind == 'n'
let import = a:imports[base_parts[0]]
let relative_name = substitute(full_name, '^'.substitute(import.name, '\\', '\\\\', 'g'), base_parts[0], '')
else
let relative_name = strpart(full_name, stridx(full_name, a:base))
endif
else
let relative_name = strpart(full_name, stridx(full_name, a:base))
endif
if leading_slash == ''
let ext_namespaces[relative_name.'\'] = info
else
let ext_namespaces['\'.full_name.'\'] = info
endif
elseif tag.kind ==? 'f' && !has_key(tag, 'class') " class related functions (methods) completed elsewhere, only works with patched ctags
if has_key(tag, 'signature')
let prototype = tag.signature[1:-2] " drop the ()s around the string
else
let prototype = matchstr(tag.cmd,
\ 'function\s\+&\?[^[:space:]]\+\s*(\s*\zs.\{-}\ze\s*)\s*{\?')
endif
let info = prototype.') - '.tag.filename
if !has_key(tag, 'namespace')
let ext_functions[tag.name.'('] = info
else
if tag.namespace ==? namespace_for_tag
if leading_slash == ''
let ext_functions[relative_name.'('] = info
else
let ext_functions['\'.full_name.'('] = info
endif
endif
endif
elseif tag.kind ==? 'd'
let info = ' - '.tag.filename
if !has_key(tag, 'namespace')
let ext_constants[tag.name] = info
else
if tag.namespace ==? namespace_for_tag
if leading_slash == ''
let ext_constants[relative_name] = info
else
let ext_constants['\'.full_name] = info
endif
endif
endif
elseif tag.kind ==? 'c' || tag.kind ==? 'i' || tag.kind ==? 't'
let info = ' - '.tag.filename
let key = ''
if !has_key(tag, 'namespace')
let key = tag.name
else
if tag.namespace ==? namespace_for_tag
if leading_slash == ''
let key = relative_name
else
let key = '\'.full_name
endif
endif
endif
if key != ''
if tag.kind ==? 'c'
let ext_classes[key] = info
elseif tag.kind ==? 'i'
let ext_interfaces[key] = info
elseif tag.kind ==? 't'
let ext_traits[key] = info
endif
endif
endif
endif
endfor
let builtin_constants  = {}
let builtin_classnames = {}
let builtin_interfaces = {}
let builtin_functions  = {}
let builtin_keywords   = {}
let base = substitute(a:base, '^\', '', '')
if a:current_namespace == '\' || (a:base =~ '^\\' && a:base =~ '^\\[^\\]*$')
for [classname, info] in items(g:php_builtin_classnames)
if classname =~? '^'.base
let builtin_classnames[leading_slash.g:php_builtin_classes[tolower(classname)].name] = info
endif
endfor
for [interfacename, info] in items(g:php_builtin_interfacenames)
if interfacename =~? '^'.base
let builtin_interfaces[leading_slash.g:php_builtin_interfaces[tolower(interfacename)].name] = info
endif
endfor
endif
for [constant, info] in items(g:php_constants)
if constant =~# '^'.base
let builtin_constants[leading_slash.constant] = info
endif
endfor
if leading_slash == '' " keywords should not be completed when base starts with '\'
for [constant, info] in items(g:php_keywords)
if constant =~? '^'.a:base
let builtin_keywords[constant] = info
endif
endfor
endif
for [function_name, info] in items(g:php_builtin_functions)
if function_name =~? '^'.base
let builtin_functions[leading_slash.function_name] = info
endif
endfor
call extend(int_constants, ext_constants)
call extend(int_functions, ext_functions)
call extend(int_functions, builtin_functions)
for [imported_name, import] in items(a:imports)
if imported_name =~? '^'.base
if import.kind ==? 'c'
if import.builtin
let builtin_classnames[imported_name] = ' '.import.name
else
let ext_classes[imported_name] = ' '.import.name.' - '.import.filename
endif
elseif import.kind ==? 'i'
if import.builtin
let builtin_interfaces[imported_name] = ' '.import.name
else
let ext_interfaces[imported_name] = ' '.import.name.' - '.import.filename
endif
elseif import.kind ==? 't'
let ext_traits[imported_name] = ' '.import.name.' - '.import.filename
endif
if import.kind == 'n'
let ext_namespaces[imported_name.'\'] = ' '.import.name.' - '.import.filename
endif
end
endfor
let all_values = {}
call extend(all_values, int_functions)
call extend(all_values, ext_namespaces)
call extend(all_values, int_constants)
call extend(all_values, builtin_constants)
call extend(all_values, ext_classes)
call extend(all_values, ext_interfaces)
call extend(all_values, ext_traits)
call extend(all_values, builtin_classnames)
call extend(all_values, builtin_interfaces)
call extend(all_values, builtin_keywords)
let final_list = []
let int_list = sort(keys(all_values))
for i in int_list
if has_key(ext_namespaces, i)
let final_list += [{'word':i, 'kind':'n', 'menu': ext_namespaces[i], 'info': ext_namespaces[i]}]
elseif has_key(int_functions, i)
let final_list +=
\ [{'word':i,
\	'info':i.int_functions[i],
\	'menu':int_functions[i],
\	'kind':'f'}]
elseif has_key(ext_classes, i) || has_key(builtin_classnames, i)
let info = has_key(ext_classes, i) ? ext_classes[i] : builtin_classnames[i].' - builtin'
let final_list += [{'word':i, 'kind': 'c', 'menu': info, 'info': i.info}]
elseif has_key(ext_interfaces, i) || has_key(builtin_interfaces, i)
let info = has_key(ext_interfaces, i) ? ext_interfaces[i] : builtin_interfaces[i].' - builtin'
let final_list += [{'word':i, 'kind': 'i', 'menu': info, 'info': i.info}]
elseif has_key(ext_traits, i)
let final_list += [{'word':i, 'kind': 't', 'menu': ext_traits[i], 'info': ext_traits[i]}]
elseif has_key(int_constants, i) || has_key(builtin_constants, i)
let info = has_key(int_constants, i) ? int_constants[i] : ' - builtin'
let final_list += [{'word':i, 'kind': 'd', 'menu': info, 'info': i.info}]
else
let final_list += [{'word':i}]
endif
endfor
return final_list
endfunction
function! phpcomplete#CompleteUnknownClass(base, context) " {{{
let res = []
if g:phpcomplete_complete_for_unknown_classes != 1
return []
endif
if a:base =~ '^\$'
let adddollar = '$'
else
let adddollar = ''
endif
let file = getline(1, '$')
if a:context =~ '::'
let variables = filter(deepcopy(file),
\ 'v:val =~ "^\\s*\\(static\\|static\\s\\+\\(public\\|var\\)\\|\\(public\\|var\\)\\s\\+static\\)\\s\\+\\$"')
elseif a:context =~ '->'
let variables = filter(deepcopy(file),
\ 'v:val =~ "^\\s*\\(public\\|var\\)\\s\\+\\$"')
endif
let jvars = join(variables, ' ')
let svars = split(jvars, '\$')
let int_vars = {}
for i in svars
let c_var = matchstr(i,
\ '^\zs[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\ze')
if c_var != ''
let int_vars[adddollar.c_var] = ''
endif
endfor
call filter(deepcopy(file),
\ 'v:val =~ "function\\s\\+&\\?[a-zA-Z_\\x7f-\\xff][a-zA-Z_0-9\\x7f-\\xff]*\\s*("')
let jfile = join(file, ' ')
let int_values = split(jfile, 'function\s\+')
let int_functions = {}
for i in int_values
let f_name = matchstr(i,
\ '^&\?\zs[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\ze')
let f_args = matchstr(i,
\ '^&\?[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\s*(\zs.\{-}\ze)\_s*\(;\|{\|$\)')
let int_functions[f_name.'('] = f_args.')'
endfor
let ext_functions = {}
let tags = phpcomplete#GetTaglist('^'.substitute(a:base, '^\$', '', ''))
for tag in tags
if tag.kind ==? 'f'
let item = tag.name
if has_key(tag, 'signature')
let prototype = tag.signature[1:-2]
else
let prototype = matchstr(tag.cmd,
\ 'function\s\+&\?[^[:space:]]\+\s*(\s*\zs.\{-}\ze\s*)\s*{\?')
endif
let ext_functions[item.'('] = prototype.') - '.tag['filename']
endif
endfor
call extend(int_functions, ext_functions)
let all_values = {}
call extend(all_values, int_functions)
call extend(all_values, int_vars) " external variables are already in
call extend(all_values, g:php_builtin_object_functions)
for m in sort(keys(all_values))
if m =~ '\(^\|::\)'.a:base
call add(res, m)
endif
endfor
let start_list = res
let final_list = []
for i in start_list
if has_key(int_vars, i)
let class = ' '
if all_values[i] != ''
let class = i.' class '
endif
let final_list += [{'word':i, 'info':class.all_values[i], 'kind':'v'}]
else
let final_list +=
\ [{'word':substitute(i, '.*::', '', ''),
\	'info':i.all_values[i],
\	'menu':all_values[i],
\	'kind':'f'}]
endif
endfor
return final_list
endfunction
function! phpcomplete#CompleteVariable(base) " {{{
let res = []
let file = getline(1, '$')
let jfile = join(file, ' ')
let int_vals = split(jfile, '\ze\$')
let int_vars = {}
for i in int_vals
if i =~? '^\$[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\s*=\s*new'
let val = matchstr(i,
\ '^\$[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*')
else
let val = matchstr(i,
\ '^\$[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*')
endif
if val != ''
let int_vars[val] = ''
endif
endfor
call extend(int_vars, g:php_builtin_vars)
if  g:phpcomplete_search_tags_for_variables
let ext_vars = {}
let tags = phpcomplete#GetTaglist('\C^'.substitute(a:base, '^\$', '', ''))
for tag in tags
if tag.kind ==? 'v'
let item = tag.name
let m_menu = ''
if tag.cmd =~? tag['name'].'\s*=\s*new\s\+'
let m_menu = matchstr(tag.cmd,
\ '\c=\s*new\s\+\zs[a-zA-Z_0-9\x7f-\xff]\+\ze')
endif
let ext_vars['$'.item] = m_menu
endif
endfor
call extend(int_vars, ext_vars)
endif
for m in sort(keys(int_vars))
if m =~# '^\'.a:base
call add(res, m)
endif
endfor
let int_list = res
let int_dict = []
for i in int_list
if int_vars[i] != ''
let class = ' '
if int_vars[i] != ''
let class = i.' class '
endif
let int_dict += [{'word':i, 'info':class.int_vars[i], 'menu':int_vars[i], 'kind':'v'}]
else
let int_dict += [{'word':i, 'kind':'v'}]
endif
endfor
return int_dict
endfunction
function! phpcomplete#CompleteClassName(base, kinds, current_namespace, imports) " {{{
let kinds = sort(a:kinds)
let res = []
if a:base =~? '^\'
let leading_slash = '\'
let base = substitute(a:base, '^\', '', '')
else
let leading_slash = ''
let base = a:base
endif
let file = getline(1, '$')
let filterstr = ''
if kinds == ['c', 'i']
let filterstr = 'v:val =~? "\\(class\\|interface\\)\\s\\+[a-zA-Z_\\x7f-\\xff][a-zA-Z_0-9\\x7f-\\xff]*\\s*"'
elseif kinds == ['c', 'n']
let filterstr = 'v:val =~? "\\(class\\|namespace\\)\\s\\+[a-zA-Z_\\x7f-\\xff][a-zA-Z_0-9\\x7f-\\xff]*\\s*"'
elseif kinds == ['c']
let filterstr = 'v:val =~? "class\\s\\+[a-zA-Z_\\x7f-\\xff][a-zA-Z_0-9\\x7f-\\xff]*\\s*"'
elseif kinds == ['i']
let filterstr = 'v:val =~? "interface\\s\\+[a-zA-Z_\\x7f-\\xff][a-zA-Z_0-9\\x7f-\\xff]*\\s*"'
endif
call filter(file, filterstr)
for line in file
let c_name = matchstr(line, '\c\(class\|interface\)\s*\zs[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*')
let kind = (line =~? '^\s*class' ? 'c' : 'i')
if c_name != '' && c_name =~? '^'.base
call add(res, {'word': c_name, 'kind': kind})
endif
endfor
let [tag_match_pattern, namespace_for_class] = phpcomplete#ExpandClassName(a:base, a:current_namespace, a:imports)
let tags = []
if len(tag_match_pattern) >= g:phpcomplete_min_num_of_chars_for_namespace_completion
let tags = phpcomplete#GetTaglist('^\c'.tag_match_pattern)
endif
if len(tags)
let base_parts = split(a:base, '\')
if len(base_parts) > 1
let namespace_part = join(base_parts[0:-2], '\').'\'
else
let namespace_part = ''
endif
let no_namespace_matches = []
let namespaced_matches = []
let seen_namespaced_tag = 0
for tag in tags
if has_key(tag, 'namespace')
let seen_namespaced_tag = 1
endif
let relative_name = namespace_part.tag.name
if !has_key(tag, 'namespace') && index(kinds, tag.kind) != -1 && stridx(tolower(tag.name), tolower(base[len(namespace_part):])) == 0
call add(no_namespace_matches, {'word': leading_slash.relative_name, 'kind': tag.kind, 'menu': tag.filename, 'info': tag.filename })
endif
if has_key(tag, 'namespace') && index(kinds, tag.kind) != -1 && tag.namespace ==? namespace_for_class
let full_name = tag.namespace.'\'.tag.name " absolute namespaced name (without leading '\')
call add(namespaced_matches, {'word': leading_slash == '\' ? leading_slash.full_name : relative_name, 'kind': tag.kind, 'menu': tag.filename, 'info': tag.filename })
endif
endfor
if seen_namespaced_tag && namespace_part != ''
let no_namespace_matches = []
endif
let res += no_namespace_matches + namespaced_matches
endif
let base_parts = split(base, '\')
if a:current_namespace == '\' || (leading_slash == '\' && len(base_parts) < 2)
if index(kinds, 'c') != -1
let builtin_classnames = filter(keys(copy(g:php_builtin_classnames)), 'v:val =~? "^'.substitute(a:base, '\\', '', 'g').'"')
for classname in builtin_classnames
let menu = ''
if has_key(g:php_builtin_classes[tolower(classname)].methods, '__construct')
let menu = g:php_builtin_classes[tolower(classname)]['methods']['__construct']['signature']
endif
call add(res, {'word': leading_slash.g:php_builtin_classes[tolower(classname)].name, 'kind': 'c', 'menu': menu})
endfor
endif
if index(kinds, 'i') != -1
let builtin_interfaces = filter(keys(copy(g:php_builtin_interfaces)), 'v:val =~? "^'.substitute(a:base, '\\', '', 'g').'"')
for interfacename in builtin_interfaces
call add(res, {'word': leading_slash.g:php_builtin_interfaces[interfacename]['name'], 'kind': 'i', 'menu': ''})
endfor
endif
endif
for [imported_name, import] in items(a:imports)
if imported_name =~? '^'.base && index(kinds, import.kind) != -1
let menu = import.name.(import.builtin ? ' - builtin' : '')
call add(res, {'word': imported_name, 'kind': import.kind, 'menu': menu})
endif
endfor
let res = sort(res, 'phpcomplete#CompareCompletionRow')
return res
endfunction
function! phpcomplete#CompareCompletionRow(i1, i2) " {{{
return a:i1.word == a:i2.word ? 0 : a:i1.word > a:i2.word ? 1 : -1
endfunction
function! s:getNextCharWithPos(filelines, current_pos) " {{{
let line_no   = a:current_pos[0]
let col_no    = a:current_pos[1]
let last_line = a:filelines[len(a:filelines) - 1]
let end_pos   = [len(a:filelines) - 1, strlen(last_line) - 1]
if line_no > end_pos[0] || line_no == end_pos[0] && col_no > end_pos[1]
return ['EOF', 'EOF']
endif
if col_no + 1 < strlen(a:filelines[line_no])
let col_no += 1
else
let line_no += 1
while strlen(a:filelines[line_no]) == 0
let line_no += 1
endwhile
let col_no = 0
endif
if line_no == end_pos[0] && col_no > end_pos[1]
return ['EOF', 'EOF']
endif
return [[line_no, col_no], a:filelines[line_no][col_no]]
endfunction " }}}
function! phpcomplete#EvaluateModifiers(modifiers, required_modifiers, prohibited_modifiers) " {{{
if len(a:modifiers) == 0 && len(a:required_modifiers) == 0
return 1
else
for required_modifier in a:required_modifiers
if index(a:modifiers, required_modifier) == -1
return 0
endif
endfor
for modifier in a:modifiers
if index(a:prohibited_modifiers, modifier) != -1
return 0
endif
endfor
return 1
endif
endfunction
function! phpcomplete#CompleteUserClass(context, base, sccontent, visibility) " {{{
let final_list = []
let res  = []
let required_modifiers = []
let prohibited_modifiers = []
if a:visibility == 'public'
let prohibited_modifiers += ['private', 'protected']
endif
let static_con = ''
if a:context =~ '::$' && a:context !~? 'parent::$'
if g:phpcomplete_relax_static_constraint != 1
let required_modifiers += ['static']
endif
elseif a:context =~ '->$'
let prohibited_modifiers += ['static']
endif
let all_function = filter(deepcopy(a:sccontent),
\ 'v:val =~ "^\\s*\\(public\\s\\+\\|protected\\s\\+\\|private\\s\\+\\|final\\s\\+\\|abstract\\s\\+\\|static\\s\\+\\)*function"')
let functions = []
for i in all_function
let modifiers = split(matchstr(tolower(i), '\zs.\+\zefunction'), '\s\+')
if phpcomplete#EvaluateModifiers(modifiers, required_modifiers, prohibited_modifiers) == 1
call add(functions, i)
endif
endfor
let c_functions = {}
let c_doc = {}
for i in functions
let f_name = matchstr(i,
\ 'function\s*&\?\zs[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\ze')
let f_args = matchstr(i,
\ 'function\s*&\?[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\s*(\zs.\{-}\ze)\_s*\(;\|{\|\_$\)')
if f_name != '' && stridx(f_name, '__') != 0
let c_functions[f_name.'('] = f_args
if g:phpcomplete_parse_docblock_comments
let c_doc[f_name.'('] = phpcomplete#GetDocBlock(a:sccontent, 'function\s*&\?\<'.f_name.'\>')
endif
endif
endfor
if a:context =~ '::$' && a:context !~? 'parent::$'
let required_modifiers += ['static']
endif
let all_variable = filter(deepcopy(a:sccontent),
\ 'v:val =~ "\\(^\\s*\\(var\\s\\+\\|public\\s\\+\\|protected\\s\\+\\|private\\s\\+\\|final\\s\\+\\|abstract\\s\\+\\|static\\s\\+\\)\\+\\$\\|^\\s*\\(\\/\\|\\*\\)*\\s*@property\\s\\+\\S\\+\\s\\S\\{-}\\s*$\\)"')
let variables = []
for i in all_variable
let modifiers = split(matchstr(tolower(i), '\zs.\+\ze\$'), '\s\+')
if phpcomplete#EvaluateModifiers(modifiers, required_modifiers, prohibited_modifiers) == 1
call add(variables, i)
endif
endfor
let static_vars = split(join(variables, ' '), '\$')
let c_variables = {}
let var_index = 0
for i in static_vars
let c_var = matchstr(i,
\ '^\zs[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\ze')
if c_var != ''
if a:context =~ '::$'
let c_var = '$'.c_var
endif
let c_variables[c_var] = ''
if g:phpcomplete_parse_docblock_comments && len(get(variables, var_index)) > 0
let c_doc[c_var] = phpcomplete#GetDocBlock(a:sccontent, variables[var_index])
endif
let var_index += 1
endif
endfor
let constants = filter(deepcopy(a:sccontent),
\ 'v:val =~ "^\\s*const\\s\\+"')
let jcons = join(constants, ' ')
let scons = split(jcons, 'const')
let c_constants = {}
let const_index = 0
for i in scons
let c_con = matchstr(i,
\ '^\s*\zs[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*\ze')
if c_con != ''
let c_constants[c_con] = ''
if g:phpcomplete_parse_docblock_comments && len(get(constants, const_index)) > 0
let c_doc[c_con] = phpcomplete#GetDocBlock(a:sccontent, constants[const_index])
endif
let const_index += 1
endif
endfor
let all_values = {}
call extend(all_values, c_functions)
call extend(all_values, c_variables)
call extend(all_values, c_constants)
for m in sort(keys(all_values))
if stridx(m, a:base) == 0
call add(res, m)
endif
endfor
let start_list = res
let final_list = []
for i in start_list
let docblock = phpcomplete#ParseDocBlock(get(c_doc, i, ''))
if has_key(c_variables, i)
let final_list +=
\ [{'word': i,
\	'info':phpcomplete#FormatDocBlock(docblock),
\	'menu':get(docblock.var, 'type', ''),
\	'kind':'v'}]
elseif has_key(c_constants, i)
let info = phpcomplete#FormatDocBlock(docblock)
if info != ''
let info = "\n".info
endif
let final_list +=
\ [{'word':i,
\	'info':i.info,
\	'menu':all_values[i],
\	'kind':'d'}]
else
let return_type = get(docblock.return, 'type', '')
if return_type != ''
let return_type = ' | '.return_type
endif
let info = phpcomplete#FormatDocBlock(docblock)
if info != ''
let info = "\n".info
endif
let final_list +=
\ [{'word':substitute(i, '.*::', '', ''),
\	'info':i.all_values[i].')'.info,
\	'menu':all_values[i].')'.return_type,
\	'kind':'f'}]
endif
endfor
return final_list
endfunction
function! phpcomplete#CompleteBuiltInClass(context, classname, base) " {{{
let class_info = g:php_builtin_classes[tolower(a:classname)]
let res = []
if a:context =~ '->$' " complete for everything instance related
for [method_name, method_info] in items(class_info.methods)
if stridx(method_name, '__') != 0 && (a:base == '' || method_name =~? '^'.a:base)
call add(res, {'word':method_name.'(', 'kind': 'f', 'menu': method_info.signature, 'info': method_info.signature })
endif
endfor
for [property_name, property_info] in items(class_info.properties)
if a:base == '' || property_name =~? '^'.a:base
call add(res, {'word':property_name, 'kind': 'v', 'menu': property_info.type, 'info': property_info.type })
endif
endfor
elseif a:context =~ '::$' " complete for everything static
for [method_name, method_info] in items(class_info.static_methods)
if a:base == '' || method_name =~? '^'.a:base
call add(res, {'word':method_name.'(', 'kind': 'f', 'menu': method_info.signature, 'info': method_info.signature })
endif
endfor
for [property_name, property_info] in items(class_info.static_properties)
if a:base == '' || property_name =~? '^'.a:base
call add(res, {'word':property_name, 'kind': 'v', 'menu': property_info.type, 'info': property_info.type })
endif
endfor
for [constant_name, constant_info] in items(class_info.constants)
if a:base == '' || constant_name =~? '^'.a:base
call add(res, {'word':constant_name, 'kind': 'd', 'menu': constant_info, 'info': constant_info})
endif
endfor
endif
return res
endfunction
function! phpcomplete#GetTaglist(pattern) " {{{
let cache_checksum = ''
if g:phpcomplete_cache_taglists == 1
for tagfile in sort(tagfiles())
let cache_checksum .= fnamemodify(tagfile, ':p').':'.getftime(tagfile).'$'
endfor
if s:cache_tags_checksum != cache_checksum
let s:cache_tags = {}
endif
if has_key(s:cache_tags, a:pattern)
return s:cache_tags[a:pattern]
endif
endif
let tags = taglist(a:pattern)
for tag in tags
for prop in keys(tag)
if prop == 'cmd' || prop == 'static' || prop == 'kind' || prop == 'builtin'
continue
endif
let tag[prop] = substitute(tag[prop], '\\\\', '\\', 'g')
endfor
endfor
let s:cache_tags[a:pattern] = tags
let has_key = has_key(s:cache_tags, a:pattern)
let s:cache_tags_checksum = cache_checksum
return tags
endfunction
function! phpcomplete#GetCurrentInstruction(line_number, col_number, phpbegin) " {{{
let col_number = a:col_number
let line_number = a:line_number
let line = getline(a:line_number)
let current_char = -1
let instruction = ''
let parent_depth = 0
let bracket_depth = 0
let stop_chars = [
\ '!', '@', '%', '^', '&',
\ '*', '/', '-', '+', '=',
\ ':', '>', '<', '.', '?',
\ ';', '(', '|', '['
\ ]
let phpbegin_length = len(matchstr(getline(a:phpbegin[0]), '\zs<?\(php\)\?\ze'))
let phpbegin_end = [a:phpbegin[0], a:phpbegin[1] - 1 + phpbegin_length]
let first_coma_break_pos = -1
let next_char = len(line) < col_number ? line[col_number + 1] : ''
while !(line_number == 1 && col_number == 1)
if current_char != -1
let next_char = current_char
endif
let current_char = line[col_number]
let synIDName = synIDattr(synID(line_number, col_number + 1, 0), 'name')
if col_number - 1 == -1
let prev_line_number = line_number - 1
let prev_line = getline(line_number - 1)
let prev_col_number = strlen(prev_line)
else
let prev_line_number = line_number
let prev_col_number = col_number - 1
let prev_line = line
endif
let prev_char = prev_line[prev_col_number]
if synIDName =~? 'comment\|phpDocTags'
let current_char = ''
endif
if synIDName == 'phpOperator' && (current_char == 'r' || current_char == 'd')
break
endif
if synIDName == 'phpStatement' || synIDName == 'phpException'
break
endif
if current_char != '' && parent_depth >= 0 && bracket_depth >= 0 && synIDName !~? 'comment\|string'
if index(stop_chars, current_char) != -1
let do_break = 1
if (prev_char == '-' && current_char == '>') || (current_char == '-' && next_char == '>')
let do_break = 0
endif
if (prev_char == ':' && current_char == ':') || (current_char == ':' && next_char == ':')
let do_break = 0
endif
if do_break
break
endif
endif
if first_coma_break_pos == -1 && current_char == ','
let first_coma_break_pos = len(instruction)
endif
endif
if synIDName =~? 'phpBraceFunc\|phpParent\|Delimiter'
if current_char == '('
let parent_depth += 1
elseif current_char == ')'
let parent_depth -= 1
elseif current_char == '['
let bracket_depth += 1
elseif current_char == ']'
let bracket_depth -= 1
endif
endif
if (current_char == '{' || current_char == '}') && synIDName =~? 'phpBraceFunc\|phpParent\|Delimiter'
break
endif
if [line_number, col_number] == phpbegin_end
break
endif
let instruction = current_char.instruction
let col_number -= 1
if col_number == -1
let line_number -= 1
let line = getline(line_number)
let col_number = strlen(line)
endif
endwhile
let instruction = substitute(instruction, '^\s\+', '', '')
if first_coma_break_pos != -1
if instruction !~? '^use' && instruction !~? '^class' " use ... statements and class delcarations should not be broken up by comas
let pos = (-1 * first_coma_break_pos) + 1
let instruction = instruction[pos :]
endif
endif
if instruction =~? '\c^\(if\|while\|foreach\|for\)\s*('
let instruction = substitute(instruction, '^\(if\|while\|foreach\|for\)\s*(\s*', '', '')
let i = 0
let depth = 1
while i < len(instruction)
if instruction[i] == '('
let depth += 1
endif
if instruction[i] == ')'
let depth -= 1
endif
if depth == 0
break
end
let i += 1
endwhile
let instruction = instruction[i + 1 : len(instruction)]
endif
let instruction = substitute(instruction, '\v^(^\s+)|(\s+)$', '', 'g')
return instruction
endfunction " }}}
function! phpcomplete#GetCallChainReturnType(classname_candidate, class_candidate_namespace, imports, methodstack) " {{{
let classname_candidate = a:classname_candidate
let class_candidate_namespace = a:class_candidate_namespace
let methodstack = a:methodstack
let unknown_result = ['', '']
let prev_method_is_array = (methodstack[0] =~ '\v^[^([]+\[' ? 1 : 0)
let classname_candidate_is_array = (classname_candidate =~ '\[\]$' ? 1 : 0)
if prev_method_is_array
if classname_candidate_is_array
let classname_candidate = substitute(classname_candidate, '\[\]$', '', '')
else
return unknown_result
endif
endif
if (len(methodstack) == 1)
let [classname_candidate, class_candidate_namespace] = phpcomplete#ExpandClassName(classname_candidate, class_candidate_namespace, a:imports)
return [classname_candidate, class_candidate_namespace]
else
call remove(methodstack, 0)
let method_is_array = (methodstack[0] =~ '\v^[^[]+\[' ? 1 : 0)
let method = matchstr(methodstack[0], '\v^\$*\zs[^[(]+\ze')
let classlocation = phpcomplete#GetClassLocation(classname_candidate, class_candidate_namespace)
if classlocation == 'VIMPHP_BUILTINOBJECT' && has_key(g:php_builtin_classes, tolower(classname_candidate))
let class_info = g:php_builtin_classes[tolower(classname_candidate)]
if has_key(class_info['methods'], method)
return phpcomplete#GetCallChainReturnType(class_info['methods'][method].return_type, '\', a:imports, methodstack)
endif
if has_key(class_info['properties'], method)
return phpcomplete#GetCallChainReturnType(class_info['properties'][method].type, '\', a:imports, methodstack)
endif
if has_key(class_info['static_methods'], method)
return phpcomplete#GetCallChainReturnType(class_info['static_methods'][method].return_type, '\', a:imports, methodstack)
endif
if has_key(class_info['static_properties'], method)
return phpcomplete#GetCallChainReturnType(class_info['static_properties'][method].type, '\', a:imports, methodstack)
endif
return unknown_result
elseif classlocation != '' && filereadable(classlocation)
let classcontents = phpcomplete#GetCachedClassContents(classlocation, classname_candidate)
for classstructure in classcontents
let docblock_target_pattern = 'function\s\+&\?'.method.'\>\|\(public\|private\|protected\|var\).\+\$'.method.'\>\|@property.\+\$'.method.'\>'
let doc_str = phpcomplete#GetDocBlock(split(classstructure.content, '\n'), docblock_target_pattern)
let return_type_hint = phpcomplete#GetFunctionReturnTypeHint(split(classstructure.content, '\n'), 'function\s\+&\?'.method.'\>')
if doc_str != '' || return_type_hint != ''
break
endif
endfor
if doc_str != '' || return_type_hint != ''
let docblock = phpcomplete#ParseDocBlock(doc_str)
if has_key(docblock.return, 'type') || has_key(docblock.var, 'type') || len(docblock.properties) > 0 || return_type_hint != ''
if return_type_hint == ''
let type = has_key(docblock.return, 'type') ? docblock.return.type : has_key(docblock.var, 'type') ? docblock.var.type : ''
if type == ''
for property in docblock.properties
if property.description =~? method
let type = property.type
break
endif
endfor
endif
else
let type = return_type_hint
end
if type =~ '\\'
let parts = split(substitute(type, '^\\', '', ''), '\')
let class_candidate_namespace = join(parts[0:-2], '\')
let classname_candidate = parts[-1]
if has_key(classstructure.imports, class_candidate_namespace)
let class_candidate_namespace = classstructure.imports[class_candidate_namespace].name
endif
else
let returnclass = type
if has_key(classstructure.imports, returnclass)
if has_key(classstructure.imports[returnclass], 'namespace')
let fullnamespace = classstructure.imports[returnclass].namespace
else
let fullnamespace = class_candidate_namespace
endif
else
let fullnamespace = class_candidate_namespace
endif
if returnclass == 'self' || returnclass == 'static' || returnclass == '$this' || returnclass == 'self[]' || returnclass == 'static[]' || returnclass == '$this[]'
if returnclass =~ '\[\]$'
let classname_candidate = a:classname_candidate.'[]'
else
let classname_candidate = a:classname_candidate
endif
let class_candidate_namespace = a:class_candidate_namespace
else
let [classname_candidate, class_candidate_namespace] = phpcomplete#ExpandClassName(returnclass, fullnamespace, a:imports)
endif
endif
return phpcomplete#GetCallChainReturnType(classname_candidate, class_candidate_namespace, a:imports, methodstack)
endif
endif
return unknown_result
else
return unknown_result
endif
endif
endfunction " }}}
function! phpcomplete#GetMethodStack(line) " {{{
let methodstack = []
let i = 0
let end = len(a:line)
let current_part = ''
let parent_depth = 0
let in_string = 0
let string_start = ''
let next_char = ''
while i	< end
let current_char = a:line[i]
let next_char = i + 1 < end ? a:line[i + 1] : ''
let prev_char = i >= 1 ? a:line[i - 1] : ''
let prev_prev_char = i >= 2 ? a:line[i - 2] : ''
if in_string == 0 && parent_depth == 0 && ((current_char == '-' && next_char == '>') || (current_char == ':' && next_char == ':'))
call add(methodstack, current_part)
let current_part = ''
let i += 2
continue
endif
if current_char == "'" || current_char == '"'
if prev_char != '\' || (prev_char == '\' && prev_prev_char == '\')
if in_string
if current_char == string_start
let in_string = 0
endif
else " ... and we are not in a string
let in_string = 1
let string_start = current_char
endif
endif
endif
if !in_string && a:line[i] == '('
let parent_depth += 1
endif
if !in_string && a:line[i] == ')'
let parent_depth -= 1
endif
let current_part .= current_char
let i += 1
endwhile
if current_part != ''
call add(methodstack, current_part)
endif
return methodstack
endfunction
function! phpcomplete#GetClassName(start_line, context, current_namespace, imports) " {{{
let class_name_pattern = '[a-zA-Z_\x7f-\xff\\][a-zA-Z_0-9\x7f-\xff\\]*'
let function_name_pattern = '[a-zA-Z_\x7f-\xff][a-zA-Z_0-9\x7f-\xff]*'
let function_invocation_pattern = '[a-zA-Z_\x7f-\xff\\][a-zA-Z_0-9\x7f-\xff\\]*('
let variable_name_pattern = '\$[a-zA-Z_\x7f-\xff][a-zA-Z0-9_\x7f-\xff]*'
let classname_candidate = ''
let class_candidate_namespace = a:current_namespace
let class_candidate_imports = a:imports
let methodstack = phpcomplete#GetMethodStack(a:context)
if a:context =~? '\$this->' || a:context =~? '\(self\|static\)::' || a:context =~? 'parent::'
let i = 1
while i < a:start_line
let line = getline(a:start_line - i)
if line =~ '^}'
return ''
endif
if line =~? '\v^\s*(abstract\s+|final\s+)*\s*class\s'
let class_name = matchstr(line, '\cclass\s\+\zs'.class_name_pattern.'\ze')
let extended_class = matchstr(line, '\cclass\s\+'.class_name_pattern.'\s\+extends\s\+\zs'.class_name_pattern.'\ze')
let classname_candidate = a:context =~? 'parent::' ? extended_class : class_name
if classname_candidate != ''
let [classname_candidate, class_candidate_namespace] = phpcomplete#GetCallChainReturnType(classname_candidate, class_candidate_namespace, class_candidate_imports, methodstack)
return (class_candidate_namespace == '\' || class_candidate_namespace == '') ? classname_candidate : class_candidate_namespace.'\'.classname_candidate
endif
endif
let i += 1
endwhile
elseif a:context =~? '(\s*new\s\+'.class_name_pattern.'\s*)->'
let classname_candidate = matchstr(a:context, '\cnew\s\+\zs'.class_name_pattern.'\ze')
let [classname_candidate, class_candidate_namespace] = phpcomplete#GetCallChainReturnType(classname_candidate, class_candidate_namespace, class_candidate_imports, methodstack)
return (class_candidate_namespace == '\' || class_candidate_namespace == '') ? classname_candidate : class_candidate_namespace.'\'.classname_candidate
elseif get(methodstack, 0) =~# function_invocation_pattern
let function_name = matchstr(methodstack[0], '^\s*\zs'.function_name_pattern)
let function_file = phpcomplete#GetFunctionLocation(function_name, a:current_namespace)
if function_file == ''
let function_file = phpcomplete#GetFunctionLocation(function_name, '\')
endif
if function_file == 'VIMPHP_BUILTINFUNCTION'
let return_type = matchstr(g:php_builtin_functions[function_name.'('], '\v\|\s+\zs.+$')
let classname_candidate = return_type
let class_candidate_namespace = '\'
elseif function_file != '' && filereadable(function_file)
let file_lines = readfile(function_file)
let docblock_str = phpcomplete#GetDocBlock(file_lines, 'function\s*&\?\<'.function_name.'\>')
let return_type_hint = phpcomplete#GetFunctionReturnTypeHint(file_lines, 'function\s*&\?'.function_name.'\>')
let docblock = phpcomplete#ParseDocBlock(docblock_str)
let type = has_key(docblock.return, 'type') ? docblock.return.type : return_type_hint
if type != ''
let classname_candidate = type
let [class_candidate_namespace, function_imports] = phpcomplete#GetCurrentNameSpace(file_lines)
let [classname_candidate, class_candidate_namespace] = phpcomplete#ExpandClassName(classname_candidate, class_candidate_namespace, function_imports)
endif
endif
if classname_candidate != ''
let [classname_candidate, class_candidate_namespace] = phpcomplete#GetCallChainReturnType(classname_candidate, class_candidate_namespace, class_candidate_imports, methodstack)
return (class_candidate_namespace == '\' || class_candidate_namespace == '') ? classname_candidate : class_candidate_namespace.'\'.classname_candidate
endif
else
let object = methodstack[0]
let object_is_array = (object =~ '\v^[^[]+\[' ? 1 : 0)
let object = matchstr(object, variable_name_pattern)
let function_boundary = phpcomplete#GetCurrentFunctionBoundaries()
let search_end_line = max([1, function_boundary[0][0]])
let lines = reverse(getline(search_end_line, a:start_line - 1))
let constant_object = matchstr(a:context, '\zs'.class_name_pattern.'\ze::')
if constant_object != ''
let classname_candidate = constant_object
endif
if classname_candidate == ''
for line in lines
if line =~# '@var\s\+'.object.'\s\+'.class_name_pattern
let classname_candidate = matchstr(line, '@var\s\+'.object.'\s\+\zs'.class_name_pattern.'\(\[\]\)\?')
let [classname_candidate, class_candidate_namespace] = phpcomplete#ExpandClassName(classname_candidate, a:current_namespace, a:imports)
break
endif
if line =~# '@var\s\+'.class_name_pattern.'\s\+'.object
let classname_candidate = matchstr(line, '@var\s\+\zs'.class_name_pattern.'\(\[\]\)\?\ze'.'\s\+'.object)
let [classname_candidate, class_candidate_namespace] = phpcomplete#ExpandClassName(classname_candidate, a:current_namespace, a:imports)
break
endif
endfor
endif
if classname_candidate != ''
let [classname_candidate, class_candidate_namespace] = phpcomplete#GetCallChainReturnType(classname_candidate, class_candidate_namespace, class_candidate_imports, methodstack)
return (class_candidate_namespace == '\' || class_candidate_namespace == '') ? classname_candidate : class_candidate_namespace.'\'.classname_candidate
endif
let i = 1
for line in lines " {{{
if line =~# '^\s*'.object.'\s*=\s*new\s\+'.class_name_pattern && !object_is_array
let classname_candidate = matchstr(line, object.'\c\s*=\s*new\s*\zs'.class_name_pattern.'\ze')
let [classname_candidate, class_candidate_namespace] = phpcomplete#ExpandClassName(classname_candidate, a:current_namespace, a:imports)
break
endif
if line =~# '^\s*'.object.'\s*=&\?\s*'.class_name_pattern.'\s*::\s*getInstance' && !object_is_array
let classname_candidate = matchstr(line, object.'\s*=&\?\s*\zs'.class_name_pattern.'\ze\s*::\s*getInstance')
let [classname_candidate, class_candidate_namespace] = phpcomplete#ExpandClassName(classname_candidate, a:current_namespace, a:imports)
break
endif
if line =~# '^\s*'.object.'\s*=&\?\s*'.class_name_pattern.'\s*::\s*$\?[a-zA-Z_0-9\x7f-\xff]\+'
let classname  = matchstr(line, '^\s*'.object.'\s*=&\?\s*\zs'.class_name_pattern.'\ze\s*::')
if has_key(a:imports, classname) && a:imports[classname].kind == 'c'
let classname = a:imports[classname].name
endif
if has_key(g:php_builtin_classes, tolower(classname))
let sub_methodstack = phpcomplete#GetMethodStack(matchstr(line, '^\s*'.object.'\s*=&\?\s*\s\+\zs.*'))
let [classname_candidate, class_candidate_namespace] = phpcomplete#GetCallChainReturnType(classname, '\', {}, sub_methodstack)
return classname_candidate
else
let [classname, namespace_for_class] = phpcomplete#ExpandClassName(classname, a:current_namespace, a:imports)
let sub_methodstack = phpcomplete#GetMethodStack(matchstr(line, '^\s*'.object.'\s*=&\?\s*\s\+\zs.*'))
let [classname_candidate, class_candidate_namespace] = phpcomplete#GetCallChainReturnType(
\ classname,
\ namespace_for_class,
\ a:imports,
\ sub_methodstack)
return (class_candidate_namespace == '\' || class_candidate_namespace == '') ? classname_candidate : class_candidate_namespace.'\'.classname_candidate
endif
endif
if line =~? 'function\(\s\+'.function_name_pattern.'\)\?\s*('
let function_lines = join(reverse(copy(lines)), " ")
if function_lines =~? 'function\(\s\+'.function_name_pattern.'\)\?\s*(.\{-}'.class_name_pattern.'\s\+'.object && !object_is_array
let f_args = matchstr(function_lines, '\cfunction\(\s\+'.function_name_pattern.'\)\?\s*(\zs.\{-}\ze)')
let args = split(f_args, '\s*\zs,\ze\s*')
for arg in args
if arg =~# object.'\(,\|$\)'
let classname_candidate = matchstr(arg, '\s*\zs'.class_name_pattern.'\ze\s\+'.object)
let [classname_candidate, class_candidate_namespace] = phpcomplete#ExpandClassName(classname_candidate, a:current_namespace, a:imports)
break
endif
endfor
if classname_candidate != ''
break
endif
endif
let match_line = substitute(line, '\\', '\\\\', 'g')
let sccontent = getline(0, a:start_line - i)
let doc_str = phpcomplete#GetDocBlock(sccontent, match_line)
if doc_str != ''
let docblock = phpcomplete#ParseDocBlock(doc_str)
for param in docblock.params
if param.name =~? object
let classname_candidate = matchstr(param.type, class_name_pattern.'\(\[\]\)\?')
let [classname_candidate, class_candidate_namespace] = phpcomplete#ExpandClassName(classname_candidate, a:current_namespace, a:imports)
break
endif
endfor
if classname_candidate != ''
break
endif
endif
endif
if line =~# '^\s*'.object.'\s*=&\?\s\+\(clone\)\?\s*'.variable_name_pattern
let start_col = match(line, '^\s*'.object.'\C\s*=\zs&\?\s\+\(clone\)\?\s*'.variable_name_pattern)
let filelines = reverse(copy(lines))
let [pos, char] = s:getNextCharWithPos(filelines, [len(filelines) - i, start_col])
let chars_read = 1
let last_pos = pos
let real_lines_offset = len(function_boundary) == 1 ? 1 : function_boundary[0][0]
while char != 'EOF' && chars_read < 1000
let last_pos = pos
let [pos, char] = s:getNextCharWithPos(filelines, pos)
let chars_read += 1
if char == ';'
let synIDName = synIDattr(synID(real_lines_offset + pos[0], pos[1] + 1, 0), 'name')
if synIDName !~? 'comment\|string'
break
endif
endif
endwhile
let prev_context = phpcomplete#GetCurrentInstruction(real_lines_offset + last_pos[0], last_pos[1], b:phpbegin)
if prev_context == ''
return
endif
let prev_class = phpcomplete#GetClassName(a:start_line - i, prev_context, a:current_namespace, a:imports)
if stridx(prev_class, '\') != -1
let classname_parts = split(prev_class, '\\\+')
let classname_candidate = classname_parts[-1]
let class_candidate_namespace = join(classname_parts[0:-2], '\')
else
let classname_candidate = prev_class
let class_candidate_namespace = '\'
endif
break
endif
if line =~# '^\s*'.object.'\s*=&\?\s*'.function_invocation_pattern
let start_col = match(line, '\C^\s*'.object.'\s*=\zs&\?\s*'.function_invocation_pattern)
let filelines = reverse(copy(lines))
let [pos, char] = s:getNextCharWithPos(filelines, [len(filelines) - i, start_col])
let chars_read = 1
let last_pos = pos
let real_lines_offset = len(function_boundary) == 1 ? 1 : function_boundary[0][0]
while char != 'EOF' && chars_read < 1000
let last_pos = pos
let [pos, char] = s:getNextCharWithPos(filelines, pos)
let chars_read += 1
if char == ';'
let synIDName = synIDattr(synID(real_lines_offset + pos[0], pos[1] + 1, 0), 'name')
if synIDName !~? 'comment\|string'
break
endif
endif
endwhile
let prev_context = phpcomplete#GetCurrentInstruction(real_lines_offset + last_pos[0], last_pos[1], b:phpbegin)
if prev_context == ''
return
endif
let function_name = matchstr(prev_context, '^'.function_invocation_pattern.'\ze')
let function_name = matchstr(function_name, '^\zs.\+\ze\s*($') " strip the trailing (
let [function_name, function_namespace] = phpcomplete#ExpandClassName(function_name, a:current_namespace, a:imports)
let function_file = phpcomplete#GetFunctionLocation(function_name, function_namespace)
if function_file == ''
let function_file = phpcomplete#GetFunctionLocation(function_name, '\')
endif
if function_file == 'VIMPHP_BUILTINFUNCTION'
let return_type = matchstr(g:php_builtin_functions[function_name.'('], '\v\|\s+\zs.+$')
let classname_candidate = return_type
let class_candidate_namespace = '\'
break
elseif function_file != '' && filereadable(function_file)
let file_lines = readfile(function_file)
let docblock_str = phpcomplete#GetDocBlock(file_lines, 'function\s*&\?\<'.function_name.'\>')
let return_type_hint = phpcomplete#GetFunctionReturnTypeHint(file_lines, 'function\s*&\?'.function_name.'\>')
let docblock = phpcomplete#ParseDocBlock(docblock_str)
let type = has_key(docblock.return, 'type') ? docblock.return.type : return_type_hint
if type != ''
let classname_candidate = type
let [class_candidate_namespace, function_imports] = phpcomplete#GetCurrentNameSpace(file_lines)
let [classname_candidate, class_candidate_namespace] = phpcomplete#ExpandClassName(classname_candidate, class_candidate_namespace, function_imports)
break
endif
endif
endif
if line =~? 'foreach\s*(.\{-}\s\+'.object.'\s*)'
let sub_context = matchstr(line, 'foreach\s*(\s*\zs.\{-}\ze\s\+as')
let prev_class = phpcomplete#GetClassName(a:start_line - i, sub_context, a:current_namespace, a:imports)
if prev_class =~ '\[\]$'
let prev_class = matchstr(prev_class, '\v^[^[]+')
else
return
endif
if stridx(prev_class, '\') != -1
let classname_parts = split(prev_class, '\\\+')
let classname_candidate = classname_parts[-1]
let class_candidate_namespace = join(classname_parts[0:-2], '\')
else
let classname_candidate = prev_class
let class_candidate_namespace = '\'
endif
break
endif
if line =~? 'catch\s*(\zs'.class_name_pattern.'\ze\s\+'.object
let classname = matchstr(line, 'catch\s*(\zs'.class_name_pattern.'\ze\s\+'.object)
if stridx(classname, '\') != -1
let classname_parts = split(classname, '\\\+')
let classname_candidate = classname_parts[-1]
let class_candidate_namespace = join(classname_parts[0:-2], '\')
else
let classname_candidate = classname
let class_candidate_namespace = '\'
endif
break
endif
let i += 1
endfor " }}}
if classname_candidate != ''
let [classname_candidate, class_candidate_namespace] = phpcomplete#GetCallChainReturnType(classname_candidate, class_candidate_namespace, class_candidate_imports, methodstack)
return (class_candidate_namespace == '\' || class_candidate_namespace == '') ? classname_candidate : class_candidate_namespace.'\'.classname_candidate
endif
if g:phpcomplete_search_tags_for_variables
let tags = phpcomplete#GetTaglist('^'.substitute(object, '^\$', '', ''))
if len(tags) == 0
return
else
for tag in tags
if tag.kind ==? 'v' && tag.cmd =~? '=\s*new\s\+\zs'.class_name_pattern.'\ze'
let classname = matchstr(tag.cmd, '=\s*new\s\+\zs'.class_name_pattern.'\ze')
let classname = substitute(classname, '\\\(\_.\)', '\1', 'g')
return classname
endif
endfor
endif
endif
endif
endfunction
function! phpcomplete#GetClassLocation(classname, namespace) " {{{
if has_key(g:php_builtin_classes, tolower(a:classname)) && (a:namespace == '' || a:namespace == '\')
return 'VIMPHP_BUILTINOBJECT'
endif
if has_key(g:php_builtin_interfaces, tolower(a:classname)) && (a:namespace == '' || a:namespace == '\')
return 'VIMPHP_BUILTINOBJECT'
endif
if a:namespace == '' || a:namespace == '\'
let search_namespace = '\'
else
let search_namespace = tolower(a:namespace)
endif
let [current_namespace, imports] = phpcomplete#GetCurrentNameSpace(getline(0, line('.')))
let i = 1
while i < line('.')
let line = getline(line('.')-i)
if line =~? '^\s*\(abstract\s\+\|final\s\+\)*\s*\(class\|interface\|trait\)\s*'.a:classname.'\(\s\+\|$\|{\)' && tolower(current_namespace) == search_namespace
return expand('%:p')
else
let i += 1
continue
endif
endwhile
let no_namespace_candidate = ''
let tags = phpcomplete#GetTaglist('^'.a:classname.'$')
for tag in tags
if tag.kind == 'c' || tag.kind == 'i' || tag.kind == 't'
if !has_key(tag, 'namespace')
let no_namespace_candidate = tag.filename
else
if search_namespace == tolower(tag.namespace)
return tag.filename
endif
endif
endif
endfor
if no_namespace_candidate != ''
return no_namespace_candidate
endif
return ''
endfunction
function! phpcomplete#GetFunctionLocation(function_name, namespace) " {{{
if has_key(g:php_builtin_functions, a:function_name.'(')
return 'VIMPHP_BUILTINFUNCTION'
endif
let i = 1
let buffer_lines = getline(1, line('$'))
for line in buffer_lines
if line =~? '^\s*function\s\+&\?'.a:function_name.'\s*('
return expand('%:p')
endif
endfor
if a:namespace == '' || a:namespace == '\'
let search_namespace = '\'
else
let search_namespace = tolower(a:namespace)
endif
let no_namespace_candidate = ''
let tags = phpcomplete#GetTaglist('\c^'.a:function_name.'$')
for tag in tags
if tag.kind == 'f'
if !has_key(tag, 'namespace')
let no_namespace_candidate = tag.filename
else
if search_namespace == tolower(tag.namespace)
return tag.filename
endif
endif
endif
endfor
if no_namespace_candidate != ''
return no_namespace_candidate
endif
return ''
endfunction
function! phpcomplete#GetCachedClassContents(classlocation, class_name) " {{{
let full_file_path = fnamemodify(a:classlocation, ':p')
let cache_key = full_file_path.'#'.a:class_name.'#'.getftime(full_file_path)
if has_key(s:cache_classstructures, cache_key)
let classcontents = s:cache_classstructures[cache_key]
let valid = 1
for classstructure in classcontents
if getftime(classstructure.file) != classstructure.mtime
let valid = 0
call phpcomplete#ClearCachedClassContents(classstructure.file)
endif
endfor
if valid
return classcontents
else
call remove(s:cache_classstructures, cache_key)
call phpcomplete#ClearCachedClassContents(full_file_path)
endif
else
call phpcomplete#ClearCachedClassContents(full_file_path)
endif
let classfile = readfile(a:classlocation)
let classcontents = phpcomplete#GetClassContentsStructure(full_file_path, classfile, a:class_name)
let s:cache_classstructures[cache_key] = classcontents
return classcontents
endfunction " }}}
function! phpcomplete#ClearCachedClassContents(full_file_path) " {{{
for [cache_key, cached_value] in items(s:cache_classstructures)
if stridx(cache_key, a:full_file_path.'#') == 0
call remove(s:cache_classstructures, cache_key)
endif
endfor
endfunction " }}}
function! phpcomplete#GetClassContentsStructure(file_path, file_lines, class_name) " {{{
let full_file_path = fnamemodify(a:file_path, ':p')
let class_name_pattern = '[a-zA-Z_\x7f-\xff\\][a-zA-Z_0-9\x7f-\xff\\]*'
let cfile = join(a:file_lines, "\n")
let result = []
let phpcomplete_original_window = winnr()
silent! below 1new
silent! 0put =cfile
call search('\c\(class\|interface\|trait\)\_s\+'.a:class_name.'\(\>\|$\)')
let cfline = line('.')
call search('{')
let endline = line('.')
let content = join(getline(cfline, endline), "\n")
if content =~? 'extends'
let extends_string = matchstr(content, '\(class\|interface\)\_s\+'.a:class_name.'\_.\+extends\_s\+\zs\('.class_name_pattern.'\(,\|\_s\)*\)\+\ze\(extends\|{\)')
let extended_classes = map(split(extends_string, '\(,\|\_s\)\+'), 'substitute(v:val, "\\_s\\+", "", "g")')
else
let extended_classes = ''
endif
if content =~? 'implements'
let implements_string = matchstr(content, 'class\_s\+'.a:class_name.'\_.\+implements\_s\+\zs\('.class_name_pattern.'\(,\|\_s\)*\)\+\ze')
let implemented_interfaces = map(split(implements_string, '\(,\|\_s\)\+'), 'substitute(v:val, "\\_s\\+", "", "g")')
else
let implemented_interfaces = []
endif
call searchpair('{', '', '}', 'W')
let class_closing_bracket_line = line('.')
let doc_line = cfline - 1
if getline(doc_line) =~? '^\s*\*/'
while doc_line != 0
if getline(doc_line) =~? '^\s*/\*\*'
let cfline = doc_line
break
endif
let doc_line -= 1
endwhile
endif
let classcontent = join(getline(cfline, class_closing_bracket_line), "\n")
let used_traits = []
call cursor(endline + 1, 1)
let keep_searching = 1
while keep_searching != 0
let [lnum, col] = searchpos('\c^\s\+use\s\+'.class_name_pattern, 'cW', class_closing_bracket_line)
let syn_name = synIDattr(synID(lnum, col, 0), "name")
if syn_name =~? 'string\|comment'
call cursor(lnum + 1, 1)
continue
endif
let trait_line = getline(lnum)
if trait_line !~? ';'
let l = lnum
let search_line = trait_line
while search_line !~? ';' && l > 0
let l += 1
let search_line = getline(l)
let trait_line .= ' '.substitute(search_line, '\(^\s\+\|\s\+$\)', '', 'g')
endwhile
endif
let use_expression = matchstr(trait_line, '^\s*use\s\+\zs.\{-}\ze;')
let use_parts = map(split(use_expression, '\s*,\s*'), 'substitute(v:val, "\\s+", " ", "g")')
let used_traits += map(use_parts, 'substitute(v:val, "\\s", "", "g")')
call cursor(lnum + 1, 1)
if [lnum, col] == [0, 0]
let keep_searching = 0
endif
endwhile
silent! bw! %
let [current_namespace, imports] = phpcomplete#GetCurrentNameSpace(a:file_lines[0:cfline])
exe phpcomplete_original_window.'wincmd w'
call add(result, {
\ 'class': a:class_name,
\ 'content': classcontent,
\ 'namespace': current_namespace,
\ 'imports': imports,
\ 'file': full_file_path,
\ 'mtime': getftime(full_file_path),
\ })
let all_extends = used_traits
if len(extended_classes) > 0
call extend(all_extends, extended_classes)
endif
if len(implemented_interfaces) > 0
call extend(all_extends, implemented_interfaces)
endif
if len(all_extends) > 0
for class in all_extends
let [class, namespace] = phpcomplete#ExpandClassName(class, current_namespace, imports)
if namespace == ''
let namespace = '\'
endif
let classlocation = phpcomplete#GetClassLocation(class, namespace)
if classlocation == "VIMPHP_BUILTINOBJECT"
if has_key(g:php_builtin_classes, tolower(class))
let result += [phpcomplete#GenerateBuiltinClassStub('class', g:php_builtin_classes[tolower(class)])]
endif
if has_key(g:php_builtin_interfaces, tolower(class))
let result += [phpcomplete#GenerateBuiltinClassStub('interface', g:php_builtin_interfaces[tolower(class)])]
endif
elseif classlocation != '' && filereadable(classlocation)
let full_file_path = fnamemodify(classlocation, ':p')
let result += phpcomplete#GetClassContentsStructure(full_file_path, readfile(full_file_path), class)
elseif tolower(current_namespace) == tolower(namespace) && match(join(a:file_lines, "\n"), '\c\(class\|interface\|trait\)\_s\+'.class.'\(\>\|$\)') != -1
let result += phpcomplete#GetClassContentsStructure(full_file_path, a:file_lines, class)
endif
endfor
endif
return result
endfunction
function! phpcomplete#GetClassContents(classlocation, class_name) " {{{
let classcontents = phpcomplete#GetCachedClassContents(a:classlocation, a:class_name)
let result = []
for classstructure in classcontents
call add(result, classstructure.content)
endfor
return join(result, "\n")
endfunction
function! phpcomplete#GenerateBuiltinClassStub(type, class_info) " {{{
let re = a:type.' '.a:class_info['name']." {"
if has_key(a:class_info, 'constants')
for [name, initializer] in items(a:class_info.constants)
let re .= "\n\tconst ".name." = ".initializer.";"
endfor
endif
if has_key(a:class_info, 'properties')
for [name, info] in items(a:class_info.properties)
let re .= "\n\t// @var $".name." ".info.type
let re .= "\n\tpublic $".name.";"
endfor
endif
if has_key(a:class_info, 'static_properties')
for [name, info] in items(a:class_info.static_properties)
let re .= "\n\t// @var ".name." ".info.type
let re .= "\n\tpublic static ".name." = ".info.initializer.";"
endfor
endif
if has_key(a:class_info, 'methods')
for [name, info] in items(a:class_info.methods)
if name =~ '^__'
continue
endif
let re .= "\n\t/**"
let re .= "\n\t * ".name
let re .= "\n\t *"
let re .= "\n\t * @return ".info.return_type
let re .= "\n\t */"
let re .= "\n\tpublic function ".name."(".info.signature."){"
let re .= "\n\t}"
endfor
endif
if has_key(a:class_info, 'static_methods')
for [name, info] in items(a:class_info.static_methods)
let re .= "\n\t/**"
let re .= "\n\t * ".name
let re .= "\n\t *"
let re .= "\n\t * @return ".info.return_type
let re .= "\n\t */"
let re .= "\n\tpublic static function ".name."(".info.signature."){"
let re .= "\n\t}"
endfor
endif
let re .= "\n}"
return { a:type : a:class_info['name'],
\ 'content': re,
\ 'namespace': '',
\ 'imports': {},
\ 'file': 'VIMPHP_BUILTINOBJECT',
\ 'mtime': 0,
\ }
endfunction " }}}
function! phpcomplete#GetDocBlock(sccontent, search) " {{{
let i = 0
let l = 0
let comment_start = -1
let comment_end = -1
let sccontent_len = len(a:sccontent)
while (i < sccontent_len)
let line = a:sccontent[i]
if line =~? a:search
if line =~? '@property'
let doc_line = i
while doc_line != sccontent_len - 1
if a:sccontent[doc_line] =~? '^\s*\*/'
let l = doc_line
break
endif
let doc_line += 1
endwhile
else
let l = i - 1
endif
while l != 0
let line = a:sccontent[l]
if line =~? '^\s*\/\*\*.\+\*\/\s*$'
return substitute(line, '\v^\s*(\/\*\*\s*)|(\s*\*\/)\s*$', '', 'g')
elseif line =~? '^\s*\*/'
let comment_end = l
break
elseif line !~? '^\s*$'
break
endif
let l -= 1
endwhile
if comment_end == -1
return ''
end
while l >= 0
let line = a:sccontent[l]
if line =~? '^\s*/\*\*'
let comment_start = l
break
endif
let l -= 1
endwhile
if comment_start == -1
return ''
end
let comment_start += 1 " we dont need the /**
let comment_end   -= 1 " we dont need the */
let docblock = join(map(copy(a:sccontent[comment_start :comment_end]), 'substitute(v:val, "^\\s*\\*\\s*", "", "")'), "\n")
return docblock
endif
let i += 1
endwhile
return ''
endfunction
function! phpcomplete#ParseDocBlock(docblock) " {{{
let res = {
\ 'description': '',
\ 'params': [],
\ 'return': {},
\ 'throws': [],
\ 'var': {},
\ 'properties': [],
\ }
let res.description = substitute(matchstr(a:docblock, '\zs\_.\{-}\ze\(@type\|@var\|@param\|@return\|$\)'), '\(^\_s*\|\_s*$\)', '', 'g')
let docblock_lines = split(a:docblock, "\n")
let param_lines = filter(copy(docblock_lines), 'v:val =~? "^@param"')
for param_line in param_lines
let parts = matchlist(param_line, '@param\s\+\(\S\+\)\s\+\(\S\+\)\s*\(.*\)')
if len(parts) > 0
call add(res.params, {
\ 'line': parts[0],
\ 'type': phpcomplete#GetTypeFromDocBlockParam(get(parts, 1, '')),
\ 'name': get(parts, 2, ''),
\ 'description': get(parts, 3, '')})
endif
endfor
let return_line = filter(copy(docblock_lines), 'v:val =~? "^@return"')
if len(return_line) > 0
let return_parts = matchlist(return_line[0], '@return\s\+\(\S\+\)\s*\(.*\)')
let res['return'] = {
\ 'line': return_parts[0],
\ 'type': phpcomplete#GetTypeFromDocBlockParam(get(return_parts, 1, '')),
\ 'description': get(return_parts, 2, '')}
endif
let exception_lines = filter(copy(docblock_lines), 'v:val =~? "^\\(@throws\\|@exception\\)"')
for exception_line in exception_lines
let parts = matchlist(exception_line, '^\(@throws\|@exception\)\s\+\(\S\+\)\s*\(.*\)')
if len(parts) > 0
call add(res.throws, {
\ 'line': parts[0],
\ 'type': phpcomplete#GetTypeFromDocBlockParam(get(parts, 2, '')),
\ 'description': get(parts, 3, '')})
endif
endfor
let var_line = filter(copy(docblock_lines), 'v:val =~? "^\\(@var\\|@type\\)"')
if len(var_line) > 0
let var_parts = matchlist(var_line[0], '\(@var\|@type\)\s\+\(\S\+\)\s*\(.*\)')
let res['var'] = {
\ 'line': var_parts[0],
\ 'type': phpcomplete#GetTypeFromDocBlockParam(get(var_parts, 2, '')),
\ 'description': get(var_parts, 3, '')}
endif
let property_lines = filter(copy(docblock_lines), 'v:val =~? "^@property"')
for property_line in property_lines
let parts = matchlist(property_line, '\(@property\)\s\+\(\S\+\)\s*\(.*\)')
if len(parts) > 0
call add(res.properties, {
\ 'line': parts[0],
\ 'type': phpcomplete#GetTypeFromDocBlockParam(get(parts, 2, '')),
\ 'description': get(parts, 3, '')})
endif
endfor
return res
endfunction
function! phpcomplete#GetFunctionReturnTypeHint(sccontent, search)
let i = 0
let l = 0
let function_line_start = -1
let function_line_end = -1
let sccontent_len = len(a:sccontent)
let return_type = ''
while (i < sccontent_len)
let line = a:sccontent[i]
if line =~? a:search
let l = i
let function_line_start = i
while l < sccontent_len
let line = a:sccontent[l]
if line =~? '\V{'
let function_line_end = l
break
endif
let l += 1
endwhile
break
endif
let i += 1
endwhile
if function_line_start != -1 && function_line_end != -1
let function_line = join(a:sccontent[function_line_start :function_line_end], " ")
let class_name_pattern = '[a-zA-Z_\x7f-\xff\\][a-zA-Z_0-9\x7f-\xff\\]*'
let return_type = matchstr(function_line, '\c\s*:\s*\zs'.class_name_pattern.'\ze\s*{')
endif
return return_type
endfunction
function! phpcomplete#GetTypeFromDocBlockParam(docblock_type) " {{{
if a:docblock_type !~ '|'
return a:docblock_type
endif
let primitive_types = [
\ 'string', 'float', 'double', 'int',
\ 'scalar', 'array', 'bool', 'void', 'mixed',
\ 'null', 'callable', 'resource', 'object']
let primitive_types += map(copy(primitive_types), 'v:val."[]"')
let types = split(a:docblock_type, '|')
for type in types
if index(primitive_types, type) == -1
return type
endif
endfor
return types[0]
endfunction
function! phpcomplete#FormatDocBlock(info) " {{{
let res = ''
if len(a:info.description)
let res .= "Description:\n".join(map(split(a:info['description'], "\n"), '"\t".v:val'), "\n")."\n"
endif
if len(a:info.params)
let res .= "\nArguments:\n"
for arginfo in a:info.params
let res .= "\t".arginfo['name'].' '.arginfo['type']
if len(arginfo.description) > 0
let res .= ': '.arginfo['description']
endif
let res .= "\n"
endfor
endif
if has_key(a:info.return, 'type')
let res .= "\nReturn:\n\t".a:info['return']['type']
if len(a:info.return.description) > 0
let res .= ": ".a:info['return']['description']
endif
let res .= "\n"
endif
if len(a:info.throws)
let res .= "\nThrows:\n"
for excinfo in a:info.throws
let res .= "\t".excinfo['type']
if len(excinfo['description']) > 0
let res .= ": ".excinfo['description']
endif
let res .= "\n"
endfor
endif
if has_key(a:info.var, 'type')
let res .= "Type:\n\t".a:info['var']['type']."\n"
if len(a:info['var']['description']) > 0
let res .= ': '.a:info['var']['description']
endif
endif
return res
endfunction!
function! phpcomplete#GetCurrentNameSpace(file_lines) " {{{
let original_window = winnr()
silent! below 1new
silent! 0put =a:file_lines
normal! G
while 1
let block_start_pos = searchpos('\c\(class\|trait\|function\|interface\)\s\+\_.\{-}\zs{', 'Web')
if block_start_pos == [0, 0]
break
endif
let block_end_pos = searchpairpos('{', '', '}\|\%$', 'W', 'synIDattr(synID(line("."), col("."), 0), "name") =~? "string\\|comment"')
if block_end_pos != [0, 0]
silent! exec block_start_pos[0].','.block_end_pos[0].'d _'
else
silent! exec block_start_pos[0].',$d _'
endif
endwhile
normal! G
let file_lines = reverse(getline(1, line('.') - 1))
silent! bw! %
exe original_window.'wincmd w'
let namespace_name_pattern = '[a-zA-Z_\x7f-\xff\\][a-zA-Z_0-9\x7f-\xff\\]*'
let i = 0
let file_length = len(file_lines)
let imports = {}
let current_namespace = '\'
while i < file_length
let line = file_lines[i]
if line =~? '^\(<?php\)\?\s*namespace\s*'.namespace_name_pattern
let current_namespace = matchstr(line, '\c^\(<?php\)\?\s*namespace\s*\zs'.namespace_name_pattern.'\ze')
break
endif
if line =~? '^\s*use\>'
if line =~? ';'
let use_line = line
else
let l = i
let search_line = line
let use_line = line
while search_line !~? ';' && l > 0
let l -= 1
let search_line = file_lines[l]
let use_line .= ' '.substitute(search_line, '\(^\s\+\|\s\+$\)', '', 'g')
endwhile
endif
let use_expression = matchstr(use_line, '^\c\s*use\s\+\zs.\{-}\ze;')
let use_parts = map(split(use_expression, '\s*,\s*'), 'substitute(v:val, "\\s+", " ", "g")')
for part in use_parts
if part =~? '\s\+as\s\+'
let [object, name] = split(part, '\s\+as\s\+\c')
let object = substitute(object, '^\\', '', '')
let name   = substitute(name, '^\\', '', '')
else
let object = part
let name = part
let object = substitute(object, '^\\', '', '')
let name   = substitute(name, '^\\', '', '')
if name =~? '\\'
let	name = matchstr(name, '\\\zs[^\\]\+\ze$')
endif
endif
let imports[name] = {'name': object, 'kind': ''}
endfor
for [key, import] in items(imports)
if import.name =~ '\\'
let patched_ctags_detected = 0
let [classname, namespace_for_classes] = phpcomplete#ExpandClassName(import.name, '\', {})
let namespace_name_candidate = substitute(import.name, '\\', '\\\\', 'g')
let tags = phpcomplete#GetTaglist('^\('.namespace_name_candidate.'\|'.classname.'\)$')
if len(tags) > 0
for tag in tags
if tag.kind == 'n' && tag.name == import.name
call extend(import, tag)
let import['builtin'] = 0
let patched_ctags_detected = 1
break
endif
if (tag.kind == 'c' || tag.kind == 'i' || tag.kind == 't') && tag.name == classname
if has_key(tag, 'namespace')
let patched_ctags_detected = 1
if tag.namespace == namespace_for_classes
call extend(import, tag)
let import['builtin'] = 0
break
endif
elseif !exists('no_namespace_candidate')
let tag.namespace = namespace_for_classes
let no_namespace_candidate = tag
endif
endif
endfor
if exists('no_namespace_candidate') && !patched_ctags_detected
call extend(import, no_namespace_candidate)
let import['builtin'] = 0
endif
else
let ns = matchstr(import.name, '\c\zs[a-zA-Z0-9\\]\+\ze\\' . name)
if len(ns) > 0
let import['name'] = name
let import['namespace'] = ns
let import['builtin'] = 0
endif
endif
else
if has_key(g:php_builtin_classnames, tolower(import.name))
let import['kind'] = 'c'
let import['builtin'] = 1
elseif has_key(g:php_builtin_interfacenames, tolower(import.name))
let import['kind'] = 'i'
let import['builtin'] = 1
else
let tags = phpcomplete#GetTaglist('^'.import['name'].'$')
for tag in tags
if !has_key(tag, 'namespace') && (tag.kind == 'n' || tag.kind == 'c' || tag.kind == 'i' || tag.kind == 't')
call extend(import, tag)
let import['builtin'] = 0
break
endif
endfor
endif
endif
if exists('no_namespace_candidate')
unlet no_namespace_candidate
endif
endfor
endif
let i += 1
endwhile
let sorted_imports = {}
for name in sort(keys(imports))
let sorted_imports[name] = imports[name]
endfor
return [current_namespace, sorted_imports]
endfunction
function! phpcomplete#GetCurrentFunctionBoundaries() " {{{
let old_cursor_pos = [line('.'), col('.')]
let current_line_no = old_cursor_pos[0]
let function_pattern = '\c\(.*\%#\)\@!\_^\s*\zs\(abstract\s\+\|final\s\+\|private\s\+\|protected\s\+\|public\s\+\|static\s\+\)*function\_.\{-}(\_.\{-})\_.\{-}{'
let func_start_pos = searchpos(function_pattern, 'Wbc')
if func_start_pos == [0, 0]
call cursor(old_cursor_pos[0], old_cursor_pos[1])
return 0
endif
call search('\cfunction\_.\{-}(\_.\{-})\_.\{-}{', 'Wce')
let func_end_pos = searchpairpos('{', '', '}', 'W')
if func_end_pos == [0, 0]
let func_end_pos = [line('$'), len(getline(line('$')))]
endif
if func_start_pos[0] <= current_line_no && current_line_no <= func_end_pos[0]
call cursor(old_cursor_pos[0], old_cursor_pos[1])
return [func_start_pos, func_end_pos]
endif
call cursor(old_cursor_pos[0], old_cursor_pos[1])
return 0
endfunction
function! phpcomplete#ExpandClassName(classname, current_namespace, imports) " {{{
if has_key(a:imports, a:classname) && (a:imports[a:classname].kind == 'c' || a:imports[a:classname].kind == 'i' || a:imports[a:classname].kind == 't')
let namespace = has_key(a:imports[a:classname], 'namespace') ? a:imports[a:classname].namespace : ''
return [a:imports[a:classname].name, namespace]
endif
if a:classname !~ '^\' && a:classname =~ '\\'
let classname_parts = split(a:classname, '\\\+')
if has_key(a:imports, classname_parts[0]) && a:imports[classname_parts[0]].kind == 'n'
let classname_parts[0] = a:imports[classname_parts[0]].name
let namespace = join(classname_parts[0:-2], '\')
let classname = classname_parts[-1]
return [classname, namespace]
endif
endif
let namespace = ''
let classname = a:classname
if a:classname =~ '\\' || (a:current_namespace != '\' && a:current_namespace != '')
if a:classname !~ '^\'
let classname = a:current_namespace.'\'.substitute(a:classname, '^\\', '', '')
else
let classname = substitute(a:classname, '^\\', '', '')
endif
let classname_parts = split(classname, '\\\+')
if len(classname_parts) > 1
let namespace = join(classname_parts[0:-2], '\')
let classname = classname_parts[-1]
endif
endif
return [classname, namespace]
endfunction
function! phpcomplete#LoadData() " {{{
let g:php_keywords={'PHP_SELF':'','argv':'','argc':'','GATEWAY_INTERFACE':'','SERVER_ADDR':'','SERVER_NAME':'','SERVER_SOFTWARE':'','SERVER_PROTOCOL':'','REQUEST_METHOD':'','REQUEST_TIME':'','QUERY_STRING':'','DOCUMENT_ROOT':'','HTTP_ACCEPT':'','HTTP_ACCEPT_CHARSET':'','HTTP_ACCEPT_ENCODING':'','HTTP_ACCEPT_LANGUAGE':'','HTTP_CONNECTION':'','HTTP_POST':'','HTTP_REFERER':'','HTTP_USER_AGENT':'','HTTPS':'','REMOTE_ADDR':'','REMOTE_HOST':'','REMOTE_PORT':'','SCRIPT_FILENAME':'','SERVER_ADMIN':'','SERVER_PORT':'','SERVER_SIGNATURE':'','PATH_TRANSLATED':'','SCRIPT_NAME':'','REQUEST_URI':'','PHP_AUTH_DIGEST':'','PHP_AUTH_USER':'','PHP_AUTH_PW':'','AUTH_TYPE':'','and':'','or':'','xor':'','__FILE__':'','exception':'','__LINE__':'','as':'','break':'','case':'','class':'','const':'','continue':'','declare':'','default':'','do':'','echo':'','else':'','elseif':'','enddeclare':'','endfor':'','endforeach':'','endif':'','endswitch':'','endwhile':'','extends':'','for':'','foreach':'','function':'','global':'','if':'','new':'','static':'','switch':'','use':'','var':'','while':'','final':'','php_user_filter':'','interface':'','implements':'','public':'','private':'','protected':'','abstract':'','clone':'','try':'','catch':'','throw':'','cfunction':'','old_function':'','this':'','INI_USER': '','INI_PERDIR': '','INI_SYSTEM': '','INI_ALL': '','ABDAY_1': '','ABDAY_2': '','ABDAY_3': '','ABDAY_4': '','ABDAY_5': '','ABDAY_6': '','ABDAY_7': '','DAY_1': '','DAY_2': '','DAY_3': '','DAY_4': '','DAY_5': '','DAY_6': '','DAY_7': '','ABMON_1': '','ABMON_2': '','ABMON_3': '','ABMON_4': '','ABMON_5': '','ABMON_6': '','ABMON_7': '','ABMON_8': '','ABMON_9': '','ABMON_10': '','ABMON_11': '','ABMON_12': '','MON_1': '','MON_2': '','MON_3': '','MON_4': '','MON_5': '','MON_6': '','MON_7': '','MON_8': '','MON_9': '','MON_10': '','MON_11': '','MON_12': '','AM_STR': '','D_T_FMT': '','ALT_DIGITS': '',}
let g:php_builtin_functions = {}
let g:php_builtin_classes = {}
let g:php_builtin_interfaces = {}
let g:php_constants = {}
let g:php_builtin_object_functions = {}
let g:php_builtin_classnames = {}
let required_class_hash_keys = ['constants', 'properties', 'static_properties', 'methods', 'static_methods']
let g:php_builtin_interfacenames = {}
let php_control = {
\ 'include(': 'string filename | resource',
\ 'include_once(': 'string filename | resource',
\ 'require(': 'string filename | resource',
\ 'require_once(': 'string filename | resource',
\ }
call extend(g:php_builtin_functions, php_control)
let g:php_builtin_vars ={
\ '$GLOBALS':'',
\ '$_SERVER':'',
\ '$_GET':'',
\ '$_POST':'',
\ '$_COOKIE':'',
\ '$_FILES':'',
\ '$_ENV':'',
\ '$_REQUEST':'',
\ '$_SESSION':'',
\ '$HTTP_SERVER_VARS':'',
\ '$HTTP_ENV_VARS':'',
\ '$HTTP_COOKIE_VARS':'',
\ '$HTTP_GET_VARS':'',
\ '$HTTP_POST_VARS':'',
\ '$HTTP_POST_FILES':'',
\ '$HTTP_SESSION_VARS':'',
\ '$php_errormsg':'',
\ '$this':'',
\ }
endfunction
