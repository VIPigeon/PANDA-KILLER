Panda = table.copy(Body)

function Panda:new(x, y)
    trace('Im spawned SENPAI!😍')
    local ahahahahha = {
        sprite = data.panda.sprite.stay_boring,
        hitbox = Hitbox:new(x, y, x + 8, y + 8),
        --flip = 0,
        --rotate = 0,
        x = x, y = y,
        velocity = {
            x = 0,
            y = 0,
        },
        target = {
            x = nil,
            y = nil,
        },
        speed = 2,
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

-- 😌😌😌 BAD CODE ENDED. BAD CODE ENDED. BAD CODE ENDED 😌😌😌

local function special_panda_moving()
    is_grounded = check_horizontal_line_tilemap_collision(line_under_hitbox(self)) 
    
    --downshifting / upshifting
    if is_grounded then
        self.velocity.y = 0
    else
        self.y = self.y - Time.dt()
    end

    --forwardshifting
    self.x = self.x + self.speed * self.velocity.x * Time.dt()

end

function Panda:update_target()
    self.target = check_player_location()
    trace('panda targeted: '..self.target.x..' '..self.target.y)
end

function Panda:update_velocity()
    
    if self.target.x > self.x then
        self.velocity.x = 1
    else 
        self.velocity.x = -1
    end
    if self.target.y > self.y then
        self.velocity.y = 1
    else
        self.velocity.y = -1
    end
end

function Panda:update()
    trace('haah')
    self:update_target()
    self:update_velocity()
    trace(self.velocity.x)
    self:move(self.velocity.x * self.speed * Time.dt(), self.velocity.y * self.speed * Time.dt())
end

function Panda:harm(damage)
    self.health = math.clamp(self.health - damage, 0, self.health)
    trace('woooooooooooooooo!')
end



return Panda