--[[

Добро пожаловать в джунгли! 🌴🐒

Ниже находится полотно кода, которое тиранически управляет игроком. Практически
вся логика лежит в player.update(). А что? Думаете это не круто(вообще-то да << Nerd), что у меня большая
функция, которая будет расти ещё больше в будущем? Вот что Джон Кармак (🤯) сказал
бы вам: https://cbarrete.com/carmack.html

Не знаете кто такой Джон Кармак? Позор. Не, реально, посмотрите кто это 🤬.
И статью прочитайте.

Не верите этому старичку? Тогда более реальный пример: класс игрока из Celeste 🍓,
платформера с, пожалуй, самым лучшим управлением когда либо сделанным. Он есть
в открытом доступе: https://github.com/NoelFB/Celeste/blob/master/Source/Player/Player.cs
В этом монолите 5000 строк кода. И они работают безупречно. Вот так!

Референс для физики игрока: https://2dengine.com/doc/platformers.html
Крутой видос про Celeste: https://www.youtube.com/watch?v=yorTG9at90g

ЛИЦЕНЗИЯ: Использовать этот код в коммерческих целях ЗАПРЕЩЕНО.
Если очень хочется, то нужно заплатить мне $10. (c) кавайный-код

--]]

-- ⏰

--[[

Итак, объясняю как работает прыжок от стены 🤓

1. Если игрок в воздухе врезается в стену, он "прилепляется" к ней.
2. Если игрок продолжает идти в стену, то он будет скользит с
   замедленной скоростью PLAYER_WALL_SLIDE_SPEED.
3. Самое сложное: игрок отпрыгивает от стены. После прыжка на короткое
   время (PLAYER_REMOVE_SPEED_LIMIT_AFTER_WALL_JUMP_TIME) у игрока
   уменьшается гравитация, чтобы можно было легче контролировать полёт.
   Такие дела.

Всё константы измеряются либо в 'пикселях', либо в 'секундах', либо в 'пикселях в секунду'.
Ещё есть проценты от 0 до 1 ⚖

--]]

PLAYER_MAX_HORIZONTAL_SPEED = 67.0
PLAYER_HORIZONTAL_ACCELERATION = 900.0
PLAYER_FRICTION = 0.2
PLAYER_AIR_FRICTION = 0.5 * PLAYER_FRICTION

PLAYER_WALL_SLIDE_SPEED = 30.0
PLAYER_WALL_JUMP_HORIZONTAL_STRENGTH = 140.0
PLAYER_WALL_JUMP_VERTICAL_STRENGTH = 120.0
PLAYER_REMOVE_SPEED_LIMIT_AFTER_WALL_JUMP_TIME = 0.26
PLAYER_DELAY_AFTER_JUMP_BEFORE_STICKING_TO_WALL = 0.2

PLAYER_ATTACK_DURATION = 0.2

PLAYER_COYOTE_TIME = 0.23
PLAYER_JUMP_BUFFER_TIME = 0.18

PLAYER_MAX_FALL_SPEED = 200.0
PLAYER_JUMP_HEIGHT = 24
PLAYER_TIME_TO_APEX = 0.33 -- Время, чтобы достичь высшей точки прыжка (apex)
PLAYER_GRAVITY = (2 * PLAYER_JUMP_HEIGHT) / (PLAYER_TIME_TO_APEX * PLAYER_TIME_TO_APEX)
PLAYER_GRAVITY_AFTER_WALL_JUMP = 0.75 * PLAYER_GRAVITY
PLAYER_JUMP_STRENGTH = math.sqrt(2 * PLAYER_GRAVITY * PLAYER_JUMP_HEIGHT)

PLAYER_SPRITE_IDLE = Sprite:new({257})
PLAYER_SPRITE_RUNNING = Sprite:new({258, 258, 258, 258, 259, 259, 259, 259})
-- А что? 😳
PLAYER_SPRITE_ATTACK = Sprite:new({276, 276, 276, 276, 276, 276, 277, 277, 277, 277, 277, 277})
PLAYER_SPRITE_JUMP = Sprite:new({273})
PLAYER_SPRITE_DEAD = Sprite:new({274})


player = {
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

    stuck_to_left_wall = false,
    stuck_to_right_wall = false,
    looking_left = false,
    was_on_ground_last_frame = false,

    time_before_we_can_stick_to_wall = 0.0,
    coyote_time = 0.0,
    attack_timer = 0.0,
    jump_buffer_time = 0.0,
    remove_horizontal_speed_limit_time = 0.0,

    sprite = PLAYER_SPRITE_IDLE,
}


