## About

[dotpkg] is a _dotfile package_ manager for *nix shell users.

## Quick Start

1. Choose a location in your home directory (or elsewhere) to store packages.

    ```
    mkdir -p ~/dotfiles/packages
    ```
2. Install [dotpkg]:

    ```
    git clone http://github.com/aghast/dotpkg ~/dotfiles/packages/dotpkg
    ```

3. Update your .profile, .bashrc, .login, or whatever startup file:

    Sample `.bashrc`:

    ```sh
    # ...

    # Load dotpkg {{{
    eval `$HOME/dotfiles/packages/dotpkg/dotpkg -s`

    # Let dotpkg manage dotpkg
    dotpkg 'aghast/dotpkg'
    # {{{

    # Dotfile packages {{{
    dotpkg 'bitbucket/foo/bar'
    dotpkg 'http://mycompany.com/gitrepo/a-package.git'
    # }}}
    ```

4. Install configured dotpkgs - open a new shell window (you may need a login window if you installed in a login-only script).

5. Profit!

## Why DotPkg?

[dotpkg] allows you to easily:

- install dotfile packages without having to think about how your files are organized
- clean up unused scripts and hacks
- ignore how the author's files are organized
- forget worrying about installing scripts in `~/bin` using cp, install, symlinks
- publish your clever dotfile ideas to others without a super-formal structure

## How it works

Say you have a really clever dotfile trick for your shell. You want to share this with others, but don't know how.

Make a directory - this will be your "project." Put the directory under control of your favorite VCS tool.

    ```sh
    ~$ mkdir coolidea
    ~/coolidea$ cd coolidea
    ~/coolidea$ git init
    Initialized empty Git repository in ~/coolidea/.git/
    (master) ~/coolidea$
    ```

Now, create a file called `autoload.sh` (or .bash, .csh, .ksh, .zsh) depending on the minimum shell required to use the script.
If you need it, you can also create `logout.sh` (or .bash, .csh, etc.) to run when the user logs out.

Once your script is set up, check in your changes and share them with the world.

    ```sh
    (master) ~/coolidea$ git commit -m "My gift to a grateful world"
    (master) ~/coolidea$ git push
    ```

Now other users can install and use your cool idea, without have to know anything about the implementation details. (That's _your_ problem!)

## Inspiration and Ideas

[dotpkg] was inspired directly by the awesome [Vundle] package by [gmarik]. Thanks, dude - you rock!

## Also

[dotpkg] was developed using [Vim] 7.3, using Bash on Mac OSX 10.8.4 (Mountain Lion).

## TODO:

* Port to other systems, particularly zsh.
* Add support for csh-variants.
* Add verbose mode to show package operations.

[dotpkg]:http://github.com/aghast/dotpkg
[Vim]:http://www.vim.org
[Vundle]:http://github.com/gmarik/vundle
[gmarik]:http://gmarik.info/about

