Panda = table.copy(Body)

-- Стаггер - небольшое время стана после одного удара от игрока
-- Если игрок бъет панду много раз и быстро, то она входит в стан

-- Короче ну вас, не могу придумать название 🤬
-- Если непонятно что это, то спросите. Не хочу
-- даже в этом комментарии объяснять, что это такое!
PANDA_TIME_INTERVAL_BETWEEN_HITS_FROM_PLAYER = 1.0
PANDA_HITS_NEEDED_TO_GET_STUNNED = 3
PANDA_STAGGER_TIME = 1.0
PANDA_STUNNED_TIME = 2.5

-- Пока что используются для отлета панды (когда её застанило)
PANDA_FLY_AWAY_SPEED = 75.0
PANDA_FLY_UP_SPEED = 40.0
PANDA_GRAVITY = 149.7
PANDA_FRICTION = 3.5
PANDA_MIN_HORIZONTAL_VELOCITY = 4.0

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
    local ahahahahha = {
        sprite = data.panda.sprite.stay_boring,
        hitbox = Hitbox:new(2, 0, 4, 8),
        status = 'normal',
        staggered_time = 0.0,
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
        time_of_most_recent_hit = 0,
        count_of_recent_hits = 0,
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
    local is_on_ground = Physics.is_on_ground(self)

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

    if self.status == 'normal' then
        self:special_panda_moving()
    elseif self.status == 'staggered' then
        self.staggered_time = self.staggered_time + Time.dt()
        if self.staggered_time > PANDA_STAGGER_TIME then
            self.status = 'normal'
        end
    elseif self.status == 'stunned' then
        -- Здесь дубляж кода из `special_panda_moving()`, потому что другой
        -- **сотрудник** решил сделать такую функцию. Если бы всё было свалено в
        -- update-е, не пришлось бы копипастить. Вот так!
        --
        -- Нет, ну конечно, можно и без копипаста, но это будет изменение
        -- больше, чем просто добавление ветки в if, а я не хочу сильно уродовать
        -- код Myanmar-а 😍
        --
        --
        -- Это я из будущего 👽 (каваи-грот). Копипасты получилось не так много,
        -- поэтому игнорируйте верхний пассивно-агрессивный комментарий.
        --
        local is_on_ground = Physics.is_on_ground(self)
        local horizontal_collision = Physics.move_x(self)
        if horizontal_collision ~= nil then
            self.velocity.x = 0
        end

        local vertical_collision = Physics.move_y(self)
        if vertical_collision ~= nil then
            self.velocity.y = 0
        end

        self.stunned_time = self.stunned_time + Time.dt()
        if self.stunned_time > PANDA_STUNNED_TIME then
            self.status = 'normal'
        end

        if not is_on_ground then
            self.velocity.y = self.velocity.y - PANDA_GRAVITY * Time.dt()
        end

        self.velocity.x = self.velocity.x - (self.velocity.x * PANDA_FRICTION * Time.dt())
        if math.abs(self.velocity.x) < PANDA_MIN_HORIZONTAL_VELOCITY then
            self.velocity.x = 0
        end
    else
        assert(false) -- ✂
    end

    if Time.now() - self.time_of_most_recent_hit > PANDA_TIME_INTERVAL_BETWEEN_HITS_FROM_PLAYER then
        self.count_of_recent_hits = 0
    end
end

function Panda:stun(hit_x, hit_y)
    if hit_x < 0 then
        self.velocity.x = -PANDA_FLY_AWAY_SPEED
    elseif hit_x > 0 then
        self.velocity.x = PANDA_FLY_AWAY_SPEED
    end
    self.velocity.y = PANDA_FLY_UP_SPEED

    self.status = 'stunned'
    self.stunned_time = 0.0
end

function Panda:get_hit(hit_x, hit_y)
    if self.status == 'stunned' then
        table.removeElement(game.pandas, self)
        return
    end

    if hit_x < 0 then
        create_blood(self.x, self.y, -1)
    elseif hit_x > 0 then
        create_blood(self.x, self.y, 1)
    else
        create_blood(self.x, self.y, -1)
        create_blood(self.x, self.y, 1)
    end
    self.status = 'staggered'
    self.staggered_time = 0.0
    self.count_of_recent_hits = self.count_of_recent_hits + 1
    self.time_of_most_recent_hit = Time.now()
    if self.count_of_recent_hits >= PANDA_HITS_NEEDED_TO_GET_STUNNED then
        -- Не знаю можно ли
        self:stun(hit_x, hit_y)
        self.count_of_recent_hits = 0
    end
end

function Panda:harm(damage)
    self.health = math.clamp(self.health - damage, 0, self.health)
end

Panda.__index = Panda
