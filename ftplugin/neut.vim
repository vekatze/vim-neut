if exists('b:did_ftplugin')
  finish
endif

let b:did_ftplugin = 1

function! s:InsertBar() abort
  let l:lnum = line('.')
  let l:line = getline(line('.'))
  let l:col = col('.')
  if l:line =~ '^\s*$'
    call setline(l:lnum, l:line . '| ')
    silent! normal! ==
    call cursor(l:lnum, col('$'))
  else
    let l:prefix = strpart(l:line, 0, l:col - 1)
    let l:suffix = strpart(l:line, l:col - 1)
    call setline(l:lnum, l:prefix . '|' . l:suffix)
    call cursor(l:lnum, l:col + 1)
  endif
endfunction

setlocal commentstring=//\ %s
setlocal comments=://
setlocal iskeyword=@,48-57,_,192-255,-,.

inoremap <buffer> <Bar> <C-o>:call <SID>InsertBar()<CR>

let b:undo_ftplugin = 'setlocal commentstring< comments< iskeyword< | silent! iunmap <buffer> <Bar>'
