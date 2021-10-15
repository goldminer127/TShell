--Shell Info
Version = "BETA 0.1.8"

--Available Modules
local AvailableModules = {"attacking", "farming", "mining", "timber"}

--General Functions

--Splits string with specified character
function Split(string1, char1)
    local stringInsert = ""
    local splitString = {}
    for char in string1:gmatch"." do
        if char == char1 then
            table.insert(splitString, stringInsert)
            stringInsert = ""
        else
            stringInsert = stringInsert .. char
        end
    end
    table.insert(splitString, stringInsert)
    return splitString
end

--Formats messages to be 30 chars long.
--Adds spaces between messages
--Returns string added with spaces
function Format(string1, string2, numSpaces)
    local spaces = ""
    if #string1 + #string2 < numSpaces then
        local neededSpaces = numSpaces - (#string1 + #string2)
        for addSpaces = 1, neededSpaces do
            spaces = spaces .. " "
        end
    end
    return string1 .. spaces .. string2
end

--Shell Functions

--Restarts the OS **NOT THE TURTLE**
function Restart()
    shell.run("clear")
    shell.run("TShell")
end

--Check if Shell Version file is updated.
function CheckForUpdate()
    print("Checking for updates...")
    local download = http.get("https://raw.githubusercontent.com/goldminer127/TShell/master/Version")
    local versionnum = download.readAll()
    local isupToDate = versionnum == Version
    local versionfile = fs.open("ShellVersion","w")
    versionfile.write(versionnum)
    versionfile.close()
    download.close()
    --Returns true if there is no update. Returns false if there is an update
    return isupToDate
end

--Store initial version or store new version after update
function UpdateVersion()
    local versionFile = fs.open("ShellVersion","w")
    versionFile.write(Version)
    versionFile.close()
    --pcall(osVersion.close())
end

--Make directories for OS
function MakeDirectories()
    fs.makeDir("modules")
    fs.makeDir("programs")
end

--Update TShell
function UpdateShell()
    print("Downloading files...")
    local shellDownload = http.get("https://raw.githubusercontent.com/goldminer127/TShell/master/TShell.lua")
    local downloadFile = shellDownload.readAll()
    shellDownload.close()

    --Install new version
    print("Installing files...")
    local turtleShell = fs.open("TShell","w")
    turtleShell.write(downloadFile)
    turtleShell.close()
    print("Finalizing...")
    sleep(5)
end

--Commands for TShell
function TurtleHelp()
    print(Format("default [-d]", "modules [-m]", 36))
    print(Format("exit", "reinstall [-r]", 36))
    print(Format("help", "remove [rm]", 36))
    print(Format("info", "restart", 36))
    print(Format("install [-i]", "update [-u]", 36))
end

--List all modules
function ListModules()
    local modules = fs.list("modules")
    local list = "Modules:\n"
    for _, m in ipairs(modules) do
        list = list .. m .. "\n"
    end
    if list == "" then
        list = "No modules installed."
    end
    print(list)
end

--List all programs
function ListPrograms()
    local programs = fs.list("programs")
    local list = "Programs:\n"
    for _, p in ipairs(programs) do
        list = list .. p .. "\n"
    end
    if list == "" then
        list = "No programs installed."
    end
    print(list)
end

--Installs modules
function InstallModule(downloadLink, modulename)
    print("Downloading", modulename, "module...")
    local download = http.get(downloadLink)
    local moduleCode = download.readAll()
    download.close()
    print("Download complete.\nInstalling module...")
    local moduleFile = fs.open("modules/" .. modulename, "w")
    moduleFile.write(moduleCode)
    moduleFile.close()
    print("Module successfully installed.")
end

--Checks if module exists
function CheckIfModuleExists(module)
    local moduleFile = fs.open("modules/" .. module, "r")
    if moduleFile ~= nil then
        UpdateModule(module)
        moduleFile.close()
    else
        print("Module not found. Use turtle -m list to view all modules.")
    end
end

--Update module
function UpdateModule(moduleName)
    local module = require("modules/" .. moduleName)
    local versiondownload = http.get("https://raw.githubusercontent.com/goldminer127/TShell/master/modules/" .. moduleName .. "version")
    local version = versiondownload.readAll()
    if version == module.GetVersion() then
        print("Module up to date. No changes made.")
    else
        print(moduleName,"version",version,"is available. A restart will be required. Do you want to update this module? (y/n)")
        local loop = true
        while loop do
            local response = read()
            if response == "y" then
                local moduleFile = fs.open("modules/" .. moduleName, "w")
                local download = http.get("https://raw.githubusercontent.com/goldminer127/TShell/master/modules/" .. moduleName .. ".lua")
                moduleFile.write(download.readAll())
                download.close()
                moduleFile.close()
                print("Update successful.")
                print("Restarting...")
                Restart()
            elseif response == "n" then
                print("Update postponed.")
                loop = false
            else
                print("Invalid response. Try again.")
            end
        end
    end
    versiondownload.close()
end

--Removes specified module. Returns result as status message.
function RemoveModule(module)
    local modules = fs.list("modules")
    local result = ""
    for _, m in ipairs(modules) do
        if m == module then
            fs.delete("modules/" .. m)
            result = "Module " .. m .. " successfully uninstalled."
            break
        end
    end
    if result == "" then
        result = "Module " .. module .. " not found."
    end
    print(result)
end

function InstallProgram(program, token)
        print("Downloading program", program .. "...")
        local download;
        local doinstall = true;
        if #token == 8 then
            download = http.get("https://pastebin.com/raw/" .. token)
        elseif string.match(token, "/blob") and string.match(token, "github.com") then
            local gfront, gback = string.find(token, "github.com")
            local bfront, bback = string.find(token, "/blob")
            local str1 = string.sub(token, 0, gfront - 1)
            local str2 = string.sub(token, gback + 1, bfront - 1)
            local str3 = string.sub(token, bback + 1, #token)
            token = str1 .. "raw.githubusercontent.com" .. str2 .. str3
            download = http.get(token)
        else
            download = http.get(token)
        end

        --Test if program exists
        if fs.open("programs/" .. program, "r") ~= nil then
            print("Program",program,"already exists, do you want to reinstall it? (y/n)")
            while true do
                local response = read()
                if response == "y" then
                    --Keep doinstall true
                    break
                elseif response == "n" then
                    doinstall = false
                    break
                else
                    print("Invalid response. Try again.")
                end
            end
        end
                
        if download ~= nil and doinstall == true then
            print("Download complete. Installing program...")
            local file = fs.open("programs/" .. program, "w")
            file.write(download.readAll())
            file.close()
            if token ~= nil then
                print("Saving token...")
                local linkArchive = fs.open("programs/" .. program .. "Token", "w")
                linkArchive.write(token)
                linkArchive.close()
                download.close()
            end
            print("Program installed successfully.")
        elseif doinstall == false then
            print("Installation cancelled")
        else
            print(program, "could not be downloaded.")
        end
end

function CheckIfProgramExists(program)
    local programFile = fs.open("programs/" .. program, "r")
    if programFile ~= nil then
        UpdateProgram(program)
        programFile.close()
    else
        print("Program not found. Use turtle -m list to view all program.")
    end
end

--Update non-module programs
function UpdateProgram(program)
    local tokenfile = fs.open("programs/" .. program .. "Token", "r")
    local token
    print("Could not check", program, "version. Updating program...")
    if tokenfile == nil then
        print("Program link/code not found, please input link/code. Type \"cancel\" to cancel update.")
        local response = read()
        if response == "cancel" then
            print("Canceling update...")
        else
            tokenfile = fs.open("programs/" .. program .. "Token", "w")
            token = response
            tokenfile.write(token)
            tokenfile.close()
        end
    else
        token = tokenfile.readAll()
        tokenfile.close()
    end
    if token ~= nil then
        local programFile = fs.open("programs/" .. program, "w")
        local download = http.get(token)
        if download ~= nil then
            programFile.write(download.readAll())
            download.close()
            programFile.close()
            print("Update successful.")
        else
            print("Update failed, could not download program files. Possibly provided with invalid link/code.")
        end
    end
end

--Turtle Commands

function Install(input)
    local exists = false
    --Install farming module
    if input[2] == "-m" then
        if input[3] ~= nil then
            --Test if module exists
            for module, name in pairs(AvailableModules) do
                if input[3] == name then
                    exists = true
                    break
                end
            end
        else
            print("Must provide a module name.")
        end
        --Installs module if exists, if not tells user that shell compatable module does not exist
        --provides an alternative command to install non-compatable programs.
        if exists then
            local fileExists = fs.open("modules/" .. input[3], "r")
            local response
            if fileExists ~= nil then
                print(input[3],"module already exists, do you want to reinstall it? (y/n)")
                response = read()
                fileExists.close()
            end
            if (fileExists == nil) or (response == "y") then
                print("Fetching " .. input[3] .. " module...")
                --loop until valid input
                while true do
                    print("Confirm installation (y/n)")
                    response = read()
                    if response == "y" then
                        local moduleName = input[3]
                        InstallModule("https://raw.githubusercontent.com/goldminer127/TShell/master/modules/" .. moduleName .. ".lua",moduleName)
                        break
                    elseif response == "n" then
                        print("Installation cancelled.")
                        break
                    else
                        print("Invalid response. Try again.")
                    end
                end
            else
                print("Installation cancelled.")
            end
        else
            print(input[3] .. " is not listed as a module. Use 'turtle -m available' to view all available modules. Use 'turtle -i unsafe <link/code> <name>' to install programs not compatable with TShell.")
        end
    --Install unsupported programs. Requires a link or code and name of file.
    elseif input[2] == "unsafe" then
        if (input[3] == nil) or (input[4] == nil) then
            print("Must provide a link/code and file name.")
        else
            while true do
                print(input[4], "is not a supported module. This program might not be accessible by TShell.")
                print("Confirm installation (y/n)")
                local response = read()
                if response == "y" then
                    InstallProgram(input[4], input[3])
                    break
                elseif response == "n" then
                    print("Installation cancelled.")
                    break
                else
                    print("Invalid response. Try again.")
                end
            end
        end
    elseif input[2] ~= nil then
        print(input[2], "is not a command.")
    else
        print("No command input.")
    end
end

--Turtle commands
function Help(input)
    if input[2] == nil then
        TurtleHelp()
    elseif (input[2] == "default") or (input[2] == "-d") then
        print("Alias: 'default', '-d'")
        print("Run a default turtle program.")
        print("Example: 'turtle default tunnel 10'")
    elseif input[2] == "exit" then
        print("Alias: 'exit'")
        print("Exit TShell.")
    elseif input[2] == "help" then
        print("Alias: 'help'")
        print("List available commands or show info about a specific command")
    elseif input[2] == "info" then
        print("Alias: 'info'")
        print("Get information about TShell")
    elseif (input[2] == "install") or (input[2] == "-i") then
        print("Alias: 'install', '-i'")
        print("Install a module or third party program.")
    elseif (input[2] == "modules") or (input[2] == "-m") then
        print("Alias: 'modules', '-m'")
        print("Subcommands: '-u', '-l'")
        print("Install a module or third party program.")
        print("-u update a specified module.")
        print("-l list all available modules.")
    elseif (input[2] == "reinstall") or (input[2] == "-r") then
        print("Alias: 'reinstall', '-r'")
        print("Subcommands: '-m', '-p'")
        print("-m reinstall a module.")
        print("-p reinstall a program.")
        print("Reinstall a module or program.")
    elseif (input[2] == "remove") or (input[2] == "rm") then
        print("Alias: 'remove', 'rm'")
        print("Remove modules or third party programs.")
    elseif input[2] == "restart" then
        print("Alias: 'restart'")
        print("Restarts TShell.")
    elseif input[2] == "update" then
        print("Alias: 'update'")
        print("Updates TShell if there is a new update available.")
    else
        print("Command not found.")
    end
end

function ModulesCommands(input)
    if input[2] == "list" then
        ListModules()
        ListPrograms()
    elseif input[2] == "-rm" then
        if input[3] ~= nil then
            RemoveModule(input[3])
        else
            print("Module or program name required.")
        end
    elseif input[2] == "update" then
        if input[3] == "module" then
            CheckIfModuleExists(input[4])
        elseif input[3] == "program" then
            CheckIfProgramExists(input[4])
        else
            print("Specify if module or program")
        end
    elseif input[2] == "available" then
        local names = ""
        for _, name in pairs(AvailableModules) do
            names = names .. name .. "\n"
        end
        print("Available modules to install:")
        print(names)
    elseif input[2] ~= nil then
        print(input[2], "is not a command.")
    else
        print("No command input.")
    end
end

function Update()
    --True = no update, False = new update available
    if CheckForUpdate() == true then
        print("Shell is up to date")
    else
        local newVersionFile = fs.open("ShellVersion","r")
        local newVersionNum = newVersionFile.readAll()
        newVersionFile.close()
        print("TShell", newVersionNum, "is available.\nUpdate will require a restart.\nReady to update? (y/n)")
        while(true) do
            local response = read()
            if response == "y" then
                UpdateShell()
                Restart()
                break
            elseif response == "n" then
                print("Update postponed")
                newVersionFile = fs.open("ShellVersion","w")
                newVersionFile.write(Version)
                newVersionFile.close()
                break
            else
                print("Invalid input")
            end
        end
    end
end

--Used to reinstall damaged or outdated modules or programs
function Reinstall(input)
    local module = fs.open(input[3], "w")
    if module ~= nil then
        print(input[3], "does not exist.")
    elseif input[2] == "-m" then
        print("Are you sure you want to reinstall" .. input[2] .. "? (y/n)")
        --Loop until a valid response is given.
        while true do
            local response = read()
            if response == "y" then
                print("Downloading module...")
                local download = http.get("https://raw.githubusercontent.com/goldminer127/TShell/master/modules/" .. input[2] .. ".lua")
                if download ~= nil then
                    print("Installing module...")
                    module.write(download.readAll())
                    download.close()
                    module.close()
                    print("Module successfully reinstalled.")
                    break
                else --If module fails to download
                    print("Module could not be downloaded.")
                    break
                end
            elseif response == "n" then
                print("Reinstall cancelled.")
                break
            else
                print("Not a valid input.")
            end
        end
    elseif input[2] == "-p" then
        while true do
            local response = read()
            if response == "y" then
                local download = http.get("https://raw.githubusercontent.com/goldminer127/TShell/master/modules/" .. input[2] .. ".lua")
                module.write(download.readAll())
                download.close()
                module.close()
                break
            elseif response == "n" then
                print("Reinstall cancelled.")
                break
            else
                print("Not a valid input.")
            end
        end
    else
        print("Incorrect inputs. Use 'turtle help reinstall' to view specifications.")
    end
end

function Remove(input)
    if input[2] == nil or input[3] == nil then
        print("Type and filename must be provided. One was missing.")
    elseif input[2] == "module" then
        if fs.exists("modules/"..input[3]) then
            print("Removing module",input[3])
            fs.delete("modules/"..input[3])
            fs.delete("modules/"..input[3].."version")
        else
            print(input[3],"does not exist.")
        end
    elseif input[2] == "program" then
        if fs.exists("program/"..input[3]) then
            print("Removing program",input[3])
            fs.delete("program/"..input[3])
            fs.delete("program/"..input[3].."version")
        else
            print(input[3],"does not exist.")
        end
    else
        print("Invalid type specified. Must be module or program.")
    end
end

--[[
    All TShell commands. Runs the specified command from Listener.
    Returns true if exit is not called.
]]
function Turtle(input)
    if input[1] == nil then
        print("Use 'turtle help' to view available commands. Use 'turtle help <command> to read about a specific command.")
    --Default programs
    elseif input[1] == "default" or input[1] == "-d" then
        local command = ""
        for x = 2,#input,1 do
            command = command .. " " .. input[x]
        end
        shell.run(command)
    --Exit
    elseif input[1] == "exit" then
        print("Exiting TShell...")
        return false
    --Help
    elseif input[1] == "help" then
        Help(input)
    --Info
    elseif input[1] == "info" then
        print("TShell Version:", Version)
        print("Created by goldminer127")
        print("Github: https://github.com/goldminer127")
    --Install
    elseif (input[1] == "install") or (input[1] == "-i") then
        Install(input)
    --Modules
    elseif (input[1] == "modules") or (input[1] == "-m") then
        ModulesCommands(input)
    --Update
    elseif (input[1] == "update") or (input[1] == "-u") then
        Update()
    --Reinstall
    elseif input[1] == "reinstall" then
        Reinstall(input)
    --remove
    elseif input[1] == "remove" then
        Remove(input)
    --Restart
    elseif input[1] == "restart" then
        Restart()
    --Exit
    elseif input[1] == "exit" then
        print("Closing terminal")
        return false
    elseif input[1] ~= nil then
        print(input[1], "is not a command.")
    else
        print("No command input.")
    end
    --Continues loop if exit command is not used
    return true
end


--Listens for input from the user. Determins what to do with prefixes from the user
function Listener()
    local loop = true
    while loop do
        term.write("> ")
        local input = Split(read(),' ')
        local prefix = input[1]
        table.remove(input, 1)
        --Default turtle commands
        if prefix == "turtle" then
            loop = Turtle(input)
        --farming module commands
        elseif prefix == "farming" then
            local farmingExists = pcall(require,"modules/farming")
            if farmingExists == false then
                print("Farming module not installed.\nRun 'turtle -i -m farming' to install the required module.")
            else
                local farming = require("modules/farming")
                --farming functions and commands found in farming.lua
                farming.Interpreter(input)
            end
        else
            print("Invalid syntax")
        end
    end
end


--Startup stuff

function Startup()
    UpdateVersion()
    MakeDirectories()
    --Display arbutrary messages for fun. It indicated nothing
    --Loading messages
    print(Format("Loading Shell", "[ OK ]", 36))
    sleep(0.5)
    print(Format("Loading IP", "[ OK ]", 36))
    sleep(0.10)
    print(Format("Loading emotions", "[ FAILED ]", 36))
    print("Starting systems...\n")
    --Starting messages
    sleep(2)
    print(Format("Starting listener", "[ OK ]", 36))
    sleep(0.25)
    print(Format("Starting modules", "[ OK ]", 36))
    sleep(1)
    print(Format("Starting interface", "[ OK ]", 36))
    sleep(0.25)
    print(Format("Starting other services", "[ OK ]", 36))
    sleep(0.1)
    print(Format("Starting emotions", "[ FAILED ]", 36))
    print("\n\nWelcome to TShell", Version, "Loading...")
    sleep(5)
    shell.run("clear")
    Listener()
end

--Main
Startup()
--shell.run("pastebin","get","1F1cR1LH","turtle")
--shell.run("pastebin get 1F1cR1LH turtle")