--Table used to hold all functions
local farming = {}

--Module info
Version = "BETA 0.1.2"
IsStable = true

--Globals
DoingTask = false
LoopPath = true
LoopPathAgain = true
Direction = 1 --1 = front, 2 = right, 3 = back, 4 = left

--Returns string (version)
function farming.GetVersion()
    return Version
end

--Returns bool
function farming.GetStability()
    return IsStable
end

--Same as TShell format
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

--Module Functions

function Help()
    print(Format("farm", "integrity", 15))
    print(Format("help", "version", 15))
    print(Format("till", " ", 15))
end

function CommandsHelp(command)
    if command == "farm" then
        print("Alias: 'farm'")
        print("Farm in a rectangular pattern.")
        print("Example: 'farming farm 3 6'")
    elseif command == "help" then
        print("Alias: 'help'")
        print("Show all farming commands.")
    elseif command == "till" then
        print("Alias: 'till'")
        print("Till all dirt in a rectangular pattern.")
        print("Example: 'farming till 3 6'")
    elseif command == "integrity" then
        print("Alias: 'integrity'")
        print("Tests if the module is in a stable version.")
    elseif command == "version" then
        print("Alias: 'version'")
        print("Get the version of the module.")
    end
end

function TestRefuel()
    if turtle.getFuelLevel() < 1 then
        local slot = 1
        turtle.select(slot)
        local success = turtle.refuel(1)
        while success ~= true and slot < 17 do
            turtle.select(slot)
            success = turtle.refuel(1)
            slot = slot + 1
        end
        --Decide if wanted or not
        --if success == false then
            --print("No fuel available.")
        --end
    end
end 

--Finish and stop task when c is pressed, hard stop task when s is pressed
function CancelJob()
    local event, key = os.pullEvent("key")
    if keys.getName ( key ) == "c" and LoopPathAgain == true then
        print("Finishing task...")
        LoopPathAgain = false
    elseif keys.getName ( key ) == "s" and LoopPath == true then
        print("Stopping task...")
        LoopPath = false
        LoopPathAgain = false
    end
end

--Used to alternate between detecting keypress and continue other functions
function DecideCancel(time)
    parallel.waitForAny(CancelJob, function()
        if LoopPathAgain == true or LoopPath == true then
            sleep(time)
        end
    end)
end

function TurtleUp()
    TestRefuel()
    local success,data = turtle.inspectUp()
    if data.name ~= nil then
        turtle.digUp()
        turtle.suckUp()
    end
    local canmove = turtle.up()
    if canmove == false then
        print("Cannot move. Either something is blocking the way or fuel is needed.\nType \"resume\" to resume trail or type \"cancel\" to cancel process.")
        local response = read()
        if response == "resume" then
            TurtleUp()
        elseif response == "cancel" then
            return false
        end
    end
    return LoopPath --Return true if can move and if task is still going
end

function TurtleDown()
    TestRefuel()
    local success,data = turtle.inspectDown()
    if data.name ~= nil then
        turtle.digDown()
        turtle.suckDown()
    end
    local canmove = turtle.down()
    if canmove == false then
        print("Cannot move. Either something is blocking the way or fuel is needed.\nType \"resume\" to resume trail or type \"cancel\" to cancel process.")
        local response = read()
        if response == "resume" then
            TurtleDown()
        elseif response == "cancel" then
            return false
        end
    end
    return LoopPath --Return true if can move and if task is still going
end

function TurtleForward()
    TestRefuel()
    local success,data = turtle.inspect()
    if data.name ~= nil then
        turtle.dig()
        turtle.suck()
        turtle.suckUp()
    end
    local canmove = turtle.forward()
    if canmove == false then
        print("Cannot move. Either something is blocking the way or fuel is needed.\nType \"resume\" to resume trail or type \"cancel\" to cancel process.")
        local response = read()
        if response == "resume" then
            TurtleForward()
        elseif response == "cancel" then
            return false
        end
    end
    return LoopPath --Return true if can move and if task is still going
end

function CompactItems()
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

