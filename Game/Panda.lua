--[[

👋 Добро пожаловать, путник! Вижу, ты устал с дороги?
Присядь, отдохни в моем уютном файле.

Снимай своё пальто и садись за клавиатуру.

Я угощу тебя горячими классами, и напою кристально чистым кодом
из репозитория, что недалеко от моего дома. За едой я поведаю тебе
истории о мерж конфликтах и созвонах из моих детских лет. Мы будем тихо
болтать при тусклом свете монитора о всяких пустяках: файловых системах,
SOLID, видеокартах... ️🕯️

Потом я уложу тебя спать, накрыв тебя теплым монолитом. И спою тебе
колыбельную 🌜:

    Спят усталые инструкции, объекты спят.
    Сервера и рефакторинг ждут ребят.
    Даже Линус спать ложится,
    Чтобы ночью нам присниться.
    Ты ему пожелай:
    Баю-бай.

Утром я подниму тебя рано и заставлю сделать зарядку: бинарный поиск,
динамическое программирование и красно черное дерево. 🎋

Испеку законфигуранку и сделаю горячего шококода.

Потом я приглашу тебя на рыбаглку. Я возьму нейросети, а ты -- баголовные снасти.
Надеюсь на хороший улов!

Рыбачим. Тихий ветерок колышет строчки кода: процессор нагрелся. Журчит текущая память.
Вокруг летают багбочки, муравьи цепочкой ползут к документации. Квакает джаба.
Мы расслабленно сидим на берегу и наслаждаемся моментом. Да, нечасто выдается такой
хороший денек. У меня клюет: тяну, тяну, ещё чуть-чуть... Это монокарп! 🐟

Возвращаемся уже к вечеру. На гитхабе у тебя 5 новых issues: дел невпроворот.
Похоже, наше время подходит к концу. Что ж, надеюсь тебе запомнится наше маленькое
путешествие. Запомни: если вдруг твоя тяжкая ноша из легаси опять станет невыносима,
я всегда готов принять тебя в моём скромном убежище.

Прощай! 👋

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
    sleeping = 9,
}

local PANDA_STATE_COLORS = {0, 9, 0, 0, 0, 0, 0, 0}

function Panda:new(x, y, panda_type, can_tug)
    panda_type = panda_type or PANDA_TYPE.basic
    can_tug = can_tug or false
    local default_state = panda_type == PANDA_TYPE.basic and PANDA_STATE.patrol or PANDA_STATE.sleeping
    local object = {
        x = x,
        y = y,
        velocity = {
            x = 0,
            y = 0,
        },
        hitbox = Hitbox:new(1, 0, 6, 8),
        physics_settings = PANDA_PHYSICS_SETTINGS,

        type = panda_type,
        state = default_state,

        health = PANDA_SETTINGS[panda_type].health,

        stun_animation = AnimationController:new(SPRITES.panda_stun_effect),
        animation_controller = AnimationController:new(SPRITES.panda[PANDA_TYPE.basic].rest),
        look_direction = math.coin_flip() and 1 or -1,

        attack_effect = nil,       -- Мне не нравятся, что в панде плодятся такие поля
        attack_effect_time = 0.0,  -- и такие...

        -- Как же я обожаю таймеры 😍
        time_of_most_recent_hit = 0.0,
        count_of_recent_hits = 0,

        time_after_which_we_should_attack = 0.0,
        time_since_dashing = 0.0,

        chase_time_left = 0.0,
        patrol_rest_time = 0.0,
        stagger_time_left = 0.0,
        stun_time_left = 0.0,
        basic_attack_time_left = 0.0,
        change_look_direction_cooldown = 0.0,

        -- Хотите ли вы потягаться с такой пандой?🙄 Ответ был дан выше
        --kantugging_friend_panda = can_tug,
        kantugging_friend_panda = false,
    }

    setmetatable(object, self)
    return object
end

function Panda:view_cone_shape()
    local rect = Hitbox.rect_of(self)

    local tx, ty = rect:center_x(), rect:center_y()

    if self.look_direction == -1 then
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

function Panda:die()
    Basic.play_sound(SOUNDS.PANDA_DEAD)
    table.remove_element(game.current_level.pandas, self)
end

-- кто уберет, тот сам будет переписывать код миниигры
function Panda:set_dieable_state()
    self.state = PANDA_STATE.stunned
end

function Panda:take_damage(hit_x, hit_y)
    local blood_count = math.lerp(100, 10, self.health / PANDA_SETTINGS[self.type].health)

    self.health = self.health - 1

    -- if death by grief for the lost bamboo
    hit_x = hit_x or 0
    hit_y = hit_y or 0

    Basic.play_sound(SOUNDS.PANDA_HIT)

    if hit_x < 0 then
        create_blood(self.x, self.y, -1, blood_count)
    elseif hit_x > 0 then
        create_blood(self.x, self.y, 1, blood_count)
    else
        create_blood(self.x, self.y, -1, blood_count)
        create_blood(self.x, self.y, 1, blood_count)
    end

    local stun_knockback_direction_x = hit_x < 0 and -1 or 1
    local stun_knockback_direction_y = hit_y < 0 and PANDA_STUN_KNOCKBACK_VERTICAL_FROM_VERTICAL_ATTACK or PANDA_STUN_KNOCKBACK_VERTICAL

    if self.health == PANDA_SETTINGS[self.type].health_at_which_to_get_stunned then
        self.state = PANDA_STATE.stunned
        self.stun_time_left = PANDA_STUN_DURATION

        --
        -- ААХХАХАХАХА Я СОШЁЛ С УМА 🥶 😷
        --
        self.time_of_most_recent_hit = Time.now()
        self.stun_time_left = PANDA_STUN_DURATION

        self.velocity.x = stun_knockback_direction_x * PANDA_STUN_KNOCKBACK_HORIZONTAL
        self.velocity.y = stun_knockback_direction_y
    else
        self.state = PANDA_STATE.stunned
        self.stun_time_left = self.stun_time_left + PANDA_SMALL_STUN_DURATION

        self.velocity.x = stun_knockback_direction_x * PANDA_SMALL_STUN_KNOCKBACK_HORIZONTAL
        self.velocity.y = stun_knockback_direction_y
    end

    if self.health <= 0 then
        self:die()
    end
end

function Panda:update()
    --
    -- И ведь будут же люди, которым здесь нужно будет что-то сделать, они зайдут,
    -- пролистают код, и скажут: "Боже, какой кошмар!" Скажут, что тут такое непреодолимое
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
    -- И ведь они отрефакторят! Они сделают много классов, каждый с единственной ответственностью.
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
    -- 
    --
    -- rewiew #1 sp🤓kynerd@sysiphus.jam
    -- Понятно, ещё один инфоциган нашелся.
    -- Начиная читать, я подумал, Да - наверное это действительно человек пропустил через себя,
    -- много думал на этот счёт, решил донести свою мысль до людей и попытаться сделать мир лучше.
    -- А оказалось...
    -- Опять пресловутая реклама своих курсов по саморазвитию, осознанности и т.д.!
    -- И ни одного свежего тейка - всё те же сознательность, производительность,
    -- оптимизация времени(спасибо, что не тайм-менеджмент - перевёл, не поленился);
    -- И как обычно под предлогом науки! Да какое это ваше программирование наука.
    -- Software engineering и программирование это разные вещи. Программирование это тыканье
    -- по кнопкам в правильном порядке, а SE это тот, кто даёт программисту чёткий план,
    -- что ему надо натыкать, выстраивает архитектуру и т.д.
    -- Типичная манипуляция... Ну а чего ещё я ожидал...
    -- Ладно бы реклама сделана хорошо, текст-то с первого взгляда действительно цепляет!
    -- Так даже ссылки на курсы нет...
    -- Заминусите чела пж - давайте сделаем рекламу, которую мы смотрим лучше
    -- Помогу сделать рекламный пост, сформировать стратегию продвижения,
    -- по вопросам сотрудничества kawai@sysiphus.jam

    local player = game.player

    local our_rect = Hitbox.rect_of(self)
    local player_rect = Hitbox.rect_of(player)

    local is_on_ground = Physics.is_on_ground(self)

    local view_cone = self:view_cone_shape()
    local sees_player = Physics.check_collision_shape_rect(view_cone, Hitbox.rect_of(player))

    if self.state == PANDA_STATE.patrol then

        if self.patrol_rest_time > 0.0 then
            self.patrol_rest_time = Basic.tick_timer(self.patrol_rest_time)
            self.velocity.x = 0
            if self.patrol_rest_time == 0.0 then
                self:set_look_direction(-1 * self.look_direction)
            end
        else
            local x_in_the_near_future = self.x + self.look_direction * PANDA_PATROL_PIXELS_UNTIL_STOP

            local wall_to_the_right = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(x_in_the_near_future, self.y)) ~= nil
            local ground_forward = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(x_in_the_near_future, self.y + 1)) ~= nil

            if wall_to_the_right or not ground_forward then
                self.patrol_rest_time = PANDA_REST_TIME_BEFORE_DIRECTION_CHANGE()
            end

            -- 🤔
            self.velocity.x = PANDA_SETTINGS[self.type].patrol_speed * self.look_direction
        end

        if sees_player then
            self.state = PANDA_STATE.chase
            self.chase_time_left = PANDA_SETTINGS[self.type].chase_duration
        end

    elseif self.state == PANDA_STATE.chase then

        if sees_player then
            self.chase_time_left = PANDA_SETTINGS[self.type].chase_duration
        end

        local can_attack_the_player = false
        if self.time_after_which_we_should_attack > 0.0 then
            self.time_after_which_we_should_attack = Basic.tick_timer(self.time_after_which_we_should_attack)
            can_attack_the_player = self.time_after_which_we_should_attack == 0.0
        end

        local x_distance_to_player = math.abs(player_rect:center_x() - our_rect:center_x())
        local y_distance_to_player = math.abs(player_rect:center_y() - our_rect:center_y())

        self:set_look_direction(math.sign(player_rect:center_x() - our_rect:center_x()))

        local should_we_chase_the_player = true

        if x_distance_to_player <= PANDA_X_DISTANCE_TO_PLAYER_UNTIL_BASIC_ATTACK and y_distance_to_player <= PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_BASIC_ATTACK then
            if can_attack_the_player then
                Basic.play_sound(SOUNDS.PANDA_BASIC_ATTACK_CHARGE)
                self.state = PANDA_STATE.charging_basic_attack
            elseif self.time_after_which_we_should_attack == 0.0 then
                self.time_after_which_we_should_attack = PANDA_SETTINGS[self.type].delay_after_starting_chase_before_attacking
            end
        elseif is_on_ground and x_distance_to_player <= PANDA_X_DISTANCE_TO_PLAYER_UNTIL_DASH then
            if can_attack_the_player then
                if y_distance_to_player <= PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_DASH then
                    Basic.play_sound(SOUNDS.PANDA_DASH_CHARGE)
                    self.state = PANDA_STATE.charging_dash
                    self.charging_dash_time_left = PANDA_SETTINGS[self.type].dash_charge_duration
                else
                    -- Мы слишком низко, попробуем к игроку прыгнуть
                    Basic.play_sound(SOUNDS.PANDA_JUMP)
                    self.velocity.y = PANDA_CHASE_JUMP_STRENGTH
                end
                should_we_chase_the_player = false
            elseif self.time_after_which_we_should_attack == 0.0 then
                self.time_after_which_we_should_attack = PANDA_SETTINGS[self.type].delay_after_starting_chase_before_attacking
            end
        end

        if x_distance_to_player <= PANDA_MIN_X_DISTANCE_TO_PLAYER then
            should_we_chase_the_player = false
        end

        if should_we_chase_the_player then
            local x_in_the_near_future = self.x + self.look_direction * PANDA_CHASE_PIXELS_UNTIL_JUMP
            local x_direction_to_player = math.sign(player_rect:center_x() - our_rect:center_x())

            local wall_to_the_right = Physics.check_collision_rect_tilemap(self.hitbox:to_rect(x_in_the_near_future, self.y)) ~= nil

            if is_on_ground and wall_to_the_right then
                Basic.play_sound(SOUNDS.PANDA_JUMP)
                self.velocity.y = PANDA_CHASE_JUMP_STRENGTH
            end
            self.velocity.x = PANDA_SETTINGS[self.type].chase_speed * x_direction_to_player
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
            self.velocity.x = PANDA_SETTINGS[self.type].dash_strength * self.look_direction
        end

    elseif self.state == PANDA_STATE.charging_basic_attack then

        self:set_look_direction(player_rect:center_x() < our_rect:center_x() and -1 or 1)

        if self.animation_controller:is_at_last_frame() then
            if self.basic_attack_time_left == 0.0 then
                local attack_width = 22
                local attack_rect = Rect:new(
                    our_rect:center_x() + 8 * self.look_direction - attack_width / 2,
                    our_rect:top(),
                    attack_width,
                    8
                )

                -- Раскомментируйте, чтобы посмотреть на hurtbox атаки панды.
                --Debug.add(function()
                --    attack_rect:draw(2)
                --    our_rect:draw(2)
                --end)

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
                    SPRITES.particle_effects.horizontal_attack,
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

        if self.animation_controller:is_at_last_frame() then
            if self.basic_attack_time_left == 0.0 then
                local flip = (self.look_direction < 0) and 1 or 0
                self.attack_effect = ChildBody:new(
                    self,
                    8 * (self.look_direction - flip),
                    -8 * (self.animation_controller:current_animation().height - 1),
                    SPRITES.particle_effects.horizontal_attack,
                    flip
                )
                self.attack_effect_time = PANDA_BASIC_ATTACK_EFFECT_DURATION
                self.basic_attack_time_left = PANDA_BASIC_ATTACK_DURATION
            else
                local attack_width = 22
                local attack_rect = Rect:new(
                    our_rect:center_x() + 8 * self.look_direction - attack_width / 2,
                    our_rect:top(),
                    attack_width,
                    8
                )

                -- Раскомментируйте, чтобы посмотреть на hurtbox атаки панды.
                --Debug.add(function()
                --    attack_rect:draw(2)
                --    our_rect:draw(2)
                --end)

                if Physics.check_collision_rect_rect(our_rect, player_rect) then
                    player:die(self.look_direction, 0)
                elseif Physics.check_collision_rect_rect(attack_rect, player_rect) then
                    player:die(self.look_direction, 0)
                end

                self.basic_attack_time_left = Basic.tick_timer(self.basic_attack_time_left)
                if self.basic_attack_time_left == 0.0 then
                    self.state = PANDA_STATE.chase
                end
            end
        end

        if Physics.check_collision_rect_rect(our_rect, player_rect) then
            game.player:die(self.velocity.x, self.velocity.y)
        end

        self.time_since_dashing = self.time_since_dashing + Time.dt()

        if is_on_ground and self.time_since_dashing > PANDA_SETTINGS[self.type].dash_duration then
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

    elseif self.state == PANDA_STATE.sleeping then

        -- Спим :)
        if self.type == PANDA_TYPE.agro then
            self.state = PANDA_STATE.patrol
            -- Не спим >:(
        end

    else

        error('Invalid panda state!') -- ✂

    end

    Physics.update(self)


    local tile_ids = Physics.tile_ids_that_intersect_with_rect(our_rect)
    for _, collision in ipairs(tile_ids) do
        if is_bad_tile(collision.id) then
            create_blood(self.x, self.y, -1)
            create_blood(self.x, self.y, 1)
            self:die()
            return
        end
    end

    local sprites = SPRITES.panda[self.type]

    -- Под конец занимаемся спрайтами. Как в игроке! 😄
    if self.state == PANDA_STATE.stunned or
       self.state == PANDA_STATE.staggered
    then
        if self.stun_time_left > PANDA_SMALL_STUN_DURATION then
            self.animation_controller:set_sprite(sprites.sleeping)
        else
            -- goto 😎
            goto hitlocked
        end
    end

    if self.state == PANDA_STATE.patrol then
        if self.patrol_rest_time > 0.0 then
            self.animation_controller:set_sprite(sprites.rest)
        else
            self.animation_controller:set_sprite(sprites.walk)
        end
    elseif self.state == PANDA_STATE.charging_basic_attack then
        self.animation_controller:set_sprite(sprites.charging_basic_attack)
    elseif self.state == PANDA_STATE.chase then
        self.animation_controller:set_sprite(sprites.chase)
    elseif self.state == PANDA_STATE.charging_dash then
        self.animation_controller:set_sprite(sprites.charging_dash)
    elseif self.state == PANDA_STATE.dashing then
        self.animation_controller:set_sprite(sprites.dashing)
    elseif self.state == PANDA_STATE.sleeping then
        self.animation_controller:set_sprite(sprites.sleeping)
    end

    self.animation_controller:next_frame()

    ::hitlocked::

    self.attack_effect_time = Basic.tick_timer(self.attack_effect_time)
    self.change_look_direction_cooldown = Basic.tick_timer(self.change_look_direction_cooldown)
end

-- Направления: -1 влево, 1 вправо
function Panda:set_look_direction(new_look_direction)
    if new_look_direction == 0 then
        return
    end

    assert(new_look_direction == 1 or new_look_direction == -1)
    if new_look_direction == self.look_direction then
        return
    end

    if self.change_look_direction_cooldown == 0.0 then
        self.look_direction = new_look_direction
        self.change_look_direction_cooldown = PANDA_CHANGE_LOOK_DIRECTION_COOLDOWN
    end
end

function Panda:draw()
    local flip = (self.look_direction == 1) and 0 or 1

    local tx, ty = game.camera:transform_coordinates(self.x, self.y)

    -- rect(tx, ty - 6, 4, 4, PANDA_STATE_COLORS[self.state])
    if self.type == PANDA_TYPE.chilling then
        -- spr(294, tx + 4, ty - 6, 0)
    end
    -- if self.look_direction == 1 then
    --     rect(tx + 1, ty + 2, 3, 2, PANDA_STATE_COLORS[self.state])
    -- else
    --     rect(tx + 4, ty + 2, 3, 2, PANDA_STATE_COLORS[self.state])
    -- end

    local sprites = SPRITES.panda[self.type]
    if self.state == PANDA_STATE.stunned and self.animation_controller.sprite ~= sprites.sleeping then
        self.stun_animation:draw(tx, ty - 8, flip)
        self.stun_animation:next_frame()
    end

    if self.attack_effect_time > 0.0 then
        self.attack_effect:draw()
    end

    -- Ну тип ладно. Вообще довольно дурацкий костыль, не знаю как это лучше сделать.
    -- Это для правильного позиционирования спрайтов, у которых несколько анимаций
    -- с разными размерами.
    --tx = tx - 4 * (self.animation_controller:current_animation().width - 1)
    --ty = ty - 8 * (self.animation_controller:current_animation().height - 1)
    self.animation_controller:draw(tx, ty, flip)
end

Panda.__index = Panda
