ChildBody = {}

function ChildBody:new(parent, x, y, sprite, flip)
    local object = {
        parent = parent,
        x = x,
        y = y,
        sprite = sprite,
        flip = flip,
        rotate = 0,
    }

    setmetatable(object, self)
    return object
end

function ChildBody:draw()
    local tx, ty = game.camera:transform_coordinates(self.parent.x + self.x, self.parent.y + self.y)
    self.sprite:draw(tx, ty, self.flip, self.rotate)
end

ChildBody.__index = ChildBody
