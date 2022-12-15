--Imports
local modules = require("modules/functions")

--Table used to hold all functions
local mining = {}

--Module info
Version = "BETA 0.1.0"
IsStable = false

--Returns string (version)
function mining.getVersion()
    return Version
end

--Returns bool
function mining.getStability()
    return IsStable
end

--Module functions

--Module Commands

function help()
    print(Format("mine", "till", 15))
    print(Format("help", "integrity", 15))
    print(Format("plant", "version", 15))
end

--[[ Patterns ]]--

--[ RECTANGLE PATTERN ]--

function mineRectangle(length,width,height)
    local continuepath,quarry,foundbedrock = true,false,false
    local h = 1
    if height == nil then height,quarry = 1,true end --Default values
    length = length - 1
    continuepath = modules.forward(continuepath)
    while h <= height do
        for w = 1,width,1 do
            for l = 1,length,1 do
                continuepath = modules.forward(continuepath)
                if quarry == true and foundbedrock == false then foundbedrock = modules.detectBlockDown("minecraft:bedrock") end
                --Empty chest proceedure
                if modules.isFull() == true then
                    local state = modules.getState()
                    local lastx,lasty,lastz,lastdirection = state.getXOffset(),state.getYOffset(),state.getZOffset(),state.getDirection()
                    modules.rectangleReturnOriginalSquare()
                    modules.tryEmptyChest()
                    modules.returnToLocation(lastx,lasty,lastz,lastdirection)
                end
            end

            if width % 2 == 0 and h % 2 == 0 and w ~= width then
                if w % 2 == 1 then
                    modules.turnLeft()
                    continuepath = modules.forward(continuepath)
                    modules.turnLeft()
                else
                    modules.turnRight()
                    continuepath = modules.forward(continuepath)
                    modules.turnRight()
                end
                if quarry == true and foundbedrock == false then foundbedrock = modules.detectBlockDown("minecraft:bedrock") end
            elseif w ~= width then
                if w % 2 == 1 then
                    modules.turnRight()
                    continuepath = modules.forward(continuepath)
                    modules.turnRight()
                else
                    modules.turnLeft()
                    continuepath = modules.forward(continuepath)
                    modules.turnLeft()
                end
                if quarry == true and foundbedrock == false then foundbedrock = modules.detectBlockDown("minecraft:bedrock") end
            end
        end

        if quarry == true then
            if quarry == true and foundbedrock == false then foundbedrock = modules.detectBlockDown("minecraft:bedrock") end
            if foundbedrock == true then
                print("Bedrock detected, finishing quarry...")
                break
            else
                height = height + 1
            end
        end
        if width % 2 == 0 and h ~= height then
            if h % 2 == 0 then
                modules.turnTo(3)
                continuepath = modules.down(continuepath)
            else
                modules.turnTo(1)
                continuepath = modules.down(continuepath)
            end
        elseif width % 2 == 1 and h ~= height then
            if h % 2 == 1 then
                modules.turnTo(3)
                continuepath = modules.down(continuepath)
            else
                modules.turnTo(1)
                continuepath = modules.down(continuepath)
            end
        elseif continuepath == false then
            break
        end
        h = h + 1
    end
    print("returning...")
    modules.rectangleReturnOriginalSquare()
end


--[ CYLINDAR PATTERN ]--

--[[
    Calculates the starting zone for circular patterns.
    Example with semi-circle with diameter 7 (T = turle, 0 = blocks to mine)

    T - -
        0 0 0
      0 0 0 0 0
    0 0 0 0 0 0 0

    Calcuatuions:
    Diameter must be an odd number. If not subtract diameter by 1.

    diameter - (((diameter - 5) / 2) + 4)
    diameter = 7
    7 - (((7 - 5) / 2) + 4) = 2
    
  ]]
  function startingZone(diameter)
    local reduce,movestostart --Holds the value to reduce from diameter to determine starting zone
    if diameter % 2 == 1 then
        --Calculates reduce to subtract from diameter to determine starting zone
        reduce = ((diameter - 5) / 2) + 4
    else
        --Calculates reduce to subtract from diameter to determine starting zone
        local tempdiameter = diameter - 1
        reduce = ((tempdiameter - 5) / 2) + 4
    end
    movestostart = diameter - reduce
    return movestostart
