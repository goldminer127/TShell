--General Functions

--Splits string with specified character
function Split(string1, string2)
    local stringInsert = ""
    local splitString = {}
    for char in string1:gmatch "." do
        if char == " " then
            table.insert(splitString, stringInsert)
            stringInsert = ""
        else
            stringInsert = stringInsert .. char
        end
    end
    return stringInsert
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

function Turtle(input)
    if input[0] == nil then
        print("Use 'turtle help' to view available commands. Use 'turtle help <command> to read about a specific command.")
    elseif input[0] == "get" then

    end
end



--Turtle Commands
function Command(command)
    while true do
        local input = Split(read())
        local prefix = input[0]
        if prefix == nil then
            print("\n")
        --Default turtle commands
        elseif input[0] == "turtle" then
        end
    end
end
--Main
print(Format("Hello", "[ OK ]"))
print(Format("Loading Framework", "[ OK ]"))
local file = http.get(https://github.com/goldminer127/TurtleOS/blob/main/README.md)
        local handle = file.readAll()
        file.close()

        local newFile = fs.open("README.md", "w")
        newFile.write(handle)
        file.close()
--shell.run("pastebin","get","1F1cR1LH","turtle")
--shell.run("pastebin get 1F1cR1LH turtle")