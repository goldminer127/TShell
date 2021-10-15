# Modules
### Disclaimer: TShell is currently in development and is in BETA stage. There may be limited functionality and plenty of bugs. If you encounter any bugs or have any suggestions please make an issue!
Modules are what makes TShell useful. Without them you basically have an iPhone without any apps in it, useless, boring, expensive, and rectangle. But like apps on an iPhone, each module provides different functionalities to TShell. They each come with a different set of commands that are suitable for specific tasks.\
There is currently only 1 module available. Don't worry, more will show up soon!\
# Available Modules
* [Farming](#farming)
## Farming Module
Provides commands for farming functionality.\
__Syntax: 'farming'__
## Commands
* [farm](#farm)
* [help](#help)
* [integrity](#integrity)
* [plant](#plant)
* [till](#till)
* [version](#version)
### farm
Usage: farm \<length> \[width]\
Farms in a rectanglular pattern. If the width is not specified then the turtle will use length to farm in a square pattern.
### help
Usage: help \[command]\
Displays all commands for the farming module. Displays more information about a specific command if specified.
### integrity
Usage: integrity
Shows if the module is in a stable or unstable version.
### plant
Usage: plant \<length> \[width]\
Plants in a rectanglular pattern. If the width is not specified then the turtle will use length to plant in a square pattern. __Seeds must be provided for planting.__
### till
Usage: till \<length> \[width]\
Tills in a rectanglular pattern. If the width is not specified then the turtle will use length to till in a square pattern.
### version
Usage: version
Gets the installed farming module version.\
\
Why split functionalities into different modules? Each turtle has their own unique functionality which is dependent on the tool they hold. A farming turtle farms, a mining turtle mines, and a combat turtle hurts things. Unless you really made the turtle angry, a farming turtle would probably not be attacking things. It wouldn’t make sense to give that turtle commands to attack.
