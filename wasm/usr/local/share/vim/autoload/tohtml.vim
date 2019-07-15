let s:cpo_sav = &cpo
set cpo&vim
let g:tohtml#encoding_to_charset = {
\ 'latin1' : 'ISO-8859-1',
\ 'iso-8859-2' : 'ISO-8859-2',
\ 'iso-8859-3' : 'ISO-8859-3',
\ 'iso-8859-4' : 'ISO-8859-4',
\ 'iso-8859-5' : 'ISO-8859-5',
\ 'iso-8859-6' : 'ISO-8859-6',
\ 'iso-8859-7' : 'ISO-8859-7',
\ 'iso-8859-8' : 'ISO-8859-8',
\ 'iso-8859-9' : 'ISO-8859-9',
\ 'iso-8859-10' : '',
\ 'iso-8859-13' : 'ISO-8859-13',
\ 'iso-8859-14' : '',
\ 'iso-8859-15' : 'ISO-8859-15',
\ 'koi8-r' : 'KOI8-R',
\ 'koi8-u' : 'KOI8-U',
\ 'macroman' : 'macintosh',
\ 'cp437' : '',
\ 'cp775' : '',
\ 'cp850' : '',
\ 'cp852' : '',
\ 'cp855' : '',
\ 'cp857' : '',
\ 'cp860' : '',
\ 'cp861' : '',
\ 'cp862' : '',
\ 'cp863' : '',
\ 'cp865' : '',
\ 'cp866' : 'IBM866',
\ 'cp869' : '',
\ 'cp874' : '',
\ 'cp1250' : 'windows-1250',
\ 'cp1251' : 'windows-1251',
\ 'cp1253' : 'windows-1253',
\ 'cp1254' : 'windows-1254',
\ 'cp1255' : 'windows-1255',
\ 'cp1256' : 'windows-1256',
\ 'cp1257' : 'windows-1257',
\ 'cp1258' : 'windows-1258',
\ 'euc-jp' : 'EUC-JP',
\ 'sjis' : 'Shift_JIS',
\ 'cp932' : 'Shift_JIS',
\ 'cp949' : '',
\ 'euc-kr' : 'EUC-KR',
\ 'cp936' : 'GBK',
\ 'euc-cn' : 'GB2312',
\ 'big5' : 'Big5',
\ 'cp950' : 'Big5',
\ 'utf-8' : 'UTF-8',
\ 'ucs-2' : 'UTF-8',
\ 'ucs-2le' : 'UTF-8',
\ 'utf-16' : 'UTF-8',
\ 'utf-16le' : 'UTF-8',
\ 'ucs-4' : 'UTF-8',
\ 'ucs-4le' : 'UTF-8',
\ }
lockvar g:tohtml#encoding_to_charset
let g:tohtml#charset_to_encoding = {
\ 'iso_8859-1:1987' : 'latin1',
\ 'iso-ir-100' : 'latin1',
\ 'iso_8859-1' : 'latin1',
\ 'iso-8859-1' : 'latin1',
\ 'latin1' : 'latin1',
\ 'l1' : 'latin1',
\ 'ibm819' : 'latin1',
\ 'cp819' : 'latin1',
\ 'csisolatin1' : 'latin1',
\ 'iso_8859-2:1987' : 'iso-8859-2',
\ 'iso-ir-101' : 'iso-8859-2',
\ 'iso_8859-2' : 'iso-8859-2',
\ 'iso-8859-2' : 'iso-8859-2',
\ 'latin2' : 'iso-8859-2',
\ 'l2' : 'iso-8859-2',
\ 'csisolatin2' : 'iso-8859-2',
\ 'iso_8859-3:1988' : 'iso-8859-3',
\ 'iso-ir-109' : 'iso-8859-3',
\ 'iso_8859-3' : 'iso-8859-3',
\ 'iso-8859-3' : 'iso-8859-3',
\ 'latin3' : 'iso-8859-3',
\ 'l3' : 'iso-8859-3',
\ 'csisolatin3' : 'iso-8859-3',
\ 'iso_8859-4:1988' : 'iso-8859-4',
\ 'iso-ir-110' : 'iso-8859-4',
\ 'iso_8859-4' : 'iso-8859-4',
\ 'iso-8859-4' : 'iso-8859-4',
\ 'latin4' : 'iso-8859-4',
\ 'l4' : 'iso-8859-4',
\ 'csisolatin4' : 'iso-8859-4',
\ 'iso_8859-5:1988' : 'iso-8859-5',
\ 'iso-ir-144' : 'iso-8859-5',
\ 'iso_8859-5' : 'iso-8859-5',
\ 'iso-8859-5' : 'iso-8859-5',
\ 'cyrillic' : 'iso-8859-5',
\ 'csisolatincyrillic' : 'iso-8859-5',
\ 'iso_8859-6:1987' : 'iso-8859-6',
\ 'iso-ir-127' : 'iso-8859-6',
\ 'iso_8859-6' : 'iso-8859-6',
\ 'iso-8859-6' : 'iso-8859-6',
\ 'ecma-114' : 'iso-8859-6',
\ 'asmo-708' : 'iso-8859-6',
\ 'arabic' : 'iso-8859-6',
\ 'csisolatinarabic' : 'iso-8859-6',
\ 'iso_8859-7:1987' : 'iso-8859-7',
\ 'iso-ir-126' : 'iso-8859-7',
\ 'iso_8859-7' : 'iso-8859-7',
\ 'iso-8859-7' : 'iso-8859-7',
\ 'elot_928' : 'iso-8859-7',
\ 'ecma-118' : 'iso-8859-7',
\ 'greek' : 'iso-8859-7',
\ 'greek8' : 'iso-8859-7',
\ 'csisolatingreek' : 'iso-8859-7',
\ 'iso_8859-8:1988' : 'iso-8859-8',
\ 'iso-ir-138' : 'iso-8859-8',
\ 'iso_8859-8' : 'iso-8859-8',
\ 'iso-8859-8' : 'iso-8859-8',
\ 'hebrew' : 'iso-8859-8',
\ 'csisolatinhebrew' : 'iso-8859-8',
\ 'iso_8859-9:1989' : 'iso-8859-9',
\ 'iso-ir-148' : 'iso-8859-9',
\ 'iso_8859-9' : 'iso-8859-9',
\ 'iso-8859-9' : 'iso-8859-9',
\ 'latin5' : 'iso-8859-9',
\ 'l5' : 'iso-8859-9',
\ 'csisolatin5' : 'iso-8859-9',
\ 'iso-8859-10' : 'iso-8859-10',
\ 'iso-ir-157' : 'iso-8859-10',
\ 'l6' : 'iso-8859-10',
\ 'iso_8859-10:1992' : 'iso-8859-10',
\ 'csisolatin6' : 'iso-8859-10',
\ 'latin6' : 'iso-8859-10',
\ 'iso-8859-13' : 'iso-8859-13',
\ 'iso-8859-14' : 'iso-8859-14',
\ 'iso-ir-199' : 'iso-8859-14',
\ 'iso_8859-14:1998' : 'iso-8859-14',
\ 'iso_8859-14' : 'iso-8859-14',
\ 'latin8' : 'iso-8859-14',
\ 'iso-celtic' : 'iso-8859-14',
\ 'l8' : 'iso-8859-14',
\ 'iso-8859-15' : 'iso-8859-15',
\ 'iso_8859-15' : 'iso-8859-15',
\ 'latin-9' : 'iso-8859-15',
\ 'koi8-r' : 'koi8-r',
\ 'cskoi8r' : 'koi8-r',
\ 'koi8-u' : 'koi8-u',
\ 'macintosh' : 'macroman',
\ 'mac' : 'macroman',
\ 'csmacintosh' : 'macroman',
\ 'ibm437' : 'cp437',
\ 'cp437' : 'cp437',
\ '437' : 'cp437',
\ 'cspc8codepage437' : 'cp437',
\ 'ibm775' : 'cp775',
\ 'cp775' : 'cp775',
\ 'cspc775baltic' : 'cp775',
\ 'ibm850' : 'cp850',
\ 'cp850' : 'cp850',
\ '850' : 'cp850',
\ 'cspc850multilingual' : 'cp850',
\ 'ibm852' : 'cp852',
\ 'cp852' : 'cp852',
\ '852' : 'cp852',
\ 'cspcp852' : 'cp852',
\ 'ibm855' : 'cp855',
\ 'cp855' : 'cp855',
\ '855' : 'cp855',
\ 'csibm855' : 'cp855',
\ 'ibm857' : 'cp857',
\ 'cp857' : 'cp857',
\ '857' : 'cp857',
\ 'csibm857' : 'cp857',
\ 'ibm860' : 'cp860',
\ 'cp860' : 'cp860',
\ '860' : 'cp860',
\ 'csibm860' : 'cp860',
\ 'ibm861' : 'cp861',
\ 'cp861' : 'cp861',
\ '861' : 'cp861',
\ 'cp-is' : 'cp861',
\ 'csibm861' : 'cp861',
\ 'ibm862' : 'cp862',
\ 'cp862' : 'cp862',
\ '862' : 'cp862',
\ 'cspc862latinhebrew' : 'cp862',
\ 'ibm863' : 'cp863',
\ 'cp863' : 'cp863',
\ '863' : 'cp863',
\ 'csibm863' : 'cp863',
\ 'ibm865' : 'cp865',
\ 'cp865' : 'cp865',
\ '865' : 'cp865',
\ 'csibm865' : 'cp865',
\ 'ibm866' : 'cp866',
\ 'cp866' : 'cp866',
\ '866' : 'cp866',
\ 'csibm866' : 'cp866',
\ 'ibm869' : 'cp869',
\ 'cp869' : 'cp869',
\ '869' : 'cp869',
\ 'cp-gr' : 'cp869',
\ 'csibm869' : 'cp869',
\ 'windows-1250' : 'cp1250',
\ 'windows-1251' : 'cp1251',
\ 'windows-1253' : 'cp1253',
\ 'windows-1254' : 'cp1254',
\ 'windows-1255' : 'cp1255',
\ 'windows-1256' : 'cp1256',
\ 'windows-1257' : 'cp1257',
\ 'windows-1258' : 'cp1258',
\ 'extended_unix_code_packed_format_for_japanese' : 'euc-jp',
\ 'cseucpkdfmtjapanese' : 'euc-jp',
\ 'euc-jp' : 'euc-jp',
\ 'shift_jis' : 'sjis',
\ 'ms_kanji' : 'sjis',
\ 'sjis' : 'sjis',
\ 'csshiftjis' : 'sjis',
\ 'ibm-thai' : 'cp874',
\ 'csibmthai' : 'cp874',
\ 'ks_c_5601-1987' : 'cp949',
\ 'iso-ir-149' : 'cp949',
\ 'ks_c_5601-1989' : 'cp949',
\ 'ksc_5601' : 'cp949',
\ 'korean' : 'cp949',
\ 'csksc56011987' : 'cp949',
\ 'euc-kr' : 'euc-kr',
\ 'cseuckr' : 'euc-kr',
\ 'gbk' : 'cp936',
\ 'cp936' : 'cp936',
\ 'ms936' : 'cp936',
\ 'windows-936' : 'cp936',
\ 'gb_2312-80' : 'euc-cn',
\ 'iso-ir-58' : 'euc-cn',
\ 'chinese' : 'euc-cn',
\ 'csiso58gb231280' : 'euc-cn',
\ 'big5' : 'big5',
\ 'csbig5' : 'big5',
\ 'utf-8' : 'utf-8',
\ 'iso-10646-ucs-2' : 'ucs-2',
\ 'csunicode' : 'ucs-2',
\ 'utf-16' : 'utf-16',
\ 'utf-16be' : 'utf-16',
\ 'utf-16le' : 'utf-16le',
\ 'utf-32' : 'ucs-4',
\ 'utf-32be' : 'ucs-4',
\ 'utf-32le' : 'ucs-4le',
\ 'iso-10646-ucs-4' : 'ucs-4',
\ 'csucs4' : 'ucs-4'
\ }
lockvar g:tohtml#charset_to_encoding
func! tohtml#Convert2HTML(line1, line2) "{{{
let s:settings = tohtml#GetUserSettings()
if !&diff || s:settings.diff_one_file "{{{
if a:line2 >= a:line1
let g:html_start_line = a:line1
let g:html_end_line = a:line2
else
let g:html_start_line = a:line2
let g:html_end_line = a:line1
endif
runtime syntax/2html.vim "}}}
else "{{{
let win_list = []
let buf_list = []
windo if &diff | call add(win_list, winbufnr(0)) | endif
let s:settings.whole_filler = 1
let g:html_diff_win_num = 0
for window in win_list
exe ":" . bufwinnr(window) . "wincmd w"
if !exists('g:html_use_encoding') &&
\ (((&l:fileencoding=='' || (&l:buftype!='' && &l:buftype!=?'help'))
\      && &encoding!=?s:settings.vim_encoding)
\ || &l:fileencoding!='' && &l:fileencoding!=?s:settings.vim_encoding)
echohl WarningMsg
echomsg "TOhtml: mismatched file encodings in Diff buffers, using UTF-8"
echohl None
let s:settings.vim_encoding = 'utf-8'
let s:settings.encoding = 'UTF-8'
endif
let g:html_start_line = 1
let g:html_end_line = line('$')
let g:html_diff_win_num += 1
runtime syntax/2html.vim
call add(buf_list, bufnr('%'))
endfor
unlet g:html_diff_win_num
call tohtml#Diff2HTML(win_list, buf_list)
endif "}}}
unlet g:html_start_line
unlet g:html_end_line
unlet s:settings
endfunc "}}}
func! tohtml#Diff2HTML(win_list, buf_list) "{{{
let xml_line = ""
let tag_close = '>'
let s:old_paste = &paste
set paste
let s:old_magic = &magic
set magic
if s:settings.use_xhtml
if s:settings.encoding != ""
let xml_line = "<?xml version=\"1.0\" encoding=\"" . s:settings.encoding . "\"?>"
else
let xml_line = "<?xml version=\"1.0\"?>"
endif
let tag_close = ' />'
endif
let style = [s:settings.use_xhtml ? "" : '-->']
let body_line = ''
let html = []
if s:settings.use_xhtml
call add(html, xml_line)
endif
if s:settings.use_xhtml
call add(html, "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">")
call add(html, '<html xmlns="http://www.w3.org/1999/xhtml">')
elseif s:settings.use_css && !s:settings.no_pre
call add(html, "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">")
call add(html, '<html>')
else
call add(html, '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"')
call add(html, '  "http://www.w3.org/TR/html4/loose.dtd">')
call add(html, '<html>')
endif
call add(html, '<head>')
if s:settings.encoding != "" && !s:settings.use_xhtml
call add(html, "<meta http-equiv=\"content-type\" content=\"text/html; charset=" . s:settings.encoding . '"' . tag_close)
endif
call add(html, '<title>diff</title>')
call add(html, '<meta name="Generator" content="Vim/'.v:version/100.'.'.v:version%100.'"'.tag_close)
call add(html, '<meta name="plugin-version" content="'.g:loaded_2html_plugin.'"'.tag_close)
call add(html, '<meta name="settings" content="'.
\ join(filter(keys(s:settings),'s:settings[v:val]'),',').
\ ',prevent_copy='.s:settings.prevent_copy.
\ '"'.tag_close)
call add(html, '<meta name="colorscheme" content="'.
\ (exists('g:colors_name')
\ ? g:colors_name
\ : 'none'). '"'.tag_close)
call add(html, '</head>')
let body_line_num = len(html)
if !empty(s:settings.prevent_copy)
call add(html, "<body onload='FixCharWidth();".(s:settings.line_ids ? " JumpToLine();" : "")."'>")
call add(html, "<!-- hidden divs used by javascript to get the width of a char -->")
call add(html, "<div id='oneCharWidth'>0</div>")
call add(html, "<div id='oneInputWidth'><input size='1' value='0'".tag_close."</div>")
call add(html, "<div id='oneEmWidth' style='width: 1em;'></div>")
else
call add(html, '<body'.(s:settings.line_ids ? ' onload="JumpToLine();"' : '').'>')
endif
call add(html, "<table border='1' width='100%' id='vimCodeElement".s:settings.id_suffix."'>")
call add(html, '<tr>')
for buf in a:win_list
call add(html, '<th>'.bufname(buf).'</th>')
endfor
call add(html, '</tr><tr>')
let diff_style_start = 0
let insert_index = 0
for buf in a:buf_list
let temp = []
exe bufwinnr(buf) . 'wincmd w'
setlocal nofoldenable
if body_line == ''
1
call search('<body')
let body_line = getline('.')
$
call search('</body>', 'b')
let s:body_end_line = getline('.')
endif
1
let style_start = search('^<style type="text/css">')
1
let style_end = search('^</style>')
if style_start > 0 && style_end > 0
let buf_styles = getline(style_start + 1, style_end - 1)
for a_style in buf_styles
if index(style, a_style) == -1
if diff_style_start == 0
if a_style =~ '\<Diff\(Change\|Text\|Add\|Delete\)'
let diff_style_start = len(style)-1
endif
endif
call insert(style, a_style, insert_index)
let insert_index += 1
endif
endfor
endif " }}}
if diff_style_start != 0
let insert_index = diff_style_start
endif
1,/^<body.*\%(\n<!--.*-->\_s\+.*id='oneCharWidth'.*\_s\+.*id='oneInputWidth'.*\_s\+.*id='oneEmWidth'\)\?\zs/d_
$
?</body>?,$d_
let temp = getline(1,'$')
let temp[0] = substitute(temp[0], " id='vimCodeElement[^']*'", "", "")
normal! 2u
if s:settings.use_css
call add(html, '<td valign="top"><div>')
elseif s:settings.use_xhtml
call add(html, '<td nowrap="nowrap" valign="top"><div>')
else
call add(html, '<td nowrap valign="top"><div>')
endif
let html += temp
call add(html, '</div></td>')
quit!
endfor
let html[body_line_num] = body_line
call add(html, '</tr>')
call add(html, '</table>')
call add(html, s:body_end_line)
call add(html, '</html>')
call add(html, '<!-- vim: set foldmethod=manual : -->')
let i = 1
let name = "Diff" . (s:settings.use_xhtml ? ".xhtml" : ".html")
while filereadable(name)
let name = substitute(name, '\d*\.x\?html$', '', '') . i . '.' . fnamemodify(copy(name), ":t:e")
let i += 1
endwhile
exe "topleft new " . name
setlocal modifiable
%d
let &l:fileencoding=s:settings.vim_encoding
if s:settings.vim_encoding == 'utf-8'
setlocal nobomb
else
setlocal bomb
endif
call append(0, html)
if len(style) > 0
1
let style_start = search('^</head>')-1
let s:uses_script = s:settings.dynamic_folds || s:settings.line_ids || !empty(s:settings.prevent_copy)
if s:uses_script
call append(style_start, [
\ '',
\ s:settings.use_xhtml ? '//]]>' : '-->',
\ "</script>"
\ ])
endif
if !empty(s:settings.prevent_copy)
call append(style_start, [
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
if s:settings.line_ids
call append(style_start, [
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
if s:settings.dynamic_folds
call append(style_start, [
\ "",
\ "  /* navigate upwards in the DOM tree to open all folds containing the line */",
\ "  var node = lineElem;",
\ "  while (node && node.id != 'vimCodeElement".s:settings.id_suffix."')",
\ "  {",
\ "    if (node.className == 'closed-fold')",
\ "    {",
\ "      /* toggle open the fold ID (remove window ID) */",
\ "      toggleFold(node.id.substr(4));",
\ "    }",
\ "    node = node.parentNode;",
\ "  }",
\ ])
endif
endif
if s:settings.line_ids
call append(style_start, [
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
\ "  if (lineNum.indexOf('W') == -1) {",
\ "    lineNum = 'W1'+lineNum;",
\ "  }",
\ "  var lineElem = document.getElementById(lineNum);"
\ ])
endif
if s:settings.dynamic_folds
call append(style_start, [
\  "  function toggleFold(objID)",
\  "  {",
\  "    for (win_num = 1; win_num <= ".len(a:buf_list)."; win_num++)",
\  "    {",
\  "      var fold;",
\  '      fold = document.getElementById("win"+win_num+objID);',
\  "      if(fold.className == 'closed-fold')",
\  "      {",
\  "        fold.className = 'open-fold';",
\  "      }",
\  "      else if (fold.className == 'open-fold')",
\  "      {",
\  "        fold.className = 'closed-fold';",
\  "      }",
\  "    }",
\  "  }",
\ ])
endif
if s:uses_script
call append(style_start, [
\ "<script type='text/javascript'>",
\ s:settings.use_xhtml ? '//<![CDATA[' : "<!--"])
endif
if s:settings.use_css
call append(style_start,
\ ['<style type="text/css">']+
\ style+
\ [ s:settings.use_xhtml ? '' : '<!--',
\   'table { table-layout: fixed; }',
\   'html, body, table, tbody { width: 100%; margin: 0; padding: 0; }',
\   'th, td { width: '.printf("%.1f",100.0/len(a:win_list)).'%; }',
\   'td div { overflow: auto; }',
\   s:settings.use_xhtml ? '' : '-->',
\   '</style>'
\])
endif "}}}
endif
let &paste = s:old_paste
let &magic = s:old_magic
endfunc "}}}
func! tohtml#GetOption(settings, option, default) "{{{
if exists('g:html_'.a:option)
let a:settings[a:option] = g:html_{a:option}
else
let a:settings[a:option] = a:default
endif
endfunc "}}}
func! tohtml#GetUserSettings() "{{{
if exists('s:settings')
return s:settings
else
let user_settings = {}
if exists('g:use_xhtml') && !exists("g:html_use_xhtml")
let g:html_use_xhtml = g:use_xhtml
endif
call tohtml#GetOption(user_settings,    'no_progress', !has("statusline") )
call tohtml#GetOption(user_settings,  'diff_one_file', 0 )
call tohtml#GetOption(user_settings,   'number_lines', &number )
call tohtml#GetOption(user_settings,       'pre_wrap', &wrap )
call tohtml#GetOption(user_settings,        'use_css', 1 )
call tohtml#GetOption(user_settings, 'ignore_conceal', 0 )
call tohtml#GetOption(user_settings, 'ignore_folding', 0 )
call tohtml#GetOption(user_settings,  'dynamic_folds', 0 )
call tohtml#GetOption(user_settings,  'no_foldcolumn', user_settings.ignore_folding)
call tohtml#GetOption(user_settings,   'hover_unfold', 0 )
call tohtml#GetOption(user_settings,         'no_pre', 0 )
call tohtml#GetOption(user_settings,     'no_invalid', 0 )
call tohtml#GetOption(user_settings,   'whole_filler', 0 )
call tohtml#GetOption(user_settings,      'use_xhtml', 0 )
call tohtml#GetOption(user_settings,       'line_ids', user_settings.number_lines )
if user_settings.hover_unfold
let user_settings.dynamic_folds = 1
endif
if user_settings.ignore_folding && user_settings.dynamic_folds
let user_settings.dynamic_folds = 0
let user_settings.hover_unfold = 0
endif
if user_settings.dynamic_folds && user_settings.no_foldcolumn
let user_settings.hover_unfold = 1
endif
if user_settings.dynamic_folds
let user_settings.use_css = 1
else
let user_settings.no_foldcolumn = 1 " won't do anything but for consistency and for the test suite
endif
if !user_settings.use_css
let user_settings.no_pre = 1
endif
if user_settings.no_pre || !user_settings.use_css
let user_settings.pre_wrap=0
endif
if user_settings.no_pre == 0
call tohtml#GetOption(user_settings,
\ 'expand_tabs',
\ &expandtab || &ts != 8 || &vts != '' || user_settings.number_lines ||
\   (user_settings.dynamic_folds && !user_settings.no_foldcolumn))
else
let user_settings.expand_tabs = 1
endif
if exists("g:html_use_encoding") "{{{
let user_settings.encoding = g:html_use_encoding
let user_settings.vim_encoding = tohtml#EncodingFromCharset(g:html_use_encoding)
if user_settings.vim_encoding == ''
echohl WarningMsg
echomsg "TOhtml: file encoding for"
\ g:html_use_encoding
\ "unknown, please set 'fileencoding'"
echohl None
endif
else
if &l:fileencoding != '' 
if &l:buftype=='' || &l:buftype==?'help'
let user_settings.vim_encoding = &l:fileencoding
call tohtml#CharsetFromEncoding(user_settings)
else
let user_settings.encoding = '' " trigger detection using &encoding
endif
endif
if &l:fileencoding == '' || user_settings.encoding == ''
let user_settings.vim_encoding = &encoding
call tohtml#CharsetFromEncoding(user_settings)
endif
if user_settings.encoding == ''
let user_settings.vim_encoding = 'utf-8'
let user_settings.encoding = 'UTF-8'
echohl WarningMsg
echomsg "TOhtml: couldn't determine MIME charset, using UTF-8"
echohl None
endif
endif "}}}
let user_settings.prevent_copy = ""
if user_settings.use_css
if exists("g:html_prevent_copy")
if user_settings.dynamic_folds && !user_settings.no_foldcolumn && g:html_prevent_copy =~# 'f'
let user_settings.prevent_copy .= 'f'
endif
if user_settings.number_lines && g:html_prevent_copy =~# 'n'
let user_settings.prevent_copy .= 'n'
endif
if &diff && g:html_prevent_copy =~# 'd'
let user_settings.prevent_copy .= 'd'
endif
if !user_settings.ignore_folding && g:html_prevent_copy =~# 't'
let user_settings.prevent_copy .= 't'
endif
else
let user_settings.prevent_copy = ""
endif
endif
if empty(user_settings.prevent_copy)
let user_settings.no_invalid = 0
endif
if exists('g:html_id_expr')
let user_settings.id_suffix = eval(g:html_id_expr)
if user_settings.id_suffix !~ '^[-_:.A-Za-z0-9]*$'
echohl WarningMsg
echomsg '2html: g:html_id_expr evaluated to invalid string for HTML id attributes'
echomsg '2html: Omitting user-specified suffix'
echohl None
sleep 3
let user_settings.id_suffix=""
endif
else
let user_settings.id_suffix=""
endif
return user_settings
endif
endfunc "}}}
function! tohtml#CharsetFromEncoding(settings) "{{{
let l:vim_encoding = a:settings.vim_encoding
if exists('g:html_charset_override') && has_key(g:html_charset_override, l:vim_encoding)
let a:settings.encoding = g:html_charset_override[l:vim_encoding]
else
if l:vim_encoding =~ '^8bit\|^2byte'
let l:vim_encoding = substitute(l:vim_encoding, '^8bit-\|^2byte-', '', '')
endif
if has_key(g:tohtml#encoding_to_charset, l:vim_encoding)
let a:settings.encoding = g:tohtml#encoding_to_charset[l:vim_encoding]
else
let a:settings.encoding = ""
endif
endif
if a:settings.encoding != ""
let l:vim_encoding = tohtml#EncodingFromCharset(a:settings.encoding)
if l:vim_encoding != ""
let a:settings.vim_encoding = l:vim_encoding
endif
endif
endfun "}}}
function! tohtml#EncodingFromCharset(encoding) "{{{
if exists('g:html_encoding_override') && has_key(g:html_encoding_override, a:encoding)
return g:html_encoding_override[a:encoding]
elseif has_key(g:tohtml#charset_to_encoding, tolower(a:encoding))
return g:tohtml#charset_to_encoding[tolower(a:encoding)]
else
return ""
endif
endfun "}}}
let &cpo = s:cpo_sav
unlet s:cpo_sav
