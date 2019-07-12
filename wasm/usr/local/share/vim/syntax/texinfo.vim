if exists("b:current_syntax")
finish
endif
if !exists("main_syntax")
let main_syntax = 'texinfo'
endif
syn sync lines=200
syn match texinfoIdent	    "\k\+"		  contained "IDENTifier
syn match texinfoAssignment "\k\+\s*=\s*\k\+\s*$" contained "assigment statement ( var = val )
syn match texinfoSinglePar  "\k\+\s*$"		  contained "single parameter (used for several @-commands)
syn match texinfoIndexPar   "\k\k\s*$"		  contained "param. used for different *index commands (+ @documentlanguage command)
syn match texinfoSpecialChar				    "@acronym"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@acronym{" end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@b"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@b{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@cite"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@cite{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@code"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@code{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@command"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@command{" end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@dfn"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@dfn{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@email"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@email{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@emph"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@emph{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@env"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@env{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@file"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@file{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@i"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@i{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@kbd"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@kbd{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@key"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@key{"	end="}" contains=texinfoSpecialChar
syn match texinfoSpecialChar				    "@option"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@option{"	end="}" contains=texinfoSpecialChar
syn match texinfoSpecialChar				    "@r"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@r{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@samp"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@samp{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@sc"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@sc{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@strong"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@strong{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@t"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@t{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@url"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@url{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoSpecialChar				    "@var"		contained
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@var{"	end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoAtCmd "^@kbdinputstyle" nextgroup=texinfoSinglePar skipwhite
syn match texinfoComment  "@c .*"
syn match texinfoComment  "@c$"
syn match texinfoComment  "@comment .*"
syn region texinfoMltlnAtCmd matchgroup=texinfoComment start="^@ignore\s*$" end="^@end ignore\s*$" contains=ALL
syn region texinfoPrmAtCmd     matchgroup=texinfoAtCmd start="@center "		 skip="\\$" end="$"		       contains=texinfoSpecialChar,texinfoBrcPrmAtCmd oneline
syn region texinfoMltlnDMAtCmd matchgroup=texinfoAtCmd start="^@detailmenu\s*$"		    end="^@end detailmenu\s*$" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn region texinfoPrmAtCmd     matchgroup=texinfoAtCmd start="^@setfilename "    skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd     matchgroup=texinfoAtCmd start="^@settitle "       skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd     matchgroup=texinfoAtCmd start="^@shorttitlepage " skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd     matchgroup=texinfoAtCmd start="^@title "		 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoBrcPrmAtCmd  matchgroup=texinfoAtCmd start="@titlefont{"		    end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn region texinfoMltlnAtCmd   matchgroup=texinfoAtCmd start="^@titlepage\s*$"		    end="^@end titlepage\s*$" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd,texinfoMltlnDMAtCmd,texinfoAtCmd,texinfoPrmAtCmd,texinfoMltlnAtCmd
syn region texinfoPrmAtCmd     matchgroup=texinfoAtCmd start="^@vskip "		 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn match texinfoAtCmd "^@exampleindent"     nextgroup=texinfoSinglePar skipwhite
syn match texinfoAtCmd "^@headings"	     nextgroup=texinfoSinglePar skipwhite
syn match texinfoAtCmd "^\\input"	     nextgroup=texinfoSinglePar skipwhite
syn match texinfoAtCmd "^@paragraphindent"   nextgroup=texinfoSinglePar skipwhite
syn match texinfoAtCmd "^@setchapternewpage" nextgroup=texinfoSinglePar skipwhite
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="@author " skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn match texinfoAtCmd "^@bye\s*$"
syn match texinfoAtCmd "^@contents\s*$"
syn match texinfoAtCmd "^@printindex" nextgroup=texinfoIndexPar skipwhite
syn match texinfoAtCmd "^@setcontentsaftertitlepage\s*$"
syn match texinfoAtCmd "^@setshortcontentsaftertitlepage\s*$"
syn match texinfoAtCmd "^@shortcontents\s*$"
syn match texinfoAtCmd "^@summarycontents\s*$"
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@appendix"		 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@appendixsec"	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@appendixsection"	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@appendixsubsec"	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@appendixsubsubsec"	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@centerchap"		 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@chapheading"	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@chapter"		 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@heading"		 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@majorheading"	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@section"		 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@subheading "	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@subsection"		 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@subsubheading"	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@subsubsection"	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@subtitle"		 skip="\\$" end="$" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@unnumbered"		 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@unnumberedsec"	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@unnumberedsubsec"	 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@unnumberedsubsubsec" skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn match  texinfoAtCmd "^@lowersections\s*$"
syn match  texinfoAtCmd "^@raisesections\s*$"
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@anchor{"		  end="}"
syn region texinfoPrmAtCmd    matchgroup=texinfoAtCmd start="^@top"    skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd    matchgroup=texinfoAtCmd start="^@node"   skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@menu\s*$" end="^@end menu\s*$" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd,texinfoMltlnDMAtCmd
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@inforef{" end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@pxref{"   end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@ref{"     end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@uref{"    end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@xref{"    end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@cartouche\s*$"	    end="^@end cartouche\s*$"	    contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@display\s*$"	    end="^@end display\s*$"	    contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@example\s*$"	    end="^@end example\s*$"	    contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@flushleft\s*$"	    end="^@end flushleft\s*$"	    contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@flushright\s*$"	    end="^@end flushright\s*$"	    contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@format\s*$"	    end="^@end format\s*$"	    contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@lisp\s*$"		    end="^@end lisp\s*$"	    contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@quotation\s*$"	    end="^@end quotation\s*$"	    contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@smalldisplay\s*$"     end="^@end smalldisplay\s*$"    contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@smallexample\s*$"     end="^@end smallexample\s*$"    contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@smallformat\s*$"	    end="^@end smallformat\s*$"     contains=ALL
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@smalllisp\s*$"	    end="^@end smalllisp\s*$"	    contains=ALL
syn region texinfoPrmAtCmd   matchgroup=texinfoAtCmd start="^@exdent"	 skip="\\$" end="$"			    contains=texinfoSpecialChar oneline
syn match texinfoAtCmd "^@noindent\s*$"
syn match texinfoAtCmd "^@smallbook\s*$"
syn match texinfoAtCmd "@asis"		   contained
syn match texinfoAtCmd "@columnfractions"  contained
syn match texinfoAtCmd "@item"		   contained
syn match texinfoAtCmd "@itemx"		   contained
syn match texinfoAtCmd "@tab"		   contained
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@enumerate"  end="^@end enumerate\s*$"  contains=ALL
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@ftable"     end="^@end ftable\s*$"     contains=ALL
syn region texinfoMltlnNAtCmd matchgroup=texinfoAtCmd start="^@itemize"    end="^@end itemize\s*$"    contains=ALL
syn region texinfoMltlnNAtCmd matchgroup=texinfoAtCmd start="^@multitable" end="^@end multitable\s*$" contains=ALL
syn region texinfoMltlnNAtCmd matchgroup=texinfoAtCmd start="^@table"      end="^@end table\s*$"      contains=ALL
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@vtable"     end="^@end vtable\s*$"     contains=ALL
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@\(c\|f\|k\|p\|t\|v\)index"   skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@..index"			 skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn match texinfoSIPar "\k\k\s*\k\k\s*$" contained
syn match texinfoAtCmd "^@syncodeindex" nextgroup=texinfoSIPar skipwhite
syn match texinfoAtCmd "^@synindex"     nextgroup=texinfoSIPar skipwhite
syn match texinfoSpecialChar "@\(!\|?\|@\|\s\)"
syn match texinfoSpecialChar "@{"
syn match texinfoSpecialChar "@}"
syn match texinfoSpecialChar "@=."
syn match texinfoSpecialChar "@\('\|\"\|\^\|`\)[aeiouyAEIOUY]"
syn match texinfoSpecialChar "@\~[aeinouyAEINOUY]"
syn match texinfoSpecialChar "@dotaccent{.}"
syn match texinfoSpecialChar "@H{.}"
syn match texinfoSpecialChar "@,{[cC]}"
syn match texinfoSpecialChar "@AA{}"
syn match texinfoSpecialChar "@aa{}"
syn match texinfoSpecialChar "@L{}"
syn match texinfoSpecialChar "@l{}"
syn match texinfoSpecialChar "@O{}"
syn match texinfoSpecialChar "@o{}"
syn match texinfoSpecialChar "@ringaccent{.}"
syn match texinfoSpecialChar "@tieaccent{..}"
syn match texinfoSpecialChar "@u{.}"
syn match texinfoSpecialChar "@ubaraccent{.}"
syn match texinfoSpecialChar "@udotaccent{.}"
syn match texinfoSpecialChar "@v{.}"
syn match texinfoSpecialChar "@AE{}"
syn match texinfoSpecialChar "@ae{}"
syn match texinfoSpecialChar "@copyright{}"
syn match texinfoSpecialChar "@bullet" contained "for tables and lists
syn match texinfoSpecialChar "@bullet{}"
syn match texinfoSpecialChar "@dotless{i}"
syn match texinfoSpecialChar "@dotless{j}"
syn match texinfoSpecialChar "@dots{}"
syn match texinfoSpecialChar "@enddots{}"
syn match texinfoSpecialChar "@equiv" contained "for tables and lists
syn match texinfoSpecialChar "@equiv{}"
syn match texinfoSpecialChar "@error{}"
syn match texinfoSpecialChar "@exclamdown{}"
syn match texinfoSpecialChar "@expansion{}"
syn match texinfoSpecialChar "@minus" contained "for tables and lists
syn match texinfoSpecialChar "@minus{}"
syn match texinfoSpecialChar "@OE{}"
syn match texinfoSpecialChar "@oe{}"
syn match texinfoSpecialChar "@point" contained "for tables and lists
syn match texinfoSpecialChar "@point{}"
syn match texinfoSpecialChar "@pounds{}"
syn match texinfoSpecialChar "@print{}"
syn match texinfoSpecialChar "@questiondown{}"
syn match texinfoSpecialChar "@result" contained "for tables and lists
syn match texinfoSpecialChar "@result{}"
syn match texinfoSpecialChar "@ss{}"
syn match texinfoSpecialChar "@TeX{}"
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@dmn{"      end="}"
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@footnote{" end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@image{"    end="}"
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@math{"     end="}"
syn match texinfoAtCmd "@footnotestyle" nextgroup=texinfoSinglePar skipwhite
syn match texinfoSpecialChar  "@\(\*\|-\|\.\)"
syn match texinfoAtCmd	      "^@need"	   nextgroup=texinfoSinglePar skipwhite
syn match texinfoAtCmd	      "^@page\s*$"
syn match texinfoAtCmd	      "^@sp"	   nextgroup=texinfoSinglePar skipwhite
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@group\s*$"   end="^@end group\s*$" contains=ALL
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@hyphenation{" end="}"
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@w{"	    end="}"		  contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoMltlnAtCmdFLine "^@def\k\+" contained
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@def\k\+" end="^@end def\k\+$"      contains=ALL
syn match texinfoAtCmd "@defcodeindex" nextgroup=texinfoIndexPar skipwhite
syn match texinfoAtCmd "@defindex" nextgroup=texinfoIndexPar skipwhite
syn match texinfoAtCmd "^@clear" nextgroup=texinfoSinglePar skipwhite
syn region texinfoMltln2AtCmd matchgroup=texinfoAtCmd start="^@html\s*$"	end="^@end html\s*$"
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@ifclear"		end="^@end ifclear\s*$"   contains=ALL
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@ifhtml"		end="^@end ifhtml\s*$"	  contains=ALL
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@ifinfo"		end="^@end ifinfo\s*$"	  contains=ALL
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@ifnothtml"	end="^@end ifnothtml\s*$" contains=ALL
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@ifnotinfo"	end="^@end ifnotinfo\s*$" contains=ALL
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@ifnottex"	end="^@end ifnottex\s*$"  contains=ALL
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@ifset"		end="^@end ifset\s*$"	  contains=ALL
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@iftex"		end="^@end iftex\s*$"	  contains=ALL
syn region texinfoPrmAtCmd    matchgroup=texinfoAtCmd start="^@set " skip="\\$" end="$" contains=texinfoSpecialChar oneline
syn region texinfoTexCmd			      start="\$\$"		end="\$\$" contained
syn region texinfoMltlnAtCmd  matchgroup=texinfoAtCmd start="^@tex"		end="^@end tex\s*$"	  contains=texinfoTexCmd
syn region texinfoBrcPrmAtCmd matchgroup=texinfoAtCmd start="@value{"		end="}" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
syn match texinfoAtCmd "@documentencoding" nextgroup=texinfoSinglePar skipwhite
syn match texinfoAtCmd "@documentlanguage" nextgroup=texinfoIndexPar skipwhite
syn match texinfoAtCmd	"@alias"		      nextgroup=texinfoAssignment skipwhite
syn match texinfoDIEPar "\S*\s*,\s*\S*\s*,\s*\S*\s*$" contained
syn match texinfoAtCmd	"@definfoenclose"	      nextgroup=texinfoDIEPar	  skipwhite
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@macro" end="^@end macro\s*$" contains=ALL
syn match texinfoAtCmd "^@afourlatex\s*$"
syn match texinfoAtCmd "^@afourpaper\s*$"
syn match texinfoAtCmd "^@afourwide\s*$"
syn match texinfoAtCmd "^@finalout\s*$"
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@pagesizes" end="$" oneline
syn region texinfoPrmAtCmd   matchgroup=texinfoAtCmd start="^@dircategory"  skip="\\$" end="$" oneline
syn region texinfoMltlnAtCmd matchgroup=texinfoAtCmd start="^@direntry\s*$"	       end="^@end direntry\s*$" contains=texinfoSpecialChar
syn match  texinfoAtCmd "^@novalidate\s*$"
syn match texinfoAtCmd "^@include" nextgroup=texinfoSinglePar skipwhite
syn match texinfoHFSpecialChar "@|"		  contained
syn match texinfoThisAtCmd     "@thischapter"	  contained
syn match texinfoThisAtCmd     "@thischaptername" contained
syn match texinfoThisAtCmd     "@thisfile"	  contained
syn match texinfoThisAtCmd     "@thispage"	  contained
syn match texinfoThisAtCmd     "@thistitle"	  contained
syn match texinfoThisAtCmd     "@today{}"	  contained
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@evenfooting"  skip="\\$" end="$" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd,texinfoThisAtCmd,texinfoHFSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@evenheading"  skip="\\$" end="$" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd,texinfoThisAtCmd,texinfoHFSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@everyfooting" skip="\\$" end="$" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd,texinfoThisAtCmd,texinfoHFSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@everyheading" skip="\\$" end="$" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd,texinfoThisAtCmd,texinfoHFSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@oddfooting"   skip="\\$" end="$" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd,texinfoThisAtCmd,texinfoHFSpecialChar oneline
syn region texinfoPrmAtCmd matchgroup=texinfoAtCmd start="^@oddheading"   skip="\\$" end="$" contains=texinfoSpecialChar,texinfoBrcPrmAtCmd,texinfoThisAtCmd,texinfoHFSpecialChar oneline
syn match  texinfoAtCmd "@refill"
syn cluster texinfoAll contains=ALLBUT,texinfoThisAtCmd,texinfoHFSpecialChar
syn cluster texinfoReducedAll contains=texinfoSpecialChar,texinfoBrcPrmAtCmd
hi def link texinfoSpecialChar	Special
hi def link texinfoHFSpecialChar	Special
hi def link texinfoError		Error
hi def link texinfoIdent		Identifier
hi def link texinfoAssignment	Identifier
hi def link texinfoSinglePar	Identifier
hi def link texinfoIndexPar	Identifier
hi def link texinfoSIPar		Identifier
hi def link texinfoDIEPar		Identifier
hi def link texinfoTexCmd		PreProc
hi def link texinfoAtCmd		Statement	"@-command
hi def link texinfoPrmAtCmd	String		"@-command in one line with unknown nr. of parameters
hi def link texinfoBrcPrmAtCmd	String		"@-command with parameter(s) in braces ({})
hi def link texinfoMltlnAtCmdFLine  texinfoAtCmd	"repeated embedded First lines in @-commands
hi def link texinfoMltlnAtCmd	String		"@-command in multiple lines
hi def link texinfoMltln2AtCmd	PreProc		"@-command in multiple lines (same as texinfoMltlnAtCmd, just with other colors)
hi def link texinfoMltlnDMAtCmd	PreProc		"@-command in multiple lines (same as texinfoMltlnAtCmd, just with other colors; used for @detailmenu, which can be included in @menu)
hi def link texinfoMltlnNAtCmd	Normal		"@-command in multiple lines (same as texinfoMltlnAtCmd, just with other colors)
hi def link texinfoThisAtCmd	Statement	"@-command used in headers and footers (@this... series)
hi def link texinfoComment	Comment
let b:current_syntax = "texinfo"
if main_syntax == 'texinfo'
unlet main_syntax
endif
