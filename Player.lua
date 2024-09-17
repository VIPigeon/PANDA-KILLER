-- Референс:
-- https://2dengine.com/doc/platformers.html
--
-- Всё измеряется в пикселях / секундах
PLAYER_HORIZONTAL_SPEED = 80.0

PLAYER_COYOTE_TIME = 0.15
PLAYER_JUMP_BUFFER_TIME = 0.23

PLAYER_JUMP_HEIGHT  = 24
PLAYER_TIME_TO_APEX = 0.33
PLAYER_GRAVITY = (2 * PLAYER_JUMP_HEIGHT) / (PLAYER_TIME_TO_APEX * PLAYER_TIME_TO_APEX)
PLAYER_JUMP_STRENGTH = math.sqrt(2 * PLAYER_GRAVITY * PLAYER_JUMP_HEIGHT)

local player = {
    x = 0,
    y = 40,
    velocity = {
        x = 0,
        y = 0,
    },
    hitbox = {
        offset_x = 2,
        offset_y = 0,
        width = 4,
        height = 8,
    },

    coyote_time = 0.0,
    jump_buffer_time = 0.0,

    looking_left = false,
    was_on_ground_last_frame = false,
}

local function trace_hitbox(hitbox)
    trace('x = ' .. hitbox.x .. ' y = ' .. hitbox.y .. ' w = ' .. hitbox.w .. ' h = ' .. hitbox.h)
end


-- Одной из проблем в бумеранге было то, что координаты
-- объекта (x, y) нужно было постоянно копировать в hitbox,
-- потому что он тоже требовал глобальные координаты.
-- Может вот такое решение будет лучше.
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
local function line_under_hitbox(something_with_hitbox)
    -- Помню как выделения памяти из-за таблиц были большой проблемой.
    -- Теперь страшно их делать 😖
    return {
        x1 = hitbox_left(something_with_hitbox),
        y1 = hitbox_bottom(something_with_hitbox),
        x2 = hitbox_right(something_with_hitbox) - 1,
        y2 = hitbox_bottom(something_with_hitbox),
    }
end
local function line_to_the_top_of_hitbox(something_with_hitbox)
    return {
        x1 = hitbox_left(something_with_hitbox),
        y1 = hitbox_top(something_with_hitbox),
        x2 = hitbox_right(something_with_hitbox) - 1,
        y2 = hitbox_top(something_with_hitbox),
    }
end
local function line_to_the_right_of_hitbox(something_with_hitbox)
    return {
        x1 = hitbox_right(something_with_hitbox),
        y1 = hitbox_bottom(something_with_hitbox) - 2,
        x2 = hitbox_right(something_with_hitbox),
        y2 = hitbox_top(something_with_hitbox) + 1,
    }
end
local function line_to_the_left_of_hitbox(something_with_hitbox)
    return {
        x1 = hitbox_left(something_with_hitbox),
        y1 = hitbox_bottom(something_with_hitbox) - 2,
        x2 = hitbox_left(something_with_hitbox),
        y2 = hitbox_top(something_with_hitbox) + 1,
    }
end

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

local function check_point_tilemap_collision(world_x, world_y)
    local tile_x, tile_y = world_to_tile(world_x, world_y)
    local tile = mget(tile_x, tile_y)
    return tile == 1
end

-- Оригинально... Нужна отдельно горизонтальная и вертикальная линии
local function check_horizontal_line_tilemap_collision(line)
    if check_point_tilemap_collision(line.x1, line.y1) then
        return true, line.x1, line.y1
    elseif check_point_tilemap_collision(line.x2, line.y1) then
        return true, line.x2, line.y1
    end

    local x = line.x1 + 8
    while x <= line.x2 do
        if check_point_tilemap_collision(x, line.y1) then
            return true, x, line.y1
        end
        x = x + 8
    end
    return false, nil, nil
end

local function check_vertical_line_tilemap_collision(line)
    if check_point_tilemap_collision(line.x1, line.y1) then
        return true, line.x1, line.y1
    elseif check_point_tilemap_collision(line.x1, line.y2) then
        return true, line.x1, line.y2
    end

    local y = line.y1 + 8
    while y <= line.y2 do
        if check_point_tilemap_collision(line.x1, y) then
            return true, line.x1, y
        end
        y = y + 8
    end
    return false, nil, nil
end


local function is_tile_solid(tile_id)
    -- XD Это кому-то исправлять 😆😂😂
    return tile_id == 1
end

local function combine_hitboxes(h1, h2)
    local x1 = math.min(h1.x, h2.x)
    local y1 = math.min(h1.y, h2.y)
    local x2 = math.max(h1.x + h1.w, h2.x + h2.w)
    local y2 = math.max(h1.y + h1.h, h2.y + h2.h)
    return {
        x = x1,
        y = y1,
        w = x2 - x1,
        h = y2 - y1,
    }
end

-- Дуальность хитбоксов с оффсетом и без меня подбешивает 🤬
local function hitbox_as_if_it_was_at(rect, x, y)
    return {
        x = x + rect.offset_x,
        y = y + rect.offset_y,
        w = rect.width,
        h = rect.height,
    }
