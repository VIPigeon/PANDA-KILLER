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
    charging_attack = 3,
    pounce = 4,
    staggered = 5,
    stunned = 6,
}

local PANDA_STATE_COLORS = {2, 3, 4, 5, 7, 6}

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

        sprite = nil,
        sprites = {
            rest = PANDA_SPRITES.rest:copy(),
            patrol = PANDA_SPRITES.walk:copy(),
            chase = PANDA_SPRITES.chase:copy(),
            charging_attack = PANDA_SPRITES.charging_attack:copy(),
            pounce = PANDA_SPRITES.pounce:copy(),
        },
        look_direction = math.coin_flip() and 1 or -1,

        time_of_most_recent_hit = 0.0,
        count_of_recent_hits = 0.0,

        time_since_pounce = 0.0,
        chase_time_left = 0.0,
        patrol_rest_time = 0.0,
        stagger_time_left = 0.0,
        stun_time_left = 0.0,

        kantugging_friend_panda = CANTUG,
    }
    object.sprite = object.sprites.rest

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

        -- Bullshit
        local x_distance_to_player = math.abs(player.x - self.x)
        self.look_direction = math.sign(player.x - self.x)
        if x_distance_to_player <= PANDA_X_DISTANCE_TO_PLAYER_UNTIL_ATTACK then
            Basic.play_sound(SOUNDS.PANDA_ATTACK_CHARGE)
            self.state = PANDA_STATE.charging_attack
            self.charging_attack_time_left = PANDA_ATTACK_CHARGE_DURATION
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

    elseif self.state == PANDA_STATE.charging_attack then

        self.charging_attack_time_left = Basic.tick_timer(self.charging_attack_time_left)
        if self.charging_attack_time_left == 0.0 then
            Basic.play_sound(SOUNDS.PANDA_POUNCE)
            self.state = PANDA_STATE.pounce
            self.time_since_pounce = 0.0

            local y_distance_to_player = math.abs(player.y - self.y)
            if y_distance_to_player <= PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_ATTACK then
                -- Тут прикольно было бы сделать математику чтобы панда расчитывала
                -- угол прыжка в зависимости от того, где находится игрок, но это
                -- если ГД захочет.
                self.velocity.x = 100 * math.sign(player.x - self.x)
                self.velocity.y = 60 * -1 * math.sign(player.y - self.y)
            elseif is_on_ground and player.y < self.y then
                Basic.play_sound(SOUNDS.PANDA_JUMP)
                self.velocity.y = PANDA_CHASE_JUMP_STRENGTH
            end
        end

    elseif self.state == PANDA_STATE.pounce then

        local our_rect = Hitbox.rect_of(self)
        local player_rect = Hitbox.rect_of(game.player)

        if Physics.check_collision_rect_rect(our_rect, player_rect) then
            game.player:die(self.velocity.x, self.velocity.y)
        end

        self.time_since_pounce = self.time_since_pounce + Time.dt()

        if is_on_ground and self.time_since_pounce > PANDA_POUNCE_DURATION then
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
    local previous_sprite = self.sprite

    if self.state == PANDA_STATE.stunned or
       self.state == PANDA_STATE.staggered
    then
        -- goto 😎
        goto hitlocked
    end

    if self.state == PANDA_STATE.patrol then
        if self.patrol_rest_time > 0.0 then
            self.sprite = self.sprites.rest
        else
            self.sprite = self.sprites.patrol
        end
    elseif self.state == PANDA_STATE.chase then
        self.sprite = self.sprites.chase
    elseif self.state == PANDA_STATE.charging_attack then
        self.sprite = self.sprites.charging_attack
    elseif self.state == PANDA_STATE.pounce then
        self.sprite = self.sprites.pounce
    end

    if previous_sprite ~= self.sprite then
        self.sprite:reset()
    end
    self.sprite:next_frame()

    ::hitlocked::
end

function Panda:draw()
    local flip = self.look_direction == PANDA_LOOK_DIRECTION_RIGHT and 0 or 1

    local tx, ty = game.camera:transform_coordinates(self.x, self.y)

    rect(tx, ty - 6, 4, 4, PANDA_STATE_COLORS[self.state])

    -- Ну тип ладно. Вообще довольно дурацкий костыль, не знаю как это лучше сделать.
    -- Это для правильного позиционирования спрайтов, у которых несколько анимаций
    -- с разными размерами.
    tx = tx - 4 * (self.sprite:current_animation().width - 1)
    ty = ty - 8 * (self.sprite:current_animation().width - 1)
    self.sprite:draw(tx, ty, flip)
end

Panda.__index = Panda
