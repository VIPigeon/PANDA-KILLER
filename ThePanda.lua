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
        hitbox = { -- это надо будет менять на хороший код, но пока сделаю как у нас повелось среди убийц панд
            offset_x = 2,
            offset_y = 0,
            width = 4,
            height = 8,
        },
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
    self.__index = self; return ahahahahha
end

local function check_player_location()
    local goto_x = game.player.x
    local goto_y = game.player.y
    return {x = goto_x, y = goto_y}
end

-- ⚠⚠💀⚡💀⚠⚠ DANGER COPYPASTINGS AND BAD CODE ALERT ⚠⚠💀⚡💀⚠⚠
-- Я просто скопирую код Вани сюда, потому что он делает платформер, значит сделать хорошую архитектуру платформера это его забота

local function hitbox_top(something_with_hitbox)
    return something_with_hitbox.y + something_with_hitbox.hitbox.offset_y
end
local function hitbox_bottom(something_with_hitbox)
    return hitbox_top(something_with_hitbox) + something_with_hitbox.hitbox.height
end
local function hitbox_left(something_with_hitbox)
    return something_with_hitbox.x + something_with_hitbox.hitbox.offset_x
end
local function hitbox_right(something_with_hitbox)
    return hitbox_left(something_with_hitbox) + something_with_hitbox.hitbox.width
end

local function hitbox_as_if_it_was_at(hitbox, x, y)
    return {
        x = x + hitbox.offset_x,
        y = y + hitbox.offset_y,
        w = hitbox.width,
        h = hitbox.height,
    }
end

local function world_to_tile(x, y)
    local tile_x = x // 8
    local tile_y = y // 8
    return tile_x, tile_y
end

local function tile_to_world(x, y)
    local world_x = x * 8
    local world_y = y * 8
    return world_x, world_y
end

local function is_tile_solid(tile_id)
    -- XD Это кому-то исправлять 😆😂😂
    return tile_id == 1
end

-- TODO: Уверен, в будущем нужно будет возвращать не только самое первое
-- столкновение, но вообще все столкновения, которые случились.
local function check_collision_hitbox_tilemap(hitbox)
    assert(hitbox.w ~= 0)
    assert(hitbox.h ~= 0)

    local x = hitbox.x
    local y = hitbox.y
    local x2 = hitbox.x + hitbox.w - 1
    local y2 = hitbox.y + hitbox.h - 1

    local tile_x = x // 8
    local tile_y = y // 8

    local tile_x1 = x // 8
    local tile_y1 = y // 8
    local tile_x2 = x2 // 8
    local tile_y2 = y2 // 8

    while y <= y2 do
        while x <= x2 do
            local tile_id = mget(tile_x, tile_y)

            if is_tile_solid(tile_id) then
                return {
                    x = 8 * tile_x,
                    y = 8 * tile_y,
                }
            end

            tile_x = tile_x + 1
            x = x + 8
        end

        y = y + 8
        tile_y = tile_y + 1
        x = hitbox.x
        tile_x = x // 8
    end

    if is_tile_solid(mget(tile_x2, tile_y1)) then
        return { x = 8 * tile_x2, y = 8 * tile_y1 }
    end

    if is_tile_solid(mget(tile_x1, tile_y2)) then
        return { x = 8 * tile_x1, y = 8 * tile_y2 }
    end

    if is_tile_solid(mget(tile_x2, tile_y2)) then
        return { x = 8 * tile_x2, y = 8 * tile_y2 }
    end

    return nil
end

-- 😌😌😌 BAD CODE ENDED. BAD CODE ENDED. BAD CODE ENDED 😌😌😌

function Panda:update_target()
    -- todo optimization
    self.target = check_player_location()
    --trace('panda targeted: '..self.target.x..' '..self.target.y)
end

-- double collision checking is shit
function Panda:safe_move_directly_with_collision_check()

end

function Panda:special_panda_moving()
    -- копипаста никуда не пропала
    local ground_collision = check_collision_hitbox_tilemap(hitbox_as_if_it_was_at(self.hitbox, self.x, self.y + 1))
    local is_on_ground = ground_collision ~= nil

    local collision_to_the_left = check_collision_hitbox_tilemap(hitbox_as_if_it_was_at(self.hitbox, self.x - 1, self.y))
    local hugging_left_wall = collision_to_the_left ~= nil
    local will_hug_left_wall_soon = check_collision_hitbox_tilemap(hitbox_as_if_it_was_at(self.hitbox, self.x - READY_TO_JUMP_DISTANCE_CONSTANT, self.y)) ~= nil

    local collision_to_the_right = check_collision_hitbox_tilemap(hitbox_as_if_it_was_at(self.hitbox, self.x + 1, self.y))
    local hugging_right_wall = collision_to_the_right ~= nil
    local will_hug_right_wall_soon = check_collision_hitbox_tilemap(hitbox_as_if_it_was_at(self.hitbox, self.x + READY_TO_JUMP_DISTANCE_CONSTANT, self.y)) ~= nil

    trace(tostring(is_on_ground)..' - '..tostring(hugging_left_wall)..' - '..tostring(hugging_right_wall)..' - '..self.current_jump_strenth)

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



return Panda