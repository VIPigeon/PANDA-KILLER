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

function Player:new()
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

        animation_controller = AnimationController:new(SPRITES.player.idle),

        -- Когда игрок умирает, у него слетает шляпа
        hat = nil,

        attack_rects = {},
        attack_effect = nil,
        attack_effect_time = 0,
        attack_cooldown = 0,

        stuck_to_left_wall = false,
        stuck_to_right_wall = false,
        looking_left = false,
        was_on_ground_last_frame = false,
        was_sliding_on_wall_last_frame = false,
        we_jumped_off_a_panda = false,
        is_dead = false,
        hide = false,  -- Когда игрок садится на байк, его надо прятать

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

    -- heart attack 💔 <- 💓 <- 💢
    kill_velocity_x = kill_velocity_x or 0
    kill_velocity_y = kill_velocity_y or 0

    self.velocity.x = PLAYER_DEATH_KNOCKBACK_HORIZONTAL * math.sign(kill_velocity_x)
    self.velocity.y = PLAYER_DEATH_KNOCKBACK_VERTICAL

    self.time_before_showing_death_screen = PLAYER_TIME_BEFORE_SHOWING_DEATH_SCREEN_AFTER_DEATH
    self.is_dead = true

    self.attack_effect_time = 0
    self.attack_cooldown = 0
    self.hat = Hat:new(self.x, self.y, 0.5 * self.velocity.x + kill_velocity_x, 0.5 * self.velocity.y + kill_velocity_y)

    Basic.play_sound(SOUNDS.PLAYER_DEAD)
end

function Player:is_attacking_or_charging_attack()
    return self.attack_timer > 0 and
           table.contains(PLAYER_ATTACK_SPRITES, self.animation_controller.sprite)
end

function Player:is_attacking()
    return self.attack_timer > 0 and
           table.contains(PLAYER_ATTACK_SPRITES, self.animation_controller.sprite) and
           self.animation_controller:animation_ended()
end

