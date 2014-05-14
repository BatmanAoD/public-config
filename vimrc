"
" TODO fix the following problems (probably both related to QuitIfLastBuffer):
" * the close-when-last-buffer-is-closed autocommand appears to prevent opening
"   directories
" * in non-gui Vim, help window is apparently unavailable

set noerrorbells t_vb=
set hidden
" apparently not on by default in 7.4?
syntax enable
" fancier % matching
runtime macros/matchit.vim
" TODO: consider adding one of these as well:
" * https://github.com/nelstrom/vim-textobj-rubyblock
" * https://github.com/rhysd/vim-textobj-ruby
set hlsearch
set nocompatible
set showcmd
set ruler
set wildmenu
set wildmode=longest,list
" switch back to 'block' if this is too open-ended.
" alternatively, only set to 'all' if I'm editing a file with tabs.
" This would be easy since I already have the 'PickTabUsage' function.
function! TempNonVirtual()
    let g:oldvirtualedit=&virtualedit
    set virtualedit=
endfunction
" TODO: is there a better way to clean up than using two separate functions
" that must always be used in conjunction?
function! RestoreVirtual()
    let &virtualedit=g:oldvirtualedit
endfunction
set virtualedit=all
nnoremap <silent> <LeftMouse> :call TempNonVirtual()<CR><LeftMouse>:call RestoreVirtual()<CR>
" This works for most things, but is kind of stupid when the last character in
" the line is a tab.
nnoremap <silent> a :call TempNonVirtual()<CR>:call RestoreVirtual()<CR>a
" TODO: figure out a way to only enter insert mode if cursor is past
" end-of-line (something like getpos > col('$')), and to do the standard
" visual-mode word-highlight otherwise.
" TODO: figure out how to make this work...
" nnoremap <silent> <2-LeftMouse> <LeftMouse>i
set nostartofline

function! GenericFile()
    " is this what I want?
    setlocal ft=sh
    " Include - as a 'word' character
    set iskeyword+=-
endfunction
autocmd BufEnter * if &filetype == "" | :call GenericFile() | endif

" Single ~ acts like g~ by allowing motion commands
"   (so ~l acts like ~ does with notildeop)
" Actually, this is kind of annoying, because apparently I apply ~ to a single
" letter rather frequently.
" set tildeop
set incsearch
" Why is this even limited?
set undolevels=9999999999
if has('win32')
    set guifont=Consolas:h8:cANSI
elseif has('win32unix') " Cygwin
    " TODO get a better Cygwin font!
    set guifont=Fixed\ 10
else
    set guifont=DejaVu\ Sans\ Mono\ 10
    " set guifont=Liberation\ Mono\ 10
endif

" Don't use this; makes file recovery impossible
" set noswapfile

set ignorecase
set smartcase
nnoremap <Leader>c :set ignorecase!<cr>

" to get a one-off single replacement, use /g option
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
" after leaving insert mode, move cursor one position to the right.
" From http://unix.stackexchange.com/a/79083/38050
" Note: this is controversial. See
" http://unix.stackexchange.com/a/11403/38050.
" Also, this will put the cursor past the end of the line if virtualedit is
" on--which, in my setup, it is.
" Also also, after leaving an insert, 'p' will insert the text one character
" to the right of what's expected.
" This must be in a group with 'autocmd!' because otherwise it's cumulative
" every time this file is reloaded.
" ....sigh...finally, this doesn't work with vim-multiple-cursors. So, for
" now, just...don't use it.
augroup insertleave
    autocmd!
    " au InsertLeave * if (getpos('.')[2] > 1) | call cursor([getpos('.')[1], getpos('.')[2]+1])
augroup END
" expand tabs even when chars are shown explicitly; also show trailing spaces
" and end-of-line with 'set list'
set lcs=tab:»·,trail:¬
set backspace=indent,eol,start
" hopefully this will stop some of the 'Press Enter to continue' stuff.
" ....sadly, it looks like getting this message fairly frequently is
" unavoidable with i3.
set shortmess=at
" Vundle setup, taken from sample .vimrc on Vundle github page
" TODO: consider using NeoBundle instead: https://github.com/Shougo/neobundle.vim
filetype off
if has('win32')
    set rtp+=~/vimfiles/bundle/Vundle/
    let path='~/vimfiles/bundle'
    call vundle#begin(path)
else
    set rtp+=~/.vim/bundle/Vundle.vim/
    call vundle#rc()
endif
Bundle 'gmarik/vundle'

" Put new bundles here
Bundle 'nanotech/jellybeans.vim'
Bundle 'terryma/vim-multiple-cursors'
" This remaps '/', which makes it no longer a simple movement, which
" wrecks things like 'c\{pat}' and 'V\pat'. It probably also causes
" some slow-down when initiating a search. So I'm disabling it.
" Bundle 'SearchComplete'
Bundle 'sjl/gundo.vim.git'
Bundle 'sjl/clam.vim'
Bundle 'rkitover/vimpager'
Bundle 'tpope/vim-surround'
Bundle 'AndrewRadev/linediff.vim'
Bundle 'LargeFile'
" TODO figure out why this doesn't seem to work, or figure out a different
" 'tail-like' configuration
" Bundle 'Tail-Bundle'
" This *apparently* getting the right script (1928), but I don't know why it's
" not getting 3525. Numerical precedence, maybe? This is a known bug,
" unfortunately.
Bundle 'Rename'

