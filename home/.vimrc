" Vim profile
" Adrien Mahieux <adrien@mahieux.net>
" 
" Links
" - http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
" - http://vim.wikia.com/wiki/Copy_or_change_search_hit


"NeoBundle Scripts-----------------------------
if has('vim_starting')
  if &compatible
    set nocompatible               " Be iMproved
  endif

  " Required:
  set runtimepath+=/home/adrien/.vim/bundle/neobundle.vim/
endif

" Required:
call neobundle#begin(expand('/home/adrien/.vim/bundle'))

" Let NeoBundle manage NeoBundle
" Required:
NeoBundleFetch 'Shougo/neobundle.vim'

" Add or remove your Bundles here:
NeoBundle 'Shougo/neosnippet.vim'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'tpope/vim-fugitive'
NeoBundle 'ctrlpvim/ctrlp.vim'
NeoBundle 'flazz/vim-colorschemes'

" Added
NeoBundle 'trusktr/seti.vim'

" You can specify revision/branch/tag.
NeoBundle 'Shougo/vimshell', { 'rev' : '3787e5' }

" Required:
call neobundle#end()

" Required:
filetype plugin indent on

" If there are uninstalled bundles found on startup,
" this will conveniently prompt you to install them.
NeoBundleCheck
"End NeoBundle Scripts-------------------------





" Syntax and load
syn on
set ai
set modeline

" Tab spaces
set ts=4
set sts=4
set sw=4

" Remap the leader key
let mapleader = "\<Space>"
nmap <Leader><Leader> V

" Search and replace
vnoremap <silent> s //e<C-r>=&selection=='exclusive'?'+1':''<CR><CR>
    \:<C-u>call histdel('search',-1)<Bar>let @/=histget('search',-1)<CR>gv
omap s :normal vs<CR>

" For the 'crap I forgot to run vim as sudo'
cmap w!! w !sudo tee % >/dev/null


