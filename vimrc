" Functions and commands are defined with '!' to avoid errors when re-sourcing
"
" TODO fix the following problems:
" * the close-when-last-buffer-is-closed autocommand appears to prevent opening
"   directories
" * in non-gui Vim, help window is apparently unavailable

set noerrorbells t_vb=
set hidden
" apparently not on by default in 7.4?
syntax enable
set hlsearch
set nocompatible
set showcmd
set ruler
set wildmenu
set wildmode=longest,list
set virtualedit=block
set nostartofline
" Include - as a 'word' character
set iskeyword+=-
set incsearch
set guifont=DejaVu\ Sans\ Mono\ 10
" set guifont=Liberation\ Mono\ 10

" Don't use this; makes file recovery impossible
" set noswapfile
" turn this back off if I prefer to always specify case insensitivity w/ \c
set ignorecase
set smartcase
" turn this back off if I start making accidental replacements
" (to get a one-off single replacement, use /g option)
set gdefault
" I don't use vim splits that much, but in any case...
set splitbelow
set splitright
" Figure out what the right behavior is...don't want unintended linebreaks, e.g.
" when editing a long path in a bash script.
" set tw=80
set ww=h,l,<,>
" start scrolling 5 lines from edge of screen
set scrolloff=5
" expand tabs even when chars are shown explicitly; also show trailing spaces
" and end-of-line with 'set list'
set lcs=tab:��,trail:�
set backspace=indent,eol,start
" hopefully this will stop some of the 'Press Enter to continue' stuff.
set shortmess=at
let g:jellybeans_overrides = {
\   'cursor':       { 'guifg': '151515', 'guibg': 'b0d0f0' },
\   'statement':    { 'guifg': '57D9C7' },
\   'SpecialKey':   { 'guifg': 'FFFA00' },
\   'NonText':      { 'guifg': '444499' },
\   'Todo':         { 'guibg': '772222' },
\}
if has('gui_running')
    colors jellybeans
    set enc=utf-8
    set mouse=a
else
    colors torte
    set mouse=
endif
" Vundle setup, taken from sample .vimrc on Vundle github page
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'

" Put new bundles here
Bundle 'terryma/vim-multiple-cursors'
Bundle 'SearchComplete'
Bundle 'sjl/gundo.vim.git'
Bundle 'sjl/clam.vim'
Bundle 'rkitover/vimpager'
Bundle 'tpope/vim-surround'

filetype plugin indent on     " required!
"
" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install(update) bundles
" :BundleSearch(!) foo - search(or refresh cache first) for foo
" :BundleClean(!)      - confirm(or auto-approve) removal of unused bundles
"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle command are not allowed..

" source $VIMRUNTIME/mswin.vim

" TODO learn to use this...
nnoremap <F5> :GundoToggle<CR>

cmap w!! w !sudo tee > /dev/null %

set nobackup
set nowritebackup
set nu
let vim73file = expand("~/.vimrc73")
if version >= 703 && filereadable(vim73file)
  source ~/.vimrc73
endif

" Don't get caught off-guard by tabs
function! Usetabs()
  set shiftwidth=8
  set tabstop=8
  set noexpandtab
  " if I'm using tabs, LOOK AT THEM.
  set list
endfunction
" Once I've acknowledged that tabs are in use, make the colors quieter.
" Trailing spaces are in the same category as tabs are, so they'll get dimmer
" too. One way to deal with this would be to show the eol character.
" However, the eol character is still annoying, so don't bother.
" TODO: can I make the syntax color category for trailing spaces be something
" else, instead?
function! Tabcolors()
    if has('gui_running')
        let g:jellybeans_overrides.SpecialKey = {'guifg':'444444'}
        let g:jellybeans_overrides.NonText    = {'guifg':'7777CC'}
        colors jellybeans
    else
        set lcs=tab:��,trail:�
    endif
endfunction
nnoremap <Leader>t :call Usetabs()<cr>
                  \:call Tabcolors()<cr>
function! Nousetabs()
  set shiftwidth=4
  set tabstop=4
  set expandtab
  " still might want to see trailing spaces.
  " set nolist
endfunction
function! Nontabcolors()
    if has('gui_running')
        let g:jellybeans_overrides.SpecialKey = {'guifg':'FFFA00'}
        let g:jellybeans_overrides.NonText    = {'guifg':'444499'}
        colors jellybeans
    else
        set nolist
    endif
endfunction
nnoremap <Leader>n :call Nousetabs()<cr>
                  \:call Nontabcolors()<cr>
function! Untab()
  set expandtab
  retab
endfunction
" Either way, this is convenient
set softtabstop=4

" exit vim when exiting last buffer
" stolen from
" http://vim.1045645.n5.nabble.com/buffer-list-count-td1200936.html
" TODO: figure out why this causes problems with directory-viewer, etc
function! CountNonemptyBuffers()
    let cnt = 0
    for nr in range(1,bufnr("$"))
        if buflisted(nr) && ! empty(bufname(nr)) || ! empty(getbufvar(nr, '&buftype'))
            let cnt += 1
        endif
    endfor
    return cnt
endfunction
function! QuitIfLastBuffer()
    if CountNonemptyBuffers() == 1
        :q
    endif
endfunction
augroup closebuf
    autocmd BufDelete * :call QuitIfLastBuffer()
