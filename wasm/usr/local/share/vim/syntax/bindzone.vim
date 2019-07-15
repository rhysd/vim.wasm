if exists("b:current_syntax")
finish
endif
syn case match
syn region      zoneRRecord     start=/^/ end=/$/ contains=zoneOwnerName,zoneSpecial,zoneTTL,zoneClass,zoneRRType,zoneComment,zoneUnknown
syn match       zoneDirective   /^\$ORIGIN\s\+/   nextgroup=zoneOrigin,zoneUnknown
syn match       zoneDirective   /^\$TTL\s\+/      nextgroup=zoneTTL,zoneUnknown
syn match       zoneDirective   /^\$INCLUDE\s\+/  nextgroup=zoneText,zoneUnknown
syn match       zoneDirective   /^\$GENERATE\s/
syn match       zoneUnknown     contained /\S\+/
syn match       zoneOwnerName   contained /^[^[:space:]!"#$%&'()*+,\/:;<=>?@[\]\^`{|}~]\+\(\s\|;\)\@=/ nextgroup=zoneTTL,zoneClass,zoneRRType skipwhite
syn match       zoneOrigin      contained  /[^[:space:]!"#$%&'()*+,\/:;<=>?@[\]\^`{|}~]\+\(\s\|;\|$\)\@=/
syn match       zoneDomain      contained  /[^[:space:]!"#$%&'()*+,\/:;<=>?@[\]\^`{|}~]\+\(\s\|;\|$\)\@=/
syn match       zoneSpecial     contained /^[@*.]\s/
syn match       zoneTTL         contained /\s\@<=\d[0-9WwDdHhMmSs]*\(\s\|$\)\@=/ nextgroup=zoneClass,zoneRRType skipwhite
syn keyword     zoneClass       contained IN CHAOS nextgroup=zoneRRType,zoneTTL skipwhite
syn keyword     zoneRRType      contained A AAAA CNAME DNAME HINFO MX NS PTR SOA SRV TXT SPF nextgroup=zoneRData skipwhite
syn match       zoneRData       contained /[^;]*/ contains=zoneDomain,zoneIPAddr,zoneIP6Addr,zoneText,zoneNumber,zoneParen,zoneUnknown
syn match       zoneIPAddr      contained /\<[0-9]\{1,3}\(\.[0-9]\{1,3}\)\{,3}\>/
syn match       zoneIP6Addr     contained /\<\(\x\{1,4}:\)\{6}\(\x\{1,4}:\x\{1,4}\|\([0-2]\?\d\{1,2}\.\)\{3}[0-2]\?\d\{1,2}\)\>/
syn match       zoneIP6Addr     contained /\s\@<=::\(\(\x\{1,4}:\)\{,6}\x\{1,4}\|\(\x\{1,4}:\)\{,5}\([0-2]\?\d\{1,2}\.\)\{3}[0-2]\?\d\{1,2}\)\>/
syn match       zoneIP6Addr     contained /\<\(\x\{1,4}:\)\{1}:\(\(\x\{1,4}:\)\{,5}\x\{1,4}\|\(\x\{1,4}:\)\{,4}\([0-2]\?\d\{1,2}\.\)\{3}[0-2]\?\d\{1,2}\)\>/
syn match       zoneIP6Addr     contained /\<\(\x\{1,4}:\)\{2}:\(\(\x\{1,4}:\)\{,4}\x\{1,4}\|\(\x\{1,4}:\)\{,3}\([0-2]\?\d\{1,2}\.\)\{3}[0-2]\?\d\{1,2}\)\>/
syn match       zoneIP6Addr     contained /\<\(\x\{1,4}:\)\{3}:\(\(\x\{1,4}:\)\{,3}\x\{1,4}\|\(\x\{1,4}:\)\{,2}\([0-2]\?\d\{1,2}\.\)\{3}[0-2]\?\d\{1,2}\)\>/
syn match       zoneIP6Addr     contained /\<\(\x\{1,4}:\)\{4}:\(\(\x\{1,4}:\)\{,2}\x\{1,4}\|\(\x\{1,4}:\)\{,1}\([0-2]\?\d\{1,2}\.\)\{3}[0-2]\?\d\{1,2}\)\>/
syn match       zoneIP6Addr     contained /\<\(\x\{1,4}:\)\{5}:\(\(\x\{1,4}:\)\{,1}\x\{1,4}\|\([0-2]\?\d\{1,2}\.\)\{3}[0-2]\?\d\{1,2}\)\>/
syn match       zoneIP6Addr     contained /\<\(\x\{1,4}:\)\{6}:\x\{1,4}\>/
syn match       zoneIP6Addr     contained /\<\(\x\{1,4}:\)\{1,7}:\(\s\|;\|$\)\@=/
syn match       zoneText        contained /"\([^"\\]\|\\.\)*"\(\s\|;\|$\)\@=/
syn match       zoneNumber      contained /\<[0-9]\+\(\s\|;\|$\)\@=/
syn match       zoneSerial      contained /\<[0-9]\{9,10}\(\s\|;\|$\)\@=/
syn match       zoneErrParen    /)/
syn region      zoneParen       contained start="(" end=")" contains=zoneSerial,zoneTTL,zoneNumber,zoneComment
syn match       zoneComment     /;.*/
hi def link zoneDirective    Macro
hi def link zoneUnknown      Error
hi def link zoneOrigin       Statement
hi def link zoneOwnerName    Statement
hi def link zoneDomain       Identifier
hi def link zoneSpecial      Special
hi def link zoneTTL          Constant
hi def link zoneClass        Include
hi def link zoneRRType       Type
hi def link zoneIPAddr       Number
hi def link zoneIP6Addr      Number
hi def link zoneText         String
hi def link zoneNumber       Number
hi def link zoneSerial       Special
hi def link zoneErrParen     Error
hi def link zoneComment      Comment
let b:current_syntax = "bindzone"