end

local function check_collision_hitbox_tilemap(hitbox)
    assert(hitbox.w ~= 0)
    assert(hitbox.h ~= 0)

    local x = hitbox.x
    local y = hitbox.y
    local x2 = hitbox.x + hitbox.w - 1
    local y2 = hitbox.y + hitbox.h - 1

    local tile_x = x // 8
    local tile_y = y // 8

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

    local tile_x2 = x2 // 8
    local tile_y2 = y2 // 8
    local tile_id = mget(tile_x2, tile_y2)
    if is_tile_solid(tile_id) then
        return {
            x = 8 * tile_x2,
            y = 8 * tile_y2,
        }
    end

    return nil
end





function player.update(self)
    self.velocity.x = 0
    if btn(BUTTON_RIGHT) then
        self.velocity.x = self.velocity.x + PLAYER_HORIZONTAL_SPEED
    elseif btn(BUTTON_LEFT) then
        self.velocity.x = self.velocity.x - PLAYER_HORIZONTAL_SPEED
    end
    if self.velocity.x > 0 then
        self.looking_left = false
    elseif self.velocity.x < 0 then
        self.looking_left = true
    end

    local is_on_ground, cx, cy = check_horizontal_line_tilemap_collision(line_under_hitbox(self))
    if not is_on_ground and self.velocity.y <= 0 and self.was_on_ground_last_frame then
       self.coyote_time = PLAYER_COYOTE_TIME
    end
    local jump_inputted = btnp(BUTTON_UP) or btnp(BUTTON_A)
    if jump_inputted then
       if self.coyote_time > 0.0 then
          self.velocity.y = PLAYER_JUMP_STRENGTH
          self.coyote_time = 0.0
          self.jump_buffer_time = 0.0
       else
          self.jump_buffer_time = PLAYER_JUMP_BUFFER_TIME
       end
    end
    if is_on_ground and self.jump_buffer_time > 0.0 and self.velocity.y <= 0 then
       self.velocity.y = PLAYER_JUMP_STRENGTH
       self.coyote_time = 0.0
       self.jump_buffer_time = 0.0
    end
    if not is_on_ground then
        self.velocity.y = self.velocity.y - PLAYER_GRAVITY * Time.dt()
    end
    self.was_on_ground_last_frame = is_on_ground

    local desired_x = self.x + self.velocity.x * Time.dt()
    local hitbox_after_x_move = combine_hitboxes(
        hitbox_as_if_it_was_at(self.hitbox, self.x, self.y),
        hitbox_as_if_it_was_at(self.hitbox, desired_x, self.y)
    )
    local horizontal_collision = check_collision_hitbox_tilemap(hitbox_after_x_move)
    if horizontal_collision ~= nil then
        -- desired_x is busted 💣
        --trace('what: ' .. ' x = ' .. desired_x .. ' cx = ' .. horizontal_collision.x)
        local going_to_the_right = self.velocity.x > 0
        if going_to_the_right then
            desired_x = horizontal_collision.x - self.hitbox.width - self.hitbox.offset_x
        else
            desired_x = horizontal_collision.x + self.hitbox.width + self.hitbox.offset_x
        end
        self.velocity.x = 0
    end

    local desired_y = self.y - self.velocity.y * Time.dt()
    local hitbox_after_y_move = hitbox_as_if_it_was_at(self.hitbox, self.x, desired_y)
    --combine_hitboxes(
    --    hitbox_as_if_it_was_at(self.hitbox, self.x, self.y),
    --    hitbox_as_if_it_was_at(self.hitbox, self.x, desired_y)
    --)
    local vertical_collision = check_collision_hitbox_tilemap(hitbox_after_y_move)
    if vertical_collision ~= nil then
        -- desired_y is busted 💣
        --trace('what: ' .. ' x = ' .. desired_x .. ' cx = ' .. vertical_collision.x)
        local flying_down = self.velocity.y < 0
        if flying_down then
            desired_y = vertical_collision.y - self.hitbox.height
        else
            desired_y = vertical_collision.y + self.hitbox.height
        end
        self.velocity.y = 0
    end

    --trace_hitbox(hitbox_after_y_move)
    --trace('px = ' .. self.x .. ' dx = ' .. desired_x .. ' py = ' .. self.y .. ' dy = ' .. desired_y)
    self.x = desired_x
    self.y = desired_y

    self.jump_buffer_time = math.max(self.jump_buffer_time - Time.dt(), 0.0)
    self.coyote_time = math.max(self.coyote_time - Time.dt(), 0.0)
end

function player.draw(self)
    local colorkey = 0
    local scale = 1
    local flip = self.looking_left and 1 or 0
    spr(257, self.x, self.y, colorkey, scale, flip)
    rect(self.x + self.hitbox.offset_x, self.y + self.hitbox.offset_y, self.hitbox.width, self.hitbox.height, 2)
end

return player