function TryEmptyChest()
    for x = 1,4,1 do
        turtle.turnRight()
        local success,data = turtle.inspect()
        if data.name == "minecraft:chest" then
            for slot = 1,16,1 do
                turtle.select(slot)
                local data = turtle.getItemDetail()
                if data == nil then --Do nothing
                elseif data.name == "minecraft:wheat_seeds" then turtle.drop(data.count/2)
                elseif data.name == "minecraft:carrot" then turtle.drop(data.count/2)
                elseif data.name == "minecraft:potato" then turtle.drop(data.count/2)
                elseif data.name == "minecraft:beetroot_seeds" then turtle.drop(data.count/2)
                elseif turtle.refuel(0) then --Do nothing
                else turtle.drop()
                end
            end
        end
    end
end

function TurtleTill()
    local success,blockid = turtle.inspectDown()
    if blockid ~= nil then
        turtle.digDown()
        turtle.digDown()
        turtle.suckDown()
    else
        turtle.digDown()
        turtle.suckDown()
    end
end

function TurtlePlant()
    local data = turtle.getItemDetail()
    if data ~= nil and (data.name == "minecraft:wheat_seeds" or data.name == "minecraft:potato" or data.name == "minecraft:carrot" or data.name == "minecraft:beetroot_seeds") then
        turtle.placeDown()
    else
        local validseed = false
        for slot = 1,16,1 do
            turtle.select(slot) 
            data = turtle.getItemDetail()
            if data == nil then --Do nothing
            elseif data.name == "minecraft:wheat_seeds" then 
                validseed = true 
                break
            elseif data.name == "minecraft:carrot" then 
                validseed = true 
                break
            elseif data.name == "minecraft:potato" then 
                validseed = true 
                break
            elseif data.name == "minecraft:beetroot_seeds" then
                validseed = true 
                break
            end
        end
        if validseed == false then
            print("No plantable seed available. Please load inventory with seeds to plant and enter \"resume\". Enter \"cancel\" to cancel planting.")
            local response = read()
            if response == "resume" then
                TurtlePlant()
            elseif response == "cancel" then
                LoopPath = false
            end
        else
            turtle.placeDown()
        end
    end
end

function TurtleSuckBreakPlant()
    local success,blockid = turtle.inspectDown()
    --Check if block is tilled, if not leave it.
    --Done in case there are small dirt platforms or lilypads inside the farm
    if blockid.name == "minecraft:wheat" or blockid.name == "minecraft:carrots" or blockid.name == "minecraft:potatoes" or blockid.name == "minecraft:beetroots" then
        turtle.digDown()
        turtle.suckDown()
    end
    local selectedid = turtle.getItemDetail()
    local seedid
    if blockid.name == "minecraft:wheat" then seedid = "minecraft:wheat_seeds"
    elseif blockid.name == "minecraft:carrots" then seedid = "minecraft:carrot"
    elseif blockid.name == "minecraft:potatoes" then seedid = "minecraft:potato"
    elseif blockid.name == "minecraft:beetroots" then seedid = "minecraft:beetroot_seeds"
    else seedid = "none"
    end
    if selectedid ~= nil and seedid ~= selectedid.name then
        local slot = 1
        while selectedid ~= nil and seedid ~= selectedid.name and slot < 17 do
           turtle.select(slot)
           selectedid = turtle.getItemDetail()
           slot = slot + 1
        end
    end
    if selectedid == nil or seedid ~= selectedid.name then
        --print("Could not replant plant. No seeds found.")
    else
        turtle.placeDown()
    end
end

function ReturnOriginalSquare(x, y)
    LoopPath = true
    if x % 2 == 1 then
        TurtleForward()
        for col = 1,y,1 do
            if LoopPath ~= false then
                LoopPath = TurtleForward()
            else
                break
            end
        end
        turtle.turnRight()
        for row = 1,x,1 do
            if LoopPath ~= false then
                LoopPath = TurtleForward()
            else
                break
            end
        end
        turtle.turnRight()
    else
        turtle.turnRight()
        turtle.turnRight()
        TurtleForward()
        turtle.turnRight()
        for row = 1,x,1 do
            if LoopPath ~= false then
                LoopPath = TurtleForward()
            else
                break
            end
        end
        turtle.turnRight()
    end
