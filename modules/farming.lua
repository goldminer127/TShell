--Module info
Version = "BETA 0.1.0"
IsStable = false

--Returns string (version)
function GetVersion()
    return Version
end

--Returns bool
function GetStability()
    return IsStable
end

--Module Functions

function TurtleForward()
    local canmove = turtle.forward()
    turtle.suck()
    if canmove == false then
        print("Cannot move. Either something is blocking the way or fuel is needed.\nType \"resume\" to resume trail.")
        if read() == "resume" then
            TurtleForward()
        end
    end
end

function FarmSquare(x)
    for row = 1, x do
        for col = 1, x do
            TurtleForward()
        end
        if row % 2 == 1 then
            turtle.turnRight()
            TurtleForward()
            turtle.turnRight()
        else
            turtle.turnLeft()
            TurtleForward()
            turtle.turnLeft()
        end
    end
end

function Interpreter(input)
    if input[1] == "-version" then
        print("Farming",Version)
    elseif input[1].count == 2 then
        
    end
end