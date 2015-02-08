# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
	. "$HOME/.bashrc"
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# ensure gsettings here , when override in /usr/share/glib-2.0/schemas/ may be not work
if [ -x "$HOME/.gsettings-override" ]; then
    . "$HOME/.gsettings-override"
    #只有第一次开机更改相关软件的默认设置，当用户通过设置界面重新修改后，以后开机并不会覆盖用户的设置
    chmod a-x "$HOME/.gsettings-override"
fi
