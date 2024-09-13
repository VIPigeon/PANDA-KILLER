-- Референс:
-- https://2dengine.com/doc/platformers.html
--
-- Всё измеряется в пикселях / секунды
PLAYER_HORIZONTAL_SPEED = 80.0
PLAYER_JUMP_HEIGHT  = 24
PLAYER_TIME_TO_APEX = 0.33
PLAYER_GRAVITY      = (2 * PLAYER_JUMP_HEIGHT) / (PLAYER_TIME_TO_APEX * PLAYER_TIME_TO_APEX)
PLAYER_JUMP_STRENGTH = math.sqrt(2 * PLAYER_GRAVITY * PLAYER_JUMP_HEIGHT)

local player = {
    x = 0,
    y = 0,
    velocity = {
        x = 0,
        y = 0,
    },

    looking_left = false,
    was_on_ground_last_frame = false,
}

-- TODO: Эту документацию нужно куда-то выделить
--
-- В игре есть 3 разные координатные системы, о которых нужно помнить.
-- 1. Мировая -- измеряется в пикселях, x от 0 до 1920, y от 0 до 1088
-- 2. Тайловая -- каждый тайл 8x8 пикселей, соответственно перевод из
--    мировой в тайловую и обратно - это умножение / деление на 8.
--    В тайловой координатной системе x от 0 до 240, y от 0 до 136
-- 3. Локальная -- её ещё нету, но она связана с камерой и положением
--    игровых объектов относительно неё.
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

local function check_collision_with_tilemap(world_x, world_y)
    local tile_x, tile_y = world_to_tile(world_x, world_y)
    local tile = mget(tile_x, tile_y)
    return tile == 1
end

function player.update(self)
    self.velocity.x = 0
    if btn(BUTTON_RIGHT) then
        self.velocity.x = self.velocity.x + PLAYER_HORIZONTAL_SPEED
    elseif btn(BUTTON_LEFT) then
        self.velocity.x = self.velocity.x - PLAYER_HORIZONTAL_SPEED
    end

        -- To the bottom
        local check_x, check_y = self.x + 4, self.y + 9
        local is_on_ground = check_collision_with_tilemap(check_x, check_y)
        if self.velocity.y < 0 and is_on_ground and not self.was_on_ground_last_frame then
            local tile_x, tile_y = world_to_tile(check_x, check_y)
            local new_x, new_y = tile_to_world(tile_x, tile_y)
            self.velocity.y = 0
            self.y = new_y - 8
        elseif not is_on_ground then
            self.velocity.y = self.velocity.y - PLAYER_GRAVITY * Time.dt()
        end
        self.was_on_ground_last_frame = is_on_ground

        -- To the top! Haikyuu season 4 🏐
        check_x, check_y = self.x + 4, self.y - 1
        local is_hitting_top = check_collision_with_tilemap(check_x, check_y)
        if self.velocity.y > 0 and is_hitting_top then
            local tile_x, tile_y = world_to_tile(check_x, check_y)
            local new_x, new_y = tile_to_world(tile_x, tile_y)
            self.velocity.y = 0
            self.y = new_y + 8
        end

        -- To the right
        check_x, check_y = self.x + 9, self.y + 4
        local is_hitting_right = check_collision_with_tilemap(check_x, check_y)
        if self.velocity.x > 0 and is_hitting_right then
            local tile_x, tile_y = world_to_tile(check_x, check_y)
            local new_x, new_y = tile_to_world(tile_x, tile_y)
            self.velocity.x = 0
            self.x = new_x - 8
        end

        -- To the left
        check_x, check_y = self.x - 1, self.y + 4
        local is_hitting_left = check_collision_with_tilemap(check_x, check_y)
        if self.velocity.x < 0 and is_hitting_left then
            local tile_x, tile_y = world_to_tile(check_x, check_y)
            local new_x, new_y = tile_to_world(tile_x, tile_y)
            self.velocity.x = 0
            self.x = new_x + 8
        end

    if btnp(BUTTON_UP) or btnp(BUTTON_A) then
        if is_on_ground then
            self.velocity.y = PLAYER_JUMP_STRENGTH
        end
    end

    if self.velocity.x > 0 then
        self.looking_left = false
    elseif self.velocity.x < 0 then
        self.looking_left = true
    end

    self.x = self.x + self.velocity.x * Time.dt()
    self.y = self.y - self.velocity.y * Time.dt()
end

function player.draw(self)
    local colorkey = -1
    local scale = 1
    local flip = self.looking_left and 1 or 0
    spr(257, self.x, self.y, colorkey, scale, flip)
end

return player
