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
set guifont=DejaVu\ Sans\ Mono\ 12

"" set the runtime path to include Vundle and initialize

" Insert pdb command
:map! <F2> <C-R> import pdb; pdb.set_trace()<CR>
:map! <F3> <C-R> sys.exit()<CR>
:map! <F4> <C-R> import matplotlib.pyplot as plt<CR>
:map! <F5> <C-R> from hydrodiy.plot import putils<CR>
:map! <F6> <C-R> fig, axs = putils.get_fig_axs()<CR>

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