end

function turnFirstHalf(row,continuepath)
    if row % 2 == 1 then
        modules.turnLeft()
        continuepath = modules.forward(continuepath)
        modules.turnRight()
        continuepath = modules.forward(continuepath)
        modules.turnLeft(2)
        continuepath = modules.forward(continuepath)
    else
        modules.turnRight()
        continuepath = modules.forward(continuepath)
        modules.turnLeft()
        continuepath = modules.forward(continuepath)
        modules.turnRight(2)
        continuepath = modules.forward(continuepath)
    end
    return continuepath
end

function handleCenter(row,diameter,maxmove,continuepath)
    if diameter % 2 == 1 then
        if row % 2 == 1 then
            modules.turnRight()
            continuepath = modules.forward(continuepath)
            modules.turnRight()
        else
            modules.turnLeft()
            continuepath = modules.forward(continuepath)
            modules.turnLeft()
        end

        for currentwidth = 1,maxmove,1 do
            continuepath = modules.forward(continuepath)
        end

        if row % 2 == 1 then
            modules.turnLeft()
            continuepath = modules.forward(continuepath)
            modules.turnLeft()
        else
            modules.turnRight()
            continuepath = modules.forward(continuepath)
            modules.turnRight()
        end
    else
        if row % 2 == 1 then
            modules.turnRight()
            continuepath = modules.forward(continuepath)
            modules.turnRight()
        else
            modules.turnLeft()
            continuepath = modules.forward(continuepath)
            modules.turnLeft()
        end

        for currentwidth = 1,maxmove,1 do
            continuepath = modules.forward(continuepath)
        end
    end

    return continuepath
end

function turnSecondHalf(row,continuepath)
    if row % 2 == 1 then
        continuepath = modules.forward(continuepath)
        modules.turnLeft(2)
        continuepath = modules.forward(continuepath)
        modules.turnRight()
        continuepath = modules.forward(continuepath)
        modules.turnLeft()
    else
        continuepath = modules.forward(continuepath)
        modules.turnRight(2)
        continuepath = modules.forward(continuepath)
        modules.turnLeft()
        continuepath = modules.forward(continuepath)
        modules.turnRight()
    end
    return continuepath
end

function resetCircle(diameter,continuepath)
    if diameter % 2 == 1 then
        modules.turnRight(2)
        continuepath = modules.forward(continuepath)
        continuepath = modules.forward(continuepath)
        modules.turnLeft()
    else
        modules.turnLeft()
    end

    for col = 1,diameter - 1,1 do
        continuepath = modules.forward(continuepath)
    end

    modules.turnLeft()
    continuepath = modules.down(continuepath)
    return continuepath
end

function returnCircle(diameter,height,startingpos,continuepath)
    if diameter % 2 == 1 then
        modules.turnRight(2)
        continuepath = modules.forward(continuepath)
        continuepath = modules.forward(continuepath)
        modules.turnLeft()
    else
        modules.turnLeft()
    end

    for col = 1,diameter-1,1 do
        continuepath = modules.forward(continuepath)
    end

    for height = 1,height-1,1 do
        continuepath = modules.up(continuepath)
    end
    continuepath = modules.forward(continuepath)
    modules.turnRight()
    for col = 1,startingpos,1 do
        continuepath = modules.forward(continuepath)
    end
    modules.turnRight()
    
    return continuepath
end

--[[
  Circles with odd diameter has a flat edge of 3 blocks
  Circles with even diameter has a flat edge of 2 blocks
  
  Example Circles:
     Diameter 6
        0 0
      0 0 0 0
    0 0 0 0 0 0
    0 0 0 0 0 0
      0 0 0 0
        0 0
  
     Diameter 7
        0 0 0
      0 0 0 0 0
    0 0 0 0 0 0 0
    0 0 0 0 0 0 0
    0 0 0 0 0 0 0
      0 0 0 0 0
        0 0 0
  ]]
