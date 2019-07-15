if exists("b:current_syntax")
finish
endif
syntax match  flexwikiWord          /\%(_\?\([A-Z]\{2,}[a-z0-9]\+[A-Za-z0-9]*\)\|\([A-Z][a-z0-9]\+[A-Za-z0-9]*[A-Z]\+[A-Za-z0-9]*\)\)/
syntax match  flexwikiWord          /\[[[:alnum:]\s]\+\]/
syntax match flexwikiLink           `\("[^"(]\+\((\([^)]\+\))\)\?":\)\?\(https\?\|ftp\|gopher\|telnet\|file\|notes\|ms-help\):\(\(\(//\)\|\(\\\\\)\)\+[A-Za-z0-9:#@%/;$~_?+-=.&\-\\\\]*\)`
syntax match flexwikiBold           /\(^\|\W\)\zs\*\([^ ].\{-}\)\*/
syntax match flexwikiBold           /'''\([^'].\{-}\)'''/
syntax match flexwikiItalic         /\(^\|\W\)\zs_\([^ ].\{-}\)_/
syntax match flexwikiItalic         /''\([^'].\{-}\)''/
syntax match flexwikiDeEmphasis     /``\([^`].\{-}\)``/
syntax match flexwikiCode           /\(^\|\s\|(\|\[\)\zs@\([^@]\+\)@/
syntax match flexwikiDelText        /\(^\|\s\+\)\zs-\([^ <a ]\|[^ <img ]\|[^ -].*\)-/
syntax match flexwikiInsText        /\(^\|\W\)\zs+\([^ ].\{-}\)+/
syntax match flexwikiSuperScript    /\(^\|\W\)\zs^\([^ ].\{-}\)^/
syntax match flexwikiSubScript      /\(^\|\W\)\zs\~\([^ ].\{-}\)\~/
syntax match flexwikiCitation       /\(^\|\W\)\zs??\([^ ].\{-}\)??/
syntax match flexwikiEmoticons      /\((.)\|:[()|$@]\|:-[DOPS()\]|$@]\|;)\|:'(\)/
syntax cluster flexwikiText contains=flexwikiItalic,flexwikiBold,flexwikiCode,flexwikiDeEmphasis,flexwikiDelText,flexwikiInsText,flexwikiSuperScript,flexwikiSubScript,flexwikiCitation,flexwikiLink,flexwikiWord,flexwikiEmoticons
syntax match flexwikiSingleLineProperty /^:\?[A-Z_][_a-zA-Z0-9]\+:/
syntax match flexwikiH1             /^!.*$/
syntax match flexwikiH2             /^!!.*$/
syntax match flexwikiH3             /^!!!.*$/
syntax match flexwikiH4             /^!!!!.*$/
syntax match flexwikiH5             /^!!!!!.*$/
syntax match flexwikiH6             /^!!!!!!.*$/
syntax match flexwikiHR             /^----.*$/
syntax match flexwikiEscape         /"".\{-}""/
syntax match flexwikiTable          /||/
syntax match flexwikiList           /^\(\t\| \{8}\)\s*\(\*\|1\.\).*$/   contains=@flexwikiText
syntax match flexwikiPre            /^[ \t]\+[^ \t*1].*$/
hi def link flexwikiH1                    Title
hi def link flexwikiH2                    flexwikiH1
hi def link flexwikiH3                    flexwikiH2
hi def link flexwikiH4                    flexwikiH3
hi def link flexwikiH5                    flexwikiH4
hi def link flexwikiH6                    flexwikiH5
hi def link flexwikiHR                    flexwikiH6
hi def flexwikiBold                       term=bold cterm=bold gui=bold
hi def flexwikiItalic                     term=italic cterm=italic gui=italic
hi def link flexwikiCode                  Statement
hi def link flexwikiWord                  Underlined
hi def link flexwikiEscape                Todo
hi def link flexwikiPre                   PreProc
hi def link flexwikiLink                  Underlined
hi def link flexwikiList                  Type
hi def link flexwikiTable                 Type
hi def link flexwikiEmoticons             Constant
hi def link flexwikiDelText               Comment
hi def link flexwikiDeEmphasis            Comment
hi def link flexwikiInsText               Constant
hi def link flexwikiSuperScript           Constant
hi def link flexwikiSubScript             Constant
hi def link flexwikiCitation              Constant
hi def link flexwikiSingleLineProperty    Identifier
let b:current_syntax="FlexWiki"
