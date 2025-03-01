Hat = {}

function Hat:new(x, y, velocity_x, velocity_y)
    local object = {
        x = x,
        y = y,
        velocity = {
            x = velocity_x,
            y = velocity_y,
        },
        hitbox = Hitbox:new(0, 6, 8, 2),
        physics_settings = {
            gravity = 0.5 * PLAYER_GRAVITY,
            friction = 0.5 * PLAYER_FRICTION,
            min_horizontal_velocity = PLAYER_MIN_HORIZONTAL_VELOCITY,
        },
        sprite = SPRITES.hat,
    }

    setmetatable(object, self)
    return object
end

function Hat:update()
    Physics.update(self)
end

function Hat:draw()
    local tx, ty = game.camera:transform_coordinates(self.x, self.y)
    self.sprite:draw(tx, ty)
end

Hat.__index = Hat
