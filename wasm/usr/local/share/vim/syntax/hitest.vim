let s:hidden      = &hidden
let s:lazyredraw  = &lazyredraw
let s:more	  = &more
let s:report      = &report
let s:whichwrap   = &whichwrap
let s:shortmess   = &shortmess
let s:wrapscan    = &wrapscan
let s:register_a  = @a
let s:register_se = @/
set hidden lazyredraw nomore report=99999 shortmess=aoOstTW wrapscan
set whichwrap&
redir @a
silent highlight
redir END
if line("$") != 1 || getline(1) != ""
new
endif
edit Highlight\ test
setlocal autoindent noexpandtab formatoptions=t shiftwidth=18 noswapfile tabstop=18
let &textwidth=&columns
% delete
put a
silent! g/ cleared$/d
g/xxx /s///e
global! /links to/ substitute /\s.*$//e
% substitute /^\(\w\+\)\n\s*\(links to.*\)/\1\t\2/e
global /links to/ move $
% substitute /^\(\w\+\)\s*\(links to\)\s*\(\w\+\)$/\3\t\2 \1/e
silent! global /links to/ normal mz3ElD0#$p'zdd
global /^ *$/ delete
% substitute /^[^ ]*/syn keyword &\t&/
syntax clear
% yank a
@a
% substitute /^syn keyword //
global /^/ exe "normal Wi\<CR>\t\eAA\ex"
global /^\S/ join
let b:various = &highlight.',:Normal,:Cursor,:,'
let b:i = 1
while b:various =~ ':'.substitute(getline(b:i), '\s.*$', ',', '')
let b:i = b:i + 1
if b:i > line("$") | break | endif
endwhile
call append(0, "Highlighting groups for various occasions")
call append(1, "-----------------------------------------")
if b:i < line("$")-1
let b:synhead = "Syntax highlighting groups"
if exists("hitest_filetypes")
redir @a
let
redir END
let @a = substitute(@a, 'did_\(\w\+\)_syn\w*_inits\s*#1', ', \1', 'g')
let @a = substitute(@a, "\n\\w[^\n]*", '', 'g')
let @a = substitute(@a, "\n", '', 'g')
let @a = substitute(@a, '^,', '', 'g')
if @a != ""
let b:synhead = b:synhead." - filetype"
if @a =~ ','
let b:synhead = b:synhead."s"
endif
let b:synhead = b:synhead.":".@a
endif
endif
call append(b:i+1, "")
call append(b:i+2, b:synhead)
call append(b:i+3, substitute(b:synhead, '.', '-', 'g'))
endif
nohlsearch
normal 0
set nomodified
0 append
.
let &hidden      = s:hidden
let &lazyredraw  = s:lazyredraw
let &more	 = s:more
let &report	 = s:report
let &shortmess	 = s:shortmess
let &whichwrap   = s:whichwrap
let &wrapscan	 = s:wrapscan
let @a		 = s:register_a
call histdel("search", -1)
let @/ = s:register_se
unlet s:hidden s:lazyredraw s:more s:report s:shortmess
unlet s:whichwrap s:wrapscan s:register_a s:register_se
