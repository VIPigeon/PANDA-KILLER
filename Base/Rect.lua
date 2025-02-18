--[[

Прямоугольник -- основной примитив физики. Если мы хотим проверить какую-то
коллизию, то нам понадобится прямоугольник 🔲.

На умном языке, это axis aligned bounding box (AABB):
https://gdbooks.gitbooks.io/3dcollisions/content/Chapter1/aabb.html

--]]

Rect = {}

-- x, y -- координаты левого верхнего угла
-- x + w, y + h не включительно
function Rect:new(x, y, w, h)
    local object = {
        x = x,
        y = y,
        w = w,
        h = h,
    }

    setmetatable(object, self)
    return object
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

function Rect:center_x()
    return self.x + self.w / 2
end

function Rect:center_y()
    return self.y + self.h / 2
end

function Rect:move(dx, dy)
    self.x = self.x + dx
    self.y = self.y + dy
end

function Rect:move_left_to(x)
    self.x = x
end

function Rect:move_right_to(x)
    self.x = x - self.w
end

function Rect:move_up_to(y)
    self.y = y
end

function Rect:move_down_to(y)
    self.y = y - self.h
end

function Rect:move_center_to(x, y)
    self.x = x - self.w / 2
    self.y = y - self.h / 2
end

function Rect:is_object_right(object, object_width)
    return self:right() < object.x + object_width
end

function Rect:is_object_left(object)
    return self.x > object.x
end

function Rect:is_object_above(object)
    return self.y > object.y
end

function Rect:is_object_below(object, object_height)
    return self:bottom() < object.y + object_height
end

function Rect:is_object_inside(object, object_width, object_height)
    return not self:is_object_above(object) and
           not self:is_object_below(object, object_height) and
           not self:is_object_left(object) and
           not self:is_object_right(object, object_width)
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
    local x2 = math.max(self:right(), other:right())
    local y2 = math.max(self:bottom(), other:bottom())
    return {
        x = x1,
        y = y1,
        w = x2 - x1,
        h = y2 - y1,
    }
end

function Rect:draw(color)
    color = color or 1
    local x, y = game.camera:transform_coordinates(self.x, self.y)
    rect(x, y, self.w, self.h, color)
end

Rect.__index = Rect
