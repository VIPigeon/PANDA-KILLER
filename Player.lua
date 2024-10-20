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
PLAYER_FRICTION = 12.0
PLAYER_AIR_FRICTION = 0.52 * PLAYER_FRICTION

PLAYER_WALL_SLIDE_SPEED = 30.0
PLAYER_WALL_JUMP_HORIZONTAL_STRENGTH = 140.0
PLAYER_WALL_JUMP_VERTICAL_STRENGTH = 120.0
PLAYER_REMOVE_SPEED_LIMIT_AFTER_WALL_JUMP_TIME = 0.26
PLAYER_DELAY_AFTER_JUMP_BEFORE_STICKING_TO_WALL = 0.2

PLAYER_ATTACK_DURATION = 0.2
PLAYER_DAMAGE = 10

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
    x = PLAYER_START_X,
    y = PLAYER_START_Y,
    velocity = {
        x = 0,
        y = 0,
    },
    hitbox = Hitbox:new(2, 0, 4, 8), -- 2048 🤓

    sprite = PLAYER_SPRITE_IDLE,

    stuck_to_left_wall = false,
    stuck_to_right_wall = false,
    looking_left = false,
    was_on_ground_last_frame = false,
    is_dead = false,

    time_before_we_can_stick_to_wall = 0.0,
    coyote_time = 0.0,
    attack_timer = 0.0,
    jump_buffer_time = 0.0,
    remove_horizontal_speed_limit_time = 0.0,
    time_we_have_been_running = 0.0,
}

local function tick_timer(timer)
    return math.max(timer - Time.dt(), 0.0)
end

