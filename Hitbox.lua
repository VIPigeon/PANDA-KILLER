--Hitbox = table.copy(Rect)
Hitbox = {}

function Hitbox:new(x1, y1, x2, y2)
    local obj = {
        x1 = x1,
        y1 = y1,
        x2 = x2,
        y2 = y2,
        shiftX = 0,
        shiftY = 0,
        type = 'hitbox',
    }

    setmetatable(obj, self)
    self.__index = self
    return obj
end


function Hitbox:new_with_shift(x1, y1, x2, y2, shiftX, shiftY)
   local obj = {
        x1 = x1, y1 = y1,
        x2 = x2, y2 = y2,
        shiftX = shiftX,
        shiftY = shiftY
    }
    -- чистая магия!
    setmetatable(obj, self)
    self.__index = self
    return obj
end


function Hitbox:collide(hb)
    if hb.type == 'hitcircle' then
        return hb:collide(self)
    end
    if math.floor(hb.x1) > math.floor(self.x2) or
        math.floor(self.x1) > math.floor(hb.x2) or
        math.floor(hb.y1) > math.floor(self.y2) or
        math.floor(self.y1) > math.floor(hb.y2) then
        return false
    end
    return true
end


function Hitbox:mapCheck()
    return gm.getTileType(self.x1, self.y1) == TileType.Void
        and gm.getTileType(self.x1, self.y2) == TileType.Void
        and gm.getTileType(self.x2, self.y1) == TileType.Void
        and gm.getTileType(self.x2, self.y2) == TileType.Void
end


function Hitbox:set_xy(x, y)
    x = x + self.shiftX
    y = y + self.shiftY
    local dx = x - self.x1
    local dy = y - self.y1
    self.x1 = x
    self.y1 = y
    self.x2 = self.x2 + dx
    self.y2 = self.y2 + dy
end


function Hitbox:draw(color)
    local x1 = self.x1 - gm.x*8 + gm.sx
    local y1 = self.y1 - gm.y*8 + gm.sy
    local w = (self.x2 - self.x1)
    local h = (self.y2 - self.y1)
    rect(x1, y1, w, h, color)
end


function Hitbox:get_center()
    local x1 = self.x1
    local x2 = self.x2
    local y1 = self.y1
    local y2 = self.y2
    return {
        x = x1 + (x2 - x1) / 2,
        y = y1 + (y2 - y1) / 2
    }
end

function Hitbox:getWidth()
    return self.x2 - self.x1
end

function Hitbox:getHeight()
    return self.y2 - self.y1
end

return Hitbox
