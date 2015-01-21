public-config
=============

Various config files I want to keep synchronized between working environments. SHOULD NOT contain any proprietary code, OR any code that will be bundled with proprietary code.

Also contains various general-use scripts.

config files included directly
-----------
 * most rc files of the form ~/.<type> are included in this directory simply
    as <type>. To set up for use, make symlinks to them, then prepend a `.`.
 * Note:
    * .Xmodmap -- Should probably be generated instead of included directly.
    * .Xkbmap -- DEPRECATED, but possibly I should update it to replace .Xmodmap,
                since apparently it's more portable.
 * Various general-use scripts, which should be linked to in ~/bin; not
        exactly "config" files, but still used to configure a standardized
        working environment

config to eventually include directly
-----------
 * git config file? Or should this be generated?

config files to eventually re-write as generated code
-----------
 * .i3/config
 * crontab (how to generate programmatically?)

other TODO items
-----------
 * one-stop-shopping: easy way to install/update all this stuff
 * use local variables in Bash functions!
 * file or set of files just containing variables for options that should be
    easy to change without digging through code and adjusting multiple things 
    (e.g. setting primary editor to be Vim, Emacs, or Sublime)
 * Refactor .vimrc to give it some organization

setup notes (delete once this is automated)
-----------
 * Vundle:
    `git clone https://github.com/gmarik/Vundle.vim.git /home/BatmanAoD/.vim/bundle/Vundle.vim`
