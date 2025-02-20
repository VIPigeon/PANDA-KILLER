--[[

Body -- пережиток прошлого, который используется для панд.

Это класс, от которого можно отнаследоваться, чтобы спрайт
автоматически рисовался. Какие глупости.

--]]

Body = {}

function Body:new(sprite, x, y)
    local object = {
        x = x,
        y = y,
        sprite = sprite,
        flip = 0,
        rotate = 0,
    }

    setmetatable(obj, self)
    return object
end

function Body:draw()
    local tx, ty = game.camera:transform_coordinates(self.x, self.y)
    if self.flip == 1 then
        -- Ну тип ладно. Вообще довольно дурацкий костыль, не знаю как это лучше сделать.
        tx = tx - 8 * (self.sprite.animation.width - 1)
    end
    self.sprite:draw(tx, ty, self.flip, self.rotate)
end

Body.__index = Body
