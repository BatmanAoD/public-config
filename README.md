public-config
=============

Various config files I want to keep synchronized between working environments. SHOULD NOT contain any proprietary code, OR any code that will be bundled with proprietary code.

config files included directly
-----------
 * .vimpagerrc
 * .vim73
 * .vimrc
 * .inputrc
 * .gdbinit
 * .i3/config -- should eventually be generated

config to eventually include directly
-----------

 * .Xkbmap -- currently, my Avago computer's settings are manually maintained
                using xkeycaps, a graphical keymapping editor; I should switch
                to using a single, synchronized .Xkbmap file.
 * .zshrc
 * git config file? Or should this be generated?

config files to eventually re-write as generated code
-----------
 * .i3/config
 * crontab (how to generate programmatically?)

other TODO items
-----------
 * one-stop-shopping: easy way to install/update all this stuff
 * bash autocomplete stuff (specifically, caps insensitivity and tab
    completion) doesn't seem to behave identically on laptop and work computer
