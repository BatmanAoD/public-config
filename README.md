public-config
=============

Various config files I want to keep synchronized between working environments. SHOULD NOT contain any proprietary code, OR any code that will be bundled with proprietary code.

Also contains various general-use scripts; 

config files included directly
-----------
 * .vimpagerrc
 * .vim73
 * .vimrc
 * .inputrc
 * .gdbinit
 * .i3/config -- should eventually be generated
 * Various general-use scripts, which should be linked to in ~/bin; not
        exactly "config" files, but still used to configure a standardized
        working environment

config to eventually include directly
-----------

 * .Xkbmap -- currently, my Avago computer's settings are manually maintained
                using xkeycaps, a graphical keymapping editor; I should switch
                to using a single, synchronized .Xkbmap file.
                The one currently in the project is from my home Linux machine,
                and unfortunately it merely switches caps-lock with Esc rather
                than mapping Esc to Enter.
 * .zshrc
 * git config file? Or should this be generated?

config files to eventually re-write as generated code
-----------
 * .i3/config
 * crontab (how to generate programmatically?)

other TODO items
-----------
 * one-stop-shopping: easy way to install/update all this stuff
 * file or set of files just containing variables for options that should be
    easy to change without digging through code and adjusting multiple things 
    (e.g. setting primary editor to be Vim, Emacs, or Sublime)
 * bash autocomplete stuff (specifically, caps insensitivity and tab
    completion) doesn't seem to behave identically on laptop and work computer
