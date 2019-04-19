# 
Terminal Paint can be run in 3 different modes
* terminal_paint --ncurses
* terminal_paint --tty-cursor
* terminal_paint --basic

## 1. terminal_paint --ncurses  
#### Interactive terminal application using curses gem / libncursesw5-dev. 
Utilizes the `curses` gem for managing the terminal alternate screen. 
The gem is a wrapper around the ubiquitous ncurses library available on several nix platforms and on windows with mingw
There are two versions of this library: ncurses and ncursesw.
The gem needs to be compiled with the `ncursesw` package otherwise unicode characters will not render properly.
You can install ncursesw on ubuntu by running `sudo apt install libncursesw5-dev`
Using
Windows users can install MinGW. This should have already been installed along with a ruby MRI windows installation  

## 2. terminal_paint --basic 
#### Simple REPL 
Non interactive Terminal paint without any app chrome. Provided as a fallback when facing compatibility issues.

## 1. terminal_paint --tty-cursor
#### Interactive terminal using manually printed ANSI Control Sequence Introducer (CSI) commands
Provided as a fallback for environmments that can't utilize the `curses` gem (i.e newer versions of jruby with no support for native c extensions). Utilizes the tty-reader, tty-cursor gems 

# Common Requirements
* jruby-9.2.6.0 (other versions might work, but this version has been tested)
* linux based os. Tested on native Ubuntu and Windows Subsystem for Linux Ubuntu. ANSI compatible terminal 
* Win console / Powershell support is limited. Tests pass with MRI ruby but expect to run in to compatibility issues with jruby/powershell.  

# Installation
* cd to project directory and run `gem build terminal-paint`. This will create a gem file `terminal-paint-0.0.1.gem`
* run `gem install terminal-paint-0.0.1.gem`

### Using the optional ncurses driver (only available with MRI Ruby)
#### Installation on ubuntu
  * make sure libncursesw is installed `sudo apt install libnursesw-dev`
  * install ruby 
  * cd to project directory and run `gem build terminal-paint`. This will create a gem file `terminal-paint-0.0.1.gem`
  * run `gem install terminal-paint-0.0.1.gem` 
#### Common Issues
  * If you built the `curses` gem before ncursesw was installed, it's possible that the native extension linked to the older ncurses library instead of ncursesw. To fix this uninstall and reinstall the curses gem. 
#### Installation on Windows
  * Install Ruby with MSYS2 development tool chain option. I prefer to use [ruby installer](https://rubyinstaller.org/)
  If you're not sure whether you installed MSYS2 along with your existing ruby, you can either re-run the ruby installer or install MINGW separately
  

# Dev Notes
- Git repo is not synced to a public repository in keeping with requirements

# Known Issues
* dynamic resizing is broken for users on windows consoles https://github.com/PowerShell/PowerShell/issues/8975.
avoid resizing console window or use terminal_paint --basic 
* dynamic resizing is partially broken using the --tty-cursor display driver. Users can hit any key after resizing their terminal window to fix a corrupt display.
The issue is caused by the way ruby delivers signal interrupts. There is no simple fix for the issue outside of making the application multi-threaded. I've forgone that for this release.
 