-- TODO: Все эти функции с хитбоксами нужно куда-то убрать
--
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

--[[

+---+     +-+      +---+
|   |  +  | |   =  |   |
+---+     | |      |   |
          +-+      +---+

--]]
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
-- Есть хитбокс с offset_x, offset_y, который нужно прицеплять к другому
-- игровому объекту, а есть самостоятельный хитбокс (просто прямоугольник)
-- у которого есть x, y -- мировые координаты. И с ними
-- немного путаница. Вот бы строго типизированный язык 😋
--
-- Эта функция переводит из оффсетного в самостоятельный прямоугольник
local function hitbox_as_if_it_was_at(hitbox, x, y)
    return {
        x = x + hitbox.offset_x,
        y = y + hitbox.offset_y,
        w = hitbox.width,
        h = hitbox.height,
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


local function trace_hitbox(hitbox)
    trace('x = ' .. hitbox.x .. ' y = ' .. hitbox.y .. ' w = ' .. hitbox.w .. ' h = ' .. hitbox.h)
end

local debug_rects = {}


function player.update(self)
    -- Краткое описание update() 📰
    --
    -- 1. На начале кадра делаем несколько "запросов" к физике, чтобы определить
    --    какие стены рядом с нами, на земле ли мы, т.д.
    --
    -- 2. Считываем ввод игрока и преобразуем его в "физические силы", что
    --    действуют на игрока.  Например, если мы нажимаем RIGHT, то на игрока
    --    подействует ускорение(!) направленное направо. Фактически здесь мы
    --    определяем player.velocity
    --
    -- 3. Пытаемся применить изменения в позиции (desired_x, desired_y). Однако
    --    реальный мир забирает нашу свободу 🗽❌! Нужно проверить, что мы не
    --    столкнулись ни с чем. А если столкнулись, то нужно поставить игрока
    --    настолько близко к месту к столкновению, насколько возможно. Другими
    --    словами, если (2) ставит player.velocity, то (3) ставит player.x, player.y.
    --    Я не очень хорошо объясняю, мне надоело писать комменты. Читайте код сами 😡!
    --


    -- 1. Запросы. Ничего интересного
    local ground_collision = check_collision_hitbox_tilemap(hitbox_as_if_it_was_at(self.hitbox, self.x, self.y + 1))
    local is_on_ground = ground_collision ~= nil

    local collision_to_the_left = check_collision_hitbox_tilemap(hitbox_as_if_it_was_at(self.hitbox, self.x - 1, self.y))
    local hugging_left_wall = collision_to_the_left ~= nil

    local collision_to_the_right = check_collision_hitbox_tilemap(hitbox_as_if_it_was_at(self.hitbox, self.x + 1, self.y))
    local hugging_right_wall = collision_to_the_right ~= nil

    -- Для дебага
    if is_on_ground then
        table.insert(debug_rects, { x = ground_collision.x, y = ground_collision.y, w = 8, h = 8 })
    end
    if hugging_left_wall then
        table.insert(debug_rects, { x = collision_to_the_left.x, y = collision_to_the_left.y, w = 8, h = 8 })
    end
    if hugging_right_wall then
        table.insert(debug_rects, { x = collision_to_the_right.x, y = collision_to_the_right.y, w = 8, h = 8 })
    end

    -- 2. Считываем ввод, работаем только с self.velocity
    local walking_right = btn(BUTTON_RIGHT)
    local walking_left = btn(BUTTON_LEFT)
    local looking_down = btn(BUTTON_DOWN)
    local looking_up = btn(BUTTON_UP)
    local jump_pressed = btnp(BUTTON_Z)
    local attack_pressed = btnp(BUTTON_X)
    if jump_pressed then
      self.jump_buffer_time = PLAYER_JUMP_BUFFER_TIME
    end

    if attack_pressed then
        if self.attack_timer == 0 then
            self.attack_timer = PLAYER_ATTACK_DURATION
        else
            -- Может быть сделать буфер для атаки? 🤔
        end
    end

    if self.attack_timer == 0 then
        self.attack_hitbox = nil
    else
        local attack_x = self.x
        local attack_y = self.y

        -- Это сделано для испольнения Clean Code принципа (c)
        -- Don't Repeat Yourself (DRY). Я, как хороший программист,
        -- стремлюсь всегда следовать best practices и использовать
        -- design patterns. Мой код проверяется на S.O.L.I.D, YAGNI,
        -- G.R.A.S.P, и т.д. и т.п. Люблю TDD, DDD и OOP.
        --
        -- Опыт работы: нету, но стремлюсь улучшиться в этом аспекте
        -- Пет проекты: я все пытался сделать, но потом сразу понимал,
        --              насколько плоха architecture проекта, поэтому
        --              я их начинал с нуля, используя более современные
        --              best practices
        --
        -- Буду рад работать у вас 😻! -- kawaii-Год
        local diagonal_movement = 0
        if walking_left then
            diagonal_movement = 0 - 8
        elseif walking_right then
            -- Я хотел написать +8, но lua не смог откомпилировать, поэтому...
            diagonal_movement = 0 + 8
        end

        if looking_down then
            attack_y = attack_y + 8
            attack_x = attack_x + diagonal_movement
        elseif looking_up then
            attack_y = attack_y - 8
            attack_x = attack_x + diagonal_movement
        else
            if self.looking_left then
                attack_x = attack_x - 8
            else
                attack_x = attack_x + 8
            end
        end

        self.attack_hitbox = Rect:new(attack_x, attack_y, 8, 8)
        local collision = check_collision_hitbox_tilemap(self.attack_hitbox)
        if collision ~= nil then
            self.attack_timer = 0
        end

        for _, panda in ipairs(game.pandas) do
            if check_collision_rect_rect(self.attack_hitbox, panda.hitbox)
        end
    end

    if is_on_ground then
        self.velocity.x = self.velocity.x - self.velocity.x * PLAYER_FRICTION
    else
        -- Типа в воздухе другое сопротивление 💨
        -- Не знаю, на сколько это нужно 😅
        self.velocity.x = self.velocity.x - self.velocity.x * PLAYER_AIR_FRICTION
    end
    local not_at_speed_limit = math.abs(self.velocity.x) < PLAYER_MAX_HORIZONTAL_SPEED
    if not_at_speed_limit then
        if walking_right then
            if math.abs(self.velocity.x) < PLAYER_MAX_HORIZONTAL_SPEED then
                self.velocity.x = self.velocity.x + PLAYER_HORIZONTAL_ACCELERATION * Time.dt()
            end
        end
        if walking_left then
            if math.abs(self.velocity.x) < PLAYER_MAX_HORIZONTAL_SPEED then
                self.velocity.x = self.velocity.x - PLAYER_HORIZONTAL_ACCELERATION * Time.dt()
            end
        end
        self.velocity.x = math.clamp(self.velocity.x, -PLAYER_MAX_HORIZONTAL_SPEED, PLAYER_MAX_HORIZONTAL_SPEED)
    end

    if not is_on_ground then
        if self.remove_horizontal_speed_limit_time == 0.0 then
            self.velocity.y = self.velocity.y - PLAYER_GRAVITY * Time.dt()
        else
            self.velocity.y = self.velocity.y - PLAYER_GRAVITY_AFTER_WALL_JUMP * Time.dt()
        end
    end

    local should_jump = self.jump_buffer_time > 0.0
    local has_jumped = false
    if should_jump then
        if is_on_ground and self.velocity.y <= 0 then
            self.velocity.y = PLAYER_JUMP_STRENGTH
            has_jumped = true
            self.time_before_we_can_stick_to_wall = PLAYER_DELAY_AFTER_JUMP_BEFORE_STICKING_TO_WALL
        elseif hugging_left_wall and not is_on_ground then
            self.velocity.y = PLAYER_WALL_JUMP_VERTICAL_STRENGTH
            self.velocity.x = PLAYER_WALL_JUMP_HORIZONTAL_STRENGTH
            self.remove_horizontal_speed_limit_time = PLAYER_REMOVE_SPEED_LIMIT_AFTER_WALL_JUMP_TIME
            has_jumped = true
        elseif hugging_right_wall and not is_on_ground then
            self.velocity.y = PLAYER_WALL_JUMP_VERTICAL_STRENGTH
            self.velocity.x = -1 * PLAYER_WALL_JUMP_HORIZONTAL_STRENGTH
            self.remove_horizontal_speed_limit_time = PLAYER_REMOVE_SPEED_LIMIT_AFTER_WALL_JUMP_TIME
            has_jumped = true
        end
    end
    if jump_inputted and self.coyote_time > 0.0 and self.velocity.y <= 0.0 then
        self.velocity.y = PLAYER_JUMP_STRENGTH
        self.time_before_we_can_stick_to_wall = PLAYER_DELAY_AFTER_JUMP_BEFORE_STICKING_TO_WALL
        has_jumped = true
    end
    if has_jumped then
        self.coyote_time = 0.0
        self.jump_buffer_time = 0.0
    end

    if not is_on_ground and self.was_on_ground_last_frame and self.velocity.y <= 0 then
       self.coyote_time = PLAYER_COYOTE_TIME
    end
    self.was_on_ground_last_frame = is_on_ground

    local can_stick_to_wall = self.time_before_we_can_stick_to_wall == 0.0
    if not is_on_ground and can_stick_to_wall then
        if hugging_left_wall and self.velocity.x < 0 then
            self.velocity.y = -1 * PLAYER_WALL_SLIDE_SPEED
        end
        if hugging_right_wall and self.velocity.x > 0 then
            self.velocity.y = -1 * PLAYER_WALL_SLIDE_SPEED
        end
    end


    EPSILON = 4.0
    if math.abs(self.velocity.x) < EPSILON then
        self.velocity.x = 0
    end
    if math.abs(self.velocity.y) < EPSILON then
        self.velocity.y = 0
    end

    self.velocity.y = math.clamp(self.velocity.y, -PLAYER_MAX_FALL_SPEED, PLAYER_MAX_FALL_SPEED)

    local moving_right = self.velocity.x > 0
    local moving_left  = self.velocity.x < 0
    if moving_right then
        self.looking_left = false
    elseif moving_left then
        self.looking_left = true
    end


    -- 3. Проверка коллизий
    local desired_x = self.x + self.velocity.x * Time.dt()
    local hitbox_after_x_move = combine_hitboxes(
        hitbox_as_if_it_was_at(self.hitbox, self.x, self.y),
        hitbox_as_if_it_was_at(self.hitbox, desired_x, self.y)
    )
    local horizontal_collision = check_collision_hitbox_tilemap(hitbox_after_x_move)
    if horizontal_collision ~= nil then
        -- desired_x is busted 💣
        if moving_right then
            desired_x = horizontal_collision.x - self.hitbox.width - self.hitbox.offset_x
        else
            desired_x = horizontal_collision.x + self.hitbox.width + self.hitbox.offset_x
        end
        self.velocity.x = 0
    end

    local desired_y = self.y - self.velocity.y * Time.dt()
    local hitbox_after_y_move = combine_hitboxes(
        hitbox_as_if_it_was_at(self.hitbox, self.x, self.y),
        hitbox_as_if_it_was_at(self.hitbox, self.x, desired_y)
    )
    local vertical_collision = check_collision_hitbox_tilemap(hitbox_after_y_move)
    if vertical_collision ~= nil then
        -- desired_y is busted 💣
        local flying_down = self.velocity.y < 0
        if flying_down then
            desired_y = vertical_collision.y - self.hitbox.height
        else
            desired_y = vertical_collision.y + self.hitbox.height
        end
        self.velocity.y = 0
    end

    if self.attack_timer > 0 then
        self.sprite = PLAYER_SPRITE_ATTACK
    elseif self.velocity.y ~= 0 then
        self.sprite = PLAYER_SPRITE_JUMP
    elseif self.velocity.x ~= 0 then
        self.sprite = PLAYER_SPRITE_RUNNING
    else
        self.sprite = PLAYER_SPRITE_IDLE
    end

    self.x = desired_x
    self.y = desired_y

    self.time_before_we_can_stick_to_wall = math.max(self.time_before_we_can_stick_to_wall - Time.dt(), 0.0)
    self.jump_buffer_time = math.max(self.jump_buffer_time - Time.dt(), 0.0)
    self.coyote_time = math.max(self.coyote_time - Time.dt(), 0.0)
    self.remove_horizontal_speed_limit_time = math.max(self.remove_horizontal_speed_limit_time - Time.dt(), 0.0)
    self.attack_timer = math.max(self.attack_timer - Time.dt(), 0.0)
end

function player.draw(self)
    local colorkey = 0
    local scale = 1
    local flip = self.looking_left and 1 or 0

    local tx, ty = game.camera_window:transform_coordinates(self.x, self.y)

    self.sprite:nextFrame()
    spr(self.sprite:current(), tx, ty, colorkey, scale, flip)

    -- Дебаг 🐜
    if false then
        for i, r in ipairs(debug_rects) do
            rect(r.x, r.y, r.w, r.h, 5 + i)
        end
    end
    debug_rects = {}

    if self.attack_hitbox then
        self.attack_hitbox:drawDebug()
    end
end
