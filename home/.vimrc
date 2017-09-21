" -----------------------------------------------------------------------------
" Vim profile
" Adrien Mahieux <adrien@mahieux.net>
" 
" Links
" - http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
" - http://vim.wikia.com/wiki/Copy_or_change_search_hit
"

"NeoBundle Scripts-----------------------------
if (0 == 1)
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
endif
"End NeoBundle Scripts-------------------------



" Syntax and load
syntax on
set ai
set modeline
colorscheme molokai

" indent
set tabstop=4
set softtabstop=4
set shiftwidth=4
set smartindent
set autoindent
set list!
set lcs=tab:>.,trail:.,extends:~

" Fix a 100% CPU hang with yaml files
set re=1

" Remap the leader key
let mapleader = "\<Space>"
nmap <Leader><Leader> V

" Search and replace
vnoremap <silent> s //e<C-r>=&selection=='exclusive'?'+1':''<CR><CR>
    \:<C-u>call histdel('search',-1)<Bar>let @/=histget('search',-1)<CR>gv
omap s :normal vs<CR>

" For the 'crap I forgot to run vim as sudo'
cmap w!! w !sudo tee % >/dev/null


" 80 & 120 column display
"let &colorcolumn=join(range(81,999),",")
let &colorcolumn="80,".join(range(120,999),",")
"highlight ColorColumn ctermbg=235 guibg=#2c2d27


" Infos options
set showmatch
set showcmd

" Auto-paste
let &t_SI .= "\<Esc>[?2004h"
let &t_EI .= "\<Esc>[?2004l"
inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

function! XTermPasteBegin()
	set pastetoggle=<Esc>[201~
	set paste
	return ""
endfunction

" Toggle shortcut
nnoremap <space> za

" Skeletton
au BufNewFile *.sh 0r ~/.vim/templates/bash.skel

" -----------------------------------------------------------------------------
