--Imports
local modules = require("modules/functions")

--Headers
local farming = {}

--Module info
Version = "BETA 0.1.4"
IsStable = true

--Globals
DoingTask = false


--Retrieve module info
function farming.getVersion()
    return Version
end

function farming.getStability()
    return IsStable
end

--[[ --Farming Functions-- ]]

--[[ Decide which task is being done ]]
function decideType(type)
    if type == 1 then
        return till()

    elseif type == 2 then
        return plant()

    elseif type == 3 then
        return breakSuckReplant()

    else
        return nil
    end
end

--[[ Till tillable blocks. Clears any clearable debris or objects ]]
function till()
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

--[[ Plants any plantable seeds (currently only vanilla seeds) ]]
function plant()
    local data = turtle.getItemDetail()

    if data ~= nil and (data.name == "minecraft:wheat_seeds" or data.name == "minecraft:potato" or data.name == "minecraft:carrot" or data.name == "minecraft:beetroot_seeds") then
        turtle.placeDown()

    else
        local validseed = false

        for slot = 1,16,1 do

            turtle.select(slot) 
            data = turtle.getItemDetail()

            if data == nil then --Do nothing if no valid seed is found.

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
                plant()

            elseif response == "cancel" then
                looppath = false
            end

        else
            turtle.placeDown()
        end
    end
end

