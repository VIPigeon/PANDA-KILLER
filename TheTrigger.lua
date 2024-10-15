TriggerTile = table.copy(Body)

function TriggerTile:new(x, y, width, height)
    trace('hello Im Tiler!😍')
    width = width or 1
    height = height or 8
    local TilerDerden = {
        sprite = data.panda.sprite.stay_boring,
        hitbox = Hitbox:new(0,0,width, height),
        x = x, y = y,
    }

    setmetatable(TilerDerden, self)
    self.__index = self; return TilerDerden
end

function TriggerTile:trigger()
	trace('AAAAAAAAAAAAAAAAAAAAAHh💦💦💦')
end

function TriggerTile:monitor_player()
    trace(game.player.x..' -- '..game.player.y)
end

function TriggerTile:is_colliding(collideable)
	return Physics.check_collision_obj_obj(self, collideable)
end

function TriggerTile:draw()
    Hitbox.rect_of(self):draw()
end

function TriggerTile:update()
	if self:is_colliding(game.player) then
		self:trigger()
	end
    
    --self:monitor_player()
end