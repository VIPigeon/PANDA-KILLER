--[[

Здесь начал размножаться грязнокод ♻️ 🤮

Кто прочитал, тот обязан это почистить 🚽
> Я прочитал. Готов взяться за уборку 🧽
> Убрано. киви-код (c) 2025

--]]

Panda = {}

-- Когда уже в lua добавят enum-ы? 😩
local PANDA_STATE = {
    patrol = 1,
    chase = 2,
    charging_dash = 3,
    charging_basic_attack = 4,
    doing_basic_attack = 5,
    dashing = 6,
    staggered = 7,
    stunned = 8,
}

local PANDA_STATE_COLORS = {2, 3, 4, 5, 7, 6, 8, 9}

function Panda:new(x, y, can_tug)
    CANTUG = can_tug or false
    local object = {
        x = x,
        y = y,
        velocity = {
            x = 0,
            y = 0,
        },
        hitbox = Hitbox:new(2, 0, 4, 8),
        physics_settings = PANDA_PHYSICS_SETTINGS,

        state = PANDA_STATE.patrol,

        animation_controller = AnimationController:new(PANDA_SPRITES.rest),
        look_direction = math.coin_flip() and 1 or -1,

        attack_effect = nil,       -- Мне не нравятся, что в панде плодятся такие поля
        attack_effect_time = 0.0,  -- и такие...

        time_of_most_recent_hit = 0.0,
        count_of_recent_hits = 0.0,

        time_we_have_been_chasing = 0.0,
        time_since_dashing = 0.0,

        chase_time_left = 0.0,
        patrol_rest_time = 0.0,
        stagger_time_left = 0.0,
        stun_time_left = 0.0,
        basic_attack_time_left = 0.0,

        -- Хотите ли вы потягаться с такой пандой?🙄 Ответ был дан выше
        kantugging_friend_panda = CANTUG,
    }

    setmetatable(object, self)
    return object
end

function Panda:view_cone_shape()
    local rect = Hitbox.rect_of(self)

    local tx, ty = rect:center_x(), rect:center_y()

    if self.look_direction == PANDA_LOOK_DIRECTION_LEFT then
        tx = tx - PANDA_VIEW_CONE_WIDTH / 2
    else
        tx = tx + PANDA_VIEW_CONE_WIDTH / 2
    end

    ty = ty - PANDA_VIEW_CONE_HEIGHT / 2
    tx = tx - PANDA_VIEW_CONE_WIDTH / 2

    local look_ahead_rect = Rect:new(tx, ty, PANDA_VIEW_CONE_WIDTH, PANDA_VIEW_CONE_HEIGHT)
    PANDA_BACK_VIEW = 20
    local a_bit_behind_rect = Rect:new(
        self.x - PANDA_BACK_VIEW,
        self.y - PANDA_BACK_VIEW / 2,
        2 * PANDA_BACK_VIEW,
        PANDA_BACK_VIEW
    )

    return Shape:new({look_ahead_rect, a_bit_behind_rect})
end

