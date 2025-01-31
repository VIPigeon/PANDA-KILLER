--[[

Здесь начал размножаться грязнокод ♻️ 🤮

Кто прочитал, тот обязан это почистить 🚽

--]]


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

Pandas = {
    alive_pandas = {}
}

function Pandas.add(panda)
    panda.status = 'patrol/move'
    panda.look_direction = math.coin_flip() and 1 or -1
    panda.rest_time = PANDA_REST_TIME_BEFORE_DIRECTION_CHANGE()
    table.insert(Pandas.alive_pandas, panda)
end

local function view_cone_shape(panda)
    local panda_rect = Hitbox.rect_of(panda)

    local tx, ty = panda_rect:center_x(), panda_rect:center_y()

    if panda.look_direction == PANDA_LOOK_DIRECTION_LEFT then
        tx = tx - PANDA_VIEW_CONE_WIDTH / 2
    else
        tx = tx + PANDA_VIEW_CONE_WIDTH / 2
    end

    ty = ty - PANDA_VIEW_CONE_HEIGHT / 2
    tx = tx - PANDA_VIEW_CONE_WIDTH / 2

    local look_ahead_rect = Rect:new(tx, ty, PANDA_VIEW_CONE_WIDTH, PANDA_VIEW_CONE_HEIGHT)
    PANDA_BACK_VIEW = 20
    local a_bit_behind_rect = Rect:new(
        panda.x - PANDA_BACK_VIEW,
        panda.y - PANDA_BACK_VIEW / 2,
        2 * PANDA_BACK_VIEW,
        PANDA_BACK_VIEW
    )

    return Shape:new({look_ahead_rect, a_bit_behind_rect})
end

function Pandas.update()
    -- Здесь небольшая свалочка которая образовалась пока я разбирался как у нас
    -- работают панды. Если честно, фиксить её мне лень 😊. "Грязный" код -- это далеко
    -- не самая большая проблема в разработке игр.
    --
    -- Вот в AAA играх я уверен бесконечно много отвратительного легаси и ничего, выпускают
    -- же. Правда не всегда хорошо, не уверен что это норм пример. Ну у нас маленькая инди
    -- студия, легаси немного, так что всё хорошо and dandy.
    --
    -- К чему я это? 🤔
    for _, panda in ipairs(Pandas.alive_pandas) do
        local panda_rect = Hitbox.rect_of(panda)

        if panda.status ~= 'attacked/stunned' and panda.velocity.y < 0 then
            -- ахаха бедная панда падает 🤣
            panda.status = 'panic!'
        end

        local is_on_ground = Physics.is_on_ground(panda)

        local view_cone = view_cone_shape(panda)
        local sees_player = Physics.check_collision_shape_rect(view_cone, Hitbox.rect_of(game.player))

        if sees_player then
            panda.chase_time = PANDA_CHASE_TIME
        end

        if panda.attacking_time > 0.0 and Physics.check_collision_rect_rect(Hitbox.rect_of(panda), Hitbox.rect_of(game.player)) then
            --trace('player is fucking dead')
        end

        local status_patrol_rest = panda.rest_time > 0.0
        if panda.status == 'attacked/staggered' then
            panda.velocity.x = 0

            -- TODO: Переделать на таймеры
            panda.staggered_time = panda.staggered_time + Time.dt()
            if panda.staggered_time > PANDA_STAGGER_TIME then
                panda.status = 'patrol/move'
            end
        elseif panda.status == 'attacked/stunned' then
            panda.stunned_time = panda.stunned_time + Time.dt()
            if panda.stunned_time > PANDA_STUNNED_TIME then
                panda.rest_time = PANDA_REST_TIME_BEFORE_DIRECTION_CHANGE()
                panda.status = 'patrol/rest'
                panda.stunned_time = 0.0;
            end

            panda.velocity.x = panda.velocity.x - math.sign(panda.velocity.x) * PANDA_DECELERATION * Time.dt()
            if math.abs(panda.velocity.x) < PANDA_MIN_HORIZONTAL_VELOCITY then
                panda.velocity.x = 0
            end
        elseif panda.chase_time > 0.0 then
            local x_distance_to_player = math.abs(player.x - panda.x)
            panda.look_direction = math.sign(player.x - panda.x)
            if x_distance_to_player <= PANDA_X_DISTANCE_TO_PLAYER_UNTIL_ATTACK then
                local y_distance_to_player = math.abs(player.y - panda.y)
                if panda.attacking_time == 0.0 then
                    if y_distance_to_player <= PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_ATTACK then
                        panda.velocity.x = 100 * math.sign(player.x - panda.x)
                        panda.velocity.y = 60 * -1 * math.sign(player.y - panda.y)
                        panda.attacking_time = PANDA_ATTACK_TIME
                    elseif is_on_ground and player.x < panda.x then
                        --trace('shit, I am too low. Jumping')
                        panda.velocity.y = PANDA_CHASE_JUMP_STRENGTH
                    end
                end
            else
                local x_in_the_near_future = panda.x + panda.look_direction * PANDA_CHASE_PIXELS_UNTIL_JUMP
                local x_direction_to_player = math.sign(game.player.x - panda.x)

                local wall_to_the_right = Physics.check_collision_rect_tilemap(panda.hitbox:to_rect(x_in_the_near_future, panda.y)) ~= nil
                local ground_forward = Physics.check_collision_rect_tilemap(panda.hitbox:to_rect(x_in_the_near_future, panda.y + 1)) ~= nil

                if is_on_ground and wall_to_the_right then
                    --trace('chas jump: ' .. panda.velocity.y)
                    panda.velocity.y = PANDA_CHASE_JUMP_STRENGTH
                end
                panda.velocity.x = PANDA_CHASE_SPEED * x_direction_to_player
            end
            panda.chase_time = Basic.tick_timer(panda.chase_time)
        elseif status_patrol_rest then
            panda.velocity.x = panda.velocity.x - PANDA_SLOWDOWN_FOR_REST * panda.velocity.x
            panda.rest_time = Basic.tick_timer(panda.rest_time)
            if panda.rest_time == 0.0 then
                panda.look_direction = -1 * panda.look_direction
                panda.status = 'patrol/move'
            end
        elseif panda.status == 'patrol/move' then
            local x_in_the_near_future = panda.x + panda.look_direction * PANDA_PATROL_PIXELS_UNTIL_STOP

            local wall_to_the_right = Physics.check_collision_rect_tilemap(panda.hitbox:to_rect(x_in_the_near_future, panda.y)) ~= nil
            local ground_forward = Physics.check_collision_rect_tilemap(panda.hitbox:to_rect(x_in_the_near_future, panda.y + 1)) ~= nil

            if wall_to_the_right or not ground_forward then
                panda.rest_time = PANDA_REST_TIME_BEFORE_DIRECTION_CHANGE()
            end

            panda.velocity.x = PANDA_PATROL_SPEED * panda.look_direction
        elseif panda.status == 'panic!' then
            -- Если панда паникует, то она проста отдается на волю силам физики
            -- и молится.
            panda.rest_time = PANDA_REST_TIME_BEFORE_DIRECTION_CHANGE()
        else
            trace('unknown state ' .. panda.status)
        end

        if not is_on_ground then
            panda.velocity.y = panda.velocity.y - PANDA_GRAVITY * Time.dt()
        end

        if math.abs(panda.velocity.y) < 0.5 then
            panda.velocity.y = 0.0
        end

        local horizontal_collision = Physics.move_x(panda)
        if horizontal_collision ~= nil then
            panda.velocity.x = -0.9 * panda.velocity.x
        end

        local vertical_collision = Physics.move_y(panda)
        if vertical_collision ~= nil then
            panda.velocity.y = 0
        end

        panda.sprite:next_frame()

        if panda.status == 'attacked/staggered' then
            panda.sprite = PANDA_PANIC_SPRITE
        elseif panda.status == 'attacked/stunned' then
            panda.sprite = PANDA_PANIC_SPRITE
        elseif panda.chase_time > 0.0 then
            panda.sprite = PANDA_CHASE_SPRITE
        elseif status_patrol_rest then
            panda.sprite = PANDA_REST_SPRITE
        elseif panda.status == 'patrol/move' then
            panda.sprite = PANDA_DEFAULT_SPRITE
        elseif panda.status == 'panic!' then
            panda.sprite = PANDA_PANIC_SPRITE
        end

        panda.attacking_time = Basic.tick_timer(panda.attacking_time)
    end