--[[
    Harvest fully grown plants (Only vanilla plants currently.
    Pick up any item on the ground.
    Replant exact same plant that was harvested. If no seeds of the same plant
    is available, replant next available seed. If no seeds do not plant anything.
]]
function breakSuckReplant()
    local success,blockid = turtle.inspectDown()

    --Check if block is tilled, if not leave it.
    --Only harvests fully grown crops
    if (blockid.name == "minecraft:wheat" or blockid.name == "minecraft:carrots" or blockid.name == "minecraft:potatoes" or blockid.name == "minecraft:beetroots") and blockid.metadata == 7 then
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
        --Decide to keep or not
        --print("Could not replant same plant, planting next available seed...")
        plant()

    else
        turtle.placeDown()
    end
end

--[[
    Attempt to empty inventory into adjacent chest. Empties half the stack of any plantable items.
    Fully empties non-plantable items.
    Keeps any fuel items.
]]
function tryEmptyChest()
    for x = 1,4,1 do

        modules.turnRight()
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

--Perform any rectangular pattern tasks.
function rectangleTask(x, y, task)
    local looppath,looproute,cancelrepeat = true,true,false
    local originaly = y
    if task == 3 then
        cancelrepeat = true
    end

    looppath,looproute = modules.up(looppath,looproute,cancelrepeat)

    for row = 1,x,1 do

        if looppath == true then

            for col = 1,y,1 do

                if looppath == true then
                    --before y is reduced and col is 1, skip breaking tile
                    if y ~= originaly then
                        decideType(task)
                        looppath,looproute = modules.forward(looppath,looproute,cancelrepeat)

                    elseif col > 1 then
                        decideType(task)
                        looppath,looproute = modules.forward(looppath,looproute,cancelrepeat)

                    else
                        looppath,looproute = modules.forward(looppath,looproute,cancelrepeat)
                    end

                    completedcol = col

                else
                    break
                end

            end

            if task == 3 then
                modules.compactItems()
            end

            --Starting position is y + 1 the specified dimension. Must subtract 1 to adjust for specified dimensons

            if looppath == false then
                break

            elseif row % 2 == 1 and row ~= x then
                modules.turnRight()
                completedcol = 0

                decideType(task)

                looppath,looproute = modules.forward(looppath,looproute,cancelrepeat)
                modules.turnRight()

            elseif row ~= x then
                modules.turnLeft()
                completedcol = 0

                decideType(task)

                looppath,looproute = modules.forward(looppath,looproute,cancelrepeat)
                modules.turnLeft()
            end

            if looppath == true then
                completedrow = row

                if row == 1 then
                    y = y - 1
                end
            end

        else
            break
        end

    end

    looppath,looproute = modules.rectangleReturnOriginalSquare(looppath, looproute, cancelrepeat)

    tryEmptyChest()
    modules.compactItems()

    return looproute
end

--[[ --Command Functions-- ]]

function help()
    print(modules.format("farm", "integrity", 15))
    print(modules.format("help", "version", 15))
    print(modules.format("till", " ", 15))
end

function commandshelp(command)
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

--[[ Read commands from user ]]
function farming.interpreter(input)
    local timerest = 60 --seconds

    if input[1] == "version" then
        print(farming.getVersion())

    elseif input[1] == "integrity" or input["-s"] then
        if IsStable == true then
            print("Farming module is in a stable version.")

        else
            print("Farming module is in an unstable version.")
        end

    elseif input[1] == "help" then
        if input[2] == nil then
            help()

        else
            commandshelp(input[2])
        end

    --Farming things. The pain part
    elseif input[1] ~= nil and DoingTask == true then
        print("Turtle currently doing a task. Stop the task to initiate another.")

    elseif input[1] == "till" and input[2] ~= nil and input[3] ~= nil then
        DoingTask = true
        shell.run("clear")

        print("Tilling in a a square pattern of", input[2], "x", input[3] .. ". Repeatingly press \"s\" to immediately stop task.")
        rectangleTask(tonumber(input[3]), tonumber(input[2]), 1) --reversed due to for loops
        DoingTask = false
        print("Task completed.")

    elseif input[1] == "till" and input[2] ~= nil then
        DoingTask = true
        shell.run("clear")

        print("Tilling in a a square pattern of", input[2], "x", input[2] .. ". Repeatingly press \"s\" to immediately stop task.")
        rectangleTask(tonumber(input[2]), tonumber(input[2]), 1)
        DoingTask = false
        print("Task completed.")

    elseif input[1] == "plant" and input[2] ~= nil and input[3] ~= nil then
        DoingTask = true
        shell.run("clear")

        print("Planting in a a square pattern of", input[2], "x", input[3] .. ". Repeatingly \"s\" to immediately stop task.")
        rectangleTask(tonumber(input[3]), tonumber(input[2]), 2) --reversed due to for loops
        DoingTask = false
        print("Task completed.")

    elseif input[1] == "plant" and input[2] ~= nil then
        DoingTask = true
        shell.run("clear")

        print("Planting in a a square pattern of", input[2], "x", input[2] .. ". Repeatingly \"s\" to immediately stop task.")
        rectangleTask(tonumber(input[2]), tonumber(input[2]), 2) --reversed due to for loops
        DoingTask = false
        print("Task completed.")

    elseif input[1] == "farm" and input[2] ~= nil and input[3] ~= nil then
        DoingTask = true
        local looproute = true

        while looproute do

            shell.run("clear")

            print("Farming in a a square pattern of", input[2], "x", input[3] .. ". Repeatingly press \"c\" to finish and stop task, repeatingly press \"s\" to immediately stop task.")
            looproute = rectangleTask(tonumber(input[3]), tonumber(input[2]), 3) --reversed due to for loops

            if looproute then
                print("Resting for",timerest,"seconds. Press \"s\" to stop task.")
                looproute = modules.decideCancel(timerest, nil, looproute)
            end
            
        end

        DoingTask = false
        print("Task completed.")

    elseif input[1] == "farm" and input[2] ~= nil then
        DoingTask = true
        local looproute = true

        while looproute do

            shell.run("clear")
            print("Farming in a a square pattern of", input[2], "x", input[2] .. ". Repeatingly press \"c\" to finish and stop task, repeatingly press \"s\" to immediately stop task.")
            looproute = rectangleTask(tonumber(input[2]), tonumber(input[2]), 3)

            if looproute then
                print("Resting for",timerest,"seconds. Press \"s\" to stop task.")
                looproute = modules.decideCancel(timerest, nil, looproute)
            end

        end

        DoingTask = false
        print("Task completed.")

    elseif input[1] == nil then
        print("No command input.")

    else
        print("Invalid command. Use 'farming help' to view all commands.")
    end
end

return farming
