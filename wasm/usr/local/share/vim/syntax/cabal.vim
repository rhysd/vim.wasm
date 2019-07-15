if exists("b:current_syntax")
finish
endif
let s:cpo_save = &cpo
set cpo&vim
syn iskeyword @,48-57,192-255,-
syn case match
syn keyword cabalConditional	if else
syn keyword cabalFunction	os arche impl flag
syn match cabalComment		/--.*$/
syn case ignore
syn keyword cabalCategory contained
\ executable
\ library
\ benchmark
\ test-suite
\ source-repository
\ flag
\ custom-setup
syn match cabalCategoryTitle contained /[^{]*\ze{\?/
syn match cabalCategoryRegion
\ contains=cabalCategory,cabalCategoryTitle
\ nextgroup=cabalCategory skipwhite
\ /^\c\s*\(contained\|executable\|library\|benchmark\|test-suite\|source-repository\|flag\|custom-setup\)\+\s*\%(.*$\|$\)/
syn keyword cabalTruth true false
syn region cabalStatementRegion start=+^\s*\(--\)\@<!\k\+\s*:+ end=+:+
syn keyword cabalStatement contained containedin=cabalStatementRegion
\ default-language
\ default-extensions
\ author
\ branch
\ bug-reports
\ build-depends
\ build-tools
\ build-type
\ buildable
\ c-sources
\ cabal-version
\ category
\ cc-options
\ copyright
\ cpp-options
\ data-dir
\ data-files
\ default
\ description
\ executable
\ exposed-modules
\ exposed
\ extensions
\ extra-tmp-files
\ extra-doc-files
\ extra-lib-dirs
\ extra-libraries
\ extra-source-files
\ exta-tmp-files
\ for example
\ frameworks
\ ghc-options
\ ghc-prof-options
\ ghc-shared-options
\ homepage
\ hs-source-dirs
\ hugs-options
\ include-dirs
\ includes
\ install-includes
\ ld-options
\ license
\ license-file
\ location
\ main-is
\ maintainer
\ manual
\ module
\ name
\ nhc98-options
\ other-extensions
\ other-modules
\ package-url
\ pkgconfig-depends
\ setup-depends
\ stability
\ subdir
\ synopsis
\ tag
\ tested-with
\ type
\ version
\ virtual-modules
syn match cabalOperator /&&\|||\|!/
syn match cabalVersionOperator contained
\ /!\|==\|\^\?>=\|<=\|<\|>/
syn match cabalVersion contained
\ /[%$_-]\@<!\<\d\+\%(\.\d\+\)*\%(\.\*\)\?\>/
syn match cabalVersionRegionA
\ contains=cabalVersionOperator,cabalVersion
\ keepend
\ /\%(==\|\^\?>=\|<=\|<\|>\)\s*\d\+\%(\.\d\+\)*\%(\.\*\)\?\>/
syn match cabalVersionRegionB
\ contains=cabalStatementRegion,cabalVersionOperator,cabalVersion
\ /^\s*\%(cabal-\)\?version\s*:.*$/
syn keyword cabalLanguage Haskell98 Haskell2010
syn match cabalName contained /:\@<=.*/
syn match cabalNameRegion
\ contains=cabalStatementRegion,cabalName
\ nextgroup=cabalStatementRegion
\ oneline
\ /^\c\s*name\s*:.*$/
syn match cabalAuthor contained /:\@<=.*/
syn match cabalAuthorRegion
\ contains=cabalStatementRegion,cabalStatement,cabalAuthor
\ nextgroup=cabalStatementRegion
\ oneline
\ /^\c\s*author\s*:.*$/
syn match cabalMaintainer contained /:\@<=.*/
syn match cabalMaintainerRegion
\ contains=cabalStatementRegion,cabalStatement,cabalMaintainer
\ nextgroup=cabalStatementRegion
\ oneline
\ /^\c\s*maintainer\s*:.*$/
syn match cabalLicense contained /:\@<=.*/
syn match cabalLicenseRegion
\ contains=cabalStatementRegion,cabalStatement,cabalLicense
\ nextgroup=cabalStatementRegion
\ oneline
\ /^\c\s*license\s*:.*$/
syn match cabalLicenseFile contained /:\@<=.*/
syn match cabalLicenseFileRegion
\ contains=cabalStatementRegion,cabalStatement,cabalLicenseFile
\ nextgroup=cabalStatementRegion
\ oneline
\ /^\c\s*license-file\s*:.*$/
syn keyword cabalCompiler contained ghc nhc yhc hugs hbc helium jhc lhc
syn match cabalTestedWithRegion
\ contains=cabalStatementRegion,cabalStatement,cabalCompiler,cabalVersionRegionA
\ nextgroup=cabalStatementRegion
\ oneline
\ /^\c\s*tested-with\s*:.*$/
syn keyword cabalBuildType contained
\ simple custom configure
syn match cabalBuildTypeRegion
\ contains=cabalStatementRegion,cabalStatement,cabalBuildType
\ nextgroup=cabalStatementRegion
\ /^\c\s*build-type\s*:.*$/
hi def link cabalName	      Title
hi def link cabalAuthor	      Normal
hi def link cabalMaintainer   Normal
hi def link cabalCategoryTitle Title
hi def link cabalLicense      Normal
hi def link cabalLicenseFile  Normal
hi def link cabalBuildType    Keyword
hi def link cabalVersion      Number
hi def link cabalTruth        Boolean
hi def link cabalComment      Comment
hi def link cabalStatement    Statement
hi def link cabalLanguage     Type
hi def link cabalCategory     Type
hi def link cabalFunction     Function
hi def link cabalConditional  Conditional
hi def link cabalOperator     Operator
hi def link cabalVersionOperator Operator
hi def link cabalCompiler     Constant
let b:current_syntax = "cabal"
let &cpo = s:cpo_save
unlet! s:cpo_save
