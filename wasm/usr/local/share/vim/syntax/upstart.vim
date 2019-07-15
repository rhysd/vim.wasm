if exists("b:current_syntax")
finish
endif
let is_bash = 1
syn include @Shell syntax/sh.vim
syn case match
setlocal iskeyword+=-
syn match upstartComment /#.*$/ contains=upstartTodo
syn keyword upstartTodo TODO FIXME contained
syn region upstartString start=/"/ end=/"/ skip=/\\"/
syn region upstartScript matchgroup=upstartStatement start="script" end="end script" contains=@upstartShellCluster
syn cluster upstartShellCluster contains=@Shell
syn keyword upstartStatement description author version instance expect
syn keyword upstartStatement pid kill normal console env exit export
syn keyword upstartStatement umask nice oom chroot chdir exec
syn keyword upstartStatement limit
syn keyword upstartStatement emits
syn keyword upstartStatement on start stop
syn keyword upstartStatement respawn service instance manual debug task
syn keyword upstartOption pre-start post-start pre-stop post-stop
syn keyword upstartOption timeout
syn keyword upstartOption never
syn keyword upstartOption output owner
syn keyword upstartOption fork daemon
syn keyword upstartOption unlimited
syn keyword upstartOption and or
syn keyword upstartEvent runlevel
syn keyword upstartEvent started
syn keyword upstartEvent starting
syn keyword upstartEvent startup
syn keyword upstartEvent stopped
syn keyword upstartEvent stopping
syn keyword upstartEvent control-alt-delete
syn keyword upstartEvent keyboard-request
syn keyword upstartEvent power-status-changed
syn keyword upstartEvent dbus-activation
syn keyword upstartEvent desktop-session-start
syn keyword upstartEvent login-session-start
syn keyword upstartEvent all-swaps
syn keyword upstartEvent filesystem
syn keyword upstartEvent mounted
syn keyword upstartEvent mounting
syn keyword upstartEvent local-filesystems
syn keyword upstartEvent remote-filesystems
syn keyword upstartEvent virtual-filesystems
syn keyword upstartEvent mounted-remote-filesystems
syn match   upstartEvent /\<\i\{-1,}-device-\(added\|removed\|up\|down\)/
syn keyword upstartEvent socket
hi def link upstartComment   Comment
hi def link upstartTodo	     Todo
hi def link upstartString    String
hi def link upstartStatement Statement
hi def link upstartOption    Type
hi def link upstartEvent     Define
let b:current_syntax = "upstart"
