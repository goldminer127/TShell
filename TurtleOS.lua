--OS Info
Version = "BETA 0.1.1"



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
function Format(string1, string2)
    local spaces = ""
    if #string1 + #string2 < 36 then
        local neededSpaces = 36 - (#string1 + #string2)
        for addSpaces = 1, neededSpaces do
            spaces = spaces .. " "
        end
    end
    return string1 .. spaces .. string2
end

--OS Functions

--Check if OS Version file is updated.
function CheckForUpdate()
    local gitVersion = pcall(fs.open("Version","r"))
    if gitVersion == true then
        gitVersion.delete("Version")
        gitVersion.close()
    end
    local download = http.get("https://raw.githubusercontent.com/goldminer127/TurtleOS/main/Version")
    local turtleOS = download.readAll()
    download.close()
    local file = fs.open("Version","w")
    file.write(turtleOS)
    file.close()
    
    --Returns true if there is no update. Returns false if there is an update
    local versionFile = fs.open("Version", "r")
    local isUpToDate = versionFile.readAll() == Version
    versionFile.close()
    return isUpToDate
end

--Store initial version or store new version after update
function UpdateVersion()
    local osVersion = pcall(fs.open("OSVersion","r"))
    if osVersion == true then
        osVersion.delete("OSVersion")
        osVersion.close()
    end
    local versionFile = fs.open("OSVersion","w")
    versionFile.write(Version)
    versionFile.close()
    --pcall(osVersion.close())
end

--Update TurtleOS
function Update()
    local turtleOS = fs.open("TurtleOS","r")
    local osDownload = http.get("https://raw.githubusercontent.com/goldminer127/TurtleOS/main/TurtleOS.lua")
    local downloadFile = osDownload.readAll()
    osDownload.close()

    --Delete old version
    turtleOS.delete("TurtleOS")
    turtleOS.close()

    --Install new version
    turtleOS = fs.open("TurtleOS","w")
    turtleOS.write(downloadFile)
    turtleOS.close()
end

--Restarts the OS **NOT THE TURTLE**
function Restart()
    shell.run("clear")
    shell.run("TurtleOS")
end

--Turtle Commands

function Listener()
    while true do
        term.write("> ")
        local input = Split(read(),' ')
        local prefix = input[1]
        table.remove(input, 1)
        --Default turtle commands
        if prefix == "turtle" then
            Turtle(input)
        end
    end
end


function Turtle(input)
    if input[1] == nil then
        print("Use 'turtle help' to view available commands. Use 'turtle help <command> to read about a specific command.")
    elseif input[1] == "update" then
        --True = no update, False = new update available
        if CheckForUpdate() == true then
            print("OS is up to date")
        else
            local newVersionFile = fs.open("Version","r")
            local newVersionNum = newVersionFile.readAll()
            newVersionFile.close()
            print("OS", newVersionNum, "is available.\nUpdate will require a restart.\nReady to update? (y/n)")
            local response = read()
            if response == "y" then
                Update()
                Restart()
            else
                print("Update postponed")
            end
        end
    elseif input[1] == "restart" then
        Restart()
    end
end

--Startup stuff

function Startup()
    UpdateVersion()
    --Display arbutrary messages for fun. It indicated nothing
    --Loading messages
    print(Format("Loading OS", "[ OK ]"))
    sleep(0.25)
    print(Format("Loading IP", "[ OK ]"))
    sleep(0.25)
    print(Format("Loading emotions", "[ FAILED ]"))
    print("Starting systems...\n")
    --Starting messages
    sleep(2)
    print(Format("Starting kernal", "[ OK ]"))
    sleep(0.25)
    print(Format("Starting modules", "[ OK ]"))
    sleep(0.25)
    print(Format("Starting interface", "[ OK ]"))
    sleep(0.25)
    print(Format("Starting other services", "[ OK ]"))
    sleep(0.25)
    print(Format("Starting emotions", "[ FAILED ]"))
    print("\n\nWelcome to TurtleOS. Loading...")
    sleep(5)
    shell.run("clear")
    Listener()
end

--Main
Startup()
--shell.run("pastebin","get","1F1cR1LH","turtle")
--shell.run("pastebin get 1F1cR1LH turtle")
