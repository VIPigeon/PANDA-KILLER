Panda = table.copy(Body)

-- vertical velocity constants
local UPPING_CONSTANT = -1
local FALLING_CONSTANT = 1

-- horizontal velocity constants

local LEFTING_CONSTANT = -1
local RIGHTING_CONSTANT = 1

--ultimate velocity constant
local CONSTANT_CONSTANT = 0

local DEFAULT_HORIZONTAL_MOVEMENT_SPEED = 10
local READY_TO_JUMP_DISTANCE_CONSTANT = 10
local VERTICAL_JUMP_SPEED_CONSTANT = 20
local HORIZONTAL_JUMP_SPEED_CONSTANT = 10
local VERTICAL_AFTERJUMP_SPEED_CONSTANT = 1 -- so called anti_jump_speed
local HORIZONTAL_AFTERJUMP_SPEED_CONSTANT = 4
local DEFAULT_JUMP_STRENTH = 1
local JUMP_STRENTH_FADING = 1

function Panda:new(x, y)
    trace('Im spawned SENPAI!😍')
    local ahahahahha = {
        sprite = data.panda.sprite.stay_boring,
        hitbox = Hitbox:new(2, 0, 4, 8),
        --flip = 0,
        --rotate = 0,
        x = x, y = y,
        velocity = {
            x = 0,
            y = 0,
        },
        current_horizontal_speed = 0,
        current_vertical_speed = 0,
        target = {
            x = nil,
            y = nil,
        },
        current_jump_strenth = DEFAULT_JUMP_STRENTH, -- в кадрах наверное, хотя это в корне не верно
        health = 100,
    }

    setmetatable(ahahahahha, self)
    return ahahahahha
end

local function check_player_location()
    local goto_x = game.player.x
    local goto_y = game.player.y
    return {x = goto_x, y = goto_y}
end

function Panda:update_target()
    -- todo optimization
    self.target = check_player_location()
    --trace('panda targeted: '..self.target.x..' '..self.target.y)
end

-- no, because otherwise ничего у тебя не получится 🤗
-- double collision checking is shit
function Panda:safe_move_directly_with_collision_check()

end

function Panda:special_panda_moving()
    -- копипаста никуда не пропала
    local ground_collision = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(self.x, self.y + 1))
    local is_on_ground = ground_collision ~= nil

    local collision_to_the_left = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(self.x - 1, self.y))
    local hugging_left_wall = collision_to_the_left ~= nil
    local will_hug_left_wall_soon = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(self.x - READY_TO_JUMP_DISTANCE_CONSTANT, self.y)) ~= nil

    local collision_to_the_right = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(self.x + 1, self.y))
    local hugging_right_wall = collision_to_the_right ~= nil
    local will_hug_right_wall_soon = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(self.x + READY_TO_JUMP_DISTANCE_CONSTANT, self.y)) ~= nil


    -- 💩💩 DIRT NEED REFACTORING 💩💩
    if not is_on_ground and self.velocity.y == UPPING_CONSTANT then
        self.current_jump_strenth = self.current_jump_strenth - JUMP_STRENTH_FADING * Time.dt()
        if self.current_jump_strenth < CONSTANT_CONSTANT then
            self.velocity.y = FALLING_CONSTANT
            self.current_vertical_speed = VERTICAL_AFTERJUMP_SPEED_CONSTANT
            self.current_horizontal_speed = HORIZONTAL_AFTERJUMP_SPEED_CONSTANT
        end

    elseif not is_on_ground then
        -- если панды неожиданно появились в воздухе, то ничего не сможет помочь одинокому путнику, кроме представленного кода
        self.velocity.y = FALLING_CONSTANT
        self.current_vertical_speed = VERTICAL_AFTERJUMP_SPEED_CONSTANT
        self.current_horizontal_speed = HORIZONTAL_AFTERJUMP_SPEED_CONSTANT 
    else
        if self.velocity.y == UPPING_CONSTANT then
            self.current_horizontal_speed = HORIZONTAL_JUMP_SPEED_CONSTANT
            self.current_vertical_speed = VERTICAL_JUMP_SPEED_CONSTANT
        else
            self.current_jump_strenth = DEFAULT_JUMP_STRENTH
            self.velocity.y = CONSTANT_CONSTANT
        end
    end

    if self.target.x >= self.x then
        self.velocity.x = RIGHTING_CONSTANT
        if will_hug_right_wall and is_on_ground then
            self.velocity.y = UPPING_CONSTANT
            self.current_horizontal_speed = HORIZONTAL_JUMP_SPEED_CONSTANT
            self.current_vertical_speed = VERTICAL_JUMP_SPEED_CONSTANT
        end
        if hugging_right_wall then
            self.current_horizontal_speed = 0
        end
    else -- self.target.x < self.x 
        self.velocity.x = LEFTING_CONSTANT
        if will_hug_left_wall_soon and is_on_ground then
            self.velocity.y = UPPING_CONSTANT
            self.current_horizontal_speed = HORIZONTAL_JUMP_SPEED_CONSTANT
            self.current_vertical_speed = VERTICAL_JUMP_SPEED_CONSTANT
        end
        if hugging_left_wall then
            self.current_horizontal_speed = 0
        end
    end

    -- inconsistant code moment
    self.x = self.x + self.current_horizontal_speed * self.velocity.x * Time.dt()
    self.y = self.y + self.velocity.y * self.current_vertical_speed * Time.dt()
end

function Panda:update()
    
    local hugging_right_wall = collision_to_the_right ~= nil

    self:update_target()

    self:special_panda_moving()
end

function Panda:harm(damage)
    self.health = math.clamp(self.health - damage, 0, self.health)
    trace('woooooooooooooooo!')
end

Panda.__index = Panda