end

function TillSquare(x, y)
    local timerest = 0.5 --seconds
    local originaly = y
    LoopPath = true
    LoopPath = TurtleUp()
    for row = 1,x,1 do
        if LoopPath == true then
            DecideCancel(timerest)
            for col = 1,y,1 do
                DecideCancel(timerest)
                if LoopPath == true then
                    --before y is reduced and col is 1, skip breaking tile
                    if y ~= originaly then
                        TurtleTill()
                        LoopPath = TurtleForward()
                    elseif col > 1 then
                        TurtleTill()
                        LoopPath = TurtleForward()
                    else
                        LoopPath = TurtleForward()
                    end
                else
                    break
                end
            end
            if row == 1 then
                y = y - 1
            end
            if LoopPath == false then
                break
            elseif row % 2 == 1 then
                turtle.turnRight()
                DecideCancel(timerest)
                TurtleTill()
                LoopPath = TurtleForward()
                DecideCancel(timerest)
                turtle.turnRight()
            else
                turtle.turnLeft()
                DecideCancel(timerest)
                TurtleTill()
                LoopPath = TurtleForward()
                DecideCancel(timerest)
                turtle.turnLeft()
            end
        else
            break
        end
    end
    if LoopPath then
        ReturnOriginalSquare(x, y)
        LoopPath = TurtleDown()
        CompactItems()
        TryEmptyChest()
    else
    end
end

function PlantSquare(x,y)
    local timerest = 0.5 --seconds
    local originaly = y
    LoopPath = true
    LoopPath = TurtleUp()
    for row = 1,x,1 do
        if LoopPath == true then
            DecideCancel(timerest)
            for col = 1,y,1 do
                DecideCancel(timerest)
                if LoopPath == true then
                    --before y is reduced and col is 1, skip breaking tile
                    if y ~= originaly then
                        TurtlePlant()
                        LoopPath = TurtleForward()
                    elseif col > 1 then
                        TurtlePlant()
                        LoopPath = TurtleForward()
                    else
                        LoopPath = TurtleForward()
                    end
                else
                    break
                end
            end
            if row == 1 then
                y = y - 1
            end
            if LoopPath == false then
                break
            elseif row % 2 == 1 then
                turtle.turnRight()
                DecideCancel(timerest)
                TurtlePlant()
                LoopPath = TurtleForward()
                DecideCancel(timerest)
                turtle.turnRight()
            else
                turtle.turnLeft()
                DecideCancel(timerest)
                TurtlePlant()
                LoopPath = TurtleForward()
                DecideCancel(timerest)
                turtle.turnLeft()
            end
        else
            break
        end
    end
    if LoopPath then
        ReturnOriginalSquare(x, y)
        LoopPath = TurtleDown()
        CompactItems()
        TryEmptyChest()
    else
    end
end

function FarmSquare(x, y)
    local timerest = 0.5 --seconds
    local originaly = y
    LoopPath = true
    LoopPath = TurtleUp()
    for row = 1,x,1 do
        if LoopPath == true then
            DecideCancel(timerest)
            for col = 1,y,1 do
                DecideCancel(timerest)
                if LoopPath == true then
                    --before y is reduced and col is 1, skip breaking tile
                    if y ~= originaly then
                        TurtleSuckBreakPlant()
                        LoopPath = TurtleForward()
                    elseif col > 1 then
                        TurtleSuckBreakPlant()
                        LoopPath = TurtleForward()
                    else
                        LoopPath = TurtleForward()
                    end
                else
                    break
                end
            end
            if row == 1 then
                y = y - 1
            end
            if LoopPath == false then
                break
            elseif row % 2 == 1 then
                turtle.turnRight()
                DecideCancel(timerest)
                TurtleSuckBreakPlant()
                LoopPath = TurtleForward()
                DecideCancel(timerest)
                turtle.turnRight()
            else
                turtle.turnLeft()
                DecideCancel(timerest)
                TurtleSuckBreakPlant()
                LoopPath = TurtleForward()
                DecideCancel(timerest)
                turtle.turnLeft()
            end
        else
            break
        end
    end
    if LoopPath then
        ReturnOriginalSquare(x, y)
        LoopPath = TurtleDown()
        CompactItems()
        TryEmptyChest()
    else
    end