function Panda:take_damage(hit_x, hit_y)
    Basic.play_sound(SOUNDS.PANDA_HIT)

    if hit_x < 0 then
        create_blood(self.x, self.y, -1)
    elseif hit_x > 0 then
        create_blood(self.x, self.y, 1)
    else
        create_blood(self.x, self.y, -1)
        create_blood(self.x, self.y, 1)
    end

    if self.state == PANDA_STATE.stunned then
        -- Умираем 💀
        Basic.play_sound(SOUNDS.PANDA_DEAD)
        table.remove_element(game.pandas, self)
        return
    end

    self.count_of_recent_hits = self.count_of_recent_hits + 1
    self.time_of_most_recent_hit = Time.now()

    local panda_should_get_stunned = self.count_of_recent_hits >= PANDA_HITS_NEEDED_TO_GET_STUNNED
    if panda_should_get_stunned then
        if hit_x < 0 then
            self.velocity.x = -1 * PANDA_STUN_KNOCKBACK_HORIZONTAL
        elseif hit_x > 0 then
            self.velocity.x = PANDA_STUN_KNOCKBACK_HORIZONTAL
        end
        self.velocity.y = PANDA_STUN_KNOCKBACK_VERTICAL

        self.rest_time = 0.0
        self.count_of_recent_hits = 0

        self.state = PANDA_STATE.stunned
        self.stun_time_left = PANDA_STUN_DURATION
    else
        if hit_x < 0 then
            self.velocity.x = -1 * PANDA_KNOCKBACK_HORIZONTAL
        else
            self.velocity.x = PANDA_KNOCKBACK_HORIZONTAL
        end
        self.velocity.y = PANDA_KNOCKBACK_VERTICAL

        self.state = PANDA_STATE.staggered
        self.stagger_time_left = PANDA_STAGGER_DURATION
    end
end

