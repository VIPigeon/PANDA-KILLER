--[[

Прямоугольник -- основной примитив физики. Если мы хотим проверить какую-то
коллизию, то нам понадобится прямоугольник 🔲.

На умном языке, это axis aligned bounding box:
https://gdbooks.gitbooks.io/3dcollisions/content/Chapter1/aabb.html

--]]


Rect = {}

-- x, y -- координаты левого верхнего угла
-- x + w, y + h не включительно
function Rect:new(x, y, w, h)
    local obj = {
        x = x,
        y = y,
        w = w,
        h = h,
    }

    setmetatable(obj, self)
    return obj
end

function Rect:left()
    return self.x
end

function Rect:right()
    return self.x + self.w
end

function Rect:top()
    return self.y
end

function Rect:bottom()
    return self.y + self.h
end

function Rect:centerX()
    return self.x + self.w / 2
end

function Rect:centerY()
    return self.y + self.h / 2
end

function Rect:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Rect:moveLeftTo(x)
    self.x = x
end

function Rect:moveRightTo(x)
    self.x = x - self.w
end

function Rect:moveUpTo(y)
    self.y = y
end

function Rect:moveDownTo(y)
    self.y = y - self.h
end

function Rect:moveCenterTo(x, y)
    self.x = x - self.w / 2
    self.y = y - self.h / 2
end

function Rect:isObjectRight(object, objectWidth)
    return self:right() < object.x + objectWidth
end

function Rect:isObjectLeft(object)
    return self.x > object.x
end

function Rect:isObjectAbove(object)
    return self.y > object.y
end

function Rect:isObjectBelow(object, objectHeight)
    return self:bottom() < object.y + objectHeight
end

function Rect:isObjectInside(object, objectWidth, objectHeight)
    return not self:isObjectAbove(object) and
           not self:isObjectBelow(object, objectHeight) and
           not self:isObjectLeft(object) and
           not self:isObjectRight(object, objectWidth)
end

--[[

+---+     +-+      +---+
|   |  +  | |   =  |   |
+---+     | |      |   |
          +-+      +---+

--]]
function Rect:combine(other)
    local x1 = math.min(self.x, other.x)
    local y1 = math.min(self.y, other.y)
    local x2 = math.max(self.x + self.w, other.x + other.w)
    local y2 = math.max(self.y + self.h, other.y + other.h)
    return {
        x = x1,
        y = y1,
        w = x2 - x1,
        h = y2 - y1,
    }
end

function Rect:draw()
    local x, y = game.camera_window:transform_coordinates(self.x, self.y)
    rect(x, y, self.w, self.h, 11)
end

Rect.__index = Rect
