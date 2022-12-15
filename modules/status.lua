--self Class--
Status = {}

function Status.new()
    local self = {}
    local direction = 1
    local xoffset = 0
    local yoffset = 0
    local zoffset = 0

    function self.getDirection()
        return direction
    end
    
    function self.getXOffset()
        return xoffset
    end
    
    function self.getYOffset()
        return yoffset
    end
    
    function self.getZOffset()
        return zoffset
    end
    
    --[[Direction can only be between 1-4. 1 = front, 2 = rightfacing, 3 = back, 4 = leftfacing
    Returns true on success, false on fail]]
    function self.setDirection(direction)
        if direction > 4 and direction < 1 then
            return false
        else
            direction = direction
            return true
        end
    end
    
    --[[Pass integer as negative to subtract or positive to add to direction  
    1 = front, 2 = rightfacing, 3 = back, 4 = leftfacing]]
    function self.modifyDirection(newdirection)
        if direction == 1 and newdirection < 0 then
            direction = 4
        elseif direction == 4 and newdirection > 0 then
            direction = 1
        else
            direction = direction + newdirection
        end
    end
    
    --[[Pass integer as negative to subtract or positive to add to xoffset]]
    function self.modifyXOffset(offset)
        xoffset = xoffset + offset
    end
    
    --[[Pass integer as negative to subtract or positive to add to yoffset]]
    function self.modifyYOffset(offset)
        yoffset = yoffset + offset
    end
    
    --[[Pass integer as negative to subtract or positive to add to zoffset]]
    function self.modifyZOffset(offset)
        zoffset = zoffset + offset
    end

    return self
end

return Status