function Panda:update()
    --
    -- И ведь будут же люди, которым здесь нужно будет что-то сделать, они зайдут,
    -- пролистают код, и скажут: "Боже, какой кошмар." Скажут, что тут такое непреодолимое
    -- нечитаемое сверх-страшное полотно, которое ни один человек в нормальном сознании
    -- не сможет осилить.
    --
    -- Хм... 🤔
    --
    -- И потом будут ещё говорить: "Эй, kawaii-Code, ты совершенно не умеешь программировать,
    -- вот этой панде очень хорошо подойдет паттерн ``Стратегия'', вот с ним бы было бы не так
    -- страшно!" А потом ещё: "Ну ты бы хотя бы вынес тут код в функции, оно же совершенно
    -- не читаемо!" И они все будут такие гордые, ведь, вот они, видят как написать этот код
    -- намного лучше чем тот, кто был до них. Они откажутся писать здесь новые фичи, ведь
    -- "Ну наговнокожено!" и запросят большой рефакторинг. "Тут надо всё переписывать с нуля."
    --
    -- Ага... 🙂
    -- 
    -- И ведь они отрефакторят! Они сделают много классов, каждый с единой ответственностью.
    -- Будет класс, занимающийся физичным движением панды и больше ничем. Будет класс
    -- атаки, там тоже всё будет мило. И будет класс самой панды, которая создает вот эти
    -- вот вспомогательные классы поменьше и контролирует их сверху. Или же они сделают
    -- state машину, ведь тут "она прямо просится, вот у тебя поле state!" И всю логику,
    -- разложенную снизу в if-ах, они распихают по отдельным классам, даже по разным файлам!
    -- Ведь так будет "Чистый Код (tm)."
    --
    -- Угу... 😐
    --
    -- Потом, после дня, отнятого на рефакторинг (а ведь не дай бог больше), они сядут,
    -- взглянут на проделанную работу и скажут: "Вот теперь хорошо!" И довольные сядут
    -- писать наконец новую фичу.
    --
    -- Эх..... 😫
    --
    -- И они даже не заметят, что кода то стало больше, чем было здесь, в огромном update-е.
    -- Просто он теперь раскидан по разным функциям и классам, которые, я не сомневаюсь,
    -- хорошо названы, ведь они придумывают так много имен для всего подряд за день!
    -- Они так же не заметят, как угробили производительность в пару раз. "Да мы и так в lua,
    -- тут пиксельная игра, какой перфоманс?" А потом у них игра в браузере лагает, ведь
    -- быстродействие умирает от тысячи порезов. Они даже не заметят, что, невероятно, но
    -- их код стал МЕНЕЕ читаемым! Ну то есть он КАЖЕТСЯ более читаемым, ведь смотрите,
    -- как всё понятно названо, коротко и ёмко, везде функции по 5 строчек! Но мне, чтобы
    -- разобраться, какого хрена панда внезапно меняет спрайт посередине атаки, нужно разрыть
    -- несколько файлов, в которых скрыта куча функций! То есть полотнище, как у меня здесь,
    -- я могу спокойно прочитать сверху вниз. Да, это требует усилий, но блин,
    -- ХОРОШО ПРОГРАММИРОВАТЬ = ПРИЛАГАТЬ УСИЛИЯ.
    -- Фанаты ООП прячут кучу мусора под красивой обёрткой и теперь им -> ПРОСТО <-, хотя по
    -- сути они только неоправданно усложнили код, но им КАЖЕТСЯ проще. Вот кто-то пытался
    -- измерить сложность кода, почитайте:
    -- https://www.researchgate.net/publication/220636945_On_the_Cognitive_Complexity_of_Software_and_its_Quantification_and_Formal_Measurement
    -- И ведь сама идея объектов хороша, мы часто хотим связать наши данные с поведением, но
    -- из-за абьюза этих возможностей получается AbstractFactoryFactory, а кто говорит, что
    -- таким не занимается, тот рано или поздно к этому придёт, потому что верит в хорошесть
    -- этих Clean Code принципов, а они к этому рано или поздно приведут.
    --
    -- Всё нужно использовать в меру. Тут не помешало бы действильно сделать немного абстракций,
    -- но в неумелых руках пара абстракций легко превратиться в огромное астрактное чудище 🦍
    -- И мои руки неумелы.
    --
    -- Я раньше писал ООП-шный код. А потом сознательно перешёл на такой стиль. У меня
    -- прибавилась производительность, я обрел способность доводить проекты до конца, а
    -- скорость написания кода выросла. Это пока что субъективно, но самое субъективное, что только
    -- есть в программировании, так это "Чистота Кода." Программирование - наука в первую очередь
    -- ИНЖЕНЕРНАЯ, не зря она называется Software Engineering. Нужно измерять. Измерять производительность
    -- кода, измерять время программиста, которое затрачивается на написание фич, измерять
    -- "сложность" или "простоту" кода. Что будет лидировать по этим параметрам, то и есть "Чистый Код."
    --
    -- А всё остальное -- мусор ♻️, которым не стоит забивать голову.
    --

    local player = game.player

    local is_on_ground = Physics.is_on_ground(self)

    local view_cone = self:view_cone_shape()
    local sees_player = Physics.check_collision_shape_rect(view_cone, Hitbox.rect_of(player))

    if self.state == PANDA_STATE.patrol then

        if self.patrol_rest_time > 0.0 then
            self.patrol_rest_time = Basic.tick_timer(self.patrol_rest_time)
            self.velocity.x = 0
            if self.patrol_rest_time == 0.0 then
                self.look_direction = -1 * self.look_direction
            end
        else
            local x_in_the_near_future = self.x + self.look_direction * PANDA_PATROL_PIXELS_UNTIL_STOP

            local wall_to_the_right = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(x_in_the_near_future, self.y)) ~= nil
            local ground_forward = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(x_in_the_near_future, self.y + 1)) ~= nil

            if wall_to_the_right or not ground_forward then
                self.patrol_rest_time = PANDA_REST_TIME_BEFORE_DIRECTION_CHANGE()
            end

            -- 🤔
            self.velocity.x = PANDA_PATROL_SPEED * self.look_direction
        end

        if sees_player then
            self.state = PANDA_STATE.chase
            self.chase_time_left = PANDA_CHASE_DURATION
        end

    elseif self.state == PANDA_STATE.chase then

        if sees_player then
            self.chase_time_left = PANDA_CHASE_DURATION
        end

        local chased_the_player_enough = self.time_we_have_been_chasing > PANDA_CHASE_DUMBNESS_TIME_AFTER_STARTING_CHASE
        local x_distance_to_player = math.abs(player.x - self.x)
        local y_distance_to_player = math.abs(player.y - self.y)

        self.look_direction = math.sign(player.x - self.x)

        if chased_the_player_enough and
           x_distance_to_player <= PANDA_X_DISTANCE_TO_PLAYER_UNTIL_BASIC_ATTACK and
           y_distance_to_player <= PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_BASIC_ATTACK
        then

            Basic.play_sound(SOUNDS.PANDA_BASIC_ATTACK_CHARGE)
            self.state = PANDA_STATE.charging_basic_attack

        elseif chased_the_player_enough and 
               is_on_ground and
               x_distance_to_player <= PANDA_X_DISTANCE_TO_PLAYER_UNTIL_DASH
        then

            if y_distance_to_player <= PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_DASH then
                Basic.play_sound(SOUNDS.PANDA_DASH_CHARGE)
                self.state = PANDA_STATE.charging_dash
                self.charging_dash_time_left = PANDA_DASH_CHARGE_DURATION
            else
                -- Мы слишком низко, попробуем к игроку прыгнуть
                Basic.play_sound(SOUNDS.PANDA_JUMP)
                self.velocity.y = PANDA_CHASE_JUMP_STRENGTH
            end

        else

            local x_in_the_near_future = self.x + self.look_direction * PANDA_CHASE_PIXELS_UNTIL_JUMP
            local x_direction_to_player = math.sign(game.player.x - self.x)

            local wall_to_the_right = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(x_in_the_near_future, self.y)) ~= nil
            local ground_forward = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(x_in_the_near_future, self.y + 1)) ~= nil

            if is_on_ground and wall_to_the_right then
                Basic.play_sound(SOUNDS.PANDA_JUMP)
                self.velocity.y = PANDA_CHASE_JUMP_STRENGTH
            end
            self.velocity.x = PANDA_CHASE_SPEED * x_direction_to_player

        end

        self.chase_time_left = Basic.tick_timer(self.chase_time_left)
        if self.chase_time_left == 0.0 then
            self.state = PANDA_STATE.patrol
            self.patrol_rest_time = PANDA_REST_TIME_BEFORE_DIRECTION_CHANGE()
        end

    elseif self.state == PANDA_STATE.charging_dash then

        self.charging_dash_time_left = Basic.tick_timer(self.charging_dash_time_left)
        if self.charging_dash_time_left == 0.0 then
            Basic.play_sound(SOUNDS.PANDA_DASH)
            self.state = PANDA_STATE.dashing
            self.time_since_dashing = 0.0

            local y_distance_to_player = math.abs(player.y - self.y)
            self.velocity.x = 100 * self.look_direction
        end

    elseif self.state == PANDA_STATE.charging_basic_attack then

        self.look_direction = player.x < self.x and -1 or 1

        if self.animation_controller:is_at_last_frame() then
            if self.basic_attack_time_left == 0.0 then
                local our_rect = Hitbox.rect_of(self)
                local player_rect = Hitbox.rect_of(player)
                local attack_rect = Rect:new(
                    our_rect:center_x() + 8 * self.look_direction,
                    our_rect:center_y(),
                    8 + 2 * self.look_direction,
                    8
                )
                if Physics.check_collision_rect_rect(our_rect, player_rect) then
                    player:die(self.look_direction, 0)
                elseif Physics.check_collision_rect_rect(attack_rect, player_rect) then
                    player:die(self.look_direction, 0)
                end

                Basic.play_sound(SOUNDS.PANDA_BASIC_ATTACK)

                local flip = (self.look_direction < 0) and 1 or 0
                self.attack_effect = ChildBody:new(
                    self,
                    8 * (self.look_direction - flip),
                    -8 * (self.animation_controller:current_animation().height - 1),
                    PANDA_SPRITE_BASIC_ATTACK_PARTICLE_EFFECT_HORIZONTAL,
                    flip
                )
                self.attack_effect_time = PANDA_BASIC_ATTACK_EFFECT_DURATION
                self.basic_attack_time_left = PANDA_BASIC_ATTACK_DURATION
            else
                self.basic_attack_time_left = Basic.tick_timer(self.basic_attack_time_left)
                if self.basic_attack_time_left == 0.0 then
                    self.state = PANDA_STATE.chase
                end
            end
        end

    elseif self.state == PANDA_STATE.dashing then

        local our_rect = Hitbox.rect_of(self)
        local player_rect = Hitbox.rect_of(game.player)

        if Physics.check_collision_rect_rect(our_rect, player_rect) then
            game.player:die(self.velocity.x, self.velocity.y)
        end

        self.time_since_dashing = self.time_since_dashing + Time.dt()

        if is_on_ground and self.time_since_dashing > PANDA_DASH_DURATION then
            self.state = PANDA_STATE.chase
        end
        self.chase_time_left = Basic.tick_timer(self.chase_time_left)

    elseif self.state == PANDA_STATE.staggered then

        self.stagger_time_left = Basic.tick_timer(self.stagger_time_left)
        if self.stagger_time_left == 0.0 then
            self.state = PANDA_STATE.patrol
        end

    elseif self.state == PANDA_STATE.stunned then

        self.stun_time_left = Basic.tick_timer(self.stun_time_left)
        if self.stun_time_left == 0.0 then
            self.state = PANDA_STATE.patrol
        end

    else

        error('Invalid panda state!') -- ✂

    end

    Physics.update(self)

    if Time.now() - self.time_of_most_recent_hit > PANDA_TIME_INTERVAL_BETWEEN_HITS_FROM_PLAYER then
        self.count_of_recent_hits = 0
    end

    -- Под конец занимаемся спрайтами. Как в игроке! 😄
    if self.state == PANDA_STATE.stunned or
       self.state == PANDA_STATE.staggered
    then
        -- goto 😎
        goto hitlocked
    end

    if self.state == PANDA_STATE.patrol then
        if self.patrol_rest_time > 0.0 then
            self.animation_controller:set_sprite(PANDA_SPRITES.rest)
        else
            self.animation_controller:set_sprite(PANDA_SPRITES.walk)
        end
    elseif self.state == PANDA_STATE.charging_basic_attack then
        self.animation_controller:set_sprite(PANDA_SPRITES.charging_basic_attack)
    elseif self.state == PANDA_STATE.chase then
        self.animation_controller:set_sprite(PANDA_SPRITES.chase)
    elseif self.state == PANDA_STATE.charging_dash then
        self.animation_controller:set_sprite(PANDA_SPRITES.charging_dash)
    elseif self.state == PANDA_STATE.dashing then
        self.animation_controller:set_sprite(PANDA_SPRITES.dash)
    end

    self.animation_controller:next_frame()

    ::hitlocked::

    self.attack_effect_time = Basic.tick_timer(self.attack_effect_time)
    if self.state == PANDA_STATE.chase then
        self.time_we_have_been_chasing = self.time_we_have_been_chasing + Time.dt()
    else
        self.time_we_have_been_chasing = 0.0
    end
end

function Panda:draw()
    local flip = self.look_direction == PANDA_LOOK_DIRECTION_RIGHT and 0 or 1

    local tx, ty = game.camera:transform_coordinates(self.x, self.y)

    rect(tx, ty - 6, 4, 4, PANDA_STATE_COLORS[self.state])

    if self.attack_effect_time > 0.0 then
        self.attack_effect:draw()
    end

    -- Ну тип ладно. Вообще довольно дурацкий костыль, не знаю как это лучше сделать.
    -- Это для правильного позиционирования спрайтов, у которых несколько анимаций
    -- с разными размерами.
    tx = tx - 4 * (self.animation_controller:current_animation().width - 1)
    ty = ty - 8 * (self.animation_controller:current_animation().height - 1)
    self.animation_controller:draw(tx, ty, flip)
end

Panda.__index = Panda
