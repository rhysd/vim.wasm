if exists("b:current_syntax")
finish
endif
syn case ignore
syn keyword tssgmParam  units mirror param active sides submodel include
syn keyword tssgmParam  iconductor nbeta ngamma optics material thickness color
syn keyword tssgmParam  initial_temp
syn keyword tssgmParam  initial_id node_ids node_add node_type
syn keyword tssgmParam  gamma_boundaries gamma_add beta_boundaries
syn keyword tssgmParam  p1 p2 p3 p4 p5 p6 rot1 rot2 rot3 tx ty tz
syn keyword tssgmSurfType  rectangle trapezoid disc ellipse triangle
syn keyword tssgmSurfType  polygon cylinder cone sphere ellipic-cone
syn keyword tssgmSurfType  ogive torus box paraboloid hyperboloid ellipsoid
syn keyword tssgmSurfType  quadrilateral trapeziod
syn keyword tssgmArgs   OUT IN DOWN BOTH DOUBLE NONE SINGLE RADK CC FECC
syn keyword tssgmArgs   white red blue green yellow orange violet pink
syn keyword tssgmArgs   turquoise grey black
syn keyword tssgmArgs   Arithmetic Boundary Heater
syn keyword tssgmDelim  assembly
syn keyword tssgmEnd    end
syn keyword tssgmUnits  cm feet meters inches
syn keyword tssgmUnits  Celsius Kelvin Fahrenheit Rankine
syn match  tssgmDefault     "^DEFAULT/LENGTH = \(ft\|in\|cm\|m\)"
syn match  tssgmDefault     "^DEFAULT/TEMP = [CKFR]"
syn match  tssgmComment       /comment \+= \+".*"/ contains=tssParam,tssgmCommentString
syn match  tssgmCommentString /".*"/ contained
syn match  tssgmSurfIdent   " \S\+\.\d\+ \=$"
syn match  tssgmString      /"[^" ]\+"/ms=s+1,me=e-1 contains=ALLBUT,tssInteger
syn match  tssgmArgs	    / = [xyz],"/ms=s+3,me=e-2
syn match  tssgmInteger     "-\=\<[0-9]*\>"
syn match  tssgmFloat       "-\=\<[0-9]*\.[0-9]*"
syn match  tssgmScientific  "-\=\<[0-9]*\.[0-9]*E[-+]\=[0-9]\+\>"
hi def link tssgmParam		Statement
hi def link tssgmSurfType		Type
hi def link tssgmArgs		Special
hi def link tssgmDelim		Typedef
hi def link tssgmEnd		Macro
hi def link tssgmUnits		Special
hi def link tssgmDefault		SpecialComment
hi def link tssgmComment		Statement
hi def link tssgmCommentString	Comment
hi def link tssgmSurfIdent		Identifier
hi def link tssgmString		Delimiter
hi def link tssgmInteger		Number
hi def link tssgmFloat		Float
hi def link tssgmScientific	Float
let b:current_syntax = "tssgm"
