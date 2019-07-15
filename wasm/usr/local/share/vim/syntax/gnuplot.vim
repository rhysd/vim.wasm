if exists("b:current_syntax")
finish
endif
syn match gnuplotSpecial	"\\." contained
syn match gnuplotUnit		"[0-9]+in"
syn match gnuplotUnit		"[0-9]+cm"
syn match gnuplotUnit		"[0-9]+pt"
syn region gnuplotExternal	start="!" end="$"
syn region gnuplotComment	start="#" end="$" contains=gnuplotTodo
syn region gnuplotString	start=+"+ skip=+\\"+ end=+"+ contains=gnuplotSpecial
syn region gnuplotString	start="'" end="'"
syn keyword gnuplotNumber	GNUTERM GPVAL_TERM GPVAL_TERMOPTIONS GPVAL_SPLOT
syn keyword gnuplotNumber	GPVAL_OUTPUT GPVAL_ENCODING GPVAL_VERSION
syn keyword gnuplotNumber	GPVAL_PATCHLEVEL GPVAL_COMPILE_OPTIONS
syn keyword gnuplotNumber	GPVAL_MULTIPLOT GPVAL_PLOT GPVAL_VIEW_ZSCALE
syn keyword gnuplotNumber	GPVAL_TERMINALS GPVAL_pi GPVAL_NaN
syn keyword gnuplotNumber	GPVAL_ERRNO GPVAL_ERRMSG GPVAL_PWD
syn keyword gnuplotNumber	pi NaN GPVAL_LAST_PLOT GPVAL_TERM_WINDOWID
syn keyword gnuplotNumber	GPVAL_X_MIN GPVAL_X_MAX GPVAL_X_LOG
syn keyword gnuplotNumber	GPVAL_DATA_X_MIN GPVAL_DATA_X_MAX GPVAL_Y_MIN
syn keyword gnuplotNumber	GPVAL_Y_MAX GPVAL_Y_LOG GPVAL_DATA_Y_MIN
syn keyword gnuplotNumber	GPVAL_DATA_Y_MAX GPVAL_X2_MIN GPVAL_X2_MAX
syn keyword gnuplotNumber	GPVAL_X2_LOG GPVAL_DATA_X2_MIN GPVAL_DATA_X2_MAX
syn keyword gnuplotNumber	GPVAL_Y2_MIN GPVAL_Y2_MAX GPVAL_Y2_LOG
syn keyword gnuplotNumber	GPVAL_DATA_Y2_MIN GPVAL_DATA_Y2_MAX GPVAL_Z_MIN
syn keyword gnuplotNumber	GPVAL_Z_MAX GPVAL_Z_LOG GPVAL_DATA_Z_MIN
syn keyword gnuplotNumber	GPVAL_DATA_Z_MAX GPVAL_CB_MIN GPVAL_CB_MAX
syn keyword gnuplotNumber	GPVAL_CB_LOG GPVAL_DATA_CB_MIN GPVAL_DATA_CB_MAX
syn keyword gnuplotNumber	GPVAL_T_MIN GPVAL_T_MAX GPVAL_T_LOG GPVAL_U_MIN
syn keyword gnuplotNumber	GPVAL_U_MAX GPVAL_U_LOG GPVAL_V_MIN GPVAL_V_MAX
syn keyword gnuplotNumber	GPVAL_V_LOG GPVAL_R_MIN GPVAL_R_LOG
syn keyword gnuplotNumber	GPVAL_TERM_XMIN GPVAL_TERM_XMAX GPVAL_TERM_YMIN
syn keyword gnuplotNumber	GPVAL_TERM_YMAX GPVAL_TERM_XSIZE
syn keyword gnuplotNumber	GPVAL_TERM_YSIZE GPVAL_VIEW_MAP GPVAL_VIEW_ROT_X
syn keyword gnuplotNumber	GPVAL_VIEW_ROT_Z GPVAL_VIEW_SCALE
syn match gnuplotNumber		"GPFUN_[a-zA-Z_]*"
syn keyword gnuplotNumber	STATS_records STATS_outofrange STATS_invalid
syn keyword gnuplotNumber	STATS_blank STATS_blocks STATS_columns STATS_min
syn keyword gnuplotNumber	STATS_max STATS_index_min STATS_index_max
syn keyword gnuplotNumber	STATS_lo_quartile STATS_median STATS_up_quartile
syn keyword gnuplotNumber	STATS_mean STATS_stddev STATS_sum STATS_sumsq
syn keyword gnuplotNumber	STATS_correlation STATS_slope STATS_intercept
syn keyword gnuplotNumber	STATS_sumxy STATS_pos_min_y STATS_pos_max_y
syn keyword gnuplotNumber	STATS_mean STATS_stddev STATS_mean_x STATS_sum_x
syn keyword gnuplotNumber	STATS_stddev_x STATS_sumsq_x STATS_min_x
syn keyword gnuplotNumber	STATS_max_x STATS_median_x STATS_lo_quartile_x
syn keyword gnuplotNumber	STATS_up_quartile_x STATS_index_min_x
syn keyword gnuplotNumber	STATS_index_max_x STATS_mean_y STATS_stddev_y
syn keyword gnuplotNumber	STATS_sum_y STATS_sumsq_y STATS_min_y
syn keyword gnuplotNumber	STATS_max_y STATS_median_y STATS_lo_quartile_y
syn keyword gnuplotNumber	STATS_up_quartile_y STATS_index_min_y
syn keyword gnuplotNumber	STATS_index_max_y STATS_correlation STATS_sumxy
syn keyword gnuplotError	FIT_LIMIT FIT_MAXITER FIT_START_LAMBDA
syn keyword gnuplotError	FIT_LAMBDA_FACTOR FIT_LOG FIT_SCRIPT
syn case    ignore
syn match   gnuplotNumber	"\<[0-9]\+\(u\=l\=\|lu\|f\)\>"
syn match   gnuplotFloat	"\<[0-9]\+\.[0-9]*\(e[-+]\=[0-9]\+\)\=[fl]\=\>"
syn match   gnuplotFloat	"\.[0-9]\+\(e[-+]\=[0-9]\+\)\=[fl]\=\>"
syn match   gnuplotFloat	"\<[0-9]\+e[-+]\=[0-9]\+[fl]\=\>"
syn match   gnuplotNumber	"\<0x[0-9a-f]\+\(u\=l\=\|lu\)\>"
syn case    match
syn match   gnuplotOctalError	"\<0[0-7]*[89]"
syn keyword gnuplotFunc		abs acos acosh airy arg asin asinh atan atan2
syn keyword gnuplotFunc		atanh EllipticK EllipticE EllipticPi besj0 besj1
syn keyword gnuplotFunc		besy0 besy1 ceil cos cosh erf erfc exp expint
syn keyword gnuplotFunc		floor gamma ibeta inverf igamma imag invnorm int
syn keyword gnuplotFunc		lambertw lgamma log log10 norm rand real sgn sin
syn keyword gnuplotFunc		sin sinh sqrt tan tanh voigt
syn keyword gnuplotFunc		gprintf sprintf strlen strstrt substr strftime
syn keyword gnuplotFunc		strptime system word words
syn keyword gnuplotFunc		column columnhead columnheader defined exists
syn keyword gnuplotFunc		hsv2rgb stringcolumn timecolumn tm_hour tm_mday
syn keyword gnuplotFunc		tm_min tm_mon tm_sec tm_wday tm_yday tm_year
syn keyword gnuplotFunc		time valid value
syn keyword gnuplotKeyword	x y t u v z s
syn keyword gnuplotConditional	if else
syn keyword gnuplotRepeat	do for while
syn match gnuplotOperator	"[-+*/^|&?:]"
syn match gnuplotOperator	"\*\*"
syn match gnuplotOperator	"&&"
syn match gnuplotOperator	"||"
syn keyword gnuplotKeyword	via z x:z x:z:s x:y:z:s
syn keyword gnuplotKeyword	x:y:t:z:s x:y:t:u:z:s x:y:t:u:v:z:s
syn keyword gnuplotKeyword	axes x1y1 x1y2 x2y1 x2y2
syn keyword gnuplotKeyword	binary matrix general array record format endian
syn keyword gnuplotKeyword	filetype avs edf png scan transpose dx dy dz
syn keyword gnuplotKeyword	flipx flipy flipz origin center rotate using
syn keyword gnuplotKeyword	perpendicular skip every
syn keyword gnuplotKeyword	binary nonuniform matrix index every using
syn keyword gnuplotKeyword	smooth volatile noautoscale every index
syn keyword gnuplotKeyword	unique frequency cumulative cnormal kdensity
syn keyword gnuplotKeyword	csplines acsplines bezer sbezier
syn keyword gnuplotError	thru
syn keyword gnuplotKeyword	using u xticlabels yticlabels zticlabels
syn keyword gnuplotKeyword	x2ticlabels y2ticlabels xtic ytic ztic
syn keyword gnuplotKeyword	errorbars xerrorbars yerrorbars xyerrorbars
syn keyword gnuplotKeyword	errorlines xerrorlines yerrorlines xyerrorlines
syn keyword gnuplotKeyword	title t tit notitle columnheader at beginning
syn keyword gnuplotKeyword	end
syn keyword gnuplotKeyword	with w linestyle ls linetype lt linewidth
syn keyword gnuplotKeyword	lw linecolor lc pointtype pt pointsize ps
syn keyword gnuplotKeyword	fill fs nohidden3d nocontours nosurface palette
syn keyword gnuplotKeyword	lines l points p linespoints lp surface dots
syn keyword gnuplotKeyword	impulses labels vectors steps fsteps histeps
syn keyword gnuplotKeyword	errorbars errorlines financebars xerrorbars
syn keyword gnuplotKeyword	xerrorlines xyerrorbars yerrorbars yerrorlines
syn keyword gnuplotKeyword	boxes boxerrorbars boxxyerrorbars boxplot
syn keyword gnuplotKeyword	candlesticks circles ellipses filledcurves
syn keyword gnuplotKeyword	histogram image rgbimage rgbalpha pm3d variable
syn keyword gnuplotKeyword	save functions func variables all var terminal
syn keyword gnuplotKeyword	term set
syn keyword gnuplotKeyword	angles degrees deg radians rad
syn keyword gnuplotKeyword	arrow from to rto length angle arrowstyle as
syn keyword gnuplotKeyword	nohead head backhead heads size filled empty
syn keyword gnuplotKeyword	nofilled front back linestyle linetype linewidth
syn keyword gnuplotKeyword	autoscale x y z cb x2 y2 zy min max fixmin
syn keyword gnuplotKeyword	fixmax fix keepfix noextend
syn keyword gnuplotKeyword	bars small large fullwidth front back
syn keyword gnuplotKeyword	bind
syn keyword gnuplotKeyword	margin bmargin lmargin rmargin tmargin
syn keyword gnuplotKeyword	border front back
syn keyword gnuplotKeyword	boxwidth absolute relative
syn keyword gnuplotError	clabel
syn keyword gnuplotKeyword	clip points one two
syn keyword gnuplotKeyword	cntrlabel format font start interval onecolor
syn keyword gnuplotKeyword	cntrparam linear cubicspline bspline points
syn keyword gnuplotKeyword	order levels auto discrete incremental
syn keyword gnuplotKeyword	colorbox vertical horizontal default user origin
syn keyword gnuplotKeyword	size front back noborder bdefault border
syn keyword gnuplotKeyword	colornames
syn keyword gnuplotKeyword	contour base surface both
syn keyword gnuplotKeyword	datafile fortran nofpe_trap missing separator
syn keyword gnuplotKeyword	whitespace tab comma commentschars binary
syn keyword gnuplotKeyword	decimalsign locale
syn keyword gnuplotKeyword	dgrid3d splines qnorm gauss cauchy exp box hann
syn keyword gnuplotKeyword	kdensity
syn keyword gnuplotKeyword	dummy
syn keyword gnuplotKeyword	encoding default iso_8859_1 iso_8859_15
syn keyword gnuplotKeyword	iso_8859_2 iso_8859_9 koi8r koi8u cp437 cp850
syn keyword gnuplotKeyword	cp852 cp950 cp1250 cp1251 cp1254 sjis utf8
syn keyword gnuplotKeyword	fit logfile default quiet noquiet results brief
syn keyword gnuplotKeyword	verbose errorvariables noerrorvariables
syn keyword gnuplotKeyword	errorscaling noerrorscaling prescale noprescale
syn keyword gnuplotKeyword	maxiter none limit limit_abs start-lambda script
syn keyword gnuplotKeyword	lambda-factor
syn keyword gnuplotKeyword	fontpath
syn keyword gnuplotKeyword	format
syn keyword gnuplotKeyword	functions
syn keyword gnuplotKeyword	grid polar layerdefault xtics ytics ztics x2tics
syn keyword gnuplotKeyword	y2tics cbtics mxtics mytics mztics mx2tics
syn keyword gnuplotKeyword	my2tics mcbtics xmtics ymtics zmtics x2mtics
syn keyword gnuplotKeyword	y2mtics cbmtics noxtics noytics noztics nox2tics
syn keyword gnuplotKeyword	noy2tics nocbtics nomxtics nomytics nomztics
syn keyword gnuplotKeyword	nomx2tics nomy2tics nomcbtics
syn keyword gnuplotKeyword	hidden3d offset trianglepattern undefined
syn keyword gnuplotKeyword	altdiagonal noaltdiagonal bentover nobentover
syn keyword gnuplotKeyword	noundefined
syn keyword gnuplotKeyword	historysize
syn keyword gnuplotKeyword	isosamples
syn keyword gnuplotKeyword	key on off inside outside at left right center
syn keyword gnuplotKeyword	top bottom vertical horizontal Left Right
syn keyword gnuplotKeyword	opaque noopaque reverse noreverse invert maxrows
syn keyword gnuplotKeyword	noinvert samplen spacing width height autotitle
syn keyword gnuplotKeyword	noautotitle title enhanced noenhanced font
syn keyword gnuplotKeyword	textcolor box nobox linetype linewidth maxcols
syn keyword gnuplotKeyword	label left center right rotate norotate by font
syn keyword gnuplotKeyword	front back textcolor point nopoint offset boxed
syn keyword gnuplotKeyword	hypertext
syn keyword gnuplotKeyword	linetype
syn keyword gnuplotKeyword	link via inverse
syn keyword gnuplotKeyword	loadpath
syn keyword gnuplotKeyword	locale
syn keyword gnuplotKeyword	logscale log
syn keyword gnuplotKeyword	macros
syn keyword gnuplotKeyword	mapping cartesian spherical cylindrical
syn keyword gnuplotKeyword	mouse doubleclick nodoubleclick zoomcoordinates
syn keyword gnuplotKeyword	nozoomcoordinates ruler noruler at polardistance
syn keyword gnuplotKeyword	nopolardistance deg tan format clipboardformat
syn keyword gnuplotKeyword	mouseformat labels nolabels zoomjump nozoomjump
syn keyword gnuplotKeyword	verbose noverbose
syn keyword gnuplotKeyword	multiplot title font layout rowsfirst downwards
syn keyword gnuplotKeyword	downwards upwards scale offset
syn keyword gnuplotKeyword	object behind fillcolor fc fs rectangle ellipse
syn keyword gnuplotKeyword	circle polygon at center size units xy xx yy to
syn keyword gnuplotKeyword	from
syn keyword gnuplotKeyword	offsets
syn keyword gnuplotKeyword	origin
syn keyword gnuplotKeyword	output
syn keyword gnuplotKeyword	parametric
syn keyword gnuplotKeyword	plot add2history
syn keyword gnuplotKeyword	hidden3d interpolate scansautomatic scansforward
syn keyword gnuplotKeyword	scansbackward depthorder flush begin center end
syn keyword gnuplotKeyword	ftriangles noftriangles clip1in clip4in mean map
syn keyword gnuplotKeyword	corners2color geomean harmean rms median min max
syn keyword gnuplotKeyword	c1 c2 c3 c4 pm3d at nohidden3d implicit explicit
syn keyword gnuplotKeyword	palette gray color gamma rgbformulae defined
syn keyword gnuplotKeyword	file functions cubehelix start cycles saturation
syn keyword gnuplotKeyword	model RGB HSV CMY YIQ XYZ positive negative
syn keyword gnuplotKeyword	nops_allcF ps_allcF maxcolors float int gradient
syn keyword gnuplotKeyword	fit2rgbformulae rgbformulae
syn keyword gnuplotKeyword	pointintervalbox
syn keyword gnuplotKeyword	pointsize
syn keyword gnuplotKeyword	polar
syn keyword gnuplotKeyword	print append
syn keyword gnuplotKeyword	psdir
syn keyword gnuplotKeyword	raxis rrange rtics
syn keyword gnuplotKeyword	samples
syn keyword gnuplotKeyword	size square nosquare ratio noratio
syn keyword gnuplotKeyword	style arrow auto back border boxplot
syn keyword gnuplotKeyword	candlesticks circle clustered columnstacked data
syn keyword gnuplotKeyword	default ellipse empty fill[ed] financebars
syn keyword gnuplotKeyword	fraction front function gap graph head[s]
syn keyword gnuplotKeyword	histogram increment labels lc line linecolor
syn keyword gnuplotKeyword	linetype linewidth lt lw noborder nofilled
syn keyword gnuplotKeyword	nohead nooutliers nowedge off opaque outliers
syn keyword gnuplotKeyword	palette pattern pi pointinterval pointsize
syn keyword gnuplotKeyword	pointtype ps pt radius range rectangle
syn keyword gnuplotKeyword	rowstacked screen separation size solid sorted
syn keyword gnuplotKeyword	textbox transparent units unsorted userstyles
syn keyword gnuplotKeyword	wedge x x2 xx xy yy
syn keyword gnuplotKeyword	surface implicit explicit
syn keyword gnuplotKeyword	table
syn keyword gnuplotKeyword	terminal term push pop aed512 aed767 aifm aqua
syn keyword gnuplotKeyword	be cairo cairolatex canvas cgm context corel
syn keyword gnuplotKeyword	debug dumb dxf dxy800a eepic emf emxvga epscairo
syn keyword gnuplotKeyword	epslatex epson_180dpi excl fig ggi gif gpic hpgl
syn keyword gnuplotKeyword	grass hp2623a hp2648 hp500c hpljii hppj imagen
syn keyword gnuplotKeyword	jpeg kyo latex linux lua mf mif mp next openstep
syn keyword gnuplotKeyword	pbm pdf pdfcairo pm png pngcairo postscript
syn keyword gnuplotKeyword	pslatex pstex pstricks qms qt regis sun svg svga
syn keyword gnuplotKeyword	tek40 tek410x texdraw tgif tikz tkcanvas tpic
syn keyword gnuplotKeyword	vgagl vws vx384 windows wx wxt x11 xlib
syn keyword gnuplotKeyword	color monochrome dashlength dl eps pdf fontscale
syn keyword gnuplotKeyword	standalone blacktext colortext colourtext header
syn keyword gnuplotKeyword	noheader mono color solid dashed notransparent
syn keyword gnuplotKeyword	crop crop background input rounded butt square
syn keyword gnuplotKeyword	size fsize standalone name jsdir defaultsize
syn keyword gnuplotKeyword	timestamp notimestamp colour mitered beveled
syn keyword gnuplotKeyword	round squared palfuncparam blacktext nec_cp6
syn keyword gnuplotKeyword	mppoints inlineimages externalimages defaultfont
syn keyword gnuplotKeyword	aspect feed nofeed rotate small tiny standalone
syn keyword gnuplotKeyword	oldstyle newstyle level1 leveldefault level3
syn keyword gnuplotKeyword	background nobackground solid clip noclip
syn keyword gnuplotKeyword	colortext colourtext epson_60dpi epson_lx800
syn keyword gnuplotKeyword	okidata starc tandy_60dpi dpu414 nec_cp6 draft
syn keyword gnuplotKeyword	medium large normal landscape portrait big
syn keyword gnuplotKeyword	inches pointsmax textspecial texthidden
syn keyword gnuplotKeyword	thickness depth version acceleration giant
syn keyword gnuplotKeyword	delay loop optimize nooptimize pspoints
syn keyword gnuplotKeyword	FNT9X17 FNT13X25 interlace nointerlace courier
syn keyword gnuplotKeyword	originreset nooriginreset gparrows nogparrows
syn keyword gnuplotKeyword	picenvironment nopicenvironment tightboundingbox
syn keyword gnuplotKeyword	notightboundingbox charsize gppoints nogppoints
syn keyword gnuplotKeyword	fontscale textscale fulldoc nofulldoc standalone
syn keyword gnuplotKeyword	preamble header tikzplot tikzarrows notikzarrows
syn keyword gnuplotKeyword	cmykimages externalimages noexternalimages
syn keyword gnuplotKeyword	polyline vectors magnification psnfss nopsnfss
syn keyword gnuplotKeyword	psnfss-version7 prologues a4paper amstex fname
syn keyword gnuplotKeyword	fsize server persist widelines interlace
syn keyword gnuplotKeyword	truecolor notruecolor defaultplex simplex duplex
syn keyword gnuplotKeyword	nofontfiles adobeglyphnames noadobeglyphnames
syn keyword gnuplotKeyword	nostandalone metric textrigid animate nopspoints
syn keyword gnuplotKeyword	hpdj FNT5X9 roman emtex rgbimages bitmap
syn keyword gnuplotKeyword	nobitmap providevars nointerlace add delete
syn keyword gnuplotKeyword	auxfile hacktext unit raise palfuncparam
syn keyword gnuplotKeyword	noauxfile nohacktext nounit noraise ctrl noctrl
syn keyword gnuplotKeyword	close widget fixed dynamic tek40xx vttek
syn keyword gnuplotKeyword	kc-tek40xx km-tek40xx bitgraph perltk
syn keyword gnuplotKeyword	interactive red green blue interpolate mode
syn keyword gnuplotKeyword	position ctrlq replotonresize position noctrlq
syn keyword gnuplotKeyword	noreplotonresize
syn keyword gnuplotKeyword	termoption font fontscale solid dashed
syn keyword gnuplotKeyword	tics add axis border mirror nomirror in out
syn keyword gnuplotKeyword	scale rotate norotate by offset nooffset left
syn keyword gnuplotKeyword	autojustify format font textcolor right center
syn keyword gnuplotError	ticslevel ticscale
syn keyword gnuplotKeyword	timestamp top bottom offset font
syn keyword gnuplotKeyword	timefmt
syn keyword gnuplotKeyword	title offset font textcolor tc
syn keyword gnuplotKeyword	trange urange vrange
syn keyword gnuplotKeyword	variables
syn keyword gnuplotKeyword	version
syn keyword gnuplotKeyword	view map equal noequal xy xyz
syn keyword gnuplotKeyword	xdata ydata zdata x2data y2data cbdata xdtics
syn keyword gnuplotKeyword	ydtics zdtics x2dtics y2dtics cbdtics xzeroaxis
syn keyword gnuplotKeyword	yzeroaxis zzeroaxis x2zeroaxis y2zeroaxis
syn keyword gnuplotKeyword	cbzeroaxis time geographic
syn keyword gnuplotKeyword	xlabel ylabel zlabel x2label y2label cblabel
syn keyword gnuplotKeyword	offset font textcolor by parallel
syn keyword gnuplotKeyword	xrange yrange zrange x2range y2range cbrange
syn keyword gnuplotKeyword	xyplane
syn keyword gnuplotKeyword	zero
syn keyword gnuplotKeyword	zeroaxis
syn keyword gnuplotKeyword	nooutput
syn keyword gnuplotKeyword	terminal palette rgb rbg grb gbr brg bgr
syn region gnuplotMacro		start="@" end=" "
syn keyword gnuplotTodo		contained TODO FIXME XXX
syn keyword gnuplotStatement	cd call clear evaluate exit fit help history
syn keyword gnuplotStatement	load lower pause plot p print pwd quit raise
syn keyword gnuplotStatement	refresh replot rep reread reset save set show
syn keyword gnuplotStatement	shell splot spstats stats system test undefine
syn keyword gnuplotStatement	unset update
hi def link gnuplotComment		Comment
hi def link gnuplotString		String
hi def link gnuplotNumber		Number
hi def link gnuplotFloat		Float
hi def link gnuplotIdentifier	Identifier
hi def link gnuplotConditional	Conditional
hi def link gnuplotRepeat		Repeat
hi def link gnuplotKeyword		Keyword
hi def link gnuplotOperator	Operator
hi def link gnuplotMacro		Macro
hi def link gnuplotStatement	Type
hi def link gnuplotFunc		Identifier
hi def link gnuplotSpecial		Special
hi def link gnuplotUnit		Special
hi def link gnuplotExternal	Special
hi def link gnuplotError		Error
hi def link gnuplotOctalError	Error
hi def link gnuplotTodo		Todo
let b:current_syntax = "gnuplot"
