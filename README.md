public-config
=============

Various config files I want to keep synchronized between working environments. SHOULD NOT contain any proprietary code, OR any code that will be bundled with proprietary code.

Also contains various general-use scripts.

Installation instructions
-----------
You may get more out of these scripts if you "cherry-pick" them for individual features you want, especially if you already have your own set of config files that you typically use.

However, if you do not already have your own config files you'd like to preserve, you should be able to get essentially the same setup used by BatmanAoD by issuing the following commands on a Linux box. (Note: I've done this successfully several times in Linux, but only a few times with Cygwin, so Windows users may not get a working install out of the box.)
```
git clone https://github.com/BatmanAoD/public-config ~/public-config
~/public-config/install
```
Note that the `install` script does **not** automatically replace existing `rc` scripts, so you may need to delete them (e.g. `rm -f ~/.bashrc`) first.

To install tools (`stderred`, `rustc`/`cargo`, etc), use `install --tools`.

The `bashrc` file here assumes that `stderred` is installed in `/usr/lib/stderred`, which is a **shared** location (and therefore requires root permission, e.g. through `sudo`, for installation). Every time the `bashrc` file is loaded, if `stderred` is not found in the expected location, it will issue a warning that cites the URL of the `stderred` GitHub repo.

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
 * use local variables in Bash functions!
 * file or set of files just containing variables for options that should be
   easy to change without digging through code and adjusting multiple things
   (e.g. setting primary editor to be Vim, Emacs, or Sublime)
 * Refactor .vimrc to give it some organization
 * Sandbox setup with makefile, inspired by http://stackoverflow.com/a/32485029/1858225
   * To check whether c++14, etc is supported:
     ```
     g++ -std=c++14 2>&1 | grep -q 'unrecognized command line'
     ```