" I really don't know why this is necessary in the Windows-native vim.
if has('win32')
    call vundle#end()
endif

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

" Mappings for use with plugins:
nnoremap <silent> <F5> :GundoToggle<CR>
" do a diff:
vnoremap <Leader>ld :Linediff<CR>
" start a diff and go to end of diff section:
vnoremap <Leader>ls :Linediff<CR>`>
" clear diff:
vnoremap <Leader>lc :LinediffReset<CR>
nnoremap <Leader>lc :LinediffReset<CR>

if ! has('win32')
    cmap <silent> w!! w !sudo tee > /dev/null %
endif

set nobackup
set nowritebackup
set nu
if has('wind32')
    let vim73file = expand("~/_vimrc73")
else
    let vim73file = expand("~/.vimrc73")
endif
if version >= 703 && filereadable(vim73file)
  exec ":source " . vim73file
endif

" Always use 4 columns for indentation.
set shiftwidth=4

" Don't get caught off-guard by tabs
function! Usetabs()
  " shiftwidth has to do with auto-indent & similar, NOT tabbing.
  " So keep 4 all the time.
  " set shiftwidth=8
  " Ensure that tabstop is 8, which shoudl be true already anyway.
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
        set lcs=tab:»·,trail:¬
    endif
endfunction
nnoremap <silent> <Leader>t :call Usetabs()<cr>
                  \:call Tabcolors()<cr>
function! Nousetabs()
  " shiftwidth has to do with auto-indent & similar, NOT tabbing.
  " So keep 4 all the time.
  " set shiftwidth=4
  " If there are already tabs in the file, I should probably keep
  " whatever tabstop I already have. If not, then it shouldn't matter.
  " set tabstop=4
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
nnoremap <silent> <Leader>n :call Nousetabs()<cr>
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
" re-source start-up file
" TODO: make this a clean start somehow?
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
" see http://vim.wikia.com/wiki/Recover_from_accidental_Ctrl-U
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
 nnoremap <silent> s :<C-U>exec "normal i".RepeatChar(nr2char(getchar()), v:count1)<CR>
 nnoremap <silent> S :<C-U>exec "normal a".RepeatChar(nr2char(getchar()), v:count1)<CR>

" somehow I got it into my head that these were the defaults anyway.
" nnoremap B _
" nnoremap E g_
" vnoremap B _
" vnoremap E g_

" for consistency with D and C
nnoremap Y y$

" For using visual mode to swap chunks of text:
" Delete one piece of text (using any kind of 'd' command), then visually
" select another piece of text, then press Ctrl-x to swap it with the last
" deleted text
" Taken from http://vim.wikia.com/wiki/Swapping_characters,_words_and_lines
vnoremap <C-X> <Esc>`.``gvP``P

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
" use three Q's to avoid trying to start a recording w/ qq and accidentally
" using caps
nnoremap QQQ :bd!<cr>
" because I often try to quit after highlighting/selecting
vnoremap :q <Esc>:q
vnoremap :WQ <Esc>:WQ<cr>
vnoremap QQQ <Esc>:bd!<cr>
" easily close all buffers
command! WQ :wqa
command! Q :qa

" for multi-cursor mode
nnoremap <C-m> :MultipleCursorsFind 
" not sure why this is necessary...why is this being mapped??
unmap <CR>
" TODO: open an issue in the vim-multiple-cursors repository

" always make your regex 'very magic'
" currently using this plugin instead:
" http://www.vim.org/scripts/script.php?script_id=4849
" TODO: since that plugin only works with 7.4+, enable these mappings for 
" earlier versions of Vim
" note that these remappings interfere with search-history
" nnoremap / /\v
" vnoremap / /\v
" cnoremap %s/ %smagic/
" cnoremap >s/ >smagic/
" nnoremap :g/ :g/\v
" nnoremap :g// :g//

" Vim's VeryMagic patterns treat '=' as a synonym for `?`. This is stupid.
" .....however, there's still no way to do a 'pattern-only' remapping...
" .....so this is too annoying to use.
" cnoremap = \=

" 'Fix' the weird \n vs \r discrepancy
" (credit: http://superuser.com/a/743087/199803 
" .....but the fancy regex is mine)
" Replaced by the 'VeryMagicSubstituteNormalise' option in EnchantedVim
" function! TranslateBackslashN()
"     if getcmdtype() ==# ':' && getcmdline() =~#
"       \ '[%>]s\([um]\w*\)\?\(.\).\{-}\(\\\)\@<!\2.*\\$'
"         return getcmdline() . 'r'
"     endif
"     return getcmdline() . 'n'
" endfunction
" cnoremap n <C-\>eTranslateBackslashN()<CR>

" quick filewide search and replace; recursive to take advantage of 'magic'
" remapping
" TODO: should I make this non-recursive now that I'm using the 'enchanted'
" plugin?
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

function! ToggleGuiScroll()
    if(&guioptions =~# 'r')
        set guioptions-=r
        echo "scroll off"
    else
        set guioptions+=r
        echo "scroll on"
    endif
endfunction

" If file is very large, show scrollbar
function! ScrollLarge()
    if ! has("gui_running")
        return
    endif
    if line('$') > 1000
        set guioptions+=r
    else
        set guioptions-=r
    endif
endfunction

augroup guiopts
    autocmd BufEnter * :call ScrollLarge()
    autocmd GUIEnter * nnoremap <Leader>s :call ToggleGuiScroll()<cr>
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
