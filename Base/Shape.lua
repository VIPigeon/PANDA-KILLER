--[[

Shape -- несколько прямоугольников, склееных вместе. Когда просто
прямоугольника не хватает.

--]]

Shape = {}

function Shape:new(rects)
    rects = rects or {}
    local object = {
        rects = rects
    }

    setmetatable(object, self)
    return object
end

function Shape:draw(color)
    for _, rect in ipairs(self.rects) do
        rect:draw(color)
    end
end

Shape.__index = Shape
