if exists('b:current_syntax')
finish
endif
runtime! syntax/make.vim
syn match automakePrimary "^\w\+\(_PROGRAMS\|_LIBRARIES\|_LISP\|_PYTHON\|_JAVA\|_SCRIPTS\|_DATA\|_HEADERS\|_MANS\|_TEXINFOS\|_LTLIBRARIES\)\s*\ze+\=="
syn match automakePrimary "^TESTS\s*\ze+\=="me=e-1
syn match automakeSecondary "^\w\+\(_SOURCES\|_LIBADD\|_LDADD\|_LDFLAGS\|_DEPENDENCIES\|_AR\|_CCASFLAGS\|_CFLAGS\|_CPPFLAGS\|_CXXFLAGS\|_FCFLAGS\|_FFLAGS\|_GCJFLAGS\|_LFLAGS\|_LIBTOOLFLAGS\|OBJCFLAGS\|RFLAGS\|UPCFLAGS\|YFLAGS\)\s*\ze+\=="
syn match automakeSecondary "^\(LDADD\|ARFLAGS\|OMIT_DEPENDENCIES\|AM_MAKEFLAGS\|\(AM_\)\=\(MAKEINFOFLAGS\|RUNTESTDEFAULTFLAGS\|ETAGSFLAGS\|CTAGSFLAGS\|JAVACFLAGS\)\)\s*\ze+\=="
syn match automakeExtra "^EXTRA_\w\+\s*\ze+\=="
syn match automakeOptions "^\(ACLOCAL_AMFLAGS\|AUTOMAKE_OPTIONS\|DISTCHECK_CONFIGURE_FLAGS\|ETAGS_ARGS\|TAGS_DEPENDENCIES\)\s*\ze+\=="
syn match automakeClean "^\(MOSTLY\|DIST\|MAINTAINER\)\=CLEANFILES\s*\ze+\=="
syn match automakeSubdirs "^\(DIST_\)\=SUBDIRS\s*\ze+\=="
syn match automakeConditional "^\(if\s*!\=\w\+\|else\|endif\)\s*$"
syn match automakeSubst     "@\w\+@"
syn match automakeSubst     "^\s*@\w\+@"
syn match automakeComment1 "#.*$" contains=automakeSubst,@Spell
syn match automakeComment2 "##.*$" contains=@Spell
syn match automakeMakeError "$[{(][^})]*[^a-zA-Z0-9_})][^})]*[})]" " GNU make function call
syn match automakeMakeError "^AM_LDADD\s*\ze+\==" " Common mistake
syn region automakeNoSubst start="^EXTRA_\w*\s*+\==" end="$" contains=ALLBUT,automakeNoSubst transparent
syn region automakeNoSubst start="^DIST_SUBDIRS\s*+\==" end="$" contains=ALLBUT,automakeNoSubst transparent
syn region automakeNoSubst start="^\w*_SOURCES\s*+\==" end="$" contains=ALLBUT,automakeNoSubst transparent
syn match automakeBadSubst  "@\(\w*@\=\)\=" contained
syn region  automakeMakeDString start=+"+  skip=+\\"+  end=+"+  contains=makeIdent,automakeSubstitution
syn region  automakeMakeSString start=+'+  skip=+\\'+  end=+'+  contains=makeIdent,automakeSubstitution
syn region  automakeMakeBString start=+`+  skip=+\\`+  end=+`+  contains=makeIdent,makeSString,makeDString,makeNextLine,automakeSubstitution
hi def link automakePrimary     Statement
hi def link automakeSecondary   Type
hi def link automakeExtra       Special
hi def link automakeOptions     Special
hi def link automakeClean       Special
hi def link automakeSubdirs     Statement
hi def link automakeConditional PreProc
hi def link automakeSubst       PreProc
hi def link automakeComment1    makeComment
hi def link automakeComment2    makeComment
hi def link automakeMakeError   makeError
hi def link automakeBadSubst    makeError
hi def link automakeMakeDString makeDString
hi def link automakeMakeSString makeSString
hi def link automakeMakeBString makeBString
let b:current_syntax = 'automake'
