scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! searchcountbuf#load() abort
  let s:changed = 0

  augroup searchcountbuf
    autocmd!
    " XXX @/ is not yet updated at CmdlineLeave
    " autocmd CmdlineLeave [/?]     call s:update_search_count()
    autocmd CmdlineLeave   [/?]     call timer_start(0, {-> s:update_search_count(0)})
    autocmd TextChanged    *        call s:update_search_count(0)
    autocmd TextChangedI,TextChangedP * let s:changed = 1
    autocmd InsertLeave               *
    \ if s:changed                    |
    \   call s:update_search_count(0) |
    \   let s:changed = 0             |
    \ endif
    autocmd OptionSet      hlsearch call s:update_search_count(1)
  augroup END
endfunction

function! s:update_search_count(allwin) abort
  if &hlsearch
    " TODO keepmarks keepjumps
    let n = matchstr(execute('%s//&/gne', 'silent'), '\d\+')
    normal! ``
    let w:searchcountbuf_statusline_searchcount = n !=# '' ? n : 'no'
  else
    unlet! w:searchcountbuf_statusline_searchcount
  endif
  let w:searchcountbuf_statusline_searchword = @/
  execute 'redrawstatus' . (a:allwin ? '!' : '')
endfunction

" Show the number of a current searching word *except* the following cases:
" * 'hlsearch' is off
" * A search (/,?) has not been done yet after :nohlsearch is done and 'viminfo' contains 'h' flag (:h viminfo-h)
" * A buffer is a terminal window
" * A buffer is not a current buffer
"
" Note that it can make a search for different word for each window of the same buffers.
" FIXME ...but 'hlsearch' and searching text (@/) are global option and variable.
" Searching different word in the another window (the same buffer) makes the current window's highlight also change.
function! searchcountbuf#string() abort
  if !exists('w:searchcountbuf_statusline_searchcount') ||
  \   term_getstatus(bufnr('')) ==# 'running' ||
  \   bufnr('') !=# g:actual_curbuf
    return ''
  endif
  " Show word when any window(s) show the same buffer for different word
  let word = ''
  if has_key(w:, 'searchcountbuf_statusline_searchword') && len(filter(tabpagebuflist(), {_,nr -> nr ==# bufnr('')})) >=# 2
    let word = ' for ' . w:searchcountbuf_statusline_searchword
  endif
  return printf('(%s matches%s)', w:searchcountbuf_statusline_searchcount, word)
endfunction


let &cpo = s:save_cpo