augroup END
 " one-line version from http://superuser.com/a/668612/199803
 " autocmd BufDelete * if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 2 | quit | endif

function! PickTabUsage()
    if &readonly || ! &modifiable
        set nolist
        set tabstop=8
    else
        if search('\t','nw') > 0
            call Usetabs()
        else
            call Nousetabs()
        endif
    endif
endfunction

" hm....is this actually a good idea?
nnoremap <Space> :

" every time I change buffers or reload file, check if I need to use tabs
augroup autotabs
    autocmd BufEnter * :call PickTabUsage()
    autocmd BufRead * :call PickTabUsage()
augroup END

nnoremap <Leader>w :set wrap!<cr>

" quick uniquification
nnoremap <Leader>u :sort u<cr>

" edit this file without using the edit menu
nnoremap <Leader>v :e $MYVIMRC<cr>
" resource start-up file
nnoremap <Leader>r :so $MYVIMRC<cr>

" '/asdf' works but is kind of stupid and annoying
nnoremap <Leader>h :noh<cr>

" Quickly font bigger/smaller
nnoremap <Leader>= :set guifont=DejaVu\ Sans\ Mono\ 18<cr>
nnoremap <Leader>- :set guifont=DejaVu\ Sans\ Mono\ 10<cr>

inoremap <C-BS> <C-W>
inoremap <C-Del> <C-O>dw
nnoremap <C-BS> <C-W>
nnoremap <C-Del> <C-O>dw

inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>

" Easily recover from accidental deletions
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

" Always show full path
nnoremap <C-g> 1<C-g>

" b/c I do like digraphs, but I'm using c-k for 'up'
inoremap <C-d> <C-k>

" b/c I don't use the default behavior anyway
nnoremap <C-k> <Up>
nnoremap <C-l> <Right>

" for single-character entry
" from http://vim.wikia.com/wiki/Insert_a_single_character
function! RepeatChar(char, count)
   return repeat(a:char, a:count)
 endfunction
 nnoremap s :<C-U>exec "normal i".RepeatChar(nr2char(getchar()), v:count1)<CR>
 nnoremap S :<C-U>exec "normal a".RepeatChar(nr2char(getchar()), v:count1)<CR>

" somehow I got it into my head that these were the defaults anyway.
nnoremap B _
nnoremap E g_
vnoremap B _
vnoremap E g_

" for consistency with D and C
nnoremap Y y$

" ex mode?? seriously?
nnoremap Q <nop>

" it's what all the cool people are doing...sort of.
" (not jj because repetition is hard)
" (not jk because that means 'just kidding' and
" because it's easier to roll from right to left)
" If this becomes a problem because of my initials,
" just remove or remap it.
inoremap kj <Esc>

" Easily write and exit buffers
function! WriteAndDelete()
  :w
  :bd
endfunction

command! Wd :call WriteAndDelete()

" save/quitting should be deliberate, and NEVER accidental
nnoremap ZZ <nop>
nnoremap ZQ <nop>
" harder to do accidentally, hopefully:
nnoremap WQ :Wd<cr>
" use three Q's to avoid trying to start a recording w/ qq and accidentally
" using caps
nnoremap QQQ :bd!<cr>
" because I often try to quit after highlighting/selecting
vnoremap :q<Enter> <Esc>:q<cr>
vnoremap WQ <Esc>:Wd<cr>
vnoremap QQQ <Esc>:bd!<cr>
" easily close all buffers
command! Q :qa

" for multi-cursor mode
nnoremap <C-m> :MultipleCursorsFind 
" not sure why this is necessary...why is this being mapped??
unmap <CR>

" always make your regex 'very magic'
nnoremap / /\v
cnoremap %s/ %s/\v
cnoremap >s/ >s/\v

" quick filewide search and replace; recursive to take advantage of 'magic'
" remapping
nmap <C-s> :%s/
" quick selection search and replace
vmap <C-s> :s/
" quick word count
nnoremap <C-c> :%s///n<cr>
inoremap <C-c> :%s///n<cr>

function! ToggleGuiMenu()
    if(&guioptions =~# 'm')
        set guioptions-=m
        echo "menu off"
    else
        set guioptions+=m
        echo "menu on"
    endif
endfunction

" If file is very large, show scrollbar
function! ScrollLarge()
    if ! has("gui_running")
        return
    endif
    if line('$') > 3000
        set guioptions+=r
    else
        set guioptions-=r
    endif
endfunction

augroup guiopts
    autocmd BufEnter * :call ScrollLarge()
    autocmd GUIEnter * set guioptions-=m
    autocmd GUIEnter * nnoremap <Leader>m :call ToggleGuiMenu()<cr>
    autocmd GUIEnter * set guioptions-=T
    autocmd GUIEnter * set guioptions+=c
    autocmd GUIEnter * set nomousehide
augroup END

" the following is from http://superuser.com/a/657733/199803
augroup matchperms
    au BufRead * let b:oldfile = expand("<afile>")
    au BufWritePost * if exists("b:oldfile") | let b:newfile = expand("<afile>") 
                \| if b:newfile != b:oldfile 
                \| silent echo system("chmod --reference=".b:oldfile." ".b:newfile) 
                \| endif |endif
augroup END

" Avago-specific config.
let avagovimfile = expand("~/.vimrc_avago")
if filereadable(avagovimfile)
    exec ":source " . avagovimfile
endif
