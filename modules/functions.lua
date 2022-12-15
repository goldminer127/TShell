--Imports
local status = require("modules/status")

--Table used to allow functions to be used on other files
local modules = {}

--Modules info
Version = "BETA 0.1.0"

--Turtle status
Status = status.new()

--[[Splits string with specified character. Returns table of strings]]
function modules.split(string, char)
    local stringInsert = ""
    local splitString = {}

    for c in string:gmatch"." do

        if c == char then
            table.insert(splitString, stringInsert)
            stringInsert = ""

        else
            stringInsert = stringInsert .. c
        end

    end

    table.insert(splitString, stringInsert)

    return splitString
end

--[[Formats messages to be 30 chars long.
Adds spaces between messages.
Returns string added with spaces]]
function modules.format(string1, string2, numSpaces)
    local spaces = ""

    if #string1 + #string2 < numSpaces then
        local neededSpaces = numSpaces - (#string1 + #string2)

        for addSpaces = 1, neededSpaces do

            spaces = spaces .. " "

        end
    end

    return string1 .. spaces .. string2
end

function modules.getState()
    return Status
end

--[[Moves turtle foward. Tests for cancel and termination requests.
Params: continuepath - if true turtle will continue on path.
continueroute - if true turtle will repeat path pattern.
dofinishpath - if true turtle will complete current path but will not repeat route.
breakblock - if true turtle will attempt to break any objects in its path.
Returns 2 booleans, boolean1 determins if path is continued, boolean2 determins if route should be repeated]]
function modules.forward(continuepath,continueroute,dofinishpath,breakblock)
    if dofinishpath == nil then dofinishpath = false end
    if breakblock == nil then breakblock = true end

    --Cancels move request if cancel or termination request is recieved
    continuepath,continueroute = modules.decideCancel(0.25,continuepath,continueroute,dofinishpath)

    if continuepath == false and continueroute == false then
        return continuepath,continueroute
    end

    modules.testRefuel()

    local success,data = turtle.inspect()
    if data.name ~= nil and breakblock == true then
        turtle.dig()
        turtle.suck()
        turtle.suckUp()
    end

    modules.attack()
    local canmove = turtle.forward()
    if canmove == false then
        print("Cannot move. Either something is blocking the way or fuel is needed.\nType \"resume\" to resume trail or type \"cancel\" to cancel process.")
        local response = read()

        if response == "resume" then
            modules.forward(continuepath,continueroute,breakblock)

        elseif response == "cancel" then
            print("Canceling task...")
            return false,false

        else
            return false,false
        end
    end

    --Modify turtle's x or y offset based on direction
    if Status.getDirection() == 1 then
        Status.modifyXOffset(1)
    elseif Status.getDirection() == 2 then
        Status.modifyYOffset(1)
    elseif Status.getDirection() == 3 then
        Status.modifyXOffset(-1)
    else
        Status.modifyYOffset(-1)
    end

    return continuepath,continueroute
end

--[[Moves turtle up. Tests for cancel and termination requests.
Params: continuepath - if true turtle will continue on path.
continueroute - if true turtle will repeat path pattern.
dofinishpath - if true turtle will complete current path but will not repeat route.
breakblock - if true turtle will attempt to break any objects in its path.
Returns 2 booleans, boolean1 determins if path is continued, boolean2 determins if route should be repeated]]
function modules.up(continuepath,continueroute,dofinishpath,breakblock)
    if dofinishpath == nil then dofinishpath = false end
    if breakblock == nil then breakblock = true end
    
    continuepath,continueroute = modules.decideCancel(0.25,continuepath,continueroute,dofinishpath)
    if continuepath == false and continueroute == false then
        return continuepath,continueroute
    end

    modules.testRefuel()

    local success,data = turtle.inspectUp()
    if data.name ~= nil and breakblock == true then
        turtle.digUp()
        turtle.suckUp()
    end

    modules.attack()
    local canmove = turtle.up()
    if canmove == false then
        print("Cannot move. Either something is blocking the way or fuel is needed.\nType \"resume\" to resume trail or type \"cancel\" to cancel process.")
        local response = read()

        if response == "resume" then
            modules.up(continuepath,continueroute,breakblock)

        elseif response == "cancel" then
            print("Canceling task...")
            return false,false

        else
            return false,false
        end
    end

    Status.modifyZOffset(1)

    return continuepath,continueroute --Return true if can move and if task is still going
end

--[[Moves turtle down. Tests for cancel and termination requests.
Params: continuepath - if true turtle will continue on path.
continueroute - if true turtle will repeat path pattern.
dofinishpath - if true turtle will complete current path but will not repeat route.
breakblock - if true turtle will attempt to break any objects in its path.
Returns 2 booleans, boolean1 determins if path is continued, boolean2 determins if route should be repeated]]
function modules.down(continuepath,continueroute,dofinishpath,breakblock)
    if dofinishpath == nil then dofinishpath = false end
    if breakblock == nil then breakblock = true end

    continuepath,continueroute = modules.decideCancel(0.25,continuepath,continueroute,dofinishpath)
    if continuepath == false and continueroute == false then
        return continuepath,continueroute
    end

    modules.testRefuel()

    local success,data = turtle.inspectDown()
    if data.name ~= nil and breakblock == true then
        turtle.digDown()
        turtle.suckDown()
    end

    modules.attack()
    local canmove = turtle.down()
    if canmove == false then
        print("Cannot move. Either something is blocking the way or fuel is needed.\nType \"resume\" to resume trail or type \"cancel\" to cancel process.")
        local response = read()

        if response == "resume" then
            modules.down(continuepath,continueroute,breakblock)

        elseif response == "cancel" then
            print("Canceling task...")
            return false,false

        else
            return false,false
        end
    end

    Status.modifyZOffset(-1)

    return continuepath,continueroute --Return true if can move and if task is still going
end

--[[Turns turtle right with specified amount of times.]]
function modules.turnRight(turns)
    turns = turns or 1

    for loop = 1,turns,1 do

        turtle.turnRight()

        Status.modifyDirection(1)

    end
end

--[[Turns turtle left with specified amount of times.]]
function modules.turnLeft(turns)
    turns = turns or 1

    for loop = 1,turns,1 do

        turtle.turnLeft()

        Status.modifyDirection(-1)

    end
end

function modules.attack()
    while turtle.attackUp() == true or turtle.attack() == true or turtle.attackDown() == true do
        sleep(1)
    end
end

--[[Turns turtle towards specified direction. int direction:
1 = front, 2 = rightfacing, 3 = back, 4 = leftfacing]]
function modules.turnTo(direction)
    while Status.getDirection() ~= direction do
        modules.turnRight()
    end
end

--[[Attempts to refuel the turtle. Returns true if refuel was successful,
false if refueling was not completed.]]
function modules.testRefuel()
    if turtle.getFuelLevel() < 1 then
        local slot = 1
        turtle.select(slot)
        local success = turtle.refuel(1)

        while success == false and slot < 17 do

            turtle.select(slot)
            success = turtle.refuel(1)
            slot = slot + 1
            
        end
        
        turtle.select(1)
        --Decide if wanted or not
        --if success == false then
            --print("No fuel available.")
        --end
        return success
    end
    return false
end

--[[Checks if turtle inventory is full by checking if all slots are not empty.
If all slots are not empty, turtle is considered full. Returns true for full,
false for not full.]]
function modules.isFull()
    for slot = 1,16,1 do
        if turtle.getItemCount(slot) == 0 then
            return false
        end
    end
    turtle.select(1)

    return true
end

--[[Compacts items by merging all items into mergable slots.]]
function modules.compactItems()
    for slot = 1,16,1 do

        turtle.select(slot)
        local data = turtle.getItemDetail()
        local currentslot = turtle.getSelectedSlot()

        if data ~= nil then
            for slot1 = 1,currentslot,1 do

                if turtle.transferTo(slot1) == true then
                    break
                end

            end
        end

    end
end

--[[Attempts to empty turtle's inventory into any adjacent chest.]]
function modules.tryEmptyChest()
    for x = 1,4,1 do

        modules.turnRight()
        local success,data = turtle.inspect()

        if data.name == "minecraft:chest" then
            for slot = 1,16,1 do

                turtle.select(slot)

                if turtle.refuel(0) then --Do nothing
                else turtle.drop() end
            end
            turtle.select(1)
        end

    end
end

--[[Detects if the block is seen under the turtle. Returns nil if inspect down error happens]]
function modules.detectBlockDown(block)
    local success,data = turtle.inspectDown()
    if success == false then
        return nil
    elseif data.name == block then
        return true
    else
        return false
    end
end

--[[Waits for keypress for cancels, if nothing within time then continue without stopping anything.]]
function modules.decideCancel(time,continuepath,continueroute,dofinishpath)
    parallel.waitForAny(
        
    function()
        local event, key = os.pullEvent("key")

        if dofinishpath == true and keys.getName ( key ) == "c" and continueroute == true then
            print("Finishing task...")
            continuepath,continueroute = true, false

        elseif keys.getName ( key ) == "s" and continuepath == true then
            print("Stopping task...")
            continuepath,continueroute = false, false
        end
    end

    ,

    function()
        if continuepath == true or continueroute == true then
            sleep(time)
        end
    end)

    return continuepath,continueroute
end

--[[Returns turtle to original spot after moving in a rectangular pattern.]]
function modules.rectangleReturnOriginalSquare(continuepath, continueroute, cancelrepeat)
    modules.turnTo(3)
    if Status.getZOffset() > 0 then
        while Status.getXOffset() ~= 0 and continuepath ~= false do
            continuepath,continueroute = modules.forward(continuepath,continueroute,cancelrepeat)
        end

        while Status.getZOffset() ~= 0 and continuepath ~= false do
            continuepath,continueroute = modules.down(continuepath,continueroute,cancelrepeat)
        end
    else
        while Status.getZOffset() ~= 0 and continuepath ~= false do
            continuepath,continueroute = modules.up(continuepath,continueroute,cancelrepeat)
        end

        while Status.getXOffset() ~= 0 and continuepath ~= false do
            continuepath,continueroute = modules.forward(continuepath,continueroute,cancelrepeat)
        end
    end

    modules.turnTo(4)
    while Status.getYOffset() ~= 0 and continuepath ~= false do
        continuepath,continueroute = modules.forward(continuepath,continueroute,cancelrepeat)
    end
    modules.turnTo(1)

    return continuepath,continueroute
end

function modules.returnToLocation(x,y,z,direction,continuepath,continueroute,cancelrepeat)
    modules.turnTo(1)
    while Status.getXOffset() ~= x and continuepath ~= false do
        continuepath,continueroute = modules.forward(continuepath,continueroute,cancelrepeat)
    end

    while Status.getZOffset() ~= z and continuepath ~= false do
        if z > 0 then
            continuepath,continueroute = modules.up(continuepath,continueroute,cancelrepeat)
        else
            continuepath,continueroute = modules.down(continuepath,continueroute,cancelrepeat)
        end
    end

    modules.turnTo(2)
    while Status.getYOffset() ~= y and continuepath ~= false do
        continuepath,continueroute = modules.forward(continuepath,continueroute,cancelrepeat)
    end
    modules.turnTo(direction)

    return continuepath,continueroute
end
--[[Emergancy return turtle to original spot after incompleted rectangular pattern.]]
--[[
function modules.rectangleReturnOnStop(x,y,z,completedx,completedy,completedz)
    print("Attempting to return to original position...")
    sleep(3)
    local continuepath = true
    if Direction == 1 then
        modules.turnRight(2)

        for col = 1,completedy - 1,1 do

            if continuepath == true then
                continuepath = modules.forward(continuepath,false,false)
            else
                break
            end

        end

        for height = 1,completedz - 1,1 do
            if continuepath == true then
                continuepath = modules.down(continuepath,false,false)
            else
                break
            end
        end

        modules.turnRight()

        for row = 1,completedx - 1,1 do

            if continuepath == true then
                continuepath = modules.forward(continuepath,false,false)
            else
                break
            end

        end

    elseif Direction == 2 then
        modules.turnRight()

        if completedx % 2 == 1 then
            for col = 1,y+1,1 do

                if continuepath == true then
                    continuepath = modules.forward(continuepath,false,false)
                else
                    break
                end

            end

        else
            modules.turnRight()
            continuepath = modules.forward(continuepath,false,false)
        end

        for height = 1,completedz - 1,1 do
            if continuepath == true then
                continuepath = modules.down(continuepath,false,false)
            else
                break
            end
        end

        modules.turnRight()

        for row = 1,completedx - 1,1 do

            if continuepath == true then
                continuepath = modules.forward(continuepath,false,false)
            else
                break
            end

        end

    elseif Direction == 3 then
        for col = 1,y-completedy,1 do

            if continuepath == true then
                continuepath = modules.forward(continuepath,false,false)
            else
                break
            end

        end

        for height = 1,completedz - 1,1 do
            if continuepath == true then
                continuepath = modules.down(continuepath,false,false)
            else
                break
            end
        end
        
        modules.turnRight()

        for row = 1,completedx - 1,1 do

            if continuepath == true then
                continuepath = modules.forward(continuepath,false,false)
            else
                break
            end

        end
    end

    modules.turnTo(1)

    return continuepath
end
]]

return modules