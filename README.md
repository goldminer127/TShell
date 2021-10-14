# TShell BETA 0.1.7
### Disclaimer: TShell is currently in development and is in BETA stage. There may be limited functionality and plenty of bugs. If you encounter any bugs or have any suggestions please make an issue!

Do you hate it when you want a turtle to do something, but have to manually code in a program to do the simplest of things? Do you you hate spending long nights debugging code for a minecraft turtle when you could be doing other things? Do you even know how to code? Well do not fear! TShell is here to satisfy your basic turtle needs. It comes with a bunch of modules packed with commands to make your life with turtles easier! If you are already familiar with TShell and just want to skip to how to get it, [press here!](##installation)
## TShell Commands
TShell itself comes with some commands. Modules must be downloaded using the command install. Check out more information about modules [here.](https://github.com/goldminer127/TShell/tree/master/modules)

Syntax for TShell is "turtle". You must have "turtle" before every command to use TShell commands.
List of current commands:
* [default](######default)
* [exit](######exit)
* [help](######help)
* [info](######info)
* [install](######install)
* [modules](######modules)
* [reinstall](######reinstall)
* [remove](######remove)
* [restart](######restart)
* [update](######update)

###### default
Shortcut: -d
Usage: default \<program/command>
Allows you to use default programs/commands provided by computercraft by default.
Example: 'turtle default tunnel 10'

###### exit
Exits TShell to default turtle mode.

###### help
Usage: help \[command\]
Displays all available TShell commands or displays more information about the specified command.

###### info
Gets information about your current TShell version.

###### install
Shortcut: -i
Usage: install \<mode> \<modulename/programlink> \<filename>
Modes: -m (module), unsafe (install unsupported programs)
Installs modules or unsupported programs into TShell. __modulename__ is needed if -m is specified, __programlink__ and __filename__ is needed if unsafe is specified.
Examples: 'turtle install -m farming'
          'turtle install unsafe <link/pastbin code> programname'
          
###### modules
Shortcut: -m
Usage: modules \<subcommand>
Subcommands:
* list
  * List all installed modules and programs
* -rm \<name>
  * Removes module or program
* update \<type> \<name>
  * Type: module, program
  * Updates module or program
* available
  * List all available modules to install
  
Manages modules or programs installed onto TShell.
Examples: 'turtle modules update module farming'
          'turtle modules -rm farming'

###### Reinstall
Shortcut: -r
Usage: reinstall \<type> \<name>
Type: -m (module), -p (program)
Reinstalls any module or program.
Example: 'turtle reinstall -m farming'

###### remove (WIP)
Shortcut: rm
Usage: remove \<name>
Command currently not available.

###### restart
Restarts TShell.

###### update
Shortcut: -u
Checks if any new TShell updates are available. Updates TShell if there is an available update.

## Installation
Turtles from computercraft only allow you to install programs through pastebin. To install TShell use the following command:
```
pastebin get 5kaWmLwz TShell
```
[View Pastebin Code](https://pastebin.com/5kaWmLwz)
You should be all set! It is that simple!
