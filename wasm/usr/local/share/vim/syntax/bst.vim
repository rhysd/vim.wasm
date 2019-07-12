if exists("b:current_syntax")
finish
endif
setlocal iskeyword=48-57,#,$,',.,A-Z,a-z
syn case ignore
syn match   bstString +"[^"]*\%("\|$\)+ contains=bstField,bstType,bstError
syn match   bstError     '[^"]\%#\@!$' contained
syn match   bstNumber         "#-\=\d\+\>"
syn keyword bstNumber         entry.max$ global.max$
syn match   bstComment        "%.*"
syn keyword bstCommand        ENTRY FUNCTION INTEGERS MACRO STRINGS
syn keyword bstCommand        READ EXECUTE ITERATE REVERSE SORT
syn match   bstBuiltIn        "\s[-<>=+*]\|\s:="
syn keyword bstBuiltIn        add.period$
syn keyword bstBuiltIn        call.type$ change.case$ chr.to.int$ cite$
syn keyword bstBuiltIn        duplicate$ empty$ format.name$
syn keyword bstBuiltIn        if$ int.to.chr$ int.to.str$
syn keyword bstBuiltIn        missing$
syn keyword bstBuiltIn        newline$ num.names$
syn keyword bstBuiltIn        pop$ preamble$ purify$ quote$
syn keyword bstBuiltIn        skip$ stack$ substring$ swap$
syn keyword bstBuiltIn        text.length$ text.prefix$ top$ type$
syn keyword bstBuiltIn        warning$ while$ width$ write$
syn match   bstIdentifier     "'\k*"
syn keyword bstType           article book booklet conference
syn keyword bstType           inbook incollection inproceedings
syn keyword bstType           manual mastersthesis misc
syn keyword bstType           phdthesis proceedings
syn keyword bstType           techreport unpublished
syn keyword bstField          abbr address annote author
syn keyword bstField          booktitle chapter crossref comment
syn keyword bstField          edition editor
syn keyword bstField          howpublished institution journal key month
syn keyword bstField          note number
syn keyword bstField          organization
syn keyword bstField          pages publisher
syn keyword bstField          school series
syn keyword bstField          title type
syn keyword bstField          volume year
hi def link bstComment           Comment
hi def link bstString            String
hi def link bstCommand           PreProc
hi def link bstBuiltIn           Statement
hi def link bstField             Special
hi def link bstNumber            Number
hi def link bstType              Type
hi def link bstIdentifier        Identifier
hi def link bstError             Error
let b:current_syntax = "bst"
