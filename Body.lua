Body = {}

function Body:new(sprite, x, y)
    local obj = {
        x = x,
        y = y,
        sprite = sprite,
        flip = 0,
        rotate = 0,
    }

    setmetatable(obj, self)
    return obj
end

function Body:draw()
    local tx, ty = game.camera_window:transform_coordinates(self.x, self.y)
    self.sprite:draw(tx, ty, self.flip, self.rotate)
end

Body.__index = Body
