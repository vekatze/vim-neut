if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

let s:offset = 2

let s:open  = ['(', '{', '[', '=', '<']
let s:close = [')', '}', ']', ';', '>']
let s:match = {'(':')', '{':'}', '[':']', '=':';', '<':'>'}

function! s:LineStartsWithCloser(line) abort
  let l = substitute(a:line, '^\s*', '', '')
  if l ==# '' | return v:false | endif
  let c = l[0]

  if index([')', '}', ']', ';', '|', '>'], c) >= 0
    return v:true
  endif

  return v:false
endfunction

function! FindParentOpener(lnum, col) abort
  let stack = []
  let lnum = a:lnum
  let col = a:col
  while lnum >= 1
    let line = getline(lnum)

    let comment_pos = match(line, '//')
    if comment_pos >= 0
      let line = line[0 : comment_pos - 1]
    endif

    let i = (lnum == a:lnum) ? col - 1 : strlen(line) - 1

    while i >= 0
      let ch = line[i]

      if ch ==# '>' && i > 0 && index(['=', '-'], line[i - 1]) >= 0
        let i -= 2 | continue
      elseif ch ==# '=' && i > 0 && line[i - 1] ==# ':'
        let i -= 2 | continue
      endif

      if index(s:close, ch) >= 0
        call add(stack, ch)
        let i -= 1 | continue
      endif

      if index(s:open, ch) >= 0
        while !empty(stack) && stack[-1] ==# ';' && ch !=# '='
          call remove(stack, -1)
        endwhile
        if !empty(stack) && get(s:match, ch, '') ==# stack[-1]
          call remove(stack, -1)
        else
          return lnum
        endif
      endif
      let i -= 1
    endwhile
    let lnum -= 1
  endwhile
  return -1
endfunction

function! FirstSignificantCharIndex(lnum) abort
  let line = getline(a:lnum)

  for i in range(0, len(line) - 1)
    let c = line[i]
    if c != ' ' && c != '|'
      return i
    endif
  endfor

  return 0
endfunction

function! GetNeutIndent(lnum) abort
  let line = getline(a:lnum)
  let plnum = FindParentOpener(a:lnum, 1)
  let parent_indent = (plnum > 0) ? FirstSignificantCharIndex(plnum) : (-1 * s:offset)
  if s:LineStartsWithCloser(line)
    return parent_indent
  endif

  return parent_indent + s:offset
endfunction

setlocal autoindent
setlocal expandtab
setlocal indentexpr=GetNeutIndent(v:lnum)
setlocal indentkeys=0{,0=},0(,0=),0[,0=],0=\|,*<Return>,*^J,o,O
setlocal nolisp
setlocal shiftwidth=2
