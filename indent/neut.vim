if exists('b:did_indent')
  finish
endif

function! s:get_indent(lnum)
  let l:line = getline(a:lnum)
  let l:stripped_line = substitute(l:line, "^\\(\\s\\||\\)*", "", "")
  echo(l:stripped_line)
  return strlen(l:line) - strlen(l:stripped_line)
endfunction

function! s:get_positive_offset(lnum)
  let l:line = getline(a:lnum)
  let l:stripped_line = substitute(getline(a:lnum), '//.*$', '', '')
  if l:stripped_line =~ '[({<\[=]\s*$'
    return shiftwidth()
  else
    return 0
  endif
endfunction

function! s:get_negative_offset(lnum)
  let l:line = getline(a:lnum)
  let l:stripped_line = substitute(getline(a:lnum), '//.*$', '', '')
  if l:stripped_line =~ '^\s*\([>})\]]\|in$\||\)'
    return -1 * shiftwidth()
  else
    return 0
  endif
endfunction

function! GetNeutIndent(lnum)
  let l:prevlnum = prevnonblank(a:lnum-1)
  if l:prevlnum == 0
    return 0
  else
    let s:prev_indent = s:get_indent(l:prevlnum)
    return s:prev_indent + s:get_positive_offset(l:prevlnum) + s:get_negative_offset(a:lnum)
  endif
endfunction

setlocal autoindent
setlocal expandtab
setlocal indentexpr=GetNeutIndent(v:lnum)
setlocal indentkeys=0{,0=},0(,0=),0[,0=],0=\|,*<Return>,*^J,o,O
setlocal nolisp
setlocal shiftwidth=2

let b:did_indent = 1
