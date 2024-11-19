Bike = table.copy(Body)

function Bike:new(x, y)
	trace('Hello Baka! I\'m Bake for you😤')

	bike_sprite = data.bike.sprite.horny
	--trace('bike sprite '..tostring(bike_sprite))
	bike_doin = TriggerActions.bike
	bike_width = 16
	bike_height = 16

    local Baka = {
        sprite = bike_sprite,
        x = x,
        y = y,
        width = bike_width,
        height = bike_height,
        move_speed = 16,
        bike_acceleration = 20,
        bike_dx = 1,
        bike_dy = 0,
        status = 'pouting',
        --TODO add wrapper to trigger, a to grobber
    }
    Baka.trigger = TriggerTile:new(x, y, bike_width, bike_height, bike_doin, bike_sprite, Baka)

    setmetatable(Baka, self)
    self.__index = self;
    --OOP MOOPMENT
    --Baka.trigger.wrapper = self
    --trace(tostring(self.trigger))
    --self.trigger.wrapper = self

    return Baka
end

function Bike:move(dx, dy)
	local new_x = self.x + dx * Time.dt()
	local new_y = self.y + dy * Time.dt()

	self.x = new_x
	self.y = new_y
	trace(self.x..' 👉👈 '..self.y)
	-- no hitbox movement lol
end

function Bike:go_away()
	self.move_speed = self.move_speed + self.bike_acceleration * Time.dt()
	local ddx = self.bike_dx * self.move_speed
	local ddy = self.bike_dy * self.move_speed
	self:move(ddx, ddy)
end

function Bike:update()
	self.trigger:update()
end

function Bike:draw()
	self.trigger:draw()
	--trace(self.sprite)
	local tx, ty = game.camera_window:transform_coordinates(self.x, self.y)
    self.sprite:draw(tx, ty, self.flip, self.rotate)
end