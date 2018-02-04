" TODO loooooots of this doesn't work with Vi (`vim-gtk` or similar must be
" installed). This is annoying when setting up a new machine/profile/etc.
"
" TODO: Look through some .vimrc files made by people who actually know what
" they're doing:
" * https://github.com/tpope/tpope/blob/master/.vimrc
" * https://github.com/garybernhardt/dotfiles/blob/master/.vimrc
" * https://github.com/nelstrom/dotfiles/blob/master/vimrc
" * https://bitbucket.org/sjl/dotfiles/src/1da770d23a2168f0e0c2e50d0d3e84e5c6d38d27/vim/vimrc?at=default&fileviewer=file-view-default

" Get rid of any existing mappings. (Must happen BEFORE trying to apply plugin
" mappings!!!!)
mapclear

" Trying to use the Git Bash shell has a weird problem--the version of Vim
" included with Git treats (escaped) spaces in the shell variable just fine,
" but native Vim/gVim tries to execute 'C:\Program' as a program. Bleargh.
if has('win32')
    set shell=$COMSPEC
endif

" This screws up the nvim-qt rtp setup.
if !has('nvim')
    " make sure runtimepath has default value
    set rtp&
endif
" create a variable to generically reference the location of vim files
let $VIMFILES=split(&rtp,",")[0]

" Setup plugin manager and load plugins
let pluginfile = expand("~/.vimrcplugins")
if !filereadable(pluginfile)
    let pluginfile = expand("~/_vimrcplugins")
endif
if filereadable(pluginfile)
    " Should plugins only be loaded once?
    " if !exists("g:pluginmgr_setup") && filereadable(pluginfile)
    exec ":source " . pluginfile
endif

" Colors and mouse settings (use jellybeans only if it's loaded as plugin;
" jellybeans only looks good when rich colors are available, which is true for
" gvim and nvim but not console-vim)
if has('gui_running') || has('nvim')
    try
        colors jellybeans
    catch
        colors torte
    endtry
        set enc=utf-8
        set mouse=a
else
    colors torte
    set mouse=
endif

set noerrorbells t_vb=
set hidden
syntax enable
" TEMPORARY fix for marco highlighting issue; see
" http://chat.stackexchange.com/rooms/21448/discussion-between-kyle-strand-and-josh-petrie
hi link cCppOut2 PreProc
" fancier % matching
runtime macros/matchit.vim
" TODO: consider adding one of these as well:
" * https://github.com/nelstrom/vim-textobj-rubyblock
" * https://github.com/rhysd/vim-textobj-ruby
set hlsearch
" TODO: there's a fair amount of 'trivial' setup here. Consider using this:
" https://github.com/tpope/vim-sensible
set nocompatible
set showcmd
set ruler
set wildmenu
set wildmode=longest,list
" Automatically change to directory of current file
set autochdir
" Automatic indent
filetype plugin indent on
" All indentation levels should be rounded to a multiple of shiftwidth
set shiftround
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
if has('win32')
    set clipboard=unnamed
else
    " XTerm clipboard setting
    set clipboard^=unnamedplus
endif

function! GenericFile()
    " is this what I want?
    setlocal ft=sh
    " TODO if name is 'README', set ft=markdown
    " Include - as a 'word' character
    set iskeyword+=-
endfunction

function! SetIndentWidth(spaces)
    let &tabstop=a:spaces
    let &shiftwidth=a:spaces
    let &softtabstop=a:spaces
endfunction

" My Cpp settings
function! CppFile()
    " I don't use tabs, but other people do.
    call SetIndentWidth(2)
    set tw=80
    set fo=tcrqnlj
endfunction

" why doesn't this work? Is there something similar that might?
" autocmd FileType "" | :call GenericFile() | endif
augroup filetypes
    " Use `sh` syntax highlighting for unknown filetypes
    autocmd FileType * if &filetype == ""
                        \| :call GenericFile()
                    \| endif
    " The number of indentation columns depends on the language, not on
    " tab usage
    au FileType * if &filetype == "cpp"
                   \| :call CppFile()
               \| else
                   \| :call SetIndentWidth(4)
               \| endif
    " Use markdown syntax for .txt files
    au FileType * if &filetype == "text"
                   \| :set syntax=markdown
                \| endif
