Bike = table.copy(Body)

function Bike:new(x, y)

	bike_sprite = data.bike.sprite.horny
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
        smoke = nil,
        explosion = nil,
        inited = false,
        smoke_frequency = 10,
        cccrutch = 0,
        --TODO add wrapper to trigger, a to grobber
    }
    Baka.trigger = TriggerTile:new(x, y, bike_width, bike_height, bike_doin, bike_sprite, Baka)

    setmetatable(Baka, self)
    self.__index = self;
    --OOP MOOPMENT
    --Baka.trigger.wrapper = self
    --self.trigger.wrapper = self

    return Baka
end

function Bike:move(dx, dy)
    local new_x = self.x + dx * Time.dt()
    local new_y = self.y + dy * Time.dt()

    self.x = new_x
    self.y = new_y
    -- no hitbox movement lol
end

function Bike:init_go_away()
    if not self.inited then
        local tx, ty = game.camera:transform_coordinates(self.x, self.y)
        self.smoke = make_smoke_ps(tx, ty)--, 200, 2000, 1, 2, 2, 3)
        self.explosion = make_explosion_ps(tx, ty, 200,500, 9,14,1,3) --100, 500
        self.smoke.autoremove = true
        self.explosion.autoremove = true

        self.inited = true
    end
end

function Bike:go_away()
    self.move_speed = self.move_speed + self.bike_acceleration * Time.dt()
    local ddx = self.bike_dx * self.move_speed
    local ddy = self.bike_dy * self.move_speed
    -- self.smoke = make_smoke_ps(self.x, self.y, 200, 2000, 1, 2, 2, 3)
    -- self.explosion = make_explosion_ps(self.x, self.y, 200,500, 9,14,1,3) --100, 500
    -- self.smoke.autoremove = true
    -- self.explosion.autoremove = true

    if self.lol then
        table.clear(self.lol.emittimers)
    else
        table.clear(self.smoke.emittimers)
        table.clear(self.explosion.emittimers)
    end

    self.cccrutch = self.cccrutch + 1
    if self.cccrutch == self.smoke_frequency then
        local tx, ty = game.camera:transform_coordinates(self.x, self.y)
        self.lol = make_smoke_ps(tx - 0.5 * self.width, ty + self.height / 4,
            200,
            2000,
             1, 7, 4, 6
        )
        self.lol.autoremove = true
        self.cccrutch = 0
    end

	self:move(ddx, ddy)
end

function Bike:update()
    self.trigger:update()
end

function Bike:draw()
    --self.trigger:draw()
    local tx, ty = game.camera:transform_coordinates(self.x, self.y)
    self.sprite:draw(tx, ty, self.flip, self.rotate)
    if self.inited then
        update_psystems()
        draw_psystems()
    end
end
