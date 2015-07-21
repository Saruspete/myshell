" Vim profile
" Adrien Mahieux <adrien@mahieux.net>
" 
" Links
" - http://sheerun.net/2014/03/21/how-to-boost-your-vim-productivity/
" - http://vim.wikia.com/wiki/Copy_or_change_search_hit


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