augroup END


" Single ~ acts like g~ by allowing motion commands
"   (so ~l acts like ~ does with notildeop)
" Actually, this is kind of annoying, because apparently I apply ~ to a single
" letter rather frequently.
" set tildeop
set incsearch
" This limit exists to limit memory consuption.
set undolevels=90000
" For NeoVim, use ~/.config/nvim/ginit.vim.
" See https://github.com/equalsraf/neovim-qt/issues/213
if has('win32')
    silent! set guifont=Consolas:h8:cANSI
    " set guifont=Anonymous_Pro:h8:cANSI
" elseif has('win32unix') " Cygwin
"     " TODO get a better Cygwin font!
"     set guifont=Fixed\ 8
else
    set guifont=DejaVu\ Sans\ Mono\ 8
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
" Disabled for most files; see below for cpp.
" set tw=80
" Delete comment leader when joining lines
" Other `fo` options for Cpp are set by CppFile
set fo+=j
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
" This avoids most (...all?) of the 'press ENTER to continue' messages from
" simple operations like undo/redo.
set shortmess=aoOstT
if ! has('win32')
    cmap <silent> w!! w !sudo tee > /dev/null %
endif

set nobackup
set nowritebackup
set nu
set relativenumber

" Don't get caught off-guard by tabs
" Note that shiftwidth and softtabstop are set separately
function! Usetabs()
  " shiftwidth has to do with auto-indent & similar, NOT tabbing.
  " So keep 4 all the time.
  " Do NOT change tabstop.
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
    if has('gui_running') && exists("g:jellybeans_overrides")
        let g:jellybeans_overrides.SpecialKey = {'guifg':'444444'}
        let g:jellybeans_overrides.NonText    = {'guifg':'7777CC'}
        colors jellybeans
    else
        set lcs=tab:»·,trail:¬
    endif
endfunction
function! Nousetabs()
  " shiftwidth has to do with auto-indent & similar, NOT tabbing.
  " So keep 4 all the time.
  " If there are already tabs in the file, I should probably keep
  " whatever tabstop I already have. If not, then it shouldn't matter.
  set expandtab
  " still might want to see trailing spaces.
  " set nolist
endfunction
function! Nontabcolors()
    if has('gui_running') && exists("g:jellybeans_overrides")
        let g:jellybeans_overrides.SpecialKey = {'guifg':'FFFA00'}
        let g:jellybeans_overrides.NonText    = {'guifg':'444499'}
        colors jellybeans
    else
        set nolist
    endif
endfunction
function! ToggleTabs()
    if(&expandtab == 1)
        call Usetabs()
        call Tabcolors()
    else
        call Nousetabs()
        call Nontabcolors()
    endif
endfunction
nnoremap <leader>t :call ToggleTabs()<cr>
function! Untab()
  call Nousetabs()
  retab
endfunction

" exit vim when exiting last buffer
" courtesy of http://superuser.com/a/668612/199803
autocmd BufDelete * if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) == 2 | quit | endif

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
    autocmd BufEnter,BufRead * :call PickTabUsage()
augroup END

" map ctrl-Y to copy into system register
nnoremap <C-Y> "+y
vnoremap <C-Y> "+y
" map ctrl-P to paste from system register
nnoremap <C-P> "+p
vnoremap <C-P> "+p

nnoremap <Leader>w :set wrap!<cr>

" quick uniquification
nnoremap <Leader>u :sort u<cr>

" edit this file without using the edit menu
nnoremap <Leader>v :e $MYVIMRC<cr>
" re-source start-up file
" TODO: make this a clean start somehow?
nnoremap <Leader>re :so $MYVIMRC<cr>

" '/asdf' works but is kind of stupid and annoying
nnoremap <Leader>h :noh<cr>

" Quickly font bigger/smaller
" TODO: this currently only works on Linux w/ DejaVu Sans Mono installed.
nnoremap <Leader>= :set guifont=DejaVu\ Sans\ Mono\ 18<cr>
nnoremap <Leader>- :set guifont=DejaVu\ Sans\ Mono\ 10<cr>

