scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim
if exists('g:loaded_searchcountbuf')
  finish
endif
let g:loaded_searchcountbuf = 1

if get(g:, 'searchcountbuf#auto_load', 1)
  call searchcountbuf#load()
endif

let &cpo = s:save_cpo
