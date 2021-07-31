"=============================================================================
" FILE: ddc.vim
" AUTHOR: Shougo Matsushita <Shougo.Matsu at gmail.com>
" License: MIT license
"=============================================================================

let s:root_dir = fnamemodify(expand('<sfile>'), ':h:h')

function! ddc#enable() abort
  if v:version < 802 && !has('nvim-0.5')
    call ddc#util#print_error(
          \ 'ddc requires Vim 8.2+ or neovim 0.5.0+.')
    return
  endif

  " Note: ddc.vim must be registered manually.
  augroup ddc
    autocmd!
    autocmd User DenopsReady call denops#plugin#register('ddc',
          \ denops#util#join_path(s:root_dir, 'denops', 'ddc', 'app.ts'))
  augroup END
endfunction

function! ddc#complete() abort
  call ddc#_clear()

  inoremap <silent> <Plug>_ <C-r>=ddc#_complete()<CR>

  set completeopt-=longest
  set completeopt+=menuone
  set completeopt-=menu
  set completeopt+=noselect

  call feedkeys("\<Plug>_", 'i')
  return ''
endfunction

function! ddc#_complete() abort
  if g:ddc#_complete_pos >= 0
    call complete(g:ddc#_complete_pos + 1, g:ddc#_candidates)
  endif

  return ''
endfunction

function! ddc#_clear() abort
  if !exists('*nvim_buf_set_virtual_text')
    return
  endif

  if !exists('s:ddc_namespace')
    let s:ddc_namespace = nvim_create_namespace('ddc')
  endif

  call nvim_buf_clear_namespace(bufnr('%'), s:ddc_namespace, 0, -1)
endfunction

function! ddc#_inline() abort
  if !exists('*nvim_buf_set_virtual_text')
    return
  endif

  if !exists('s:ddc_namespace')
    let s:ddc_namespace = nvim_create_namespace('ddc')
  endif

  if empty(g:ddc#_candidates)
    call nvim_buf_clear_namespace(bufnr('%'), s:ddc_namespace, 0, -1)
  else
    call nvim_buf_set_virtual_text(
          \ bufnr('%'), s:ddc_namespace, line('.') - 1,
          \ [[g:ddc#_candidates[0].abbr, 'PmenuSel']], {})
  endif
endfunction

function! ddc#register_source(dict) abort
  if !exists('g:ddc#_initialized')
    execute printf('autocmd User DDCReady call ' .
          \ 'denops#request_async("ddc", "registerSource", [%s], '.
          \ '{-> v:null}, {-> v:null})', a:dict
          \ )
  else
    call denops#request_async(
          \ 'ddc', 'registerSource', [a:dict], {-> v:null}, {-> v:null})
  endif
endfunction
function! ddc#register_filter(dict) abort
  if !exists('g:ddc#_initialized')
    execute printf('autocmd User DDCReady call ' .
          \ 'denops#request("ddc", "registerFilter", [%s])', a:dict)
  else
    call denops#request('ddc', 'registerFilter', [a:dict])
  endif
endfunction

function! ddc#get_input(event) abort
  let mode = mode()
  if a:event ==# 'InsertEnter'
    let mode = 'i'
  endif
  let input = (mode ==# 'i' ? (col('.')-1) : col('.')) >= len(getline('.')) ?
        \      getline('.') :
        \      matchstr(getline('.'),
        \         '^.*\%' . (mode ==# 'i' ? col('.') : col('.') - 1)
        \         . 'c' . (mode ==# 'i' ? '' : '.'))

  return input
endfunction

function! ddc#insert_candidate(number) abort
  let word = get(g:ddc#_candidates, a:number, {'word': ''}).word
  if word ==# ''
    return ''
  endif

  " Get cursor word.
  let complete_str = ddc#get_input('')[g:ddc#_complete_pos :]
  return (pumvisible() ? "\<C-e>" : '')
        \ . repeat("\<BS>", strchars(complete_str)) . word
endfunction