" Quickly underline the current line
nmap <Leader>l yypV<C-s>./-/<CR>k<Leader>h

" TODO: add a quick way to show carriage returns;
" see http://stackoverflow.com/a/27259548/1858225

inoremap <C-BS> <C-W>
inoremap <C-Del> <C-O>dw
nnoremap <C-BS> <C-W>
nnoremap <C-Del> <C-O>dw

" Change one letter using 'x'
nnoremap cx cl

" In insert or command mode, move normally by using Ctrl
inoremap <C-h> <Left>
inoremap <C-j> <Down>
inoremap <C-k> <Up>
inoremap <C-l> <Right>
cnoremap <C-h> <Left>
cnoremap <C-j> <Down>
cnoremap <C-k> <Up>
cnoremap <C-l> <Right>

" In visual and normal mode, Ctrl+up/down moves to prev/next line with same
" indentation (see
" http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation)
"
" Jump to the next or previous line that has the same level or a lower
" level of indentation than the current line.
" exclusive (bool): true: Motion is exclusive
" false: Motion is inclusive
" fwd (bool): true: Go to next line
" false: Go to previous line
" lowerlevel (bool): true: Go to line with lower indentation level
" false: Go to line with the same indentation level
" skipblanks (bool): true: Skip blank lines
" false: Don't skip blank lines
function! NextIndent(exclusive, fwd, lowerlevel, skipblanks)
let line = line('.')
let column = col('.')
let lastline = line('$')
let indent = indent(line)
let stepvalue = a:fwd ? 1 : -1
while (line > 0 && line <= lastline)
    let line = line + stepvalue
    if ( ! a:lowerlevel && indent(line) == indent ||
        \ a:lowerlevel && indent(line) < indent)
    if (! a:skipblanks || strlen(getline(line)) > 0)
        if (a:exclusive)
        let line = line - stepvalue
        endif
        exe line
        exe "normal " column . "|"
        return
    endif
    endif
endwhile
endfunction
" Moving back and forth between lines of same or lower indentation.
nnoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
nnoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
nnoremap <silent> [L :call NextIndent(0, 0, 1, 1)<CR>
nnoremap <silent> ]L :call NextIndent(0, 1, 1, 1)<CR>
vnoremap <silent> [l <Esc>:call NextIndent(0, 0, 0, 1)<CR>m'gv''
vnoremap <silent> ]l <Esc>:call NextIndent(0, 1, 0, 1)<CR>m'gv''
vnoremap <silent> [L <Esc>:call NextIndent(0, 0, 1, 1)<CR>m'gv''
vnoremap <silent> ]L <Esc>:call NextIndent(0, 1, 1, 1)<CR>m'gv''
onoremap <silent> [l :call NextIndent(0, 0, 0, 1)<CR>
onoremap <silent> ]l :call NextIndent(0, 1, 0, 1)<CR>
onoremap <silent> [L :call NextIndent(1, 0, 1, 1)<CR>
onoremap <silent> ]L :call NextIndent(1, 1, 1, 1)<CR>

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

" When `put`ing text, automatically auto-indent it
" TODO: verify that this consistently works 'well enough.' In particular, I
" never want tabs to mysteriously appear in files that previously had no tabs.
" See http://vi.stackexchange.com/q/3452/1060
nnoremap p pV`]=
nnoremap P PV`]=

