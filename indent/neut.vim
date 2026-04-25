if exists('b:did_indent')
  finish
endif
let b:did_indent = 1

let s:offset = 2

let s:match = {'(':')', '{':'}', '[':']', '=':';', '<':'>'}
let s:open_set = {'(': 1, '{': 1, '[': 1, '=': 1, '<': 1}
let s:close_set = {')': 1, '}': 1, ']': 1, ';': 1, '>': 1}
let s:token_pattern = '["`/(){}\[\]=;<>]'
let s:cache = {}

function! s:ClearCache(bufnr) abort
  if has_key(s:cache, a:bufnr)
    call remove(s:cache, a:bufnr)
  endif
endfunction

function! s:StructuralTail(lnum) abort
  return substitute(getline(a:lnum), '^\s*', '', '')
endfunction

function! s:NewCacheState() abort
  return {
        \ 'stack': [],
        \ 'stack_at': [[], []],
        \ 'parsed_lnum': 0,
        \ 'last_lnum': 0,
        \ 'last_tail': '',
        \ 'line_count': line('$'),
        \ 'tick': b:changedtick,
        \ }
endfunction

function! s:CacheState(lnum) abort
  let bufnr = bufnr('%')
  if !has_key(s:cache, bufnr)
    let s:cache[bufnr] = s:NewCacheState()
  endif

  let state = s:cache[bufnr]
  let sequential = a:lnum == get(state, 'last_lnum', 0) + 1
  if get(state, 'line_count', 0) != line('$')
    let state = s:NewCacheState()
    let s:cache[bufnr] = state
  elseif get(state, 'tick', -1) != b:changedtick && !sequential
    let state = s:NewCacheState()
    let s:cache[bufnr] = state
  elseif get(state, 'tick', -1) != b:changedtick && sequential
    if s:StructuralTail(state.last_lnum) !=# get(state, 'last_tail', '')
      let state = s:NewCacheState()
      let s:cache[bufnr] = state
    endif
  endif
  let state.tick = b:changedtick
  let state.last_lnum = a:lnum
  let state.last_tail = s:StructuralTail(a:lnum)

  return state
endfunction

function! s:LineStartsWithCloser(line) abort
  let l = substitute(a:line, '^\s*', '', '')
  if l ==# '' | return v:false | endif
  let c = l[0]

  if index([')', '}', ']', '|', '>'], c) >= 0
    return v:true
  endif

  return v:false
endfunction

function! s:PushLineTokens(stack, lnum) abort
  let line = getline(a:lnum)
  let i = 0
  let len = strlen(line)

  while i < len
    let i = match(line, s:token_pattern, i)
    if i < 0
      return
    endif

    let ch = line[i]
    if ch ==# '/' && i + 1 < len && line[i + 1] ==# '/'
      return
    elseif ch ==# '"' || ch ==# '`'
      let quote_pat = ch ==# '"' ? '["\\]' : '[`\\]'
      let i += 1
      while i < len
        let i = match(line, quote_pat, i)
        if i < 0
          return
        elseif line[i] ==# "\\"
          let i += 2
        else
          let i += 1
          break
        endif
      endwhile
      continue
    elseif ch ==# '>' && i > 1 && line[i - 1] ==# '>' && index(['=', '-'], line[i - 2]) >= 0
      " Skip the final '>' in ->> and =>>.
    elseif ch ==# '>' && i > 0 && index(['=', '-'], line[i - 1]) >= 0
      " Skip the final '>' in -> and =>.
    elseif ch ==# '=' && i > 0 && line[i - 1] ==# ':'
      " Skip the '=' in named-argument/default-argument bindings.
    elseif ch ==# '=' && i + 1 < len && line[i + 1] ==# '>'
      " Skip the '=' in => and =>>.
    elseif has_key(s:open_set, ch)
      call add(a:stack, [ch, a:lnum])
    elseif has_key(s:close_set, ch)
      if !empty(a:stack) && get(s:match, a:stack[-1][0], '') ==# ch
        call remove(a:stack, -1)
      endif
    endif

    let i += 1
  endwhile
endfunction

function! s:StackAtLineStart(state, lnum) abort
  if a:lnum < len(a:state.stack_at)
    return a:state.stack_at[a:lnum]
  endif

  while a:state.parsed_lnum < a:lnum - 1
    let next_lnum = a:state.parsed_lnum + 1
    call s:PushLineTokens(a:state.stack, next_lnum)
    let a:state.parsed_lnum = next_lnum
    call add(a:state.stack_at, deepcopy(a:state.stack))
  endwhile

  return a:lnum < len(a:state.stack_at) ? a:state.stack_at[a:lnum] : []
endfunction

function! s:ParentLine(state, lnum) abort
  let stack = s:StackAtLineStart(a:state, a:lnum)
  if empty(stack)
    return -1
  endif

  return stack[-1][1]
endfunction

function! s:FirstSignificantCharIndex(lnum) abort
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
  let state = s:CacheState(a:lnum)
  let line = getline(a:lnum)
  let plnum = s:ParentLine(state, a:lnum)
  let parent_indent = (plnum > 0) ? s:FirstSignificantCharIndex(plnum) : (-1 * s:offset)
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

augroup neut_indent_cache
  autocmd! * <buffer>
  autocmd TextChanged,TextChangedI <buffer> call <SID>ClearCache(bufnr('%'))
augroup END

let b:undo_indent = 'setlocal autoindent< expandtab< indentexpr< indentkeys< lisp< shiftwidth< | autocmd! neut_indent_cache * <buffer>'
