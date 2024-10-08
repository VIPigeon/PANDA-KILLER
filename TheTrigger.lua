TriggerTile = table.copy(Body)

function TriggerTile:new(x, y, width, height)
    trace('hello Im Tiler!😍')
    width = width or 1
    height = height or 8
    local TilerDerden = {
        sprite = data.panda.sprite.stay_boring,
        hitbox = { -- Чтобы взаимодействовать с миром тел нужно самому иметь тело << Tiler Derden 83 a.c. (C)
            offset_x = 0,
            offset_y = 0,
            width = width,
            height = height,
        },
        x = x, y = y,
    }

    setmetatable(TilerDerden, self)
    self.__index = self; return TilerDerden
end

function TriggerTile:trigger()
	trace('AAAAAAAAAAAAAAAAAAAAAHh💦💦💦')
end

local function is_colliding(collideable)
	if math.floor(collideable.x) > math.floor(self.x + self.hitbox.width) or
        math.floor(self.x) > math.floor(collideable.x + collideable.hitbox.width) or
        math.floor(collideable.y) > math.floor(self.y + self.hitbox.height) or
        math.floor(self.y) > math.floor(collideable.y + collideable.hitbox.height) then
        return false
    end
    return true
end

function TriggerTile:update()
	if is_colliding(game.player) then
		self:trigger()
	end
end