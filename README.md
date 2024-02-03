# EmacsDaemon

## About

This is an menubar status item to start an Emacs daemon for emacsclient to connect to.

## Configuration

I use this app as a login item so that I get an Emacs daemon automatically started after restarting and logging in.  When opening a new Emacs frame from this item, it looks for a socket at `~/.emacs.d/server/server`.  My emacs configuration has `server-socket-dir` defined accordingly.  My shell configuration defines `EMACS_SERVER_FILE` to this location, as well.

This app's path to Emacs is hardcoded, and assumes an Emacs.app has been installed to your `/Applications` folder.
