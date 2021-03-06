CCode - An autocompletion daemon for the C programming language.


1. Relies on the C99 compliance (flexible array members, snprintf behaviour, etc).
2. Mostly done, but has few quirks.
3. Can be used to complete C++/ObjC, but I'm not targeting these languages. Don't report C++/ObjC specific bugs.
4. Currently only per directory CFLAGS configuration (just dump your CFLAGS to .ccode file). CCode supports shell expansion, e.g. `echo "\$(pkg-config --cflags sdl)" > .ccode` will execute pkg-config with each autocompletion request.
5. Should work on both 32 and 64 bit machines.

![screenshot CCode in VIM](http://pic4net.com/di-N55HM1.png)


Manual Installation
-------------------
0. Install llvm throu `brew install llvm` and add it to PATH (read output)
1. Build everything `make`
2. Instal `sudo make install` (default /usr/local/bin)
3. Install vim plugin `cp plugin/ccode.vim ~/.vim/plugin/`
4. Daemon starts automatically, everything should work out of the box.
5. Plugin automatic open autocompletion after type <kdb>:</kdb>, <kdb>.</kdb>, <kdb>-></kdb> or use <C-x><C-o> for autocompletion.


Files
-----
 - `ccode.py` — Sublime Text 2 Plugin for completion code
 - `plugin/ccode.vim` — VIM Plugin for completion code
 - `ccode` — Client/Server program for generate completions


FAQ
---
> My linux distribution contains broken LLVM/clang build and clang doesn't see its include directory (/usr/lib/clang/2.8/include). What should I do?

In your project dir: `echo " -I/usr/lib/clang/2.8/include" >> .ccode`.

> How disable autmatic completion after <kdb>:</kdb>, <kdb>.</kdb>, <kdb>-></kdb>?

Put `g:ccode_auto = 0` in you .vimrc
