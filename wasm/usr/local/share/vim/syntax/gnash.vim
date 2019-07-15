if exists("b:current_syntax") || &compatible
finish
endif
syn case match
syn keyword GnashTodo	    contained TODO FIXME XXX NOTE
syn match   GnashComment    "^#.*$"   contains=@Spell,GnashTodo
syn match   GnashComment    "\s#.*$"  contains=@Spell,GnashTodo
syn match   GnashNumber	    display '\<\d\+\>'
syn case ignore
syn keyword GnashOn	    ON YES TRUE
syn keyword GnashOff	    OFF NO FALSE
syn match GnashSet	    '^\s*set\>'
syn match GnashSet	    '^\s*append\>'
syn match GnashKeyword	    '\<CertDir\>'
syn match GnashKeyword      '\<ASCodingErrorsVerbosity\>'
syn match GnashKeyword      '\<CertFile\>'
syn match GnashKeyword      '\<EnableExtensions\>'
syn match GnashKeyword      '\<HWAccel\>'
syn match GnashKeyword      '\<LCShmKey\>'
syn match GnashKeyword      '\<LocalConnection\>'
syn match GnashKeyword      '\<MalformedSWFVerbosity\>'
syn match GnashKeyword      '\<Renderer\>'
syn match GnashKeyword      '\<RootCert\>'
syn match GnashKeyword      '\<SOLReadOnly\>'
syn match GnashKeyword      '\<SOLSafeDir\>'
syn match GnashKeyword      '\<SOLreadonly\>'
syn match GnashKeyword      '\<SOLsafedir\>'
syn match GnashKeyword      '\<StartStopped\>'
syn match GnashKeyword      '\<StreamsTimeout\>'
syn match GnashKeyword      '\<URLOpenerFormat\>'
syn match GnashKeyword      '\<XVideo\>'
syn match GnashKeyword      '\<actionDump\>'
syn match GnashKeyword      '\<blacklist\>'
syn match GnashKeyword      '\<debugger\>'
syn match GnashKeyword      '\<debuglog\>'
syn match GnashKeyword      '\<delay\>'
syn match GnashKeyword      '\<enableExtensions\>'
syn match GnashKeyword      '\<flashSystemManufacturer\>'
syn match GnashKeyword      '\<flashSystemOS\>'
syn match GnashKeyword      '\<flashVersionString\>'
syn match GnashKeyword      '\<ignoreFSCommand\>'
syn match GnashKeyword      '\<ignoreShowMenu\>'
syn match GnashKeyword      '\<insecureSSL\>'
syn match GnashKeyword      '\<localSandboxPath\>'
syn match GnashKeyword      '\<localdomain\>'
syn match GnashKeyword      '\<localhost\>'
syn match GnashKeyword      '\<microphoneDevice\>'
syn match GnashKeyword      '\<parserDump\>'
syn match GnashKeyword      '\<pluginsound\>'
syn match GnashKeyword      '\<quality\>'
syn match GnashKeyword      '\<solLocalDomain\>'
syn match GnashKeyword      '\<sound\>'
syn match GnashKeyword      '\<splashScreen\>'
syn match GnashKeyword      '\<startStopped\>'
syn match GnashKeyword      '\<streamsTimeout\>'
syn match GnashKeyword      '\<urlOpenerFormat\>'
syn match GnashKeyword      '\<verbosity\>'
syn match GnashKeyword      '\<webcamDevice\>'
syn match GnashKeyword      '\<whitelist\>'
syn match GnashKeyword      '\<writelog\>'
hi def link GnashOn	    Identifier
hi def link GnashOff	    Preproc
hi def link GnashComment    Comment
hi def link GnashTodo	    Todo
hi def link GnashNumber	    Type
hi def link GnashSet	    String
hi def link GnashKeyword    Keyword
let b:current_syntax = "gnash"
