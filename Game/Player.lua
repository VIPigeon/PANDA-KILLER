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

Player = {}

function Player:new(x, y)
    local object = {
        x = PLAYER_SPAWNPOINT_X,
        y = PLAYER_SPAWNPOINT_Y,
        velocity = {
            x = 0,
            y = 0,
        },
        hitbox = Hitbox:new(6, 0, 4, 8),
        physics_settings = {
            gravity = PLAYER_GRAVITY,
            friction = PLAYER_FRICTION,
            min_horizontal_velocity = PLAYER_MIN_HORIZONTAL_VELOCITY,
        },

        sprite = PLAYER_SPRITE_IDLE,

        -- Когда игрок умирает, у него слетает шляпа
        hat = nil,

        attack_rects = {},
        attack_effect = nil,
        attack_effect_time = 0,

        stuck_to_left_wall = false,
        stuck_to_right_wall = false,
        looking_left = false,
        was_on_ground_last_frame = false,
        was_sliding_on_wall_last_frame = false,
        is_dead = false,

        -- Это для анимаций. Как по другому, я не придумал 😜
        has_attacked_in_air = false,
        has_attacked_downward = false,
        has_attacked_upwards = false,
        just_attacked = false,

        coyote_time = 0.0,
        attack_timer = 0.0,
        jump_buffer_time = 0.0,
        remove_horizontal_speed_limit_time = 0.0,
        attack_buffer_time = 0.0,
        time_we_have_been_running = 0.0,

        time_before_showing_death_screen = 0.0,
    }

    setmetatable(object, self)
    return object
end

function Player:die(kill_velocity_x, kill_velocity_y)
    if self.is_dead then
        return
    end

    self.velocity.x = PLAYER_DEATH_KNOCKBACK_HORIZONTAL * math.sign(kill_velocity_x)
    self.velocity.y = PLAYER_DEATH_KNOCKBACK_VERTICAL

    self.time_before_showing_death_screen = PLAYER_TIME_BEFORE_SHOWING_DEATH_SCREEN_AFTER_DEATH
    self.is_dead = true

    self.attack_effect_time = 0
    self.hat = Hat:new(self.x, self.y, 0.5 * self.velocity.x + kill_velocity_x, 0.5 * self.velocity.y + kill_velocity_y)

    Basic.play_sound(SOUNDS.PLAYER_DEAD)
end

