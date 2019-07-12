let s:cpo_sav = &cpo
let s:ls  = &ls
set cpo&vim
let s:end=line('$')
if exists("g:html_font")
if type(g:html_font) == type([])
let s:htmlfont = "'". join(g:html_font,"','") . "', monospace"
else
let s:htmlfont = "'". g:html_font . "', monospace"
endif
else
let s:htmlfont = "monospace"
endif
let s:settings = tohtml#GetUserSettings()
if !exists('s:FOLDED_ID')
let s:FOLDED_ID  = hlID("Folded")     | lockvar s:FOLDED_ID
let s:FOLD_C_ID  = hlID("FoldColumn") | lockvar s:FOLD_C_ID
let s:LINENR_ID  = hlID('LineNr')     | lockvar s:LINENR_ID
let s:DIFF_D_ID  = hlID("DiffDelete") | lockvar s:DIFF_D_ID
let s:DIFF_A_ID  = hlID("DiffAdd")    | lockvar s:DIFF_A_ID
let s:DIFF_C_ID  = hlID("DiffChange") | lockvar s:DIFF_C_ID
let s:DIFF_T_ID  = hlID("DiffText")   | lockvar s:DIFF_T_ID
let s:CONCEAL_ID = hlID('Conceal')    | lockvar s:CONCEAL_ID
endif
if s:settings.pre_wrap
let s:whitespace = "white-space: pre-wrap; "
else
let s:whitespace = ""
endif
if !empty(s:settings.prevent_copy)
if s:settings.no_invalid
let s:unselInputType = ""
else
let s:unselInputType = " type='invalid_input_type'"
endif
endif
if has("gui_running")
let s:whatterm = "gui"
else
let s:whatterm = "cterm"
if &t_Co == 8
let s:cterm_color = {
\   0: "#808080", 1: "#ff6060", 2: "#00ff00", 3: "#ffff00",
\   4: "#8080ff", 5: "#ff40ff", 6: "#00ffff", 7: "#ffffff"
\ }
else
let s:cterm_color = {
\   0: "#000000", 1: "#c00000", 2: "#008000", 3: "#804000", 
\   4: "#0000c0", 5: "#c000c0", 6: "#008080", 7: "#c0c0c0", 
\   8: "#808080", 9: "#ff6060", 10: "#00ff00", 11: "#ffff00",
\   12: "#8080ff", 13: "#ff40ff", 14: "#00ffff", 15: "#ffffff"
\ }
if &t_Co == 88
call extend(s:cterm_color, {
\   16: "#000000", 17: "#00008b", 18: "#0000cd", 19: "#0000ff",
\   20: "#008b00", 21: "#008b8b", 22: "#008bcd", 23: "#008bff",
\   24: "#00cd00", 25: "#00cd8b", 26: "#00cdcd", 27: "#00cdff",
\   28: "#00ff00", 29: "#00ff8b", 30: "#00ffcd", 31: "#00ffff",
\   32: "#8b0000", 33: "#8b008b", 34: "#8b00cd", 35: "#8b00ff",
\   36: "#8b8b00", 37: "#8b8b8b", 38: "#8b8bcd", 39: "#8b8bff",
\   40: "#8bcd00", 41: "#8bcd8b", 42: "#8bcdcd", 43: "#8bcdff",
\   44: "#8bff00", 45: "#8bff8b", 46: "#8bffcd", 47: "#8bffff",
\   48: "#cd0000", 49: "#cd008b", 50: "#cd00cd", 51: "#cd00ff",
\   52: "#cd8b00", 53: "#cd8b8b", 54: "#cd8bcd", 55: "#cd8bff",
\   56: "#cdcd00", 57: "#cdcd8b", 58: "#cdcdcd", 59: "#cdcdff",
\   60: "#cdff00", 61: "#cdff8b", 62: "#cdffcd", 63: "#cdffff",
\   64: "#ff0000"
\ })
call extend(s:cterm_color, {
\   65: "#ff008b", 66: "#ff00cd", 67: "#ff00ff", 68: "#ff8b00",
\   69: "#ff8b8b", 70: "#ff8bcd", 71: "#ff8bff", 72: "#ffcd00",
\   73: "#ffcd8b", 74: "#ffcdcd", 75: "#ffcdff", 76: "#ffff00",
\   77: "#ffff8b", 78: "#ffffcd", 79: "#ffffff", 80: "#2e2e2e",
\   81: "#5c5c5c", 82: "#737373", 83: "#8b8b8b", 84: "#a2a2a2",
\   85: "#b9b9b9", 86: "#d0d0d0", 87: "#e7e7e7"
\ })
elseif &t_Co == 256
call extend(s:cterm_color, {
\   16: "#000000", 17: "#00005f", 18: "#000087", 19: "#0000af",
\   20: "#0000d7", 21: "#0000ff", 22: "#005f00", 23: "#005f5f",
\   24: "#005f87", 25: "#005faf", 26: "#005fd7", 27: "#005fff",
\   28: "#008700", 29: "#00875f", 30: "#008787", 31: "#0087af",
\   32: "#0087d7", 33: "#0087ff", 34: "#00af00", 35: "#00af5f",
\   36: "#00af87", 37: "#00afaf", 38: "#00afd7", 39: "#00afff",
\   40: "#00d700", 41: "#00d75f", 42: "#00d787", 43: "#00d7af",
\   44: "#00d7d7", 45: "#00d7ff", 46: "#00ff00", 47: "#00ff5f",
\   48: "#00ff87", 49: "#00ffaf", 50: "#00ffd7", 51: "#00ffff",
\   52: "#5f0000", 53: "#5f005f", 54: "#5f0087", 55: "#5f00af",
\   56: "#5f00d7", 57: "#5f00ff", 58: "#5f5f00", 59: "#5f5f5f",
\   60: "#5f5f87", 61: "#5f5faf", 62: "#5f5fd7", 63: "#5f5fff",
\   64: "#5f8700"
\ })
call extend(s:cterm_color, {
\   65: "#5f875f", 66: "#5f8787", 67: "#5f87af", 68: "#5f87d7",
\   69: "#5f87ff", 70: "#5faf00", 71: "#5faf5f", 72: "#5faf87",
\   73: "#5fafaf", 74: "#5fafd7", 75: "#5fafff", 76: "#5fd700",
\   77: "#5fd75f", 78: "#5fd787", 79: "#5fd7af", 80: "#5fd7d7",
\   81: "#5fd7ff", 82: "#5fff00", 83: "#5fff5f", 84: "#5fff87",
\   85: "#5fffaf", 86: "#5fffd7", 87: "#5fffff", 88: "#870000",
\   89: "#87005f", 90: "#870087", 91: "#8700af", 92: "#8700d7",
\   93: "#8700ff", 94: "#875f00", 95: "#875f5f", 96: "#875f87",
\   97: "#875faf", 98: "#875fd7", 99: "#875fff", 100: "#878700",
\   101: "#87875f", 102: "#878787", 103: "#8787af", 104: "#8787d7",
\   105: "#8787ff", 106: "#87af00", 107: "#87af5f", 108: "#87af87",
\   109: "#87afaf", 110: "#87afd7", 111: "#87afff", 112: "#87d700"
\ })
call extend(s:cterm_color, {
\   113: "#87d75f", 114: "#87d787", 115: "#87d7af", 116: "#87d7d7",
\   117: "#87d7ff", 118: "#87ff00", 119: "#87ff5f", 120: "#87ff87",
\   121: "#87ffaf", 122: "#87ffd7", 123: "#87ffff", 124: "#af0000",
\   125: "#af005f", 126: "#af0087", 127: "#af00af", 128: "#af00d7",
\   129: "#af00ff", 130: "#af5f00", 131: "#af5f5f", 132: "#af5f87",
\   133: "#af5faf", 134: "#af5fd7", 135: "#af5fff", 136: "#af8700",
\   137: "#af875f", 138: "#af8787", 139: "#af87af", 140: "#af87d7",
\   141: "#af87ff", 142: "#afaf00", 143: "#afaf5f", 144: "#afaf87",
\   145: "#afafaf", 146: "#afafd7", 147: "#afafff", 148: "#afd700",
\   149: "#afd75f", 150: "#afd787", 151: "#afd7af", 152: "#afd7d7",
\   153: "#afd7ff", 154: "#afff00", 155: "#afff5f", 156: "#afff87",
\   157: "#afffaf", 158: "#afffd7"
\ })
call extend(s:cterm_color, {
\   159: "#afffff", 160: "#d70000", 161: "#d7005f", 162: "#d70087",
\   163: "#d700af", 164: "#d700d7", 165: "#d700ff", 166: "#d75f00",
\   167: "#d75f5f", 168: "#d75f87", 169: "#d75faf", 170: "#d75fd7",
\   171: "#d75fff", 172: "#d78700", 173: "#d7875f", 174: "#d78787",
\   175: "#d787af", 176: "#d787d7", 177: "#d787ff", 178: "#d7af00",
\   179: "#d7af5f", 180: "#d7af87", 181: "#d7afaf", 182: "#d7afd7",
\   183: "#d7afff", 184: "#d7d700", 185: "#d7d75f", 186: "#d7d787",
\   187: "#d7d7af", 188: "#d7d7d7", 189: "#d7d7ff", 190: "#d7ff00",
\   191: "#d7ff5f", 192: "#d7ff87", 193: "#d7ffaf", 194: "#d7ffd7",
\   195: "#d7ffff", 196: "#ff0000", 197: "#ff005f", 198: "#ff0087",
\   199: "#ff00af", 200: "#ff00d7", 201: "#ff00ff", 202: "#ff5f00",
\   203: "#ff5f5f", 204: "#ff5f87"
\ })
call extend(s:cterm_color, {
\   205: "#ff5faf", 206: "#ff5fd7", 207: "#ff5fff", 208: "#ff8700",
\   209: "#ff875f", 210: "#ff8787", 211: "#ff87af", 212: "#ff87d7",
\   213: "#ff87ff", 214: "#ffaf00", 215: "#ffaf5f", 216: "#ffaf87",
\   217: "#ffafaf", 218: "#ffafd7", 219: "#ffafff", 220: "#ffd700",
\   221: "#ffd75f", 222: "#ffd787", 223: "#ffd7af", 224: "#ffd7d7",
\   225: "#ffd7ff", 226: "#ffff00", 227: "#ffff5f", 228: "#ffff87",
\   229: "#ffffaf", 230: "#ffffd7", 231: "#ffffff", 232: "#080808",
\   233: "#121212", 234: "#1c1c1c", 235: "#262626", 236: "#303030",
\   237: "#3a3a3a", 238: "#444444", 239: "#4e4e4e", 240: "#585858",
\   241: "#626262", 242: "#6c6c6c", 243: "#767676", 244: "#808080",
\   245: "#8a8a8a", 246: "#949494", 247: "#9e9e9e", 248: "#a8a8a8",
\   249: "#b2b2b2", 250: "#bcbcbc", 251: "#c6c6c6", 252: "#d0d0d0",
\   253: "#dadada", 254: "#e4e4e4", 255: "#eeeeee"
\ })
endif
endif
endif
if s:whatterm == "gui"
function! s:HtmlColor(color)
return a:color
endfun
else
function! s:HtmlColor(color)
if has_key(s:cterm_color, a:color)
return s:cterm_color[a:color]
else
return ""
endif
endfun
endif
let s:fgc = s:HtmlColor(synIDattr(hlID("Normal"), "fg#", s:whatterm))
let s:bgc = s:HtmlColor(synIDattr(hlID("Normal"), "bg#", s:whatterm))
if s:fgc == ""
let s:fgc = ( &background == "dark" ? "#ffffff" : "#000000" )
endif
if s:bgc == ""
let s:bgc = ( &background == "dark" ? "#000000" : "#ffffff" )
endif
if !s:settings.use_css
function! s:HtmlOpening(id, extra_attrs)
let a = ""
if synIDattr(a:id, "inverse")
let x = s:HtmlColor(synIDattr(a:id, "fg#", s:whatterm))
let a = a . '<span '.a:extra_attrs.'style="background-color: ' . ( x != "" ? x : s:fgc ) . '">'
let x = s:HtmlColor(synIDattr(a:id, "bg#", s:whatterm))
let a = a . '<font color="' . ( x != "" ? x : s:bgc ) . '">'
else
let x = s:HtmlColor(synIDattr(a:id, "bg#", s:whatterm))
if x != ""
let a = a . '<span '.a:extra_attrs.'style="background-color: ' . x . '">'
elseif !empty(a:extra_attrs)
let a = a . '<span '.a:extra_attrs.'>'
endif
let x = s:HtmlColor(synIDattr(a:id, "fg#", s:whatterm))
if x != "" | let a = a . '<font color="' . x . '">' | endif
endif
if synIDattr(a:id, "bold") | let a = a . "<b>" | endif
if synIDattr(a:id, "italic") | let a = a . "<i>" | endif
if synIDattr(a:id, "underline") | let a = a . "<u>" | endif
return a
endfun
function! s:HtmlClosing(id, has_extra_attrs)
let a = ""
if synIDattr(a:id, "underline") | let a = a . "</u>" | endif
if synIDattr(a:id, "italic") | let a = a . "</i>" | endif
if synIDattr(a:id, "bold") | let a = a . "</b>" | endif
if synIDattr(a:id, "inverse")
let a = a . '</font></span>'
else
let x = s:HtmlColor(synIDattr(a:id, "fg#", s:whatterm))
if x != "" | let a = a . '</font>' | endif
let x = s:HtmlColor(synIDattr(a:id, "bg#", s:whatterm))
if x != "" || a:has_extra_attrs | let a = a . '</span>' | endif
endif
return a
endfun
endif
if s:settings.use_css
let wrapperfunc_lines = [
\ 'function! s:BuildStyleWrapper(style_id, diff_style_id, extra_attrs, text, make_unselectable, unformatted)',
\ '',
\ '  let l:style_name = synIDattr(a:style_id, "name", s:whatterm)'
\ ]
if &diff
let wrapperfunc_lines += [
\ '  let l:diff_style_name = synIDattr(a:diff_style_id, "name", s:whatterm)']
let wrapperfunc_lines += [
\ '',
\ '  if a:style_id == s:DIFF_D_ID || a:style_id == s:DIFF_A_ID ||'.
\ '          a:style_id == s:DIFF_C_ID || a:style_id == s:DIFF_T_ID',
\ '    let l:saved_style = get(s:diffstylelist,a:style_id)',
\ '  else'
\ ]
endif
let wrapperfunc_lines += [
\ '    let l:saved_style = get(s:stylelist,a:style_id)',
\ '    if type(l:saved_style) == type(0)',
\ '      unlet l:saved_style',
\ '      let l:saved_style = s:CSS1(a:style_id)',
\ '      if l:saved_style != ""',
\ '        let l:saved_style = "." . l:style_name . " { " . l:saved_style . "}"',
\ '      endif',
\ '      let s:stylelist[a:style_id]= l:saved_style',
\ '    endif'
\ ]
if &diff
let wrapperfunc_lines += [ '  endif' ]
endif
let wrapperfunc_lines += [
\ '',
\ '  if l:saved_style == "" && empty(a:extra_attrs)'
\ ]
if &diff
let wrapperfunc_lines += [
\ '    if a:diff_style_id <= 0'
\ ]
endif
let wrapperfunc_lines += [
\ '       return a:text'
\ ]
if &diff
let wrapperfunc_lines += [
\ '     else',
\ '       return "<span class=\"" .l:diff_style_name . "\">".a:text."</span>"',
\ '     endif'
\ ]
endif
let wrapperfunc_lines += [
\ '  else']
let diffstyle =
\ (&diff ? '(a:diff_style_id <= 0 ? "" : " ". l:diff_style_name) .'
\        : "")
if s:settings.prevent_copy == ""
let wrapperfunc_lines += [
\ '    return "<span ".a:extra_attrs."class=\"" . l:style_name .'.diffstyle.'"\">".a:text."</span>"'
\ ]
else
let wrapperfunc_lines += [
\ '    if a:make_unselectable',
\ '      return "<span ".a:extra_attrs."class=\"" . l:style_name .'.diffstyle.'"\">'.
\                '<input'.s:unselInputType.' class=\"" . l:style_name .'.diffstyle.'"\"'.
\                 ' value=\"".substitute(a:unformatted,''\s\+$'',"","")."\"'.
\                 ' onselect=''this.blur(); return false;'''.
\                 ' onmousedown=''this.blur(); return false;'''.
\                 ' onclick=''this.blur(); return false;'''.
\                 ' readonly=''readonly'''.
\                 ' size=\"".strwidth(a:unformatted)."\"'.
\                 (s:settings.use_xhtml ? '/' : '').'></span>"',
\ '    else',
\ '      return "<span ".a:extra_attrs."class=\"" . l:style_name .'. diffstyle .'"\">".a:text."</span>"'
\ ]
endif
let wrapperfunc_lines += [
\ '  endif',
\ 'endfun'
\ ]
else
if &diff
let wrapperfunc_lines = [
\ 'function! s:BuildStyleWrapper(style_id, diff_style_id, extra_attrs, text, unusedarg, unusedarg2)',
\ '  return s:HtmlOpening(a:style_id, a:extra_attrs).(a:diff_style_id <= 0 ? "" :'.
\                                     's:HtmlOpening(a:diff_style_id, "")).a:text.'.
\   '(a:diff_style_id <= 0 ? "" : s:HtmlClosing(a:diff_style_id, 0)).s:HtmlClosing(a:style_id, !empty(a:extra_attrs))',
\ 'endfun'
\ ]
else
let wrapperfunc_lines = [
\ 'function! s:BuildStyleWrapper(style_id, diff_style_id, extra_attrs, text, unusedarg, unusedarg2)',
\ '  return s:HtmlOpening(a:style_id, a:extra_attrs).a:text.s:HtmlClosing(a:style_id, !empty(a:extra_attrs))',
\ 'endfun'
\ ]
endif
endif
exec join(wrapperfunc_lines, "\n")
let s:diff_mode = &diff
function! s:HtmlFormat(text, style_id, diff_style_id, extra_attrs, make_unselectable)
let unformatted = strtrans(a:text)
let formatted = unformatted
let formatted = substitute(formatted, '&', '\&amp;',  'g')
let formatted = substitute(formatted, '<', '\&lt;',   'g')
let formatted = substitute(formatted, '>', '\&gt;',   'g')
let formatted = substitute(formatted, '"', '\&quot;', 'g')
let formatted = substitute(formatted, '"', '\&#0039;', 'g')
let formatted = substitute(formatted, "\x0c", '<hr class="PAGE-BREAK">', 'g')
if ' ' != s:HtmlSpace
let formatted = substitute(formatted, '  ', s:HtmlSpace . s:HtmlSpace, 'g')
let formatted = substitute(formatted, '^ ', s:HtmlSpace, 'g')
let formatted = substitute(formatted, ' \+$', s:HtmlSpace, 'g')
endif
return s:BuildStyleWrapper(a:style_id, a:diff_style_id, a:extra_attrs, formatted, a:make_unselectable, unformatted)
endfun
if s:settings.prevent_copy =~# 'n'
if s:settings.number_lines
if s:settings.line_ids
function! s:HtmlFormat_n(text, style_id, diff_style_id, lnr)
if a:lnr > 0
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, 'id="'.(exists('g:html_diff_win_num') ? 'W'.g:html_diff_win_num : "").'L'.a:lnr.s:settings.id_suffix.'" ', 1)
else
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, "", 1)
endif
endfun
else
function! s:HtmlFormat_n(text, style_id, diff_style_id, lnr)
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, "", 1)
endfun
endif
elseif s:settings.line_ids
function! s:HtmlFormat_n(text, style_id, diff_style_id, lnr)
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, 'id="'.(exists('g:html_diff_win_num') ? 'W'.g:html_diff_win_num : "").'L'.a:lnr.s:settings.id_suffix.'" ', 0)
endfun
endif
else
if s:settings.line_ids
function! s:HtmlFormat_n(text, style_id, diff_style_id, lnr)
if a:lnr > 0
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, 'id="'.(exists('g:html_diff_win_num') ? 'W'.g:html_diff_win_num : "").'L'.a:lnr.s:settings.id_suffix.'" ', 0)
else
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, "", 0)
endif
endfun
else
function! s:HtmlFormat_n(text, style_id, diff_style_id, lnr)
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, "", 0)
endfun
endif
endif
if s:settings.prevent_copy =~# 'd'
function! s:HtmlFormat_d(text, style_id, diff_style_id)
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, "", 1)
endfun
else
function! s:HtmlFormat_d(text, style_id, diff_style_id)
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, "", 0)
endfun
endif
if s:settings.prevent_copy =~# 'f'
function! s:FoldColumn_build(char, len, numfill, char2, class, click)
let l:input_open = "<input readonly='readonly'".s:unselInputType.
\ " onselect='this.blur(); return false;'".
\ " onmousedown='this.blur(); ".a:click." return false;'".
\ " onclick='return false;' size='".
\ string(a:len + (empty(a:char2) ? 0 : 1) + a:numfill) .
\ "' "
let l:common_attrs = "class='FoldColumn' value='"
let l:input_close = (s:settings.use_xhtml ? "' />" : "'>")
return "<span class='".a:class."'>".
\ l:input_open.l:common_attrs.repeat(a:char, a:len).
\ (!empty(a:char2) ? a:char2 : "").
\ l:input_close . "</span>"
endfun
function! s:FoldColumn_fill()
return s:FoldColumn_build('', s:foldcolumn, 0, '', 'FoldColumn', '')
endfun
else
function! s:FoldColumn_build(char, len, numfill, char2, class, click)
return "<a href='#' class='".a:class."' onclick='".a:click."'>".
\ repeat(a:char, a:len).a:char2.repeat(' ', a:numfill).
\ "</a>"
endfun
function! s:FoldColumn_fill()
return s:HtmlFormat(repeat(' ', s:foldcolumn), s:FOLD_C_ID, 0, "", 0)
endfun
endif
if s:settings.prevent_copy =~# 't'
if s:settings.dynamic_folds
function! s:HtmlFormat_t(text, style_id, diff_style_id)
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, "", 1) .
\ s:HtmlFormat("", a:style_id, 0, "", 0)
endfun
else
function! s:HtmlFormat_t(text, style_id, diff_style_id)
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, "", 1)
endfun
endif
else
function! s:HtmlFormat_t(text, style_id, diff_style_id)
return s:HtmlFormat(a:text, a:style_id, a:diff_style_id, "", 0)
endfun
endif
function! s:CSS1(id)
let a = ""
if synIDattr(a:id, "inverse")
let x = s:HtmlColor(synIDattr(a:id, "bg#", s:whatterm))
let a = a . "color: " . ( x != "" ? x : s:bgc ) . "; "
let x = s:HtmlColor(synIDattr(a:id, "fg#", s:whatterm))
let a = a . "background-color: " . ( x != "" ? x : s:fgc ) . "; "
else
let x = s:HtmlColor(synIDattr(a:id, "fg#", s:whatterm))
if x != "" | let a = a . "color: " . x . "; " | endif
let x = s:HtmlColor(synIDattr(a:id, "bg#", s:whatterm))
if x != ""
let a = a . "background-color: " . x . "; "
let a = a . "padding-bottom: 1px; "
elseif (a:id == s:FOLDED_ID || a:id == s:LINENR_ID || a:id == s:FOLD_C_ID) && !empty(s:settings.prevent_copy)
let a = a . "background-color: " . s:bgc . "; "
endif
endif
if synIDattr(a:id, "bold") | let a = a . "font-weight: bold; " | endif
if synIDattr(a:id, "italic") | let a = a . "font-style: italic; " | endif
if synIDattr(a:id, "underline") | let a = a . "text-decoration: underline; " | endif
return a
endfun
if s:settings.dynamic_folds
function! s:FoldCompare(f1, f2)
if a:f1.firstline != a:f2.firstline
return a:f1.firstline - a:f2.firstline
elseif a:f1.lastline != a:f2.lastline
return a:f2.lastline - a:f1.lastline
else
return a:f1.level - a:f2.level
endif
endfunction
endif
let s:old_title = &title
let s:old_icon = &icon
let s:old_et = &l:et
let s:old_bind = &l:scrollbind
let s:old_report = &report
let s:old_search = @/
let s:old_more = &more
set notitle noicon
setlocal et
set nomore
set report=1000000
setlocal noscrollbind
if exists(':ownsyntax') && exists('w:current_syntax')
let s:current_syntax = w:current_syntax
elseif exists('b:current_syntax')
let s:current_syntax = b:current_syntax
else
let s:current_syntax = 'none'
endif
if s:current_syntax == ''
let s:current_syntax = 'none'
endif
if exists("g:loaded_2html_plugin")
let s:pluginversion = g:loaded_2html_plugin
else
if !exists("g:unloaded_tohtml_plugin")
let s:main_plugin_path = expand("<sfile>:p:h:h")."/plugin/tohtml.vim"
if filereadable(s:main_plugin_path)
let s:lines = readfile(s:main_plugin_path, "", 20)
call filter(s:lines, 'v:val =~ "loaded_2html_plugin = "')
if empty(s:lines)
let g:unloaded_tohtml_plugin = "unknown"
else
let g:unloaded_tohtml_plugin = substitute(s:lines[0], '.*loaded_2html_plugin = \([''"]\)\(\%(\1\@!.\)\+\)\1', '\2', '')
endif
unlet s:lines
else
let g:unloaded_tohtml_plugin = "unknown"
endif
unlet s:main_plugin_path
endif
let s:pluginversion = g:unloaded_tohtml_plugin
endif
let s:orgbufnr = winbufnr(0)
let s:origwin_stl = &l:stl
if expand("%") == ""
if exists('g:html_diff_win_num')
exec 'new Untitled_win'.g:html_diff_win_num.'.'.(s:settings.use_xhtml ? 'x' : '').'html'
else
exec 'new Untitled.'.(s:settings.use_xhtml ? 'x' : '').'html'
endif
else
exec 'new %.'.(s:settings.use_xhtml ? 'x' : '').'html'
endif
let s:old_winheight = winheight(0)
let s:old_winfixheight = &l:winfixheight
if s:old_winheight > 2
resize 1 " leave enough room to view one line at a time
norm! G
norm! zt
endif
setlocal winfixheight
let s:newwin_stl = &l:stl
let s:old_fen = &foldenable
setlocal foldmethod=manual
setlocal nofoldenable
let s:newwin = winnr()
let s:orgwin = bufwinnr(s:orgbufnr)
setlocal modifiable
%d
let s:old_paste = &paste
set paste
let s:old_magic = &magic
set magic
let &l:fileencoding=s:settings.vim_encoding
if s:settings.vim_encoding == 'utf-8'
setlocal nobomb
else
setlocal bomb
endif
let s:lines = []
if s:settings.use_xhtml
if s:settings.encoding != ""
call add(s:lines, "<?xml version=\"1.0\" encoding=\"" . s:settings.encoding . "\"?>")
else
call add(s:lines, "<?xml version=\"1.0\"?>")
endif
let s:tag_close = ' />'
else
let s:tag_close = '>'
endif
let s:HtmlSpace = ' '
let s:LeadingSpace = ' '
let s:HtmlEndline = ''
if s:settings.no_pre
let s:HtmlEndline = '<br' . s:tag_close
let s:LeadingSpace = s:settings.use_xhtml ? '&#160;' : '&nbsp;'
let s:HtmlSpace = '\' . s:LeadingSpace
endif
call extend(s:lines, [
\ "<html>",
\ "<head>"])
if s:settings.encoding != "" && !s:settings.use_xhtml
call add(s:lines, "<meta http-equiv=\"content-type\" content=\"text/html; charset=" . s:settings.encoding . '"' . s:tag_close)
endif
call extend(s:lines, [
\ ("<title>".expand("%:p:~")."</title>"),
\ ("<meta name=\"Generator\" content=\"Vim/".v:version/100.".".v:version%100.'"'.s:tag_close),
\ ("<meta name=\"plugin-version\" content=\"".s:pluginversion.'"'.s:tag_close)
\ ])
call add(s:lines, '<meta name="syntax" content="'.s:current_syntax.'"'.s:tag_close)
call add(s:lines, '<meta name="settings" content="'.
\ join(filter(keys(s:settings),'s:settings[v:val]'),',').
\ ',prevent_copy='.s:settings.prevent_copy.
\ '"'.s:tag_close)
call add(s:lines, '<meta name="colorscheme" content="'.
\ (exists('g:colors_name')
\ ? g:colors_name
\ : 'none'). '"'.s:tag_close)
if s:settings.use_css
if s:settings.dynamic_folds
if s:settings.hover_unfold
call extend(s:lines, [
\ "<style type=\"text/css\">",
\ s:settings.use_xhtml ? "" : "<!--",
\ ".FoldColumn { text-decoration: none; white-space: pre; }",
\ "",
\ "body * { margin: 0; padding: 0; }", "",
\ ".open-fold   > .Folded { display: none;  }",
\ ".open-fold   > .fulltext { display: inline; }",
\ ".closed-fold > .fulltext { display: none;  }",
\ ".closed-fold > .Folded { display: inline; }",
\ "",
\ ".open-fold   > .toggle-open   { display: none;   }",
\ ".open-fold   > .toggle-closed { display: inline; }",
\ ".closed-fold > .toggle-open   { display: inline; }",
\ ".closed-fold > .toggle-closed { display: none;   }",
\ "", "",
\ '/* opening a fold while hovering won''t be supported by IE6 and other',
\ "similar browsers, but it should fail gracefully. */",
\ ".closed-fold:hover > .fulltext { display: inline; }",
\ ".closed-fold:hover > .toggle-filler { display: none; }",
\ ".closed-fold:hover > .Folded { display: none; }",
\ s:settings.use_xhtml ? "" : '-->',
\ '</style>'])
call extend(s:lines, [
\ "<!--[if lt IE 7]><style type=\"text/css\">",
\ ".open-fold   .Folded      { display: none; }",
\ ".open-fold   .fulltext      { display: inline; }",
\ ".open-fold   .toggle-open   { display: none; }",
\ ".closed-fold .toggle-closed { display: inline; }",
\ "",
\ ".closed-fold .fulltext      { display: none; }",
\ ".closed-fold .Folded      { display: inline; }",
\ ".closed-fold .toggle-open   { display: inline; }",
\ ".closed-fold .toggle-closed { display: none; }",
\ "</style>",
\ "<![endif]-->",
\])
else
call extend(s:lines, [
\ "<style type=\"text/css\">",
\ s:settings.use_xhtml ? "" :"<!--",
\ ".FoldColumn { text-decoration: none; white-space: pre; }",
\ ".open-fold   .Folded      { display: none; }",
\ ".open-fold   .fulltext      { display: inline; }",
\ ".open-fold   .toggle-open   { display: none; }",
\ ".closed-fold .toggle-closed { display: inline; }",
\ "",
\ ".closed-fold .fulltext      { display: none; }",
\ ".closed-fold .Folded      { display: inline; }",
\ ".closed-fold .toggle-open   { display: inline; }",
\ ".closed-fold .toggle-closed { display: none; }",
\ s:settings.use_xhtml ? "" : '-->',
\ '</style>'
\])
endif
else
call extend(s:lines, [
\ "<style type=\"text/css\">",
\ s:settings.use_xhtml ? "" : "<!--",
\ s:settings.use_xhtml ? "" : '-->',
\ "</style>",
\])
endif
endif
let s:uses_script = s:settings.dynamic_folds || s:settings.line_ids || !empty(s:settings.prevent_copy)
if s:uses_script
call extend(s:lines, [
\ "",
\ "<script type='text/javascript'>",
\ s:settings.use_xhtml ? '//<![CDATA[' : "<!--"])
endif
if s:settings.dynamic_folds
call extend(s:lines, [
\ "",
\ "function toggleFold(objID)",
\ "{",
\ "  var fold;",
\ "  fold = document.getElementById(objID);",
\ "  if(fold.className == 'closed-fold')",
\ "  {",
\ "    fold.className = 'open-fold';",
\ "  }",
\ "  else if (fold.className == 'open-fold')",
\ "  {",
\ "    fold.className = 'closed-fold';",
\ "  }",
\ "}"
\ ])
endif
if s:settings.line_ids
call extend(s:lines, [
\ "",
\ "/* function to open any folds containing a jumped-to line before jumping to it */",
\ "function JumpToLine()",
\ "{",
\ "  var lineNum;",
\ "  lineNum = window.location.hash;",
\ "  lineNum = lineNum.substr(1); /* strip off '#' */",
\ "",
\ "  if (lineNum.indexOf('L') == -1) {",
\ "    lineNum = 'L'+lineNum;",
\ "  }",
\ "  var lineElem = document.getElementById(lineNum);"
\ ])
if s:settings.dynamic_folds
call extend(s:lines, [
\ "",
\ "  /* navigate upwards in the DOM tree to open all folds containing the line */",
\ "  var node = lineElem;",
\ "  while (node && node.id != 'vimCodeElement".s:settings.id_suffix."')",
\ "  {",
\ "    if (node.className == 'closed-fold')",
\ "    {",
\ "      node.className = 'open-fold';",
\ "    }",
\ "    node = node.parentNode;",
\ "  }",
\ ])
endif
call extend(s:lines, [
\ "  /* Always jump to new location even if the line was hidden inside a fold, or",
\ "   * we corrected the raw number to a line ID.",
\ "   */",
\ "  if (lineElem) {",
\ "    lineElem.scrollIntoView(true);",
\ "  }",
\ "  return true;",
\ "}",
\ "if ('onhashchange' in window) {",
\ "  window.onhashchange = JumpToLine;",
\ "}"
\ ])
endif
if !empty(s:settings.prevent_copy)
call extend(s:lines, [
\ '',
\ '/* simulate a "ch" unit by asking the browser how big a zero character is */',
\ 'function FixCharWidth() {',
\ '  /* get the hidden element which gives the width of a single character */',
\ '  var goodWidth = document.getElementById("oneCharWidth").clientWidth;',
\ '  /* get all input elements, we''ll filter on class later */',
\ '  var inputTags = document.getElementsByTagName("input");',
\ '  var ratio = 5;',
\ '  var inputWidth = document.getElementById("oneInputWidth").clientWidth;',
\ '  var emWidth = document.getElementById("oneEmWidth").clientWidth;',
\ '  if (inputWidth > goodWidth) {',
\ '    while (ratio < 100*goodWidth/emWidth && ratio < 100) {',
\ '      ratio += 5;',
\ '    }',
\ '    document.getElementById("vimCodeElement'.s:settings.id_suffix.'").className = "em"+ratio;',
\ '  }',
\ '}'
\ ])
endif
if s:uses_script
call extend(s:lines, [
\ '',
\ s:settings.use_xhtml ? '//]]>' : '-->',
\ "</script>"
\ ])
endif
call extend(s:lines, ["</head>"])
if !empty(s:settings.prevent_copy)
call extend(s:lines,
\ ["<body onload='FixCharWidth();".(s:settings.line_ids ? " JumpToLine();" : "")."'>",
\ "<!-- hidden divs used by javascript to get the width of a char -->",
\ "<div id='oneCharWidth'>0</div>",
\ "<div id='oneInputWidth'><input size='1' value='0'".s:tag_close."</div>",
\ "<div id='oneEmWidth' style='width: 1em;'></div>"
\ ])
else
call extend(s:lines, ["<body".(s:settings.line_ids ? " onload='JumpToLine();'" : "").">"])
endif
if s:settings.no_pre
if s:settings.use_css
call extend(s:lines, ["<div id='vimCodeElement".s:settings.id_suffix."'>"])
endif
else
call extend(s:lines, ["<pre id='vimCodeElement".s:settings.id_suffix."'>"])
endif
exe s:orgwin . "wincmd w"
if s:settings.number_lines
let s:stylelist = { s:LINENR_ID : ".LineNr { " . s:CSS1( s:LINENR_ID ) . "}" }
else
let s:stylelist = {}
endif
let s:diffstylelist = {
\   s:DIFF_A_ID : ".DiffAdd { " . s:CSS1( s:DIFF_A_ID ) . "}",
\   s:DIFF_C_ID : ".DiffChange { " . s:CSS1( s:DIFF_C_ID ) . "}",
\   s:DIFF_D_ID : ".DiffDelete { " . s:CSS1( s:DIFF_D_ID ) . "}",
\   s:DIFF_T_ID : ".DiffText { " . s:CSS1( s:DIFF_T_ID ) . "}"
\ }
if !s:settings.no_progress
let s:progressbar={}
func! s:ProgressBar(title, max_value, winnr)
let pgb=copy(s:progressbar)
let pgb.title = a:title.' '
let pgb.max_value = a:max_value
let pgb.winnr = a:winnr
let pgb.cur_value = 0
let pgb.items = { 'title'   : { 'color' : 'Statusline' },
\'bar'     : { 'color' : 'Statusline' , 'fillcolor' : 'DiffDelete' , 'bg' : 'Statusline' } ,
\'counter' : { 'color' : 'Statusline' } }
let pgb.last_value = 0
let pgb.needs_redraw = 0
let pgb.subtractedlen=len(split(pgb.title, '\zs'))+3+4+2+2
let pgb.max_len = 0
set laststatus=2
return pgb
endfun
func! s:progressbar.calculate_ticks(pb_len)
if a:pb_len<=0
let pb_len = 100
else
let pb_len = a:pb_len
endif
let self.progress_ticks = map(range(pb_len+1), "v:val * self.max_value / pb_len")
endfun
func! s:progressbar.paint()
let max_len = winwidth(self.winnr)
let pb_len = 0
if max_len != self.max_len
let self.max_len = max_len
let pb_len = max_len - self.subtractedlen
call self.calculate_ticks(pb_len)
let self.needs_redraw = 1
let cur_value = 0
let self.pb_len = pb_len
else
let cur_value = self.last_value
let pb_len = self.pb_len
endif
let cur_val_max = pb_len > 0 ? pb_len : 100
while cur_value < cur_val_max && self.cur_value > self.progress_ticks[cur_value]
let cur_value += 1
endwhile
if self.last_value != cur_value || self.needs_redraw || self.cur_value == self.max_value
let self.needs_redraw = 1
let self.last_value = cur_value
let t_color  = self.items.title.color
let b_fcolor = self.items.bar.fillcolor
let b_color  = self.items.bar.color
let c_color  = self.items.counter.color
let stl =  "%#".t_color."#%-( ".self.title." %)".
\"%#".b_color."#".
\(pb_len>0 ?
\	('|%#'.b_fcolor."#%-(".repeat(" ",cur_value)."%)".
\	 '%#'.b_color."#".repeat(" ",pb_len-cur_value)."|"):
\	('')).
\"%=%#".c_color."#%( ".printf("%3.d ",100*self.cur_value/self.max_value)."%% %)"
call setwinvar(self.winnr, '&stl', stl)
endif
endfun
func! s:progressbar.incr( ... )
let self.cur_value += (a:0 ? a:1 : 1)
let self.cur_value = (self.cur_value > self.max_value ? self.max_value : self.cur_value)
call self.paint()
endfun
if s:settings.dynamic_folds
let s:pgb = s:ProgressBar("Processing folds:", line('$')*2, s:orgwin)
endif
endif
let s:allfolds = []
if s:settings.dynamic_folds
let s:lnum = 1
let s:end = line('$')
let s:foldtext_save = &foldtext
setlocal foldtext&
let s:foldcolumn = &foldcolumn
while s:lnum <= s:end
if foldclosed(s:lnum) == s:lnum
let s:level = match(foldtextresult(s:lnum), '+-*\zs[^-]') - 2
let s:newfold = {'firstline': s:lnum, 'lastline': foldclosedend(s:lnum), 'level': s:level,'type': "closed-fold"}
call add(s:allfolds, s:newfold)
execute s:lnum."foldopen"
else
if !s:settings.no_progress
call s:pgb.incr()
if s:pgb.needs_redraw
redrawstatus
let s:pgb.needs_redraw = 0
endif
endif
let s:lnum = s:lnum + 1
endif
endwhile
silent! %foldclose!
let s:lnum = 1
while s:lnum <= s:end
if foldclosed(s:lnum) == s:lnum
let s:level = match(foldtextresult(s:lnum), '+-*\zs[^-]') - 2
let s:newfold = {'firstline': s:lnum, 'lastline': foldclosedend(s:lnum), 'level': s:level,'type': "closed-fold"}
if empty(s:allfolds) || index(s:allfolds, s:newfold) == -1
let s:newfold.type = "open-fold"
call add(s:allfolds, s:newfold)
endif
execute s:lnum."foldopen"
else
if !s:settings.no_progress
call s:pgb.incr()
if s:pgb.needs_redraw
redrawstatus
let s:pgb.needs_redraw = 0
endif
endif
let s:lnum = s:lnum + 1
endif
endwhile
call sort(s:allfolds, "s:FoldCompare")
let &l:foldtext = s:foldtext_save
unlet s:foldtext_save
silent! %foldclose!
let leveladjust = 0
for afold in s:allfolds
let removed = 0
if exists("g:html_start_line") && exists("g:html_end_line")
if afold.firstline < g:html_start_line
if afold.lastline <= g:html_end_line && afold.lastline >= g:html_start_line
let afold.firstline = g:html_start_line
else
call remove(s:allfolds, index(s:allfolds, afold))
let removed = 1
if afold.lastline > g:html_end_line
let leveladjust += 1
endif
endif
elseif afold.firstline > g:html_end_line
call remove(s:allfolds, index(s:allfolds, afold))
let removed = 1
endif
elseif exists("g:html_start_line")
if afold.firstline < g:html_start_line
let afold.firstline = g:html_start_line
endif
elseif exists("g:html_end_line")
if afold.firstline > g:html_end_line
call remove(s:allfolds, index(s:allfolds, afold))
let removed = 1
endif
endif
if !removed
let afold.level -= leveladjust
if afold.level+1 > s:foldcolumn
let s:foldcolumn = afold.level+1
endif
endif
endfor
while leveladjust > 0
exe g:html_start_line."foldopen"
let leveladjust -= 1
endwhile
endif
if exists("g:html_start_line")
let s:lnum = html_start_line
if s:lnum < 1 || s:lnum > line("$")
let s:lnum = 1
endif
else
let s:lnum = 1
endif
if exists("g:html_end_line")
let s:end = html_end_line
if s:end < s:lnum || s:end > line("$")
let s:end = line("$")
endif
else
let s:end = line("$")
endif
let s:foldstack = []
if !s:settings.no_progress
let s:pgb = s:ProgressBar("Processing lines:", s:end - s:lnum + 1, s:orgwin)
endif
if s:settings.number_lines
let s:margin = strlen(s:end) + 1
else
let s:margin = 0
endif
if has('folding') && !s:settings.ignore_folding
let s:foldfillchar = &fillchars[matchend(&fillchars, 'fold:')]
if s:foldfillchar == ''
let s:foldfillchar = '-'
endif
endif
let s:difffillchar = &fillchars[matchend(&fillchars, 'diff:')]
if s:difffillchar == ''
let s:difffillchar = '-'
endif
let s:foldId = 0
if !s:settings.expand_tabs
let s:old_isprint = &isprint
setlocal isprint+=9
endif
while s:lnum <= s:end
let s:filler = diff_filler(s:lnum)
if s:filler > 0
let s:n = s:filler
while s:n > 0
let s:new = repeat(s:difffillchar, 3)
if s:n > 2 && s:n < s:filler && !s:settings.whole_filler
let s:new = s:new . " " . s:filler . " inserted lines "
let s:n = 2
endif
if !s:settings.no_pre
let s:new = s:new . repeat(s:difffillchar, &columns - strlen(s:new) - s:margin)
else
let s:new = s:new . repeat(s:difffillchar, 3)
endif
let s:new = s:HtmlFormat_d(s:new, s:DIFF_D_ID, 0)
if s:settings.number_lines
let s:new = s:HtmlFormat_n(repeat(' ', s:margin), s:LINENR_ID, 0, 0) . s:new
endif
if s:settings.dynamic_folds && !s:settings.no_foldcolumn && s:foldcolumn > 0
let s:new = s:FoldColumn_fill() . s:new
endif
call add(s:lines, s:new.s:HtmlEndline)
let s:n = s:n - 1
endwhile
unlet s:n
endif
unlet s:filler
if s:settings.number_lines
let s:numcol = repeat(' ', s:margin - 1 - strlen(s:lnum)) . s:lnum . ' '
endif
let s:new = ""
if has('folding') && !s:settings.ignore_folding && foldclosed(s:lnum) > -1 && !s:settings.dynamic_folds
let s:new = foldtextresult(s:lnum)
if !s:settings.no_pre
let s:new = s:new . repeat(s:foldfillchar, &columns - strlen(s:new))
endif
let s:new = (s:settings.number_lines ? s:HtmlFormat_n(s:numcol, s:FOLDED_ID, 0, s:lnum): "") . s:HtmlFormat_t(s:new, s:FOLDED_ID, 0)
let s:new_lnum = foldclosedend(s:lnum)
if !s:settings.no_progress
call s:pgb.incr(s:new_lnum - s:lnum)
endif
let s:lnum = s:new_lnum
else
let s:line = getline(s:lnum)
let s:len = strlen(s:line)
if s:settings.dynamic_folds
while !empty(s:foldstack) && get(s:foldstack,0).lastline == s:lnum-1
let s:new = s:new."</span></span>"
call remove(s:foldstack, 0)
endwhile
let s:firstfold = 1
while !empty(s:allfolds) && get(s:allfolds,0).firstline == s:lnum
let s:foldId = s:foldId + 1
let s:new .= "<span id='"
let s:new .= (exists('g:html_diff_win_num') ? "win".g:html_diff_win_num : "")
let s:new .= "fold".s:foldId.s:settings.id_suffix."' class='".s:allfolds[0].type."'>"
if !s:settings.no_foldcolumn
if s:allfolds[0].level > 1 && s:firstfold
let s:new = s:new . s:FoldColumn_build('|', s:allfolds[0].level - 1, 0, "",
\ 'toggle-open FoldColumn','javascript:toggleFold("fold'.s:foldstack[0].id.s:settings.id_suffix.'");')
endif
let s:new = s:new . s:FoldColumn_build("+", 1, 0, "",
\ 'toggle-open FoldColumn', 'javascript:toggleFold("fold'.s:foldId.s:settings.id_suffix.'");')
let s:new = s:new . s:FoldColumn_build(" ", 1, s:foldcolumn - s:allfolds[0].level - 1, "",
\ 'toggle-open FoldColumn'. (get(s:allfolds, 1, {'firstline': 0}).firstline == s:lnum ?" toggle-filler" :""),
\ 'javascript:toggleFold("fold'.s:foldId.s:settings.id_suffix.'");')
if get(s:allfolds, 1, {'firstline': 0}).firstline != s:lnum
let s:extra_space = s:foldcolumn - s:allfolds[0].level
else
let s:extra_space = 0
endif
if s:firstfold
let s:new .= s:FoldColumn_build('|', s:allfolds[0].level - 1, s:extra_space, '-',
\ 'toggle-closed FoldColumn', 'javascript:toggleFold("fold'.s:foldId.s:settings.id_suffix.'");')
else
let s:new = s:new . s:FoldColumn_build("-", 1, s:extra_space, "",
\ 'toggle-closed FoldColumn', 'javascript:toggleFold("fold'.s:foldId.s:settings.id_suffix.'");')
endif
let s:firstfold = 0
endif
let s:new = s:new . (s:settings.number_lines ? s:HtmlFormat_n(s:numcol, s:FOLDED_ID, 0, 0) : "") . substitute(s:HtmlFormat_t(foldtextresult(s:lnum), s:FOLDED_ID, 0), '</span>', s:HtmlEndline.'\n\0', '')
let s:new = s:new . "<span class='fulltext'>"
execute s:lnum."foldopen"
call insert(s:foldstack, remove(s:allfolds,0))
let s:foldstack[0].id = s:foldId
endwhile
if !s:settings.no_foldcolumn
if empty(s:foldstack)
if s:foldcolumn > 0
let s:new = s:new . s:FoldColumn_fill()
endif
else
if get(s:foldstack, 0).firstline < s:lnum
let s:new = s:new . s:FoldColumn_build('|', s:foldstack[0].level, s:foldcolumn - s:foldstack[0].level, "",
\ 'FoldColumn', 'javascript:toggleFold("fold'.s:foldstack[0].id.s:settings.id_suffix.'");')
endif
endif
endif
endif
if s:settings.number_lines
let s:new = s:new . s:HtmlFormat_n(s:numcol, s:LINENR_ID, 0, s:lnum)
elseif s:settings.line_ids
let s:new = s:new . s:HtmlFormat_n("", s:LINENR_ID, 0, s:lnum)
endif
let s:diffattr = diff_hlID(s:lnum, 1)
let s:concealinfo = [0, '']
let s:col = 1
let s:diff_id = 0
while s:col <= s:len || (s:col == 1 && s:diffattr)
let s:startcol = s:col " The start column for processing text
if !s:settings.ignore_conceal && has('conceal')
let s:concealinfo = synconcealed(s:lnum, s:col)
endif
if !s:settings.ignore_conceal && s:concealinfo[0]
let s:col = s:col + 1
while s:col <= s:len && s:concealinfo == synconcealed(s:lnum, s:col) | let s:col = s:col + 1 | endwhile
elseif s:diffattr
let s:diff_id = diff_hlID(s:lnum, s:col)
let s:id = synID(s:lnum, s:col, 1)
let s:col = s:col + 1
while s:col <= s:len && s:id == synID(s:lnum, s:col, 1)
\   && s:diff_id == diff_hlID(s:lnum, s:col) |
\     let s:col = s:col + 1 |
\ endwhile
if s:len < &columns && !s:settings.no_pre
let s:line = s:line . repeat(' ', &columns - virtcol([s:lnum, s:len]) - s:margin)
let s:len = &columns
endif
else
let s:id = synID(s:lnum, s:col, 1)
let s:col = s:col + 1
while s:col <= s:len && s:id == synID(s:lnum, s:col, 1) | let s:col = s:col + 1 | endwhile
endif
if s:settings.ignore_conceal || !s:concealinfo[0]
let s:expandedtab = strpart(s:line, s:startcol - 1, s:col - s:startcol)
if s:settings.expand_tabs
let s:offset = 0
let s:idx = stridx(s:expandedtab, "\t")
let s:tablist = split(&vts,',')
if empty(s:tablist)
let s:tablist = [ &ts ]
endif
let s:tabidx = 0
let s:tabwidth = 0
while s:idx >= 0
while s:startcol+s:idx > s:tabwidth + s:tablist[s:tabidx] 
let s:tabwidth += s:tablist[s:tabidx]
if s:tabidx < len(s:tablist)-1
let s:tabidx = s:tabidx+1
endif
endwhile
if has("multi_byte_encoding")
if s:startcol + s:idx == 1
let s:i = s:tablist[s:tabidx]
else
if s:idx == 0
let s:prevc = matchstr(s:line, '.\%' . (s:startcol + s:idx + s:offset) . 'c')
else
let s:prevc = matchstr(s:expandedtab, '.\%' . (s:idx + 1) . 'c')
endif
let s:vcol = virtcol([s:lnum, s:startcol + s:idx + s:offset - len(s:prevc)])
let s:i = s:tablist[s:tabidx] - (s:vcol - s:tabwidth)
endif
let s:offset -= s:i - 1
else
let s:i = s:tablist[s:tabidx] - ((s:idx + s:startcol - 1) - s:tabwidth)
endif
let s:expandedtab = substitute(s:expandedtab, '\t', repeat(' ', s:i), '')
let s:idx = stridx(s:expandedtab, "\t")
endwhile
end
let s:id = synIDtrans(s:id)
else
let s:id = s:CONCEAL_ID
let s:expandedtab = s:concealinfo[1]
endif
if strlen(s:expandedtab) > 0
let s:new = s:new . s:HtmlFormat(s:expandedtab,  s:id, s:diff_id, "", 0)
endif
endwhile
endif
call extend(s:lines, split(s:new.s:HtmlEndline, '\n', 1))
if !s:settings.no_progress && s:pgb.needs_redraw
redrawstatus
let s:pgb.needs_redraw = 0
endif
let s:lnum = s:lnum + 1
if !s:settings.no_progress
call s:pgb.incr()
endif
endwhile
if s:settings.dynamic_folds
while !empty(s:foldstack)
let s:lines[-1].="</span></span>"
call remove(s:foldstack, 0)
endwhile
let s:id = s:FOLD_C_ID
if !has_key(s:stylelist, s:id)
let s:stylelist[s:id] = '.FoldColumn { ' . s:CSS1(s:id) . '}'
endif
endif
if s:settings.no_pre
if !s:settings.use_css
call extend(s:lines, ["</font>", "</body>", "</html>"])
else
call extend(s:lines, ["</div>", "</body>", "</html>"])
endif
else
call extend(s:lines, ["</pre>", "</body>", "</html>"])
endif
exe s:newwin . "wincmd w"
call setline(1, s:lines)
unlet s:lines
%s!\v(%(^|\s+)%([Vv]i%(m%([<=>]?\d+)?)?|ex)):!\1\&#0058;!ge
call append(line('$'), "<!-- vim: set foldmethod=manual : -->")
if s:settings.use_css
1;/<style type="text/+1
endif
if s:settings.use_css
if s:settings.no_pre
call append('.', "body { color: " . s:fgc . "; background-color: " . s:bgc . "; font-family: ". s:htmlfont ."; }")
+
else
call append('.', "pre { " . s:whitespace . "font-family: ". s:htmlfont ."; color: " . s:fgc . "; background-color: " . s:bgc . "; }")
+
yank
put
execute "normal! ^cwbody\e"
if s:whitespace != ''
exec 's#'.s:whitespace
endif
endif
call append('.', '* { font-size: 1em; }')
+
if !empty(s:settings.prevent_copy)
call append('.', 'input { border: none; margin: 0; padding: 0; font-family: '.s:htmlfont.'; }')
+
call append('.', [
\ "input[size='1'] { width: 1em; width: 1ch; }",
\ "input[size='2'] { width: 2em; width: 2ch; }",
\ "input[size='3'] { width: 3em; width: 3ch; }",
\ "input[size='4'] { width: 4em; width: 4ch; }",
\ "input[size='5'] { width: 5em; width: 5ch; }",
\ "input[size='6'] { width: 6em; width: 6ch; }",
\ "input[size='7'] { width: 7em; width: 7ch; }",
\ "input[size='8'] { width: 8em; width: 8ch; }",
\ "input[size='9'] { width: 9em; width: 9ch; }",
\ "input[size='10'] { width: 10em; width: 10ch; }",
\ "input[size='11'] { width: 11em; width: 11ch; }",
\ "input[size='12'] { width: 12em; width: 12ch; }",
\ "input[size='13'] { width: 13em; width: 13ch; }",
\ "input[size='14'] { width: 14em; width: 14ch; }",
\ "input[size='15'] { width: 15em; width: 15ch; }",
\ "input[size='16'] { width: 16em; width: 16ch; }",
\ "input[size='17'] { width: 17em; width: 17ch; }",
\ "input[size='18'] { width: 18em; width: 18ch; }",
\ "input[size='19'] { width: 19em; width: 19ch; }",
\ "input[size='20'] { width: 20em; width: 20ch; }",
\ "#oneCharWidth, #oneEmWidth, #oneInputWidth { padding: 0; margin: 0; position: absolute; left: -999999px; visibility: hidden; }"
\ ])
+21
for w in range(5, 100, 5)
let base = 0.01 * w
call append('.', join(map(range(1,20), "'.em'.w.' input[size='''.v:val.'''] { width: '.string(v:val*base).'em; }'")))
+
endfor
if s:settings.prevent_copy =~# 'f'
call append('.', ['input.FoldColumn { cursor: pointer; }',
\ 'input.FoldColumn[value=""] { cursor: default; }'
\ ])
+2
endif
if s:settings.prevent_copy =~# 'n'
call append('.', 'input.LineNr { cursor: default; }')
+
endif
if (s:settings.prevent_copy =~# 'n' || s:settings.prevent_copy =~# 't') && !s:settings.ignore_folding
call append('.', 'input.Folded { cursor: default; }')
+
endif
endif
else
execute '%s:<body\([^>]*\):<body bgcolor="' . s:bgc . '" text="' . s:fgc . '"\1>\r<font face="'. s:htmlfont .'"'
endif
if s:settings.use_css
if s:diff_mode
call append('.', filter(map(keys(s:diffstylelist), "s:diffstylelist[v:val]"), 'v:val != ""'))
endif
if !empty(s:stylelist)
call append('.', filter(map(keys(s:stylelist), "s:stylelist[v:val]"), 'v:val != ""'))
endif
endif
%s+\(https\=://\S\{-}\)\(\([.,;:}]\=\(\s\|$\)\)\|[\\"'<>]\|&gt;\|&lt;\|&quot;\)+<a href="\1">\1</a>\2+ge
if s:settings.use_xhtml
exe "normal! gg$a\n<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">"
elseif s:settings.use_css && !s:settings.no_pre
exe "normal! gg0i<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">\n"
else
exe "normal! gg0i<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\">\n"
endif
if s:settings.use_xhtml
exe "normal! gg/<html/e\na xmlns=\"http://www.w3.org/1999/xhtml\"\e"
endif
%s:\s\+$::e
let &l:foldenable = s:old_fen
let &report = s:old_report
let &title = s:old_title
let &icon = s:old_icon
let &paste = s:old_paste
let &magic = s:old_magic
let @/ = s:old_search
let &more = s:old_more
exe s:orgwin . "wincmd w"
if !s:settings.expand_tabs
let &l:isprint = s:old_isprint
endif
let &l:stl = s:origwin_stl
let &l:et = s:old_et
let &l:scrollbind = s:old_bind
exe s:newwin . "wincmd w"
let &l:stl = s:newwin_stl
exec 'resize' s:old_winheight
let &l:winfixheight = s:old_winfixheight
let &ls=s:ls
unlet s:htmlfont s:whitespace
unlet s:old_et s:old_paste s:old_icon s:old_report s:old_title s:old_search
unlet s:old_magic s:old_more s:old_fen s:old_winheight
unlet! s:old_isprint
unlet s:whatterm s:stylelist s:diffstylelist s:lnum s:end s:margin s:fgc s:bgc s:old_winfixheight
unlet! s:col s:id s:attr s:len s:line s:new s:expandedtab s:concealinfo s:diff_mode
unlet! s:orgwin s:newwin s:orgbufnr s:idx s:i s:offset s:ls s:origwin_stl
unlet! s:newwin_stl s:current_syntax
if !v:profiling
delfunc s:HtmlColor
delfunc s:HtmlFormat
delfunc s:CSS1
delfunc s:BuildStyleWrapper
if !s:settings.use_css
delfunc s:HtmlOpening
delfunc s:HtmlClosing
endif
if s:settings.dynamic_folds
delfunc s:FoldCompare
endif
if !s:settings.no_progress
delfunc s:ProgressBar
delfunc s:progressbar.paint
delfunc s:progressbar.incr
unlet s:pgb s:progressbar
endif
endif
unlet! s:new_lnum s:diffattr s:difffillchar s:foldfillchar s:HtmlSpace
unlet! s:LeadingSpace s:HtmlEndline s:firstfold s:numcol s:foldcolumn
unlet s:foldstack s:allfolds s:foldId s:settings
let &cpo = s:cpo_sav
unlet! s:cpo_sav