end

function farming.Interpreter(input)
    local timerest = 20 --seconds
    if input[1] == "version" then
        print(farming.GetVersion())
    elseif input[1] == "integrity" or input["-s"] then
        if IsStable == true then
            print("Farming module is in a stable version.")
        else
            print("Farming module is in an unstable version.")
        end
    elseif input[1] == "help" then
        if input[2] == nil then
            Help()
        else
            CommandsHelp(input[2])
        end
    --Farming things. The pain part
    elseif input[1] ~= nil and DoingTask == true then
        print("Turtle currently doing a task. Stop the task to initiate another.")
    elseif input[1] == "till" and input[2] ~= nil and input[3] ~= nil then
        DoingTask = true
        shell.run("clear")
        print("Tilling in a a square pattern of", input[2], "x", input[3] .. ". Repeatingly press \"s\" to immediately stop task.")
        TillSquare(tonumber(input[3]), tonumber(input[2])) --reversed due to for loops
        DoingTask = false
        print("Task completed.")
    elseif input[1] == "till" and input[2] ~= nil then
        DoingTask = true
        shell.run("clear")
        print("Tilling in a a square pattern of", input[2], "x", input[2] .. ". Repeatingly press \"s\" to immediately stop task.")
        TillSquare(tonumber(input[2]), tonumber(input[2]))
        DoingTask = false
        print("Task completed.")
    elseif input[1] == "farm" and input[2] ~= nil and input[3] ~= nil then
        DoingTask = true
        LoopPathAgain = true
        while LoopPathAgain do
            shell.run("clear")
            print("Farming in a a square pattern of", input[2], "x", input[3] .. ". Repeatingly press \"c\" to finish and stop task, repeatingly press \"s\" to immediately stop task.")
            FarmSquare(tonumber(input[3]), tonumber(input[2])) --reversed due to for loops
            if LoopPathAgain then
                print("Resting for",timerest,"seconds. Press \"s\" to stop task.")
                DecideCancel(timerest)
            end
        end
        DoingTask = false
        print("Task completed.")
    elseif input[1] == "farm" and input[2] ~= nil then
        DoingTask = true
        LoopPathAgain = true
        while LoopPathAgain do
            shell.run("clear")
            print("Farming in a a square pattern of", input[2], "x", input[2] .. ". Repeatingly press \"c\" to finish and stop task, repeatingly press \"s\" to immediately stop task.")
            FarmSquare(tonumber(input[2]), tonumber(input[2]))
            if LoopPathAgain then
                print("Resting for",timerest,"seconds. Press \"s\" to stop task.")
                DecideCancel(timerest)
            end
        end
        DoingTask = false
        print("Task completed.")
    elseif input[1] == "plant" and input[2] ~= nil and input[3] ~= nil then
        DoingTask = true
        shell.run("clear")
        print("Planting in a a square pattern of", input[2], "x", input[3] .. ". Repeatingly \"s\" to immediately stop task.")
        PlantSquare(tonumber(input[3]), tonumber(input[2])) --reversed due to for loops
        DoingTask = false
        print("Task completed.")
    elseif input[1] == "plant" and input[2] ~= nil then
        DoingTask = true
        shell.run("clear")
        print("Planting in a a square pattern of", input[2], "x", input[2] .. ". Repeatingly \"s\" to immediately stop task.")
        PlantSquare(tonumber(input[2]), tonumber(input[2])) --reversed due to for loops
        DoingTask = false
        print("Task completed.")
    elseif input[1] == nil then
        print("No command input.")
    else
        print("Invalid command. Use 'farming help' to view all commands.")
    end
end
return farming