function mineCylindar(diameter,height)
    local continuepath = true
    local maxmove --Max move per row in circle. Does not count turning
    local movetostart = startingZone(diameter) --moves turtle to starting position

    --Move turtle to start
    modules.turnRight()
    for i = 1,movetostart,1 do
        continuepath = modules.forward(continuepath)
    end
    modules.turnLeft()
    continuepath = modules.forward(continuepath)
    modules.turnRight()

    --Mine cylindar
    for currentheight = 1,height,1 do
        local row = 1
        --Odd diameters have 3 blocks flat edge and even have 2
        if diameter % 2 == 1 then
            maxmove = 1
        else
            maxmove = 0
        end

        --First half
        for i = 1,2,1 do
            maxmove = maxmove + 1
            for currentwidth = 1,maxmove,1 do
                continuepath = modules.forward(continuepath)
            end
            continuepath = turnFirstHalf(row,continuepath)
            row = row + 1
        end

        if diameter % 2 == 1 then

            repeat
                maxmove = maxmove + 2
                for currentwidth = 1,maxmove,1 do
                    continuepath = modules.forward(continuepath)
                end
                if maxmove ~= diameter - 2 then
                    continuepath = turnFirstHalf(row,continuepath)
                end
                row = row + 1
            until maxmove == diameter - 2

            continuepath = handleCenter(row,diameter,diameter - 1,continuepath)

            row = row + 1
        else
            repeat
                maxmove = maxmove + 2
                for currentwidth = 1,maxmove,1 do
                    continuepath = modules.forward(continuepath)
                end
                if maxmove ~= diameter - 2 then
                    continuepath = turnFirstHalf(row,continuepath)
                end
                row = row + 1
            until maxmove == diameter - 2

            continuepath = handleCenter(row,diameter,diameter - 1,continuepath)
        end

        --Reset maxmove for second half
        maxmove = diameter

        --Second half
        if diameter % 2 == 1 then
            repeat
                maxmove = maxmove - 2
                for currentwidth = 1,maxmove,1 do
                        continuepath = modules.forward(continuepath)
                end

                if maxmove >= 3 then
                    continuepath = turnSecondHalf(row,continuepath)
                end
                row = row + 1
            until maxmove == 3
        else
            continuepath = turnSecondHalf(row,continuepath)
            row = row + 1

            maxmove = maxmove - 2
            repeat
                maxmove = maxmove - 2
                for currentwidth = 1,maxmove,1 do
                        continuepath = modules.forward(continuepath)
                end
                if maxmove >= 2 then
                    continuepath = turnSecondHalf(row,continuepath)
                end
                row = row + 1
            until maxmove == 2
        end

        for currentwidth = 1,maxmove - 1,1 do
            continuepath = modules.forward(continuepath)
        end
        row = row + 1
        
        if(continuepath == false) then
            break
        elseif currentheight ~= height then
            continuepath = resetCircle(diameter,continuepath)
        end
    end
    continuepath = returnCircle(diameter,height,movetostart,continuepath)
    modules.tryEmptyChest()

end

--Interpreter

function mining.interpreter(input)
    if input[1] == "mine" then
        if input[2] == nil then
            print("Needs specified pattern.")
        elseif input[2] == "rectangle" then
            if input[3] == nil or input[4] == nil or input[5] == nil then
                print("Insufficient arguements")
            else
                if tonumber(input[3]) ~= nil or tonumber(input[4]) ~= nil or tonumber(input[5]) ~= nil then
                    mineRectangle(tonumber(input[3]),tonumber(input[4]),tonumber(input[5]))
                else
                    print("Invalid arguements")
                end
            end
        elseif input[2] == "cylinder" then
            if input[3] == nil or input[4] == nil then
                print("Insufficient arguements")
            else
                if tonumber(input[3]) ~= nil or tonumber(input[4]) ~= nil then
                    mineCylindar(tonumber(input[3]),tonumber(input[4]))
                else
                    print("Invalid arguements")
                end
            end
        end
    elseif input[1] == "quarry" then
        if input[2] == nil or input[3] == nil then
            print("Insufficient arguements")
        else
            if tonumber(input[2]) ~= nil or tonumber(input[3]) ~= nil then
                mineRectangle(tonumber(input[2]),tonumber(input[3]))
            else
                print("Invalid arguements")
            end
        end
    end
end

return mining