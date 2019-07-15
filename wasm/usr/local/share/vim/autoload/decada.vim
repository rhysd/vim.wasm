if version < 700
finish
endif
function decada#Unit_Name () dict				     " {{{1
return substitute (substitute (expand ("%:t:r"), '__\|-', ".", "g"), '_$', "", '')
endfunction decada#Unit_Name					     " }}}1
function decada#Make () dict					     " {{{1
let l:make_prg   = substitute (g:self.Make_Command, '%<', self.Unit_Name(), '')
let &errorformat = g:self.Error_Format
let &makeprg     = l:make_prg
wall
make
copen
set wrap
wincmd W
endfunction decada#Build					     " }}}1
function decada#Set_Session (...) dict				     " {{{1
if a:0 > 0
call ada#Switch_Session (a:1)
elseif argc() == 0 && strlen (v:servername) > 0
call ada#Switch_Session (
\ expand('~')[0:-2] . ".vimfiles.session]decada_" .
\ v:servername . ".vim")
endif
return
endfunction decada#Set_Session					     " }}}1
function decada#New ()						     " }}}1
let Retval = {
\ 'Make'		: function ('decada#Make'),
\ 'Unit_Name'	: function ('decada#Unit_Name'),
\ 'Set_Session'   : function ('decada#Set_Session'),
\ 'Project_Dir'   : '',
\ 'Make_Command'  : 'ACS COMPILE /Wait /Log /NoPreLoad /Optimize=Development /Debug %<',
\ 'Error_Format'  : '%+A%%ADAC-%t-%m,%C  %#%m,%Zat line number %l in file %f,' .
\ '%+I%%ada-I-%m,%C  %#%m,%Zat line number %l in file %f'}
return Retval 
endfunction decada#New						     " }}}1
finish " 1}}}