function player.update(self)
    if self.is_dead then
        return
    end

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
    -- 3. Пытаемся применить изменения в позиции (next_x, next_y). Однако
    --    реальный мир забирает нашу свободу 🗽❌! Нужно проверить, что мы не
    --    столкнулись ни с чем. А если столкнулись, то нужно поставить игрока
    --    настолько близко к месту к столкновению, насколько возможно. Другими
    --    словами, если (2) ставит player.velocity, то (3) ставит player.x, player.y.
    --    Я не очень хорошо объясняю, мне надоело писать комменты. Читайте код сами 😡!
    --


    -- 1. Запросы. Ничего интересного
    local is_on_ground = Physics.is_on_ground(self)

    local collision_to_the_left = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(self.x - 1, self.y))
    local hugging_left_wall = collision_to_the_left ~= nil

    local collision_to_the_right = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(self.x + 1, self.y))
    local hugging_right_wall = collision_to_the_right ~= nil

    -- проверка на колизию плохого тайла и изменение is_dead
    --
    -- ⚠  Внимание ⚠
    -- Этот код с плохими тайлами не мой. Так что не жалуйтесь на него! 😠
    --
    local tiles_that_we_collide_with = Physics.tile_ids_that_intersect_with_rect(self.hitbox:to_rect(self.x,self.y))
    for _, collision in ipairs(tiles_that_we_collide_with) do
        for _, bad_tile in pairs(data.bad_tile) do
            if collision.id == bad_tile then
                self.is_dead = true
                game.dialog_window.is_closed = false
                game.status = false
                self.x = PLAYER_START_X
                self.y = PLAYER_START_Y
                self.velocity.x = 0
                self.velocity.y = 0
                return
            end
        end
    end

    -- 2. Считываем ввод, работаем только с self.velocity
    local walking_right = btn(BUTTON_RIGHT) or key(KEY_D)
    local walking_left = btn(BUTTON_LEFT) or key(KEY_A)
    local looking_down = btn(BUTTON_DOWN) or key(KEY_S)
    local looking_up = btn(BUTTON_UP) or key(KEY_W)
    local jump_pressed = btnp(BUTTON_Z) or keyp(KEY_W)
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
        self.attack_rect = nil
    else
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
        --
        -- side note:
        -- Точно ли атаки по диагонали - хорошая идея?
        local diagonal_direction = 0
        if walking_left then
            diagonal_direction = 0 - 1
        elseif walking_right then
            -- Я хотел написать просто +1, но lua не смог откомпилировать, поэтому...
            diagonal_direction = 0 + 1
        end

        local attack_direction_x = 0
        local attack_direction_y = 0
        if looking_down then
            attack_direction_y = attack_direction_y + 1
            attack_direction_x = attack_direction_x + diagonal_direction
        elseif looking_up then
            attack_direction_y = attack_direction_y - 1
            attack_direction_x = attack_direction_x + diagonal_direction
        else
            if self.looking_left then
                attack_direction_x = attack_direction_x - 1
            else
                attack_direction_x = attack_direction_x + 1
            end
        end

        local attack_width = 6
        local attack_height = 6
        local attack_x = self.x + 4 - attack_width / 2 + attack_direction_x * 8
        local attack_y = self.y + 4 - attack_height / 2 + attack_direction_y * 8
        self.attack_rect = Rect:new(attack_x, attack_y, attack_width, attack_height)

        local attack_tilemap_collision = Physics.check_collision_rect_tilemap(self.attack_rect)
        if attack_tilemap_collision ~= nil then
            self.attack_timer = 0
        end

        hit_pandas = {}
        for _, panda in ipairs(game.pandas) do
            if Physics.check_collision_rect_rect(self.attack_rect, Hitbox.rect_of(panda)) then
                table.insert(hit_pandas, panda)
            end
        end
        if #hit_pandas > 0 then
            if looking_down then
                self.velocity.y = PLAYER_JUMP_STRENGTH
            end

            for _, panda in ipairs(hit_pandas) do
                panda:harm(PLAYER_DAMAGE)
                panda:get_hit(attack_direction_x, attack_direction_y)
            end
            self.attack_timer = 0
        end
    end

    if not moving_right and not moving_left then
        if is_on_ground then
            self.velocity.x = self.velocity.x - self.velocity.x * PLAYER_FRICTION * Time.dt()
        else
            -- Типа в воздухе другое сопротивление 💨
            -- Не знаю, на сколько это нужно 😅
            self.velocity.x = self.velocity.x - self.velocity.x * PLAYER_AIR_FRICTION * Time.dt()
        end
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

    local has_jumped = false
    local should_jump = self.jump_buffer_time > 0.0
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


    -- 3. Проверка коллизий. Уже не так впечатляюще, потому что я вынес код в Physics
    local horizontal_collision = Physics.move_x(self)
    if horizontal_collision ~= nil then
        self.velocity.x = 0
    end

    local vertical_collision = Physics.move_y(self)
    if vertical_collision ~= nil then
        self.velocity.y = 0
    end

    if self.attack_timer > 0 then
        self.sprite = PLAYER_SPRITE_ATTACK
    elseif self.velocity.y ~= 0 then
        self.sprite = PLAYER_SPRITE_JUMP
    elseif self.time_we_have_been_running > 0.1 and self.velocity.x ~= 0 then
        self.sprite = PLAYER_SPRITE_RUNNING
    else
        self.sprite = PLAYER_SPRITE_IDLE
    end

    -- У игрока есть много вещей, зависящих от времени (таймеров).
    -- Они обновляются тут, в самом конце.
    --
    -- Раз уж я начал писать коммент, поясню за таймеры ⌛
    -- Таймер - это просто число с плавающей точкой (обозначим его t). Если t =
    -- 0, значит таймер остановился. Если же t > 0, то таймер идет, и осталось
    -- t секунд до конца. Делать с этим можно что угодно, примеры можно
    -- посмотреть здесь, в игроке.
    self.time_before_we_can_stick_to_wall = tick_timer(self.time_before_we_can_stick_to_wall)
    self.jump_buffer_time = tick_timer(self.jump_buffer_time)
    self.coyote_time = tick_timer(self.coyote_time)
    self.remove_horizontal_speed_limit_time = tick_timer(self.remove_horizontal_speed_limit_time)
    self.attack_timer = tick_timer(self.attack_timer)
    if self.velocity.x ~= 0 then
        self.time_we_have_been_running = self.time_we_have_been_running + Time.dt()
    else
        self.time_we_have_been_running = 0
    end
end

function player.draw(self)
    local colorkey = 0
    local scale = 1
    local flip = self.looking_left and 1 or 0

    local tx, ty = game.camera_window:transform_coordinates(self.x, self.y)

    self.sprite:nextFrame()
    spr(self.sprite:current(), tx, ty, colorkey, scale, flip)

    if self.attack_rect then
        self.attack_rect:draw()
    end
end