function Player:update()
    if self.is_dead then
        Physics.update(self)
        self.hat:update()

        self.sprite = PLAYER_SPRITE_DEAD
        self.time_before_showing_death_screen = Basic.tick_timer(self.time_before_showing_death_screen)
        if self.time_before_showing_death_screen == 0.0 then
            game.dialog_window.is_closed = false
            game.state = GAME_STATE_PAUSED
            self.x = PLAYER_SPAWNPOINT_X
            self.y = PLAYER_SPAWNPOINT_Y
            self.velocity.x = 0
            self.velocity.y = 0
        end

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

    local player_rect = Hitbox.rect_of(self)

    -- проверка на колизию плохого тайла и изменение is_dead
    --
    -- ⚠  Внимание ⚠
    -- Этот код с плохими тайлами не мой. Так что не жалуйтесь на него! 😠
    --
    local tiles_that_we_collide_with = Physics.tile_ids_that_intersect_with_rect(self.hitbox:to_rect(self.x,self.y))
    for _, collision in ipairs(tiles_that_we_collide_with) do
        for _, bad_tile in pairs(data.bad_tile) do
            if collision.id == bad_tile then
                self:die()
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
        self.attack_buffer_time = PLAYER_ATTACK_BUFFER_TIME

        if not is_on_ground then
            self.has_attacked_in_air = true
        else
            self.has_attacked_in_air = false
        end

        self.has_attacked_downward = false
        self.has_attacked_upwards = false
        if looking_down then
            self.has_attacked_downward = true
        elseif looking_up then
            self.has_attacked_upwards = true
        end
    end

    if self.attack_timer == 0 then
        self.just_attacked = false
        self.attack_rects = {}
        if self.attack_buffer_time > 0.0 then
            self.sprite:reset()
            self.attack_timer = PLAYER_ATTACK_DURATION
            self.attack_buffer_time = 0.0
            Basic.play_sound(SOUNDS.PLAYER_ATTACK)
        end
    end

    if self.attack_timer > 0 and
       table.contains(PLAYER_ATTACK_SPRITES, self.sprite) and
       self.sprite:animation_ended()
    then
        --
        -- side note:
        -- Точно ли атаки по диагонали - хорошая идея?
        local attack_direction_x = 0
        local attack_direction_y = 0
        if looking_down then
            attack_direction_y = attack_direction_y + 1
        elseif looking_up then
            attack_direction_y = attack_direction_y - 1
        else
            if self.looking_left then
                attack_direction_x = attack_direction_x - 1
            else
                attack_direction_x = attack_direction_x + 1
            end
        end

        -- Из-за вот такой штуки атаки по диагонали довольно имбовые. А что делать?
        local attack_width = 8 + 2 * math.abs(attack_direction_x)
        local attack_height = 8 + 2 * math.abs(attack_direction_y)
        local attack_x = player_rect:center_x() - attack_width / 2 + attack_direction_x * 8
        local attack_y = player_rect:center_y() - attack_height / 2 + attack_direction_y * 8
        local attack_rect = Rect:new(attack_x, attack_y, attack_width, attack_height)

        local attack_tilemap_collision = Physics.check_collision_rect_tilemap(attack_rect)

        -- Выделение памяти 🤮
        self.attack_rects = {attack_rect, player_rect}

        hit_pandas = {}
        for _, panda in ipairs(game.pandas) do
            local panda_rect = Hitbox.rect_of(panda)
            for _, attack_rect in ipairs(self.attack_rects) do
                if Physics.check_collision_rect_rect(attack_rect, panda_rect) then
                    table.insert(hit_pandas, panda)
                    break
                end
            end
        end
        if #hit_pandas > 0 then
            if looking_down then
                self.velocity.y = PLAYER_JUMP_STRENGTH
            end

            for _, panda in ipairs(hit_pandas) do
                panda:take_damage(attack_direction_x, attack_direction_y)
            end
            self.attack_timer = 0
        end

        if not self.just_attacked then
            self.just_attacked = true
            if self.has_attacked_downward then
                self.attack_effect = ChildBody:new(self, 8 * attack_direction_x, 8 * attack_direction_y, PLAYER_SPRITE_ATTACK_PARTICLE_EFFECT_DOWNWARD)
            elseif self.has_attacked_upwards then
                self.attack_effect = ChildBody:new(self, 0, -16, PLAYER_SPRITE_ATTACK_PARTICLE_EFFECT_UPWARD)
            else
                local flip = (attack_direction_x < 0) and 1 or 0
                self.attack_effect = ChildBody:new(self, 8 * attack_direction_x, -8 + 8 * attack_direction_y, PLAYER_SPRITE_ATTACK_PARTICLE_EFFECT_HORIZONTAL, flip)
            end
            self.attack_effect_time = PLAYER_ATTACK_EFFECT_DURATION
        end

        game.camera:shake(PLAYER_ATTACK_SHAKE_MAGNITUDE, PLAYER_ATTACK_SHAKE_DURATION)
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
    local has_walljumped = false
    local should_jump = self.jump_buffer_time > 0.0
    if should_jump then
        if is_on_ground and self.velocity.y <= 0 then
            self.velocity.y = PLAYER_JUMP_STRENGTH
            has_jumped = true
        elseif hugging_left_wall and not is_on_ground then
            self.velocity.y = PLAYER_WALL_JUMP_VERTICAL_STRENGTH
            self.velocity.x = PLAYER_WALL_JUMP_HORIZONTAL_STRENGTH
            self.remove_horizontal_speed_limit_time = PLAYER_REMOVE_SPEED_LIMIT_AFTER_WALL_JUMP_TIME
            has_jumped = true
            has_walljumped = true
        elseif hugging_right_wall and not is_on_ground then
            self.velocity.y = PLAYER_WALL_JUMP_VERTICAL_STRENGTH
            self.velocity.x = -1 * PLAYER_WALL_JUMP_HORIZONTAL_STRENGTH
            self.remove_horizontal_speed_limit_time = PLAYER_REMOVE_SPEED_LIMIT_AFTER_WALL_JUMP_TIME
            has_jumped = true
            has_walljumped = true
        end
    end
    if jump_pressed and self.coyote_time > 0.0 and self.velocity.y <= 0.0 then
        self.velocity.y = PLAYER_JUMP_STRENGTH
        has_jumped = true
    end
    if has_jumped then
        self.coyote_time = 0.0
        self.jump_buffer_time = 0.0
        Basic.play_sound(SOUNDS.PLAYER_JUMP)
    end

    if is_on_ground and not self.was_on_ground_last_frame then
        Effects.add(self.x, self.y, PLAYER_SPRITE_LAND_PARTICLE_EFFECT)
    end

    if not is_on_ground and self.was_on_ground_last_frame and self.velocity.y <= 0 then
       self.coyote_time = PLAYER_COYOTE_TIME
    end
    self.was_on_ground_last_frame = is_on_ground

    local can_stick_to_wall = self.velocity.y <= 0
    local sliding_on_wall = false
    if not is_on_ground and can_stick_to_wall then
        if hugging_left_wall and self.velocity.x < 0 or
           hugging_right_wall and self.velocity.x > 0 then
            self.velocity.y = -1 * PLAYER_WALL_SLIDE_SPEED
            sliding_on_wall = true
        end
    end
    if self.was_sliding_on_wall_last_frame and not sliding_on_wall then
        Basic.play_sound(SOUNDS.MUTE_CHANNEL_ONE)
    elseif not self.was_sliding_on_wall_last_frame and sliding_on_wall then
        Basic.play_sound(SOUNDS.PLAYER_SLIDE)
        sfx(8, 'D-1', -1, 1)
    end
    self.was_sliding_on_wall_last_frame = sliding_on_wall


    if math.abs(self.velocity.x) < PLAYER_MIN_HORIZONTAL_VELOCITY then
        self.velocity.x = 0
    end
    if math.abs(self.velocity.y) < PLAYER_MIN_VERTICAL_VELOCITY then
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

    -- Анимациями занимаются здесь 🏭
    -- Заметка для меня из будущего:
    -- Здесь может быть баг с тем, что спрайты глобальные. Так было
    -- в пандах, у которых был один общий спрайт на всех, поэтому пришлось
    -- копировать.
    if has_jumped then
        if has_walljumped then
            -- Наверное в будущем здесь вообще будут кастомные эффекты. Пока
            -- что же тут магические константы 🪄
            if self.looking_left then
                Effects.add(self.x + 2, self.y, PLAYER_SPRITE_JUMP_PARTICLE_EFFECT)
            else
                Effects.add(self.x + 1, self.y, PLAYER_SPRITE_JUMP_PARTICLE_EFFECT)
            end
        else
            Effects.add(self.x, self.y, PLAYER_SPRITE_JUMP_PARTICLE_EFFECT)
        end
    end

    local previous_sprite = self.sprite

    if self.sprite == PLAYER_SPRITE_ATTACK and not self.sprite:animation_ended() then
        -- goto использован 😎
        goto no_sprite_change
    end

    if self.attack_timer > 0 then
        if self.has_attacked_downward then
            self.sprite = PLAYER_SPRITE_ATTACK_AIR_DOWNWARD
        elseif self.has_attacked_upwards then
            self.sprite = PLAYER_SPRITE_ATTACK_UPWARDS
        elseif self.has_attacked_in_air then
            self.sprite = PLAYER_SPRITE_ATTACK_AIR_FORWARD
        else
            self.sprite = PLAYER_SPRITE_ATTACK
        end
    elseif sliding_on_wall then
        self.sprite = PLAYER_SPRITE_SLIDE
    elseif self.velocity.y < 0 and not is_on_ground then
        self.sprite = PLAYER_SPRITE_FALLING
    elseif self.velocity.y ~= 0 or not is_on_ground then
        self.sprite = PLAYER_SPRITE_JUMP
    elseif self.time_we_have_been_running > 0.1 and self.velocity.x ~= 0 then
        self.sprite = PLAYER_SPRITE_RUNNING
    else
        self.sprite = PLAYER_SPRITE_IDLE
    end

    if self.sprite ~= previous_sprite then
        self.sprite:reset()
    end

    ::no_sprite_change::

    -- У игрока есть много вещей, зависящих от времени (таймеров).
    -- Они обновляются тут, в самом конце.
    self.jump_buffer_time = Basic.tick_timer(self.jump_buffer_time)
    self.coyote_time = Basic.tick_timer(self.coyote_time)
    self.remove_horizontal_speed_limit_time = Basic.tick_timer(self.remove_horizontal_speed_limit_time)
    self.attack_timer = Basic.tick_timer(self.attack_timer)
    self.attack_buffer_time = Basic.tick_timer(self.attack_buffer_time)
    self.attack_effect_time = Basic.tick_timer(self.attack_effect_time)
    if self.velocity.x ~= 0 then
        self.time_we_have_been_running = self.time_we_have_been_running + Time.dt()
    else
        self.time_we_have_been_running = 0
    end
end

function Player:draw()
    local colorkey = 0
    local scale = 1

    local flip = self.looking_left and 1 or 0

    local tx, ty = game.camera:transform_coordinates(self.x, self.y)
    ty = ty - 8 * (self.sprite:current_animation().height - 1)

    for _, attack_rect in ipairs(self.attack_rects) do
        -- Этот код не работает. Почему?
        --if attack_rect.y < Hitbox.rect_of(self).y - 2 then
        --    flip = flip + 2
        --end
    end

    self.sprite:draw(tx, ty, flip)
    self.sprite:next_frame()

    if self.attack_effect_time > 0 then
        self.attack_effect:draw()
    end

    if self.is_dead then
        self.hat:draw()
    end

    --for _, attack_rect in ipairs(self.attack_rects) do
    --    attack_rect:draw()
    --end
end

Player.__index = Player
