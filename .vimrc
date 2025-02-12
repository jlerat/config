set nocompatible              " required
filetype off                  " required

set tabstop=4
set softtabstop=4
set shiftwidth=4
set textwidth=79
set expandtab
set autoindent
set nosmartindent
set fileformat=unix

" Get rid of white spaces
autocmd BufWritePre *.py :%s/\s\+$//e
autocmd BufWritePre *.pyx :%s/\s\+$//e
autocmd BufWritePre *.c :%s/\s\+$//e
autocmd BufWritePre *.h :%s/\s\+$//e

" Set encoding
set encoding=utf-8

" Pretty code
let python_highlight_all=1
syntax on

" Color management
set background=dark
colorscheme desert

" Line number
set nu

" Vim font
if has("gui_running")
  if has("gui_gtk2")
    set guifont=Inconsolata\ 12
  elseif has("gui_macvim")
    set guifont=Menlo\ Regular:h14
  elseif has("gui_win32")
    set guifont=Consolas:h11:cANSI
  endif
endif

" replace site pattern
let @z = ' / psay€kb€kb€kbat = f"lcaw'

"" set the runtime path to include Vundle and initialize

" Insert pdb command
:map! <F2> <C-R> import pdb; pdb.set_trace()<CR>
:map! <F3> <C-R> sys.exit()<CR>
:map! <F4> <C-R> import matplotlib.pyplot as plt<CR>
:map! <F5> <C-R> fig, ax = plt.subplots()<CR>

nmap <F6> i<C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR><Esc>
imap <F6> <C-R>=strftime("%Y-%m-%d %a %I:%M %p")<CR>

:map! <F8> <C-R> from termplot import lplot, splot<CR>

" Latex compile rule
let g:tex_flavor='latex'  
let g:Tex_CompileRule_pdf = 'pdflatex --synctex=-1 -src-specials -interaction=nonstopmode -file-line-error-style $*'
let g:Tex_DefaultTargetFormat='pdf'
let g:Tex_MultipleCompileFormats='pdf'
let g:Tex_DefaultTargetFormat='pdf'
let Tex_FoldedSections=""
let Tex_FoldedEnvironments=""
let Tex_FoldedMisc=""
let g:Imap_FreezeImap=1
autocmd bufreadpre *.tex setlocal textwidth=0

" Plugins
call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'nvie/vim-flake8'
" Plug 'JuliaEditorSupport/julia-vim'
call plug#end()

filetype indent off
