if exists("did_load_filetypes")
finish
endif
let did_load_filetypes = 1
let s:cpo_save = &cpo
set cpo&vim
augroup filetypedetect
if exists("*fnameescape")
au BufNewFile,BufRead ?\+.orig,?\+.bak,?\+.old,?\+.new,?\+.dpkg-dist,?\+.dpkg-old,?\+.dpkg-new,?\+.dpkg-bak,?\+.rpmsave,?\+.rpmnew,?\+.pacsave,?\+.pacnew
\ exe "doau filetypedetect BufRead " . fnameescape(expand("<afile>:r"))
au BufNewFile,BufRead *~
\ let s:name = expand("<afile>") |
\ let s:short = substitute(s:name, '\~$', '', '') |
\ if s:name != s:short && s:short != "" |
\   exe "doau filetypedetect BufRead " . fnameescape(s:short) |
\ endif |
\ unlet! s:name s:short
au BufNewFile,BufRead ?\+.in
\ if expand("<afile>:t") != "configure.in" |
\   exe "doau filetypedetect BufRead " . fnameescape(expand("<afile>:r")) |
\ endif
elseif &verbose > 0
echomsg "Warning: some filetypes will not be recognized because this version of Vim does not have fnameescape()"
endif
if !exists("g:ft_ignore_pat")
let g:ft_ignore_pat = '\.\(Z\|gz\|bz2\|zip\|tgz\)$'
endif
func! s:StarSetf(ft)
if expand("<amatch>") !~ g:ft_ignore_pat
exe 'setf ' . a:ft
endif
endfunc
au BufNewFile,BufRead $VIMRUNTIME/doc/*.txt	setf help
au BufNewFile,BufRead *.inp			call dist#ft#Check_inp()
au BufNewFile,BufRead *.8th			setf 8th
au BufNewFile,BufRead *.aap			setf aap
au BufNewFile,BufRead */etc/a2ps.cfg,*/etc/a2ps/*.cfg,a2psrc,.a2psrc setf a2ps
au BufNewFile,BufRead *.abap			setf abap
au BufNewFile,BufRead *.abc			setf abc
au BufNewFile,BufRead *.abl			setf abel
au BufNewFile,BufRead *.wrm			setf acedb
au BufNewFile,BufRead *.adb,*.ads,*.ada		setf ada
if has("vms")
au BufNewFile,BufRead *.gpr,*.ada_m,*.adc	setf ada
else
au BufNewFile,BufRead *.gpr			setf ada
endif
au BufNewFile,BufRead *.tdf			setf ahdl
au BufNewFile,BufRead *.run			setf ampl
au BufNewFile,BufRead build.xml			setf ant
au BufNewFile,BufRead *.ino,*.pde		setf arduino
au BufNewFile,BufRead .htaccess,*/etc/httpd/*.conf		setf apache
au BufNewFile,BufRead */etc/apache2/sites-*/*.com		setf apache
au BufNewFile,BufRead *.a65			setf a65
au BufNewFile,BufRead *.scpt			setf applescript
au BufNewFile,BufRead *.am
\ if expand("<afile>") !~? 'Makefile.am\>' | setf elf | endif
au BufNewFile,BufRead .asoundrc,*/usr/share/alsa/alsa.conf,*/etc/asound.conf setf alsaconf
au BufNewFile,BufRead *.aml			setf aml
au BufNewFile,BufRead apt.conf		       setf aptconf
au BufNewFile,BufRead */.aptitude/config       setf aptconf
au BufNewFile,BufRead */etc/apt/apt.conf.d/{[-_[:alnum:]]\+,[-_.[:alnum:]]\+.conf} setf aptconf
au BufNewFile,BufRead .arch-inventory,=tagging-method	setf arch
au BufNewFile,BufRead *.art			setf art
au BufNewFile,BufRead *.asciidoc,*.adoc		setf asciidoc
au BufNewFile,BufRead *.asn,*.asn1		setf asn
au BufNewFile,BufRead *.asa
\ if exists("g:filetype_asa") |
\   exe "setf " . g:filetype_asa |
\ else |
\   setf aspvbs |
\ endif
au BufNewFile,BufRead *.asp
\ if exists("g:filetype_asp") |
\   exe "setf " . g:filetype_asp |
\ elseif getline(1) . getline(2) . getline(3) =~? "perlscript" |
\   setf aspperl |
\ else |
\   setf aspvbs |
\ endif
au BufNewFile,BufRead */boot/grub/menu.lst,*/boot/grub/grub.conf,*/etc/grub.conf setf grub
au BufNewFile,BufRead *.asm,*.[sS],*.[aA],*.mac,*.lst	call dist#ft#FTasm()
au BufNewFile,BufRead *.mar			setf vmasm
au BufNewFile,BufRead *.atl,*.as		setf atlas
au BufNewFile,BufRead *.au3			setf autoit
au BufNewFile,BufRead *.ahk			setf autohotkey
au BufNewFile,BufRead [mM]akefile.am,GNUmakefile.am	setf automake
au BufNewFile,BufRead *.at			setf m4
au BufNewFile,BufRead *.ave			setf ave
au BufNewFile,BufRead *.awk			setf awk
au BufNewFile,BufRead *.mch,*.ref,*.imp		setf b
au BufNewFile,BufRead *.bas			call dist#ft#FTVB("basic")
au BufNewFile,BufRead *.vb,*.vbs,*.dsm,*.ctl	setf vb
au BufNewFile,BufRead *.iba,*.ibi		setf ibasic
au BufNewFile,BufRead *.fb,*.bi			setf freebasic
au BufNewFile,BufRead *.bat,*.sys		setf dosbatch
au BufNewFile,BufRead *.cmd
\ if getline(1) =~ '^/\*' | setf rexx | else | setf dosbatch | endif
au BufNewFile,BufRead *.btm			call dist#ft#FTbtm()
au BufNewFile,BufRead *.bc			setf bc
au BufNewFile,BufRead *.bdf			setf bdf
au BufNewFile,BufRead *.bib			setf bib
au BufNewFile,BufRead *.bst			setf bst
au BufNewFile,BufRead named*.conf,rndc*.conf,rndc*.key	setf named
au BufNewFile,BufRead named.root		setf bindzone
au BufNewFile,BufRead *.db			call dist#ft#BindzoneCheck('')
au BufNewFile,BufRead *.bl			setf blank
au BufNewFile,BufRead */etc/blkid.tab,*/etc/blkid.tab.old   setf xml
autocmd BufRead,BufNewFile *.bzl,WORKSPACE,BUILD.bazel 	setf bzl
if has("fname_case")
autocmd BufRead,BufNewFile BUILD			setf bzl
endif
au BufNewFile,BufRead *.c			call dist#ft#FTlpc()
au BufNewFile,BufRead *.lpc,*.ulpc		setf lpc
au BufNewFile,BufRead calendar			setf calendar
au BufNewFile,BufRead *.cs			setf cs
au BufNewFile,BufRead *.csdl			setf csdl
au BufNewFile,BufRead *.cabal			setf cabal
au BufNewFile,BufRead *.toc			setf cdrtoc
au BufNewFile,BufRead */etc/cdrdao.conf,*/etc/defaults/cdrdao,*/etc/default/cdrdao,.cdrdao	setf cdrdaoconf
au BufNewFile,BufRead cfengine.conf		setf cfengine
au BufRead,BufNewFile *.chai			setf chaiscript
au BufNewFile,BufRead *.cdl			setf cdl
au BufNewFile,BufRead *.recipe			setf conaryrecipe
au BufNewFile,BufRead *.crm			setf crm
au BufNewFile,BufRead *.cyn			setf cynpp
au BufNewFile,BufRead *.cc
\ if exists("cynlib_syntax_for_cc")|setf cynlib|else|setf cpp|endif
au BufNewFile,BufRead *.cpp
\ if exists("cynlib_syntax_for_cpp")|setf cynlib|else|setf cpp|endif
au BufNewFile,BufRead *.cxx,*.c++,*.hh,*.hxx,*.hpp,*.ipp,*.moc,*.tcc,*.inl setf cpp
if has("fname_case")
au BufNewFile,BufRead *.C,*.H setf cpp
endif
au BufNewFile,BufRead *.h			call dist#ft#FTheader()
au BufNewFile,BufRead *.chf			setf ch
au BufNewFile,BufRead *.tlh			setf cpp
au BufNewFile,BufRead *.css			setf css
au BufNewFile,BufRead *.con			setf cterm
au BufNewFile,BufRead changelog.Debian,changelog.dch,NEWS.Debian,NEWS.dch
\	setf debchangelog
au BufNewFile,BufRead [cC]hange[lL]og
\  if getline(1) =~ '; urgency='
\|   setf debchangelog
\| else
\|   setf changelog
\| endif
au BufNewFile,BufRead NEWS
\  if getline(1) =~ '; urgency='
\|   setf debchangelog
\| endif
au BufNewFile,BufRead *..ch			setf chill
au BufNewFile,BufRead *.ch			call dist#ft#FTchange()
au BufNewFile,BufRead *.chopro,*.crd,*.cho,*.crdpro,*.chordpro	setf chordpro
au BufNewFile,BufRead *.dcl,*.icl		setf clean
au BufNewFile,BufRead *.eni			setf cl
au BufNewFile,BufRead *.ent			call dist#ft#FTent()
au BufNewFile,BufRead *.prg
\ if exists("g:filetype_prg") |
\   exe "setf " . g:filetype_prg |
\ else |
\   setf clipper |
\ endif
au BufNewFile,BufRead *.clj,*.cljs,*.cljx,*.cljc		setf clojure
au BufNewFile,BufRead CMakeLists.txt,*.cmake,*.cmake.in		setf cmake
au BufNewFile,BufRead */.cmus/{autosave,rc,command-history,*.theme} setf cmusrc
au BufNewFile,BufRead */cmus/{rc,*.theme}			setf cmusrc
au BufNewFile,BufRead *.cbl,*.cob,*.lib	setf cobol
au BufNewFile,BufRead *.cpy
\ if getline(1) =~ '^##' |
\   setf python |
\ else |
\   setf cobol |
\ endif
au BufNewFile,BufRead *.atg			setf coco
au BufNewFile,BufRead *.cfm,*.cfi,*.cfc		setf cf
au BufNewFile,BufRead configure.in,configure.ac setf config
au BufNewFile,BufRead *.cu,*.cuh		setf cuda
au BufNewFile,BufRead Dockerfile,*.Dockerfile	setf dockerfile
au BufNewFile,BufRead *.dcd			setf dcd
au BufNewFile,BufRead *enlightenment/*.cfg	setf c
au BufNewFile,BufRead *Eterm/*.cfg		setf eterm
au BufNewFile,BufRead *.eu,*.ew,*.ex,*.exu,*.exw  call dist#ft#EuphoriaCheck()
if has("fname_case")
au BufNewFile,BufRead *.EU,*.EW,*.EX,*.EXU,*.EXW  call dist#ft#EuphoriaCheck()
endif
au BufNewFile,BufRead lynx.cfg			setf lynx
au BufNewFile,BufRead *baseq[2-3]/*.cfg,*id1/*.cfg	setf quake
au BufNewFile,BufRead *quake[1-3]/*.cfg			setf quake
au BufNewFile,BufRead *.qc			setf c
au BufNewFile,BufRead *.cfg			setf cfg
au BufNewFile,BufRead *.feature			setf cucumber
au BufNewFile,BufRead *.csp,*.fdr		setf csp
au BufNewFile,BufRead *.pld			setf cupl
au BufNewFile,BufRead *.si			setf cuplsim
au BufNewFile,BufRead */debian/control		setf debcontrol
au BufNewFile,BufRead control
\  if getline(1) =~ '^Source:'
\|   setf debcontrol
\| endif
au BufNewFile,BufRead */debian/copyright	setf debcopyright
au BufNewFile,BufRead copyright
\  if getline(1) =~ '^Format:'
\|   setf debcopyright
\| endif
au BufNewFile,BufRead */etc/apt/sources.list		setf debsources
au BufNewFile,BufRead */etc/apt/sources.list.d/*.list	setf debsources
au BufNewFile,BufRead denyhosts.conf		setf denyhosts
au BufNewFile,BufRead */etc/dnsmasq.conf	setf dnsmasq
au BufNewFile,BufRead *.desc			setf desc
au BufNewFile,BufRead *.d			call dist#ft#DtraceCheck()
au BufNewFile,BufRead *.desktop,.directory	setf desktop
au BufNewFile,BufRead dict.conf,.dictrc		setf dictconf
au BufNewFile,BufRead dictd.conf		setf dictdconf
au BufNewFile,BufRead *.diff,*.rej		setf diff
au BufNewFile,BufRead *.patch
\ if getline(1) =~ '^From [0-9a-f]\{40\} Mon Sep 17 00:00:00 2001$' |
\   setf gitsendemail |
\ else |
\   setf diff |
\ endif
au BufNewFile,BufRead .dir_colors,.dircolors,*/etc/DIR_COLORS	setf dircolors
au BufNewFile,BufRead *.rul
\ if getline(1).getline(2).getline(3).getline(4).getline(5).getline(6) =~? 'InstallShield' |
\   setf ishd |
\ else |
\   setf diva |
\ endif
au BufNewFile,BufRead *.com			call dist#ft#BindzoneCheck('dcl')
au BufNewFile,BufRead *.dot			setf dot
au BufNewFile,BufRead *.lid			setf dylanlid
au BufNewFile,BufRead *.intr			setf dylanintr
au BufNewFile,BufRead *.dylan			setf dylan
au BufNewFile,BufRead *.def			setf def
au BufNewFile,BufRead *.drac,*.drc,*lvs,*lpe	setf dracula
au BufNewFile,BufRead *.ds			setf datascript
au BufNewFile,BufRead *.dsl			setf dsl
au BufNewFile,BufRead *.dtd			setf dtd
au BufNewFile,BufRead *.dts,*.dtsi		setf dts
au BufNewFile,BufRead *.ed\(f\|if\|o\)		setf edif
au BufNewFile,BufRead *.edn
\ if getline(1) =~ '^\s*(\s*edif\>' |
\   setf edif |
\ else |
\   setf clojure |
\ endif
au BufNewFile,BufRead .editorconfig		setf dosini
au BufNewFile,BufRead *.ecd			setf ecd
au BufNewFile,BufRead *.e,*.E			call dist#ft#FTe()
au BufNewFile,BufRead */etc/elinks.conf,*/.elinks/elinks.conf	setf elinks
au BufNewFile,BufRead *.erl,*.hrl,*.yaws	setf erlang
au BufNewFile,BufRead filter-rules		setf elmfilt
au BufNewFile,BufRead *esmtprc			setf esmtprc
au BufNewFile,BufRead *.ec,*.EC			setf esqlc
au BufNewFile,BufRead *.strl			setf esterel
au BufNewFile,BufRead *.csc			setf csc
au BufNewFile,BufRead exim.conf			setf exim
au BufNewFile,BufRead *.exp			setf expect
au BufNewFile,BufRead exports			setf exports
au BufNewFile,BufRead *.fal			setf falcon
au BufNewFile,BufRead *.fan,*.fwt		setf fan
au BufNewFile,BufRead *.factor			setf factor
au BufNewFile,BufRead .fetchmailrc		setf fetchmail
au BufNewFile,BufRead *.fex,*.focexec		setf focexec
au BufNewFile,BufRead auto.master		setf conf
au BufNewFile,BufRead *.mas,*.master		setf master
au BufNewFile,BufRead *.fs,*.ft,*.fth		setf forth
au BufNewFile,BufRead *.frt			setf reva
if has("fname_case")
au BufNewFile,BufRead *.F,*.FOR,*.FPP,*.FTN,*.F77,*.F90,*.F95,*.F03,*.F08	 setf fortran
endif
au BufNewFile,BufRead   *.f,*.for,*.fortran,*.fpp,*.ftn,*.f77,*.f90,*.f95,*.f03,*.f08  setf fortran
au BufNewFile,BufRead *.fsl			setf framescript
au BufNewFile,BufRead fstab,mtab		setf fstab
au BufNewFile,BufRead .gdbinit			setf gdb
au BufNewFile,BufRead *.mo,*.gdmo		setf gdmo
au BufNewFile,BufRead *.ged,lltxxxxx.txt	setf gedcom
au BufNewFile,BufRead COMMIT_EDITMSG,MERGE_MSG,TAG_EDITMSG 	setf gitcommit
au BufNewFile,BufRead *.git/config,.gitconfig,/etc/gitconfig 	setf gitconfig
au BufNewFile,BufRead */.config/git/config			setf gitconfig
au BufNewFile,BufRead .gitmodules,*.git/modules/*/config	setf gitconfig
if !empty($XDG_CONFIG_HOME)
au BufNewFile,BufRead $XDG_CONFIG_HOME/git/config		setf gitconfig
endif
au BufNewFile,BufRead git-rebase-todo		setf gitrebase
au BufRead,BufNewFile .gitsendemail.msg.??????	setf gitsendemail
au BufNewFile,BufRead .msg.[0-9]*
\ if getline(1) =~ '^From.*# This line is ignored.$' |
\   setf gitsendemail |
\ endif
au BufNewFile,BufRead *.git/*
\ if getline(1) =~ '^\x\{40\}\>\|^ref: ' |
\   setf git |
\ endif
au BufNewFile,BufRead gkrellmrc,gkrellmrc_?	setf gkrellmrc
au BufNewFile,BufRead *.gp,.gprc		setf gp
au BufNewFile,BufRead */.gnupg/options		setf gpg
au BufNewFile,BufRead */.gnupg/gpg.conf		setf gpg
au BufNewFile,BufRead */usr/*/gnupg/options.skel setf gpg
if !empty($GNUPGHOME)
au BufNewFile,BufRead $GNUPGHOME/options	setf gpg
au BufNewFile,BufRead $GNUPGHOME/gpg.conf	setf gpg
endif
au BufNewFile,BufRead gnashrc,.gnashrc,gnashpluginrc,.gnashpluginrc setf gnash
au BufNewFile,BufRead gitolite.conf		setf gitolite
au BufNewFile,BufRead {,.}gitolite.rc,example.gitolite.rc	setf perl
au BufNewFile,BufRead *.gpi			setf gnuplot
au BufNewFile,BufRead *.go			setf go
au BufNewFile,BufRead *.gs			setf grads
au BufNewFile,BufRead *.gretl			setf gretl
au BufNewFile,BufRead *.gradle,*.groovy		setf groovy
au BufNewFile,BufRead *.gsp			setf gsp
au BufNewFile,BufRead */etc/group,*/etc/group-,*/etc/group.edit,*/etc/gshadow,*/etc/gshadow-,*/etc/gshadow.edit,*/var/backups/group.bak,*/var/backups/gshadow.bak  setf group
au BufNewFile,BufRead .gtkrc,gtkrc		setf gtkrc
au BufNewFile,BufRead *.haml			setf haml
au BufNewFile,BufRead *.hsc,*.hsm		setf hamster
au BufNewFile,BufRead *.hs,*.hs-boot		setf haskell
au BufNewFile,BufRead *.lhs			setf lhaskell
au BufNewFile,BufRead *.chs			setf chaskell
au BufNewFile,BufRead *.ht			setf haste
au BufNewFile,BufRead *.htpp			setf hastepreproc
au BufNewFile,BufRead *.vc,*.ev,*.sum,*.errsum	setf hercules
au BufNewFile,BufRead *.hex,*.h32		setf hex
au BufNewFile,BufRead *.t.html			setf tilde
au BufNewFile,BufRead *.html,*.htm,*.shtml,*.stm  call dist#ft#FThtml()
au BufNewFile,BufRead *.erb,*.rhtml		setf eruby
au BufNewFile,BufRead *.html.m4			setf htmlm4
au BufNewFile,BufRead *.tmpl			setf template
au BufNewFile,BufRead */etc/host.conf		setf hostconf
au BufNewFile,BufRead */etc/hosts.allow,*/etc/hosts.deny  setf hostsaccess
au BufNewFile,BufRead *.hb			setf hb
au BufNewFile,BufRead *.htt,*.htb		setf httest
au BufNewFile,BufRead *.icn			setf icon
au BufNewFile,BufRead *.idl			call dist#ft#FTidl()
au BufNewFile,BufRead *.odl,*.mof		setf msidl
au BufNewFile,BufRead */.icewm/menu		setf icemenu
au BufNewFile,BufRead .indent.pro		setf indent
au BufNewFile,BufRead indent.pro		call dist#ft#ProtoCheck('indent')
au BufNewFile,BufRead *.pro			call dist#ft#ProtoCheck('idlang')
au BufNewFile,BufRead indentrc			setf indent
au BufNewFile,BufRead *.inf,*.INF		setf inform
au BufNewFile,BufRead */etc/initng/*/*.i,*.ii	setf initng
au BufRead,BufNewFile upstream.dat\c,upstream.*.dat\c,*.upstream.dat\c 	setf upstreamdat
au BufRead,BufNewFile fdrupstream.log,upstream.log\c,upstream.*.log\c,*.upstream.log\c,UPSTREAM-*.log\c 	setf upstreamlog
au BufRead,BufNewFile upstreaminstall.log\c,upstreaminstall.*.log\c,*.upstreaminstall.log\c setf upstreaminstalllog
au BufRead,BufNewFile usserver.log\c,usserver.*.log\c,*.usserver.log\c 	setf usserverlog
au BufRead,BufNewFile usw2kagt.log\c,usw2kagt.*.log\c,*.usw2kagt.log\c 	setf usw2kagtlog
au BufNewFile,BufRead ipf.conf,ipf6.conf,ipf.rules	setf ipfilter
au BufNewFile,BufRead *.4gl,*.4gh,*.m4gl	setf fgl
au BufNewFile,BufRead *.ini			setf dosini
au BufNewFile,BufRead inittab			setf inittab
au BufNewFile,BufRead *.iss			setf iss
au BufNewFile,BufRead *.ijs			setf j
au BufNewFile,BufRead *.jal,*.JAL		setf jal
au BufNewFile,BufRead *.jpl,*.jpr		setf jam
au BufNewFile,BufRead *.java,*.jav		setf java
au BufNewFile,BufRead *.jj,*.jjt		setf javacc
au BufNewFile,BufRead *.js,*.javascript,*.es,*.jsx,*.mjs   setf javascript
au BufNewFile,BufRead *.jsp			setf jsp
au BufNewFile,BufRead *.properties,*.properties_??,*.properties_??_??	setf jproperties
au BufNewFile,BufRead *.clp			setf jess
au BufNewFile,BufRead *.jgr			setf jgraph
au BufNewFile,BufRead *.jov,*.j73,*.jovial	setf jovial
au BufNewFile,BufRead *.json,*.jsonp,*.webmanifest	setf json
au BufNewFile,BufRead *.kix			setf kix
au BufNewFile,BufRead *.k			setf kwt
au BufNewFile,BufRead *.kv			setf kivy
au BufNewFile,BufRead *.ks			setf kscript
au BufNewFile,BufRead Kconfig,Kconfig.debug	setf kconfig
au BufNewFile,BufRead *.ace,*.ACE		setf lace
au BufNewFile,BufRead *.latte,*.lte		setf latte
au BufNewFile,BufRead */etc/limits,*/etc/*limits.conf,*/etc/*limits.d/*.conf	setf limits
au BufNewFile,BufRead *.sig			setf lprolog
au BufNewFile,BufRead *.ldif			setf ldif
au BufNewFile,BufRead *.ld			setf ld
au BufNewFile,BufRead *.less			setf less
au BufNewFile,BufRead *.lex,*.l,*.lxx,*.l++	setf lex
au BufNewFile,BufRead */etc/libao.conf,*/.libao	setf libao
au BufNewFile,BufRead */etc/sensors.conf,*/etc/sensors3.conf	setf sensors
au BufNewFile,BufRead lftp.conf,.lftprc,*lftp/rc	setf lftp
au BufNewFile,BufRead *.ll			setf lifelines
au BufNewFile,BufRead lilo.conf			setf lilo
if has("fname_case")
au BufNewFile,BufRead *.lsp,*.lisp,*.el,*.cl,*.jl,*.L,.emacs,.sawfishrc setf lisp
else
au BufNewFile,BufRead *.lsp,*.lisp,*.el,*.cl,*.jl,.emacs,.sawfishrc setf lisp
endif
au BufNewFile,BufRead sbclrc,.sbclrc		setf lisp
au BufNewFile,BufRead *.liquid			setf liquid
au BufNewFile,BufRead *.lite,*.lt		setf lite
au BufNewFile,BufRead */LiteStep/*/*.rc		setf litestep
au BufNewFile,BufRead */etc/login.access	setf loginaccess
au BufNewFile,BufRead */etc/login.defs		setf logindefs
au BufNewFile,BufRead *.lgt			setf logtalk
au BufNewFile,BufRead *.lot,*.lotos		setf lotos
au BufNewFile,BufRead *.lou,*.lout		setf lout
au BufNewFile,BufRead *.lua			setf lua
au BufNewFile,BufRead *.rockspec		setf lua
au BufNewFile,BufRead *.lsl			setf lsl
au BufNewFile,BufRead *.lss			setf lss
au BufNewFile,BufRead *.m4
\ if expand("<afile>") !~? 'html.m4$\|fvwm2rc' | setf m4 | endif
au BufNewFile,BufRead *.mgp			setf mgp
au BufNewFile,BufRead snd.\d\+,.letter,.letter.\d\+,.followup,.article,.article.\d\+,pico.\d\+,mutt{ng,}-*-\w\+,mutt[[:alnum:]_-]\\\{6\},neomutt-*-\w\+,neomutt[[:alnum:]_-]\\\{6\},ae\d\+.txt,/tmp/SLRN[0-9A-Z.]\+,*.eml setf mail
au BufNewFile,BufRead */etc/mail/aliases,*/etc/aliases	setf mailaliases
au BufNewFile,BufRead .mailcap,mailcap		setf mailcap
au BufNewFile,BufRead *[mM]akefile,*.mk,*.mak,*.dsp setf make
au BufNewFile,BufRead *.ist,*.mst		setf ist
au BufNewFile,BufRead *.page			setf mallard
au BufNewFile,BufRead *.man			setf man
au BufNewFile,BufRead */etc/man.conf,man.config	setf manconf
au BufNewFile,BufRead *.mv,*.mpl,*.mws		setf maple
au BufNewFile,BufRead *.map			setf map
au BufNewFile,BufRead *.markdown,*.mdown,*.mkd,*.mkdn,*.mdwn,*.md  setf markdown
au BufNewFile,BufRead *.mason,*.mhtml,*.comp	setf mason
au BufNewFile,BufRead *.m			call dist#ft#FTm()
au BufNewFile,BufRead *.nb			setf mma
au BufNewFile,BufRead *.mel			setf mel
au BufNewFile,BufRead hg-editor-*.txt		setf hgcommit
au BufNewFile,BufRead *.hgrc,*hgrc		setf cfg
au BufNewFile,BufRead */log/{auth,cron,daemon,debug,kern,lpr,mail,messages,news/news,syslog,user}{,.log,.err,.info,.warn,.crit,.notice}{,.[0-9]*,-[0-9]*} setf messages
au BufNewFile,BufRead *.mf			setf mf
au BufNewFile,BufRead *.mp			setf mp
au BufNewFile,BufRead *.mgl			setf mgl
au BufNewFile,BufRead *.mix,*.mixal		setf mix
au BufNewFile,BufRead *.mms			call dist#ft#FTmms()
au BufNewFile,BufRead *.mmp			setf mmp
au BufNewFile,BufRead *.mod
\ if getline(1) =~ '\<module\>' |
\   setf lprolog |
\ else |
\   setf modsim3 |
\ endif
au BufNewFile,BufRead *.m2,*.DEF,*.MOD,*.mi	setf modula2
au BufNewFile,BufRead *.[mi][3g]		setf modula3
au BufNewFile,BufRead *.isc,*.monk,*.ssc,*.tsc	setf monk
au BufNewFile,BufRead *.moo			setf moo
au BufNewFile,BufRead */etc/modules.conf,*/etc/modules,*/etc/conf.modules setf modconf
au BufNewFile,BufRead mplayer.conf,*/.mplayer/config	setf mplayerconf
au BufNewFile,BufRead *.s19,*.s28,*.s37,*.mot,*.srec	setf srec
au BufNewFile,BufRead mrxvtrc,.mrxvtrc		setf mrxvtrc
au BufNewFile,BufRead *.msql			setf msql
au BufNewFile,BufRead *.mysql			setf mysql
au BufNewFile,BufRead */etc/Muttrc.d/*		call s:StarSetf('muttrc')
au BufNewFile,BufRead *.rc,*.rch		setf rc
au BufRead,BufNewFile *.mu			setf mupad
au BufNewFile,BufRead *.mush			setf mush
au BufNewFile,BufRead Mutt{ng,}rc		setf muttrc
au BufRead,BufNewfile *.n1ql,*.nql		setf n1ql
au BufNewFile,BufRead */etc/nanorc,*.nanorc  	setf nanorc
au BufNewFile,BufRead *.NS[ACGLMNPS]		setf natural
au BufNewFile,BufRead Neomuttrc			setf neomuttrc
au BufNewFile,BufRead .netrc			setf netrc
au BufNewFile,BufRead *.ninja			setf ninja
au BufNewFile,BufRead *.ncf			setf ncf
au BufNewFile,BufRead *.me
\ if expand("<afile>") != "read.me" && expand("<afile>") != "click.me" |
\   setf nroff |
\ endif
au BufNewFile,BufRead *.tr,*.nr,*.roff,*.tmac,*.mom	setf nroff
au BufNewFile,BufRead *.[1-9]			call dist#ft#FTnroff()
au BufNewFile,BufRead *.mm			call dist#ft#FTmm()
au BufNewFile,BufRead *.nqc			setf nqc
au BufNewFile,BufRead *.nse			setf lua
au BufNewFile,BufRead *.nsi,*.nsh		setf nsis
au BufNewFile,BufRead *.ml,*.mli,*.mll,*.mly,.ocamlinit	setf ocaml
au BufNewFile,BufRead *.occ			setf occam
au BufNewFile,BufRead *.xom,*.xin		setf omnimark
au BufNewFile,BufRead *.or			setf openroad
au BufNewFile,BufRead *.[Oo][Pp][Ll]		setf opl
au BufNewFile,BufRead *.ora			setf ora
au BufNewFile,BufRead pf.conf			setf pf
au BufNewFile,BufRead */etc/pam.conf		setf pamconf
au BufNewFile,BufRead *.papp,*.pxml,*.pxsl	setf papp
au BufNewFile,BufRead */etc/passwd,*/etc/passwd-,*/etc/passwd.edit,*/etc/shadow,*/etc/shadow-,*/etc/shadow.edit,*/var/backups/passwd.bak,*/var/backups/shadow.bak setf passwd
au BufNewFile,BufRead *.pas			setf pascal
au BufNewFile,BufRead *.dpr			setf pascal
au BufNewFile,BufRead *.pdf			setf pdf
au BufNewFile,BufRead *.pcmk 			setf pcmk
if has("fname_case")
au BufNewFile,BufRead *.pl,*.PL		call dist#ft#FTpl()
else
au BufNewFile,BufRead *.pl			call dist#ft#FTpl()
endif
au BufNewFile,BufRead *.plx,*.al,*.psgi		setf perl
au BufNewFile,BufRead *.p6,*.pm6,*.pl6		setf perl6
au BufNewFile,BufRead *.pm
\ if getline(1) =~ "XPM2" |
\   setf xpm2 |
\ elseif getline(1) =~ "XPM" |
\   setf xpm |
\ else |
\   setf perl |
\ endif
au BufNewFile,BufRead *.pod			setf pod
au BufNewFile,BufRead *.pod6			setf pod6
au BufNewFile,BufRead *.php,*.php\d,*.phtml,*.ctp	setf php
au BufNewFile,BufRead *.pike,*.pmod		setf pike
au BufNewFile,BufRead *.cmod			setf cmod
au BufNewFile,BufRead */etc/pinforc,*/.pinforc	setf pinfo
au BufNewFile,BufRead *.rcp			setf pilrc
au BufNewFile,BufRead .pinerc,pinerc,.pinercex,pinercex		setf pine
au BufNewFile,BufRead Pipfile			setf config
au BufNewFile,BufRead Pipfile.lock		setf json
au BufNewFile,BufRead *.pli,*.pl1		setf pli
au BufNewFile,BufRead *.plm,*.p36,*.pac		setf plm
au BufNewFile,BufRead *.pls,*.plsql		setf plsql
au BufNewFile,BufRead *.plp			setf plp
au BufNewFile,BufRead *.po,*.pot		setf po
au BufNewFile,BufRead main.cf			setf pfmain
au BufNewFile,BufRead *.ps,*.pfa,*.afm,*.eps,*.epsf,*.epsi,*.ai	  setf postscr
au BufNewFile,BufRead *.ppd			setf ppd
au BufNewFile,BufRead *.pov			setf pov
au BufNewFile,BufRead .povrayrc			setf povini
au BufNewFile,BufRead *.inc			call dist#ft#FTinc()
au BufNewFile,BufRead *printcap
\ let b:ptcap_type = "print" | setf ptcap
au BufNewFile,BufRead *termcap
\ let b:ptcap_type = "term" | setf ptcap
au BufNewFile,BufRead *.g			setf pccts
au BufNewFile,BufRead *.it,*.ih			setf ppwiz
au BufNewFile,BufRead *.obj			setf obj
au BufNewFile,BufRead *.pc			setf proc
au BufNewFile,BufRead *.action			setf privoxy
au BufNewFile,BufRead .procmail,.procmailrc	setf procmail
au BufNewFile,BufRead *.w			call dist#ft#FTprogress_cweb()
au BufNewFile,BufRead *.i			call dist#ft#FTprogress_asm()
au BufNewFile,BufRead *.p			call dist#ft#FTprogress_pascal()
au BufNewFile,BufRead *.psf			setf psf
au BufNewFile,BufRead INDEX,INFO
\ if getline(1) =~ '^\s*\(distribution\|installed_software\|root\|bundle\|product\)\s*$' |
\   setf psf |
\ endif
au BufNewFile,BufRead *.pdb			setf prolog
au BufNewFile,BufRead *.pml			setf promela
au BufNewFile,BufRead *.proto			setf proto
au BufNewFile,BufRead */etc/protocols		setf protocols
au BufNewFile,BufRead *.pyx,*.pxd		setf pyrex
au BufNewFile,BufRead *.py,*.pyw,.pythonstartup,.pythonrc,*.ptl,*.pyi  setf python
au BufNewFile,BufRead *.rad,*.mat		setf radiance
au BufNewFile,BufRead .ratpoisonrc,ratpoisonrc	setf ratpoison
au BufNewFile,BufRead *\,v			setf rcs
au BufNewFile,BufRead .inputrc,inputrc		setf readline
au BufNewFile,BufRead *.reg
\ if getline(1) =~? '^REGEDIT[0-9]*\s*$\|^Windows Registry Editor Version \d*\.\d*\s*$' | setf registry | endif
au BufNewFile,BufRead *.rib			setf rib
au BufNewFile,BufRead *.rex,*.orx,*.rxo,*.rxj,*.jrexx,*.rexxj,*.rexx,*.testGroup,*.testUnit	setf rexx
if has("fname_case")
au BufNewFile,BufRead *.s,*.S			setf r
else
au BufNewFile,BufRead *.s			setf r
endif
if has("fname_case")
au BufNewFile,BufRead *.rd,*.Rd		setf rhelp
else
au BufNewFile,BufRead *.rd			setf rhelp
endif
if has("fname_case")
au BufNewFile,BufRead *.Rnw,*.rnw,*.Snw,*.snw		setf rnoweb
else
au BufNewFile,BufRead *.rnw,*.snw			setf rnoweb
endif
if has("fname_case")
au BufNewFile,BufRead *.Rmd,*.rmd,*.Smd,*.smd		setf rmd
else
au BufNewFile,BufRead *.rmd,*.smd			setf rmd
endif
if has("fname_case")
au BufNewFile,BufRead *.Rrst,*.rrst,*.Srst,*.srst	setf rrst
else
au BufNewFile,BufRead *.rrst,*.srst			setf rrst
endif
au BufNewFile,BufRead *.r,*.R				call dist#ft#FTr()
au BufNewFile,BufRead .reminders,*.remind,*.rem		setf remind
au BufNewFile,BufRead resolv.conf		setf resolv
au BufNewFile,BufRead *.rnc			setf rnc
au BufNewFile,BufRead *.rng			setf rng
au BufNewFile,BufRead *.rpl			setf rpl
au BufNewFile,BufRead robots.txt		setf robots
au BufNewFile,BufRead *.x			setf rpcgen
au BufNewFile,BufRead *.rst			setf rst
au BufNewFile,BufRead *.rtf			setf rtf
au BufNewFile,BufRead .irbrc,irbrc		setf ruby
au BufNewFile,BufRead *.rb,*.rbw		setf ruby
au BufNewFile,BufRead *.gemspec			setf ruby
au BufNewFile,BufRead *.rs			setf rust
au BufNewFile,BufRead *.ru			setf ruby
au BufNewFile,BufRead Gemfile			setf ruby
au BufNewFile,BufRead *.builder,*.rxml,*.rjs	setf ruby
au BufNewFile,BufRead [rR]antfile,*.rant,[rR]akefile,*.rake	setf ruby
au BufNewFile,BufRead *.sl			setf slang
au BufNewFile,BufRead smb.conf			setf samba
au BufNewFile,BufRead *.sas			setf sas
au BufNewFile,BufRead *.sass			setf sass
au BufNewFile,BufRead *.sa			setf sather
au BufNewFile,BufRead *.scala			setf scala
au BufNewFile,BufRead *.sbt			setf sbt
au BufNewFile,BufRead *.sci,*.sce		setf scilab
au BufNewFile,BufRead *.scss			setf scss
au BufNewFile,BufRead *.sd			setf sd
au BufNewFile,BufRead *.sdl,*.pr		setf sdl
au BufNewFile,BufRead *.sed			setf sed
au BufNewFile,BufRead *.siv,*.sieve		setf sieve
au BufNewFile,BufRead sendmail.cf		setf sm
au BufNewFile,BufRead *.mc			call dist#ft#McSetf()
au BufNewFile,BufRead */etc/services		setf services
au BufNewFile,BufRead */etc/slp.conf		setf slpconf
au BufNewFile,BufRead */etc/slp.reg		setf slpreg
au BufNewFile,BufRead */etc/slp.spi		setf slpspi
au BufNewFile,BufRead */etc/serial.conf		setf setserial
au BufNewFile,BufRead *.sgm,*.sgml
\ if getline(1).getline(2).getline(3).getline(4).getline(5) =~? 'linuxdoc' |
\   setf sgmllnx |
\ elseif getline(1) =~ '<!DOCTYPE.*DocBook' || getline(2) =~ '<!DOCTYPE.*DocBook' |
\   let b:docbk_type = "sgml" |
\   let b:docbk_ver = 4 |
\   setf docbk |
\ else |
\   setf sgml |
\ endif
au BufNewFile,BufRead *.decl,*.dcl,*.dec
\ if getline(1).getline(2).getline(3) =~? '^<!SGML' |
\    setf sgmldecl |
\ endif
au BufNewFile,BufRead catalog			setf catalog
au BufNewFile,BufRead .bashrc,bashrc,bash.bashrc,.bash[_-]profile,.bash[_-]logout,.bash[_-]aliases,bash-fc[-.],*.bash,*/{,.}bash[_-]completion{,.d,.sh}{,/*},*.ebuild,*.eclass,PKGBUILD call dist#ft#SetFileTypeSH("bash")
au BufNewFile,BufRead .kshrc,*.ksh call dist#ft#SetFileTypeSH("ksh")
au BufNewFile,BufRead */etc/profile,.profile,*.sh,*.env call dist#ft#SetFileTypeSH(getline(1))
au BufNewFile,BufRead *.install
\ if getline(1) =~ '<?php' |
\   setf php |
\ else |
\   call dist#ft#SetFileTypeSH("bash") |
\ endif
au BufNewFile,BufRead .tcshrc,*.tcsh,tcsh.tcshrc,tcsh.login	call dist#ft#SetFileTypeShell("tcsh")
au BufNewFile,BufRead .login,.cshrc,csh.cshrc,csh.login,csh.logout,*.csh,.alias  call dist#ft#CSH()
au BufNewFile,BufRead .zprofile,*/etc/zprofile,.zfbfmarks  setf zsh
au BufNewFile,BufRead .zshrc,.zshenv,.zlogin,.zlogout,.zcompdump setf zsh
au BufNewFile,BufRead *.zsh			setf zsh
au BufNewFile,BufRead *.scm,*.ss,*.rkt		setf scheme
au BufNewFile,BufRead .screenrc,screenrc	setf screen
au BufNewFile,BufRead *.sim			setf simula
au BufNewFile,BufRead *.sin,*.s85		setf sinda
au BufNewFile,BufRead *.sst,*.ssm,*.ssi,*.-sst,*._sst setf sisu
au BufNewFile,BufRead *.sst.meta,*.-sst.meta,*._sst.meta setf sisu
au BufNewFile,BufRead *.il,*.ils,*.cdf		setf skill
au BufNewFile,BufRead .slrnrc			setf slrnrc
au BufNewFile,BufRead *.score			setf slrnsc
au BufNewFile,BufRead *.st			setf st
au BufNewFile,BufRead *.cls
\ if getline(1) =~ '^%' |
\  setf tex |
\ elseif getline(1)[0] == '#' && getline(1) =~ 'rexx' |
\  setf rexx |
\ else |
\  setf st |
\ endif
au BufNewFile,BufRead *.tpl			setf smarty
au BufNewFile,BufRead *.smil
\ if getline(1) =~ '<?\s*xml.*?>' |
\   setf xml |
\ else |
\   setf smil |
\ endif
au BufNewFile,BufRead *.smi
\ if getline(1) =~ '\<smil\>' |
\   setf smil |
\ else |
\   setf mib |
\ endif
au BufNewFile,BufRead *.smt,*.smith		setf smith
au BufNewFile,BufRead *.sno,*.spt		setf snobol4
au BufNewFile,BufRead *.mib,*.my		setf mib
au BufNewFile,BufRead *.hog,snort.conf,vision.conf	setf hog
au BufNewFile,BufRead *.rules			call dist#ft#FTRules()
au BufNewFile,BufRead *.spec			setf spec
au BufNewFile,BufRead *.speedup,*.spdata,*.spd	setf spup
au BufNewFile,BufRead *.ice			setf slice
au BufNewFile,BufRead *.sp,*.spice		setf spice
au BufNewFile,BufRead *.spy,*.spi		setf spyce
au BufNewFile,BufRead squid.conf		setf squid
au BufNewFile,BufRead *.tyb,*.typ,*.tyc,*.pkb,*.pks	setf sql
au BufNewFile,BufRead *.sql			call dist#ft#SQL()
au BufNewFile,BufRead *.sqlj			setf sqlj
au BufNewFile,BufRead *.sqr,*.sqi		setf sqr
au BufNewFile,BufRead ssh_config,*/.ssh/config	setf sshconfig
au BufNewFile,BufRead sshd_config		setf sshdconfig
au BufNewFile,BufRead *.ado,*.do,*.imata,*.mata	setf stata
au BufNewFile,BufRead *.class
\ if getline(1) !~ "^\xca\xfe\xba\xbe" | setf stata | endif
au BufNewFile,BufRead *.hlp,*.ihlp,*.smcl	setf smcl
au BufNewFile,BufRead *.stp			setf stp
au BufNewFile,BufRead *.sml			setf sml
au BufNewFile,BufRead *.cm			setf voscm
au BufNewFile,BufRead */etc/sysctl.conf,*/etc/sysctl.d/*.conf	setf sysctl
au BufNewFile,BufRead */systemd/*.{automount,mount,path,service,socket,swap,target,timer}	setf systemd
au BufNewFile,BufRead /etc/systemd/system/*.d/*.conf	setf systemd
au BufNewFile,BufRead /etc/systemd/system/*.d/.#*	setf systemd
au BufNewFile,BufRead *.sdc			setf sdc
au BufNewFile,BufRead */etc/sudoers,sudoers.tmp	setf sudoers
au BufNewFile,BufRead *.svg			setf svg
au BufNewFile,BufRead *.t
\ if !dist#ft#FTnroff() && !dist#ft#FTperl() | setf tads | endif
au BufNewFile,BufRead tags			setf tags
au BufNewFile,BufRead *.tak			setf tak
au BufRead,BufNewFile {pending,completed,undo}.data  setf taskdata
au BufRead,BufNewFile *.task			setf taskedit
au BufNewFile,BufRead *.tcl,*.tk,*.itcl,*.itk,*.jacl	setf tcl
au BufNewFile,BufRead *.tli			setf tli
au BufNewFile,BufRead *.slt			setf tsalt
au BufRead,BufNewFile *.ttl			setf teraterm
au BufNewFile,BufRead *.ti			setf terminfo
au BufNewFile,BufRead *.latex,*.sty,*.dtx,*.ltx,*.bbl	setf tex
au BufNewFile,BufRead *.tex			call dist#ft#FTtex()
au BufNewFile,BufRead *.mkii,*.mkiv,*.mkvi   setf context
au BufNewFile,BufRead *.texinfo,*.texi,*.txi	setf texinfo
au BufNewFile,BufRead texmf.cnf			setf texmf
au BufNewFile,BufRead .tidyrc,tidyrc		setf tidy
au BufNewFile,BufRead *.tf,.tfrc,tfrc		setf tf
au BufNewFile,BufRead {.,}tmux*.conf		setf tmux
au BufNewFile,BufReadPost *.tpp			setf tpp
au BufRead,BufNewFile *.treetop			setf treetop
au BufNewFile,BufRead trustees.conf		setf trustees
au BufNewFile,BufReadPost *.tssgm		setf tssgm
au BufNewFile,BufReadPost *.tssop		setf tssop
au BufNewFile,BufReadPost *.tsscl		setf tsscl
au BufNewFile,BufReadPost *.twig		setf twig
au BufNewFile,BufReadPost *.ts			setf typescript
au BufNewFile,BufRead *.uit,*.uil		setf uil
au BufNewFile,BufRead */etc/udev/udev.conf	setf udevconf
au BufNewFile,BufRead */etc/udev/permissions.d/*.permissions setf udevperm
au BufNewFile,BufRead */etc/udev/cdsymlinks.conf	setf sh
au BufNewFile,BufRead *.uc			setf uc
au BufNewFile,BufRead */etc/updatedb.conf	setf updatedb
au BufNewFile,BufRead */usr/share/upstart/*.conf	       setf upstart
au BufNewFile,BufRead */usr/share/upstart/*.override	       setf upstart
au BufNewFile,BufRead */etc/init/*.conf,*/etc/init/*.override  setf upstart
au BufNewFile,BufRead */.init/*.conf,*/.init/*.override	       setf upstart
au BufNewFile,BufRead */.config/upstart/*.conf		       setf upstart
au BufNewFile,BufRead */.config/upstart/*.override	       setf upstart
au BufNewFile,BufRead *.vr,*.vri,*.vrh		setf vera
au BufNewFile,BufRead *.v			setf verilog
au BufNewFile,BufRead *.va,*.vams		setf verilogams
au BufNewFile,BufRead *.sv,*.svh		setf systemverilog
au BufNewFile,BufRead *.hdl,*.vhd,*.vhdl,*.vbe,*.vst  setf vhdl
au BufNewFile,BufRead *.vim,*.vba,.exrc,_exrc	setf vim
au BufNewFile,BufRead .viminfo,_viminfo		setf viminfo
au BufRead,BufNewFile *.hw,*.module,*.pkg
\ if getline(1) =~ '<?php' |
\   setf php |
\ else |
\   setf virata |
\ endif
au BufNewFile,BufRead *.frm			call dist#ft#FTVB("form")
au BufNewFile,BufRead *.sba			setf vb
au BufNewFile,BufRead vgrindefs			setf vgrindefs
au BufNewFile,BufRead *.wrl			setf vrml
au BufNewFile,BufRead *.vroom			setf vroom
au BufNewFile,BufRead *.wm			setf webmacro
au BufNewFile,BufRead *.wast,*.wat		setf wast
au BufNewFile,BufRead .wgetrc,wgetrc		setf wget
au BufNewFile,BufRead *.wml			setf wml
au BufNewFile,BufRead *.wbt			setf winbatch
au BufNewFile,BufRead *.wsml			setf wsml
au BufNewFile,BufRead *.wpl			setf xml
au BufNewFile,BufRead wvdial.conf,.wvdialrc	setf wvdial
au BufNewFile,BufRead .cvsrc			setf cvsrc
au BufNewFile,BufRead cvs\d\+			setf cvs
au BufNewFile,BufRead *.web
\ if getline(1)[0].getline(2)[0].getline(3)[0].getline(4)[0].getline(5)[0] =~ "%" |
\   setf web |
\ else |
\   setf winbatch |
\ endif
au BufNewFile,BufRead *.ws[fc]			setf wsh
au BufNewFile,BufRead *.xhtml,*.xht		setf xhtml
au BufEnter *.xpm
\ if getline(1) =~ "XPM2" |
\   setf xpm2 |
\ else |
\   setf xpm |
\ endif
au BufEnter *.xpm2				setf xpm2
au BufNewFile,BufRead XF86Config
\ if getline(1) =~ '\<XConfigurator\>' |
\   let b:xf86conf_xfree86_version = 3 |
\ endif |
\ setf xf86conf
au BufNewFile,BufRead */xorg.conf.d/*.conf
\ let b:xf86conf_xfree86_version = 4 |
\ setf xf86conf
au BufNewFile,BufRead xorg.conf,xorg.conf-4	let b:xf86conf_xfree86_version = 4 | setf xf86conf
au BufNewFile,BufRead */etc/xinetd.conf		setf xinetd
au BufNewFile,BufRead *.xs			setf xs
au BufNewFile,BufRead .Xdefaults,.Xpdefaults,.Xresources,xdm-config,*.ad setf xdefaults
au BufNewFile,BufRead *.msc,*.msf		setf xmath
au BufNewFile,BufRead *.ms
\ if !dist#ft#FTnroff() | setf xmath | endif
au BufNewFile,BufRead *.xml			call dist#ft#FTxml()
au BufNewFile,BufRead *.xmi			setf xml
au BufNewFile,BufRead *.csproj,*.csproj.user	setf xml
au BufNewFile,BufRead *.ui			setf xml
au BufNewFile,BufRead *.tpm			setf xml
au BufNewFile,BufRead */etc/xdg/menus/*.menu	setf xml
au BufNewFile,BufRead fglrxrc			setf xml
au BufNewFile,BufRead *.wsdl			setf xml
au BufNewFile,BufRead *.xlf			setf xml
au BufNewFile,BufRead *.xliff			setf xml
au BufNewFile,BufRead *.xul			setf xml
au BufNewFile,BufRead *Xmodmap			setf xmodmap
au BufNewFile,BufRead *.xq,*.xql,*.xqm,*.xquery,*.xqy	setf xquery
au BufNewFile,BufRead *.xsd			setf xsd
au BufNewFile,BufRead *.xsl,*.xslt		setf xslt
au BufNewFile,BufRead *.yy,*.yxx,*.y++		setf yacc
au BufNewFile,BufRead *.y			call dist#ft#FTy()
au BufNewFile,BufRead *.yaml,*.yml		setf yaml
au BufNewFile,BufRead *.raml			setf raml
au BufNewFile,BufRead */etc/yum.conf		setf dosini
au BufNewFile,BufRead *.zu			setf zimbu
au BufNewFile,BufRead *.zut			setf zimbutempl
au BufNewFile,BufRead *.dtml,*.pt,*.cpt		call dist#ft#FThtml()
au BufNewFile,BufRead *.zsql			call dist#ft#SQL()
au BufNewFile,BufRead *.z8a			setf z8a
augroup END
if exists("myfiletypefile") && filereadable(expand(myfiletypefile))
execute "source " . myfiletypefile
endif
augroup filetypedetect
au BufNewFile,BufRead *
\ if !did_filetype() && expand("<amatch>") !~ g:ft_ignore_pat
\ | runtime! scripts.vim | endif
au StdinReadPost * if !did_filetype() | runtime! scripts.vim | endif
au BufNewFile,BufRead */etc/proftpd/*.conf*,*/etc/proftpd/conf.*/*	call s:StarSetf('apachestyle')
au BufNewFile,BufRead proftpd.conf*					call s:StarSetf('apachestyle')
au BufNewFile,BufRead access.conf*,apache.conf*,apache2.conf*,httpd.conf*,srm.conf*	call s:StarSetf('apache')
au BufNewFile,BufRead */etc/apache2/*.conf*,*/etc/apache2/conf.*/*,*/etc/apache2/mods-*/*,*/etc/apache2/sites-*/*,*/etc/httpd/conf.d/*.conf*		call s:StarSetf('apache')
au BufNewFile,BufRead *asterisk/*.conf*		call s:StarSetf('asterisk')
au BufNewFile,BufRead *asterisk*/*voicemail.conf* call s:StarSetf('asteriskvm')
au BufNewFile,BufRead bzr_log.*			setf bzr
if !has("fname_case")
au BufNewFile,BufRead BUILD			setf bzl
endif
au BufNewFile,BufRead */named/db.*,*/bind/db.*	call s:StarSetf('bindzone')
au BufNewFile,BufRead */.calendar/*,
\*/share/calendar/*/calendar.*,*/share/calendar/calendar.*
\					call s:StarSetf('calendar')
au BufNewFile,BufRead [cC]hange[lL]og*
\ if getline(1) =~ '; urgency='
\|  call s:StarSetf('debchangelog')
\|else
\|  call s:StarSetf('changelog')
\|endif
au BufNewFile,BufRead crontab,crontab.*,*/etc/cron.d/*		call s:StarSetf('crontab')
au BufNewFile,BufRead */etc/dnsmasq.d/*		call s:StarSetf('dnsmasq')
au BufNewFile,BufRead drac.*			call s:StarSetf('dracula')
au BufNewFile,BufRead */.fvwm/*			call s:StarSetf('fvwm')
au BufNewFile,BufRead *fvwmrc*,*fvwm95*.hook
\ let b:fvwm_version = 1 | call s:StarSetf('fvwm')
au BufNewFile,BufRead *fvwm2rc*
\ if expand("<afile>:e") == "m4"
\|  call s:StarSetf('fvwm2m4')
\|else
\|  let b:fvwm_version = 2 | call s:StarSetf('fvwm')
\|endif
au BufNewFile,BufRead */tmp/lltmp*		call s:StarSetf('gedcom')
au BufNewFile,BufRead */.gitconfig.d/*,/etc/gitconfig.d/* 	call s:StarSetf('gitconfig')
au BufNewFile,BufRead */gitolite-admin/conf/*	call s:StarSetf('gitolite')
au BufNewFile,BufRead .gtkrc*,gtkrc*		call s:StarSetf('gtkrc')
au BufNewFile,BufRead Prl*.*,JAM*.*		call s:StarSetf('jam')
au! BufNewFile,BufRead *jarg*
\ if getline(1).getline(2).getline(3).getline(4).getline(5) =~? 'THIS IS THE JARGON FILE'
\|  call s:StarSetf('jargon')
\|endif
au BufNewFile,BufRead *.properties_??_??_*	call s:StarSetf('jproperties')
au BufNewFile,BufRead Kconfig.*			call s:StarSetf('kconfig')
au BufNewFile,BufRead lilo.conf*		call s:StarSetf('lilo')
au BufNewFile,BufRead */etc/logcheck/*.d*/*	call s:StarSetf('logcheck')
au BufNewFile,BufRead [mM]akefile*		call s:StarSetf('make')
au BufNewFile,BufRead [rR]akefile*		call s:StarSetf('ruby')
au BufNewFile,BufRead {neo,}mutt[[:alnum:]._-]\\\{6\}	setf mail
au BufNewFile,BufRead reportbug-*		call s:StarSetf('mail')
au BufNewFile,BufRead */etc/modutils/*
\ if executable(expand("<afile>")) != 1
\|  call s:StarSetf('modconf')
\|endif
au BufNewFile,BufRead */etc/modprobe.*		call s:StarSetf('modconf')
au BufNewFile,BufRead .mutt{ng,}rc*,*/.mutt{ng,}/mutt{ng,}rc*	call s:StarSetf('muttrc')
au BufNewFile,BufRead mutt{ng,}rc*,Mutt{ng,}rc*		call s:StarSetf('muttrc')
au BufNewFile,BufRead .neomuttrc*,*/.neomutt/neomuttrc*	call s:StarSetf('neomuttrc')
au BufNewFile,BufRead neomuttrc*,Neomuttrc*		call s:StarSetf('neomuttrc')
au BufNewFile,BufRead tmac.*			call s:StarSetf('nroff')
au BufNewFile,BufRead /etc/hostname.*		call s:StarSetf('config')
au BufNewFile,BufRead */etc/pam.d/*		call s:StarSetf('pamconf')
au BufNewFile,BufRead *printcap*
\ if !did_filetype()
\|  let b:ptcap_type = "print" | call s:StarSetf('ptcap')
\|endif
au BufNewFile,BufRead *termcap*
\ if !did_filetype()
\|  let b:ptcap_type = "term" | call s:StarSetf('ptcap')
\|endif
au BufRead,BufNewFile *.rdf			call dist#ft#Redif()
au BufNewFile,BufRead .reminders*		call s:StarSetf('remind')
au BufNewFile,BufRead sgml.catalog*		call s:StarSetf('catalog')
au BufNewFile,BufRead .bashrc*,.bash[_-]profile*,.bash[_-]logout*,.bash[_-]aliases*,bash-fc[-.]*,,PKGBUILD* call dist#ft#SetFileTypeSH("bash")
au BufNewFile,BufRead .kshrc* call dist#ft#SetFileTypeSH("ksh")
au BufNewFile,BufRead .profile* call dist#ft#SetFileTypeSH(getline(1))
au BufNewFile,BufRead .tcshrc*	call dist#ft#SetFileTypeShell("tcsh")
au BufNewFile,BufRead .login*,.cshrc*  call dist#ft#CSH()
au BufNewFile,BufRead *.vhdl_[0-9]*		call s:StarSetf('vhdl')
au BufNewFile,BufRead *vimrc*			call s:StarSetf('vim')
au BufNewFile,BufRead svn-commit*.tmp		setf svn
au BufNewFile,BufRead Xresources*,*/app-defaults/*,*/Xresources/* call s:StarSetf('xdefaults')
au BufNewFile,BufRead XF86Config-4*
\ let b:xf86conf_xfree86_version = 4 | call s:StarSetf('xf86conf')
au BufNewFile,BufRead XF86Config*
\ if getline(1) =~ '\<XConfigurator\>'
\|  let b:xf86conf_xfree86_version = 3
\|endif
\|call s:StarSetf('xf86conf')
au BufNewFile,BufRead *xmodmap*			call s:StarSetf('xmodmap')
au BufNewFile,BufRead */etc/xinetd.d/*		call s:StarSetf('xinetd')
au BufNewFile,BufRead */etc/yum.repos.d/*	call s:StarSetf('dosini')
au BufNewFile,BufRead .zsh*,.zlog*,.zcompdump*  call s:StarSetf('zsh')
au BufNewFile,BufRead zsh*,zlog*		call s:StarSetf('zsh')
au BufNewFile,BufRead *.text,README		setf text
au BufNewFile,BufRead *.txt
\  if getline('$') !~ 'vim:.*ft=help'
\|   setf text
\| endif
runtime! ftdetect/*.vim
augroup END
au filetypedetect BufNewFile,BufRead,StdinReadPost *
\ if !did_filetype() && expand("<amatch>") !~ g:ft_ignore_pat
\    && (getline(1) =~ '^#' || getline(2) =~ '^#' || getline(3) =~ '^#'
\	|| getline(4) =~ '^#' || getline(5) =~ '^#') |
\   setf FALLBACK conf |
\ endif
if has("menu") && has("gui_running")
\ && !exists("did_install_syntax_menu") && &guioptions !~# "M"
source <sfile>:p:h/menu.vim
endif
func! TestFiletypeFuncs(testlist)
let output = ''
for f in a:testlist
try
exe f
catch
let output = output . "\n" . f . ": " . v:exception
endtry
endfor
return output
endfunc
let &cpo = s:cpo_save
unlet s:cpo_save