function Player:update()
    if self.hide then
        return
    end

    if self.is_dead then
        Physics.update(self)
        self.hat:update()

        self.animation_controller:set_sprite(SPRITES.player.dead)
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
    -- ⚠  Внимание, данный пост распростроняется разработчиком, являющимся иноагентом ⚠
    -- ⚠  Внимание ⚠
    -- Тут разработчик К решил скинуть свою вину, используя современные методы газлайтинга.
    -- Но кроме него никто не имеет доступа к этому коду и тем более не имеет возможности в нём разобраться.
    -- Неужели кто-то ещё сомневается в этом?
    -- 
    local tiles_that_we_collide_with = Physics.tile_ids_that_intersect_with_rect(self.hitbox:to_rect(self.x,self.y))
    local are_we_in_water = false
    for _, collision in ipairs(tiles_that_we_collide_with) do
        if is_bad_tile(collision.id) then
            --self:die(0, 50)
            --return
            are_we_in_water = true
        end
    end

    -- 2. Считываем ввод, работаем только с self.velocity
    local walking_right = is_held_down(CONTROLS.right)
    local walking_left = is_held_down(CONTROLS.left)
    local looking_down = is_held_down(CONTROLS.look_down)
    local looking_up = is_held_down(CONTROLS.look_up)
    local jump_pressed = was_just_pressed(CONTROLS.jump)
    local jump_held_down = is_held_down(CONTROLS.jump)
    local attack_pressed = was_just_pressed(CONTROLS.attack)

    if jump_pressed then
        self.jump_buffer_time = PLAYER_JUMP_BUFFER_TIME
    end

    if attack_pressed and self.attack_cooldown == 0 then
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
        if attack_pressed then
            self.attack_buffer_time = PLAYER_ATTACK_BUFFER_TIME
        end
        if self.attack_cooldown == 0 and self.attack_buffer_time > 0 then
            self.animation_controller:reset_animation()
            self.attack_timer = PLAYER_ATTACK_DURATION
            self.attack_buffer_time = 0.0
            Basic.play_sound(SOUNDS.PLAYER_ATTACK)
        end
    end



    if is_on_ground then
        self.velocity.x = self.velocity.x - self.velocity.x * PLAYER_FRICTION * Time.dt()
    else
        -- Типа в воздухе другое сопротивление 💨
        -- Не знаю, на сколько это нужно 😅
        self.velocity.x = self.velocity.x - self.velocity.x * PLAYER_AIR_FRICTION * Time.dt()
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
        local gravity_scale = 1
        if self.velocity.y > 0 and not jump_held_down and not self.we_jumped_off_a_panda then
            gravity_scale = PLAYER_GRAVITY_SCALE_WHEN_NOT_HOLDING
        end
        if self.remove_horizontal_speed_limit_time == 0.0 then
            self.velocity.y = self.velocity.y - gravity_scale * PLAYER_GRAVITY * Time.dt()
        else
            self.velocity.y = self.velocity.y - gravity_scale * PLAYER_GRAVITY_AFTER_WALL_JUMP * Time.dt()
        end
    end

    local has_jumped = false
    local has_walljumped = false
    local should_jump = self.jump_buffer_time > 0.0

    -- 2.5 🌟 Новая механика 🌟 
    -- Преобразование кинетической силы атаки блока в потенцально имбовую силу полёта ❗
    -- Эта фича взорвёт наших фанатов! 🤩🙄
    -- Она будет отличаться от обычного прыжка:
    -- * более слабым эффектом подбрасывания
    -- * отсутствием коётного времени для возможности соблюдать идеальный тайминг
    -- Таким образом эта фича понравится, как хардкорным игрокам, поскольку её использование
    -- значительно повысит сложность прохождения и предоставит им новые вызовы,
    -- так и простым игрокам, потому что они будут счастливы использовать обычный прыжок вместо этой странной фигни
    --
    if is_on_ground and attack_pressed and self.has_attacked_downward then
        -- Дорогой дневник разработки новых механик: 
        --
        -- 1 день:
        -- возможно будут проблемы в воде. Пока сделаю mwp
        --
        -- 2 день:
        -- вообще нет проблем с водой - зато получился бесконечный банихоп. Звучит здорово
        -- Самое классное, что он даже происходит без участия игрока
        --
        -- вечер 2 день банихопа:
        -- Нет, получилась возможность включить автобанихоп. Не баг, а фича
        -- 
        -- ночь 2 день:
        -- очень тяжело найти этот тайминг(проблема не в тайминге)
        --
        -- день 12:
        -- решил спросить у автора, получил ответ, цитата: "Я откуда знаю".
        --
        -- ^-- автор в то время был в неадекватном состоянии, иначе бы он ответил "😄🌊"
        --
        -- 35 день:
        -- Разобрался, что да как, думаю достаточно быстро для 1000000-строчного монолита
        -- Фича уходит в релиз
        --
        self.velocity.y = PLAYER_DOWNWARD_ATTACK_JUMP_STRENGTH
        has_jumped = true
    end
    -- Ну да, вписать это в обычный прыжок будет очень легко.

    if should_jump then
        if is_on_ground and self.velocity.y <= 0 then
            if are_we_in_water then
                -- Im under the water. Haha
                self.velocity.y = PLAYER_SLOWDOWN_IN_WATER_PERCENTAGE * PLAYER_JUMP_STRENGTH
            else
                self.velocity.y = PLAYER_JUMP_STRENGTH
            end
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

    if is_on_ground then
        if self.velocity.y == 0 then
            self.we_jumped_off_a_panda = false
        end
        if not self.was_on_ground_last_frame then
            Effects.add(self.x, self.y, SPRITES.particle_effects.land)
        end
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
    end
    self.was_sliding_on_wall_last_frame = sliding_on_wall


    if math.abs(self.velocity.x) < PLAYER_MIN_HORIZONTAL_VELOCITY then
        self.velocity.x = 0
    end
    if math.abs(self.velocity.y) < PLAYER_MIN_VERTICAL_VELOCITY then
        self.velocity.y = 0
    end

    self.velocity.y = math.clamp(self.velocity.y, -PLAYER_MAX_FALL_SPEED, PLAYER_MAX_FALL_SPEED)

    if self.velocity.x > 0 then
        self.looking_left = false
    elseif self.velocity.x < 0 then
        self.looking_left = true
    end


    if are_we_in_water then
        self.velocity.x = self.velocity.x * PLAYER_SLOWDOWN_IN_WATER_PERCENTAGE
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

    -- Теперь проверим, вошли ли мы в дом. Какая сложная механика с этими домами!
    local function reveal_any_house_at(tile_x, tile_y)
        if table.contains(HOUSE_DOORS_INSIDE, mget(tile_x, tile_y)) then
            local house = get_house_at(tile_x, tile_y)
            if house ~= nil then
                house:reveal(tile_x, tile_y)
            end
            return true
        end
        return false
    end
    local tile_x, tile_y = Basic.world_to_tile(player_rect:center_x(), player_rect:center_y())
    local we_are_inside_of_a_house = get_house_at(tile_x, tile_y) ~= nil
    if not we_are_inside_of_a_house then
        hide_all_houses()
    end
    reveal_any_house_at(tile_x, tile_y)
    reveal_any_house_at(tile_x - 1, tile_y)
    reveal_any_house_at(tile_x + 1, tile_y)
    reveal_any_house_at(tile_x - 2, tile_y)
    reveal_any_house_at(tile_x + 2, tile_y)

    -- Атака
    if self:is_attacking() then
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

        local attack_width = 8 + 4 * math.abs(attack_direction_x)
        local attack_height = 8 + 4 * math.abs(attack_direction_y)
        local attack_x = player_rect:center_x() - attack_width / 2 + attack_direction_x * 8
        local attack_y = player_rect:center_y() - attack_height / 2 + attack_direction_y * 8

        -- Смотреть issue #39
        if self.velocity.x < 0 then
            attack_x = attack_x - 2
        elseif self.velocity.x > 0 then
            attack_x = attack_x + 2
        end
        if not is_on_ground and looking_down then
            attack_y = attack_y + 2
        end

        local attack_rect = Rect:new(attack_x, attack_y, attack_width, attack_height)


        -- Выделение памяти 🤮
        self.attack_rects = {attack_rect, player_rect}

        local hit_pandas = {}
        for _, panda in ipairs(game.current_level.pandas) do
            local panda_rect = Hitbox.rect_of(panda)
            for _, rect in ipairs(self.attack_rects) do
                if Physics.check_collision_rect_rect(rect, panda_rect) then
                    table.insert(hit_pandas, panda)
                    break
                end
            end
        end

        if #hit_pandas > 0 then
            game.camera:shake(PLAYER_ATTACK_SHAKE_MAGNITUDE, PLAYER_ATTACK_SHAKE_DURATION)

            if looking_down then
                self.velocity.y = PLAYER_JUMP_BY_HIT
                self.we_jumped_off_a_panda = true
            end

            for _, panda in ipairs(hit_pandas) do
                if panda.state == PANDA_STATE.dashing then
                    goto next_iteration
                end

                -- Я положу здесь новую механику, каваи-гоплит не заметит грязный код,
                -- потому что он окружен обширным комментарием с смайликами😉
                -- да и монолитность не пропала, тут действительно не к чему придраться😎
                -- кхм, так вот - перетягивание бамбука
                if panda.kantugging_friend_panda then

                    ClickerMinigame:init(panda)
                    return
                end
                panda:take_damage(attack_direction_x, attack_direction_y)

                ::next_iteration::
            end
            self.attack_timer = 0
        end

        if not self.just_attacked then
            self.just_attacked = true
            if attack_direction_y > 0 then
                self.attack_effect = ChildBody:new(self, 8 * attack_direction_x, 8 * attack_direction_y, SPRITES.particle_effects.downward_attack)
            elseif attack_direction_y < 0 then
                self.attack_effect = ChildBody:new(self, 0, -16, SPRITES.particle_effects.upward_attack)
            else
                local flip = (attack_direction_x < 0) and 1 or 0
                self.attack_effect = ChildBody:new(self, 8 * attack_direction_x, -8 + 8 * attack_direction_y, SPRITES.particle_effects.horizontal_attack, flip)
            end
            self.attack_effect_time = PLAYER_ATTACK_EFFECT_DURATION
            self.attack_cooldown = PLAYER_ATTACK_COOLDOWN
        end

        for _, rect in ipairs(self.attack_rects) do
            local start_tx, start_ty = rect.x // 8, rect.y // 8
            local end_tx, end_ty = (rect.x + rect.w - 1) // 8, (rect.y + rect.h - 1) // 8
            
            for ty = start_ty, end_ty do
                for tx = start_tx, end_tx do
                    local tile = mget(tx, ty)
                    if tile >= 144 and tile <= 149 or tile >= 160 and tile <= 175 then
                        spread_leaves(attack_direction_x, attack_direction_y, tx, ty)
                    end
                end
            end
        end
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
                Effects.add(self.x + 2, self.y, SPRITES.particle_effects.jump)
            else
                Effects.add(self.x + 1, self.y, SPRITES.particle_effects.jump)
            end
        else
            Effects.add(self.x, self.y, SPRITES.particle_effects.jump)
        end
    end

    if self.attack_timer > 0 then
        if self.has_attacked_downward then
            self.animation_controller:set_sprite(SPRITES.player.attack_air_downward)
        elseif self.has_attacked_upwards then
            self.animation_controller:set_sprite(SPRITES.player.attack_upwards)
        elseif self.has_attacked_in_air then
            self.animation_controller:set_sprite(SPRITES.player.attack_air_forward)
        else
            self.animation_controller:set_sprite(SPRITES.player.attack)
        end
    elseif sliding_on_wall then
        self.animation_controller:set_sprite(SPRITES.player.slide)
    elseif self.velocity.y < 0 and not is_on_ground then
        self.animation_controller:set_sprite(SPRITES.player.falling)
    elseif self.velocity.y ~= 0 or not is_on_ground then
        self.animation_controller:set_sprite(SPRITES.player.jump)
    elseif self.time_we_have_been_running > 0.1 and self.velocity.x ~= 0 then
        self.animation_controller:set_sprite(SPRITES.player.running)
    else
        self.animation_controller:set_sprite(SPRITES.player.idle)
    end

    -- У игрока есть много вещей, зависящих от времени (таймеров).
    -- Они обновляются тут, в самом конце.
    self.jump_buffer_time = Basic.tick_timer(self.jump_buffer_time)
    self.coyote_time = Basic.tick_timer(self.coyote_time)
    self.remove_horizontal_speed_limit_time = Basic.tick_timer(self.remove_horizontal_speed_limit_time)
    self.attack_timer = Basic.tick_timer(self.attack_timer)
    self.attack_buffer_time = Basic.tick_timer(self.attack_buffer_time)
    self.attack_effect_time = Basic.tick_timer(self.attack_effect_time)
    self.attack_cooldown = Basic.tick_timer(self.attack_cooldown)
    if self.velocity.x ~= 0 then
        self.time_we_have_been_running = self.time_we_have_been_running + Time.dt()
    else
        self.time_we_have_been_running = 0
    end
end

function Player:draw()
    if self.hide then
        return
    end

    local flip = self.looking_left and 1 or 0

    local tx, ty = game.camera:transform_coordinates(self.x, self.y)
    --ty = ty - 8 * (self.animation_controller:current_animation().height - 1)

    for _, attack_rect in ipairs(self.attack_rects) do
        -- Этот код не работает. Почему?
        --if attack_rect.y < Hitbox.rect_of(self).y - 2 then
        --    flip = flip + 2
        --end
    end

    self.animation_controller:draw(tx, ty, flip)
    self.animation_controller:next_frame()

    if self.attack_effect_time > 0 then
        self.attack_effect:draw()
    end

    if self.is_dead then
        self.hat:draw()
    end

    --for _, attack_rect in ipairs(self.attack_rects) do
    --   attack_rect:draw(2)
    --end
end

Player.__index = Player
