if exists('b:did_ftplugin')
  finish
endif

function! InsertBar()
  let l:line = getline(line('.'))
  if l:line =~ '^\s*$'
    call setline('.', l:line . '| ')
  else
    let l:prefix = strpart(line, 0, col('.') - 1)
    let l:suffix = strpart(line, col('.') - 1)
    call setline('.', l:prefix . '|' . l:suffix)
  endif
endfunction

setlocal iskeyword=@,48-57,_,192-255,-

inoremap <buffer> \| <ESC>:call InsertBar()<CR>==a

let b:did_ftplugin = 1
