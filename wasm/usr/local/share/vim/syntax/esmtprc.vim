if exists("b:current_syntax")
finish
endif
syntax keyword	esmtprcOptions hostname username password starttls certificate_passphrase preconnect identity mda
syntax keyword esmtprcIdentifier default enabled disabled required
syntax match esmtprcAddress /[a-z0-9_.-]*[a-z0-9]\+@[a-z0-9_.-]*[a-z0-9]\+\.[a-z]\+/
syntax match esmtprcFulladd /[a-z0-9_.-]*[a-z0-9]\+\.[a-z]\+:[0-9]\+/
syntax region esmtprcString start=/"/ end=/"/
highlight link esmtprcOptions		Label
highlight link esmtprcString 		String
highlight link esmtprcAddress		Type
highlight link esmtprcIdentifier 	Identifier
highlight link esmtprcFulladd		Include
let b:current_syntax = "esmtprc"