end

function Pandas.draw()
    local view_cone_color = 1

    --for _, panda in ipairs(Pandas.alive_pandas) do
    --    local panda_rect = Hitbox.rect_of(panda)

    --    view_cone_shape(panda):draw(view_cone_color)
    --    view_cone_color = view_cone_color + 1
    --end

    for _, panda in ipairs(Pandas.alive_pandas) do
        panda.flip = panda.look_direction == 1 and 0 or 1
        panda:draw()
    end
end

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

        chase_time = 0.0,
        rest_time = 0.0,
        attacking_time = 0.0,
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
    self.rest_time = 0.0
    if hit_x < 0 then
        self.velocity.x = -PANDA_FLY_AWAY_SPEED
    elseif hit_x > 0 then
        self.velocity.x = PANDA_FLY_AWAY_SPEED
    end
    self.velocity.y = PANDA_FLY_UP_SPEED

    self.status = 'attacked/stunned'
    self.stunned_time = 0.0
end

function Panda:get_hit(hit_x, hit_y)
    sfx(11, 'G-5', 20, 2)

    if hit_x < 0 then
        create_blood(self.x, self.y, -1)
    elseif hit_x > 0 then
        create_blood(self.x, self.y, 1)
    else
        create_blood(self.x, self.y, -1)
        create_blood(self.x, self.y, 1)
    end

    if self.status == 'attacked/stunned' then
        sfx(11, 'G-6', 60, 2)
        table.remove_element(game.pandas, self)
        return
    end

    self.status = 'attacked/staggered'
    self.staggered_time = 0.0
    self.count_of_recent_hits = self.count_of_recent_hits + 1
    self.time_of_most_recent_hit = Time.now()
    if self.count_of_recent_hits >= PANDA_HITS_NEEDED_TO_GET_STUNNED then
        -- Не знаю можно ли
        self:stun(hit_x, hit_y)
        self.count_of_recent_hits = 0
    end
end

Panda.__index = Panda