" For using visual mode to swap chunks of text:
" Delete one piece of text (using any kind of 'd' command), then visually
" select another piece of text, then press Ctrl-x to swap it with the last
" deleted text
" Taken from http://vim.wikia.com/wiki/Swapping_characters,_words_and_lines
vnoremap <C-X> <Esc>`.``gvP``P

" ex mode?? seriously?
nnoremap Q <nop>

" No `jk` or `kj` mapping for `Esc`, because remapping to CapsLock is more
" convenient anyway.

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
vnoremap <C-c> :%s///n<cr>
" Quick section-wide 'global'
vmap <C-g> :g/

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
    " (hopefully) temporarily disabled, because this causes undesired
    " window-resizing sometimes
    " autocmd BufEnter * :call ScrollLarge()
    autocmd GUIEnter * nnoremap <Leader>s :call ToggleGuiScroll()<cr>
    autocmd GUIEnter * set guioptions-=m
    autocmd GUIEnter * nnoremap <Leader>m :call ToggleGuiMenu()<cr>
    autocmd GUIEnter * set guioptions-=T
    autocmd GUIEnter * set guioptions+=c
    autocmd GUIEnter * set nomousehide
augroup END

" from http://superuser.com/a/657733/199803
if !has('win32')
    augroup matchperms
        au BufRead * let b:oldfile = expand("<afile>")
        au BufWritePost * if exists("b:oldfile") | let b:newfile = expand("<afile>") 
                    \| if b:newfile != b:oldfile 
                    \| silent echo system("chmod --reference=".b:oldfile." ".b:newfile) 
                    \| endif |endif
    augroup END
endif

" from http://stackoverflow.com/a/4294176/1858225
function! s:MkNonExDir(file, buf)
    if empty(getbufvar(a:buf, '&buftype')) && a:file!~#'\v^\w+\:\/'
        let dir=fnamemodify(a:file, ':h')
        if !isdirectory(dir)
            call mkdir(dir, 'p')
        endif
    endif
endfunction
augroup BWCCreateDir
    autocmd!
    autocmd BufWritePre * :call s:MkNonExDir(expand('<afile>'), +expand('<abuf>'))
augroup END

" If multiple buffers, vsplit them all
"vert sba

" From https://github.com/joeytwiddle/rc_files/blob/c8264794527c6be685829f08f63fd8dfa2903528/.vim/plugin/joeycommands.vim#L112-131
" Runs the given Ex command and pipes the output to the given shell command.
" For example: :PipeToShell syn | grep 'Declaration'
" I considered other names: CmdOut, PipeToShell
command! -nargs=+ -complete=command PipeCmd call s:PassVimCommandOutputToShellCommand(<q-args>)

function! s:PassVimCommandOutputToShellCommand(line)
        let vim_cmd = substitute(a:line, '\s*|.*', '', '')
        let shell_cmd = substitute(a:line, '^[^|]*|\s*', '', '')
        " TODO: We could redir to a local variable, to avoid clobbering the 'l' register.
        redir @l
                silent exe vim_cmd
        redir END
        " To pipe to a shell, the only way I thought of was to put the data into a fresh buffer, and then do :w !...
        new
        normal "lP
        exe 'w !'.shell_cmd
        " Undo the paste so bwipeout can drop the buffer without complaint
        normal u
        exe "bwipeout"
endfunction

" Leave insert mode to the *right* of the final location of the insertion
" pointer
" From http://vim.wikia.com/wiki/Prevent_escape_from_moving_the_cursor_one_character_to_the_left
let CursorColumnI = 0 "the cursor column position in INSERT
autocmd InsertEnter * let CursorColumnI = col('.')
autocmd CursorMovedI * let CursorColumnI = col('.')
autocmd InsertLeave * if col('.') != CursorColumnI | call cursor(0, col('.')+1) | endif

" Useful if not using gVim
" TODO: figure out how to turn off the RelativeFocus autogroup once I've
" used this function to take manual control of this feature.
function! ToggleRelativeNumbering()
    if(&relativenumber == 1)
        set norelativenumber
    else
        set relativenumber
    endif
endfunction
nnoremap <Leader>n :call ToggleRelativeNumbering()<cr>

augroup RelativeFocus
    if has('win32unix') 
        " With XWin, 'focus lost' apparently only occurs when a *different*
        " X window gains focus. So here's a lame but hopefully good-enough
        " alternative.
        au CursorHold * :set norelativenumber
        au CursorMoved * :set relativenumber
    else
        au FocusLost * :set norelativenumber
        au FocusGained * :set relativenumber
    endif
augroup END

" using logic from http://stackoverflow.com/a/9528322/1858225
if exists("+undofile")
    set undodir=$VIMFILES/undodir/
    if isdirectory(expand(&undodir)) == 0
        :silent call mkdir(expand(&undodir), '-p')
    endif
    set undofile
    set undolevels=90000 "maximum number of changes that can be undone
    set undoreload=10000 "maximum number lines to save for undo on a buffer reload
endif
