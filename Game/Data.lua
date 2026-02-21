data = {}

-- 🏮 Перед релизом поставить в false!!! 🏮
DEV_MODE_ENABLED = true
DISCLAIMER = false
NEED_TO_KILL_ALL_PANDAS_ON_LEVEL = true

--
-- Управление
--
BUTTON_UP    = 0
BUTTON_DOWN  = 1
BUTTON_LEFT  = 2
BUTTON_RIGHT = 3

BUTTON_Z = 4
BUTTON_X = 5
BUTTON_A = 6
BUTTON_S = 7

KEY_W = 23
KEY_A = 01
KEY_S = 19
KEY_D = 04
KEY_N = 14
KEY_SPACE = 48

KEY_E = 5
KEY_F = 6
KEY_J = 10

KEY_P = 16
KEY_Q = 17

--[[

Таблица переводов кнопок контроллеров.
Кто-то же должен это делать 🤓

+------+-----------+----------+-----------+
| XBOX |    PS4    | Keyboard | Direction |
+------+-----------+----------+-----------+
|  A   |  cross    |    z     |   south   |
|  B   |  circle   |    x     |   east    |
|  X   |  square   |    a     |   west    |
|  Y   |  triangle |    s     |   north   |
+------+-----------+----------+-----------+

]]--



GAME_STATE_LANGUAGE_SELECTION = 1
GAME_STATE_GAMEPLAY = 2
GAME_STATE_RIDING_BIKE = 3
GAME_STATE_TRIGGERED = 4
GAME_STATE_CUTSCENE = 5
GAME_STATE_CLICKERMINIGAME = 6
GAME_STATE_PAUSED = 7


-- Это то, что в тике на F3
WORLD_TILEMAP_WIDTH  = 240 -- тайлов
WORLD_TILEMAP_HEIGHT = 136 -- тайлов

-- Размеры экрана игры, камеры, если угодно
SCREEN_WIDTH  = 240 -- пикселей
SCREEN_HEIGHT = 136 -- пикселей

WORLD_WIDTH  = 1920 -- пикселей (= 240 * 8)
WORLD_HEIGHT = 1088 -- пикселей (= 136 * 8)

-- Стремление всё кастомизировать и вынести в параметры приводит
-- к тому что приходится давать имена очень многим вещам. Что сложно.
-- Чем меньше в коде имён, тем он проще (мудрость)
--
-- Именно поэтому я назвал эту переменную Coeffecient Of Restituion 🤓:
-- https://en.wikipedia.org/wiki/Coefficient_of_restitution
WORLD_HORIZONTAL_COEFFICIENT_OF_RESTITUTION = 0.7   -- проценты
WORLD_VERTICAL_COEFFICIENT_OF_RESTITUTION   = 0.1   -- проценты


--
-- Настройки камеры 🎥
--
-- Чтобы понять, что меняют эти параметры, включите дебаг в Camera.update()
CAMERA_LINES_DISTANCE_FROM_CENTER = 35
CAMERA_PAN_OFFSET = 6
CAMERA_SMOOTH_TIME = 0.26
CAMERA_DIRECTION_CHANGE_TIME = 0.3



--[[

      ТРЕВОГА ⚠

      НАЧИНАЮТСЯ НАСТРОЙКИ ИГРОКА ☢

      БЕЗ ЗАЩИТНОГО КОСТЮМА НЕ ВХОДИТЬ

--]]

-- кароч ещё в cutscenatio есть такое
PLAYER_SPAWNPOINT_X = 10*8                                      -- пиксели
PLAYER_SPAWNPOINT_Y = 11*8                                     -- пиксели

--
-- Всё что связано с движением 🏎️
--
PLAYER_MAX_HORIZONTAL_SPEED = 67.0                           -- пиксели / секунду
PLAYER_MAX_FALL_SPEED = 200.0                                -- пиксели / секунду
PLAYER_HORIZONTAL_ACCELERATION = 900.0                       -- пиксели / (секунду*секунду)
PLAYER_FRICTION = 12.0                                       -- не знаю, просто магическое число
PLAYER_MIN_HORIZONTAL_VELOCITY = 4.0                         -- пиксели / секунду
PLAYER_MIN_VERTICAL_VELOCITY = 4.0                           -- пиксели / секунду

PLAYER_AIR_FRICTION = 0.52 * PLAYER_FRICTION                 -- тоже не знаю
-- http://www.thealmightyguru.com/Wiki/index.php?title=Coyote_time
PLAYER_COYOTE_TIME = 0.12                                    -- секунды
-- Если игрок нажимает прыжок до того, как
-- он приземлился, мы сохраняем то, что игрок
-- хотел прыгнуть. Вот кусок с реддита:
-- https://www.reddit.com/r/gamedev/comments/w1dau6/input_buffering_action_canceling_and_also/
PLAYER_JUMP_BUFFER_TIME = 0.18                               -- секунды
-- Поменяйте это, чтобы игрок стал прыгать выше
PLAYER_JUMP_HEIGHT = 27                                      -- пиксели
-- Поменяйте это, чтобы изменить время, за которое
-- игрок достигнет высшей точки прыжка (APEX).
PLAYER_TIME_TO_APEX = 0.35                                    -- секунды

-- Когда игрок не зажимает прыжок, у него увеличивается гравитация
-- Этим достигается "усиленный прыжок" при зажатии кнопки
PLAYER_GRAVITY_SCALE_WHEN_NOT_HOLDING = 1.92

-- Считается автоматически! Вручную не менять.
PLAYER_GRAVITY = (2 * PLAYER_JUMP_HEIGHT) / (PLAYER_TIME_TO_APEX * PLAYER_TIME_TO_APEX)
PLAYER_GRAVITY_AFTER_WALL_JUMP = 0.75 * PLAYER_GRAVITY
PLAYER_JUMP_STRENGTH = math.sqrt(2 * PLAYER_GRAVITY * PLAYER_JUMP_HEIGHT)
PLAYER_DOWNWARD_ATTACK_JUMP_STRENGTH = 0.8 * PLAYER_JUMP_STRENGTH
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
PLAYER_WALL_SLIDE_SPEED = 30.0                               -- пиксели / секунду
-- С какой скоростью полетит игрок, когда отпрыгнет от стены
PLAYER_WALL_JUMP_HORIZONTAL_STRENGTH = 140.0                 -- пиксели / секунду
PLAYER_WALL_JUMP_VERTICAL_STRENGTH = 120.0                   -- пиксели / секунду
-- Я на время убираю ограничение PLAYER_MAX_HORIZONTAL_SPEED
-- когда игрок отталкивается от стены, чтобы прыжок
-- чувствовался лучше.
PLAYER_REMOVE_SPEED_LIMIT_AFTER_WALL_JUMP_TIME = 0.26        -- секунды
-- После прыжка я запрещаю приклеиваться
-- к стене на какое-то время. Иначе если прыгнуть
-- рядом со стеной, то игрок сразу к ней
-- приклеится.
PLAYER_DELAY_AFTER_JUMP_BEFORE_STICKING_TO_WALL = 0.13        -- секунды

PLAYER_STATE_NORMAL = 0
PLAYER_STATE_ATTACKING = 1

--
-- Боёвка 🤺
--
-- Сколько по времени занимает одна атака.
-- Это никак не зависит от анимации атаки,
-- она просто зависнет на последнем кадре.
PLAYER_ATTACK_DURATION = 0.2                   -- секунды
PLAYER_ATTACK_BUFFER_TIME = 0.1                -- секунды
PLAYER_ATTACK_EFFECT_DURATION = 0.2

PLAYER_ATTACK_SHAKE_MAGNITUDE = 0.75
PLAYER_ATTACK_SHAKE_DURATION = 0.1

PLAYER_TIME_BEFORE_SHOWING_DEATH_SCREEN_AFTER_DEATH = 1.5

PLAYER_DEATH_KNOCKBACK_HORIZONTAL = 80
PLAYER_DEATH_KNOCKBACK_VERTICAL = 80

PLAYER_JUMP_BY_HIT = PLAYER_JUMP_STRENGTH * 1
PLAYER_ATTACK_COOLDOWN = 0.2                  -- секунды

PLAYER_SLOWDOWN_IN_WATER_PERCENTAGE = 0.8

PLAYER_DOWNWARD_ATTACK_TIME = 0.25

--[[

      Настройки игрока закончены

      Снимайте защитный костюм 🥼🕶



      🐼 🐼 🐼 🐼 🐼

      И НАЛИВАЙТЕ КОФЕ ☕!

      НАЧИНАЮТСЯ НАСТРОЙКИ ПАНДЫ

      🐼 🐼 🐼 🐼 🐼

--]]

-- Linux Torbolts был совершенно прав, снимаю шляпу 😢🎩
-- ^- Сказал бы я, если бы не быстро вскрывшиеся проблемы с Entity.
--    Мне приходится поддерживать одновременно и game.entities, и
--    game.pandas. Забыл удалить панду и из того, и из другого - баг!
--    А если не использовать game.pandas, то как мне фильтровать панд
--    из всех game.entities? Тоже непонятно. В общем, абстракция опять
--    оказалась обструкцией.
--
--    (c) кви кд 2025
--
PANDA_TYPE = {
    basic = 0,
    chilling = 1,
    orange_eyes = 2,
    stickless = 3,

    no_stick_no_dash = 5,
    no_stick_dash = 6,
    stick_no_dash = 7,
    stick_and_dash = 8,

    house_maid = 9,
    guard = 10,
}


-- Когда уже в lua добавят enum-ы? 😩
PANDA_STATE = {
    patrol = 1,
    chase = 2,
    charging_dash = 3,
    charging_basic_attack = 4,
    doing_basic_attack = 5,
    dashing = 6,
    staggered = 7,
    stunned = 8,
    sleeping = 9,
    charging_small_dash = 10,
}
--PANDA_STATE_COLORS = {0, 9, 0, 0, 0, 0, 0, 0}


-- Возможно их стоит объединить с panda type. Иначе получается излишнее
-- обобщение. Блин, вместо этого комментария я мог бы просто это сделать 😡
SPECIAL_TILES = {
    --{id = 38, type = PANDA_TYPE.basic},
    --{id = 39, type = PANDA_TYPE.chilling},
    --{id = 37, type = PANDA_TYPE.orange_eyes},
    --{id = 36, type = PANDA_TYPE.stickless},

    {id = 36, type = PANDA_TYPE.no_stick_no_dash},
    {id = 37, type = PANDA_TYPE.no_stick_dash},
    {id = 38, type = PANDA_TYPE.stick_no_dash},
    {id = 39, type = PANDA_TYPE.stick_and_dash},
    {id = 111, type = PANDA_TYPE.house_maid},
    {id = 20, type = PANDA_TYPE.guard},
}

PANDA_PHYSICS_SETTINGS = {
    gravity = 139.7,
    friction = 3.5,
    min_horizontal_velocity = 2.0,
}

-- Настройки, которые меняются в зависимости от типа панды
PANDA_SETTINGS = {
    [PANDA_TYPE.basic] = {
        health = 6,

        patrol_speed = 8,
        chase_speed  = 2.5 * 8,
        dash_charge_duration = 1.3,
        dash_duration = 1.1,
        dash_strength = 180,

        small_dash_strength = 90,
        small_dash_duration = 0.4,
        small_dash_charge_duration = 0.5,

        health_at_which_to_get_stunned = 2,

        eye_color = 13,

        delay_after_starting_chase_before_attacking = 0.4,  -- 0.3

        chase_duration = 4.0,

        default_state = PANDA_STATE.patrol,
    },
    -- Вот это всё бесполезно
    --[PANDA_TYPE.stickless] = {
    --    health = 6,

    --    patrol_speed = 8,
    --    chase_speed  = 2.5 * 8,
    --    dash_charge_duration = 0.8,  -- 1.5
    --    dash_duration = 0.6, -- 1.0
    --    dash_strength = 170,
    --    -- Это отсчет до того как панда сможет атаковать после
    --    -- того как начала гнаться за игроком. Да, я просто перевел
    --    -- название переменной с английского и назвал это документацией.
    --    delay_after_starting_chase_before_attacking = 0.3,

    --    -- Время, после которого панда устанет гоняться за игроком.
    --    -- Это при условии, что она игрока не видит.
    --    chase_duration = 3.0,
    --},
    --[PANDA_TYPE.orange_eyes] = {
    --    health = 6,

    --    patrol_speed = 9,
    --    chase_speed  = 2.7 * 8,
    --    dash_charge_duration = 0.5,  -- 1.5
    --    dash_duration = 0.6, -- 1.0
    --    dash_strength = 200,
    --    health_at_which_to_get_stunned = 2,

    --    eye_color = 9,

    --    -- Это отсчет до того как панда сможет атаковать после
    --    -- того как начала гнаться за игроком. Да, я просто перевел
    --    -- название переменной с английского и назвал это документацией.
    --    delay_after_starting_chase_before_attacking = 0.3,

    --    -- Время, после которого панда устанет гоняться за игроком.
    --    -- Это при условии, что она игрока не видит.
    --    chase_duration = 4.0,
    --},
    --[PANDA_TYPE.chilling] = {
    --    health = 6,

    --    patrol_speed = 6,
    --    chase_speed  = 2.0 * 6,
    --    dash_charge_duration = 0.7,
    --    dash_duration = 0.6,
    --    dash_strength = 100,
    --    health_at_which_to_get_stunned = 4,

    --    eye_color = 13,

    --    delay_after_starting_chase_before_attacking = 0.3,
    --    chase_duration = 2.0,

    --    default_state = PANDA_STATE.sleeping,
    --},
}


PANDA_SETTINGS[PANDA_TYPE.no_stick_no_dash] = table.copy(PANDA_SETTINGS[PANDA_TYPE.basic])
PANDA_SETTINGS[PANDA_TYPE.no_stick_no_dash].health = 4
PANDA_SETTINGS[PANDA_TYPE.no_stick_no_dash].health_at_which_to_get_stunned = 1


PANDA_SETTINGS[PANDA_TYPE.no_stick_dash] = table.copy(PANDA_SETTINGS[PANDA_TYPE.basic])
PANDA_SETTINGS[PANDA_TYPE.no_stick_dash].eye_color = 6
PANDA_SETTINGS[PANDA_TYPE.no_stick_dash].health = 4
PANDA_SETTINGS[PANDA_TYPE.no_stick_dash].has_dash = true
PANDA_SETTINGS[PANDA_TYPE.no_stick_dash].dash_charge_duration = 0.35
PANDA_SETTINGS[PANDA_TYPE.no_stick_dash].dash_duration = 0.7
PANDA_SETTINGS[PANDA_TYPE.no_stick_dash].dash_strength = 180

PANDA_SETTINGS[PANDA_TYPE.stick_no_dash] = table.copy(PANDA_SETTINGS[PANDA_TYPE.basic])
PANDA_SETTINGS[PANDA_TYPE.stick_no_dash].health = 4
PANDA_SETTINGS[PANDA_TYPE.stick_no_dash].eye_color = 10
PANDA_SETTINGS[PANDA_TYPE.stick_no_dash].has_stick = true

PANDA_SETTINGS[PANDA_TYPE.stick_and_dash] = table.copy(PANDA_SETTINGS[PANDA_TYPE.basic])
PANDA_SETTINGS[PANDA_TYPE.stick_and_dash].health = 5
PANDA_SETTINGS[PANDA_TYPE.stick_and_dash].eye_color = 6
PANDA_SETTINGS[PANDA_TYPE.stick_and_dash].has_stick = true
PANDA_SETTINGS[PANDA_TYPE.stick_and_dash].has_dash = true
PANDA_SETTINGS[PANDA_TYPE.stick_and_dash].dash_charge_duration = 0.35
PANDA_SETTINGS[PANDA_TYPE.stick_and_dash].dash_duration = 0.7
PANDA_SETTINGS[PANDA_TYPE.stick_and_dash].dash_strength = 180

PANDA_SETTINGS[PANDA_TYPE.house_maid] = table.copy(PANDA_SETTINGS[PANDA_TYPE.no_stick_no_dash])
PANDA_SETTINGS[PANDA_TYPE.guard] = table.copy(PANDA_SETTINGS[PANDA_TYPE.stick_no_dash])
PANDA_SETTINGS[PANDA_TYPE.guard].patrol_speed = 0
PANDA_SETTINGS[PANDA_TYPE.guard].chase_speed = 0
PANDA_SETTINGS[PANDA_TYPE.guard].health = 2


PANDA_WITHOUT_STICK_ATTACK_WIDTH = 18
-- Если кажется, что панда атакует слишком далеко, уменьшите это.
-- И можно раскомментировать Debug.add в Panda.update, чтобы
-- посмотреть на результат.
PANDA_STICK_ATTACK_LENGTH = 3
-- Пока что не используется. Почему? Не понятно.
-- PANDA_WITH_STICK_ATTACK_WIDTH = 26

-- Если мы ближе, чем это расстояние, то пора остановиться
PANDA_MIN_X_DISTANCE_TO_PLAYER = 8

PANDA_X_DISTANCE_TO_PLAYER_UNTIL_BASIC_ATTACK = 20
PANDA_X_DISTANCE_TO_PLAYER_UNTIL_BASIC_ATTACK_WITH_STICK = 26
PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_BASIC_ATTACK = 14
-- Время, которое панда будет держать свой последний кадр
-- анимации атаки.
PANDA_BASIC_ATTACK_EFFECT_DURATION = 0.25
PANDA_BASIC_ATTACK_DURATION = PANDA_BASIC_ATTACK_EFFECT_DURATION - 0.08

PANDA_X_DISTANCE_TO_PLAYER_UNTIL_DASH = 33
PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_DASH = 24

PANDA_CHASE_JUMP_STRENGTH = 90
PANDA_CHASE_PIXELS_UNTIL_JUMP = 16

PANDA_PATROL_PIXELS_UNTIL_STOP = 6

-- Чтобы панда не крутилась как бешеная
PANDA_CHANGE_LOOK_DIRECTION_COOLDOWN = 0.5

PANDA_VIEW_CONE_WIDTH = 64
PANDA_VIEW_CONE_HEIGHT = 32

-- Панда отлетает в стан, после этого её нужно быстро ударить
-- несколько раз, чтобы она умерла.
PANDA_STUN_DURATION = 5  -- 2.3
PANDA_SMALL_STUN_DURATION = 0.6  -- 0.7

-- Отбрасывание панды от игрока при обычном стаггере
PANDA_SMALL_STUN_KNOCKBACK_HORIZONTAL = 20.0
-- PANDA_SMALL_STUN_KNOCKBACK_VERTICAL = 10.0
--PANDA_SMALL_STUN_KNOCKBACK_VERTICAL_FROM_VERTICAL_ATTACK = 60.0
-- Когда мы впервые бьём и станим панду
PANDA_STUN_KNOCKBACK_HORIZONTAL = 75.0
PANDA_STUN_KNOCKBACK_VERTICAL = 10.0
PANDA_STUN_KNOCKBACK_VERTICAL_FROM_VERTICAL_ATTACK = 80.0

-- Поля для параллакс скроллинга
PARALLAX_LAYER_SPEED = 0.2
PARALLAX_LAYER_TILE_ID = 64
PARALLAX_TILE_HEIGHT = 4

-- константная функция 📛
PANDA_REST_TIME_BEFORE_DIRECTION_CHANGE = function()
    return 1 + 1.0 * math.random()
end

--[[

      Настройки панды завершены.

      Спасибо за посещение. 🧑💼

--]]

--
-- Спрайты! 🖼️
--
SPRITES = {
    transparent = Sprite:new({0}),

    player = {
        idle = Sprite:new({396}, 1, 2, 1),
        dead = Sprite:new({479}),

        running = Sprite:new({384, 386, 388, 390, 392, 394}, 6, 2, 2),
        jump = Animation:new({412, 414, 412}, 3):with_size(2, 2):at_end_goto_last_frame():to_sprite(),
        falling = Animation:new({426}, 1):with_size(2, 2):to_sprite(),

        slide = Sprite:new_complex({
            Animation:new({448, 450}, 8):with_size(2, 2),
            Animation:new({452, 454}, 12):with_size(2, 2):at_end_goto_animation(2),
        }),

        attack = Animation:new({416, 418, 420, 422}, 2):with_size(2, 2):at_end_goto_last_frame():to_sprite(),
        attack_upwards = Animation:new({208, 210, 212, 214}, 2):with_size(2, 2):at_end_goto_last_frame():to_sprite(),
        attack_air_forward = Animation:new({424, 456, 458}, 2):with_size(2, 2):at_end_goto_last_frame():to_sprite(),
        attack_air_downward = Animation:new({424, 456, 458}, 2):with_size(2, 2):at_end_goto_last_frame():to_sprite(),
    },

    hat = Sprite:new({478}),

    particle_effects = {
        jump = Animation:new({496, 498, 500, 502}, 6):with_size(2, 1):at_end_goto_last_frame():to_sprite(),
        land = Animation:new({500, 502}, 8):with_size(2, 1):at_end_goto_last_frame():to_sprite(),

        horizontal_attack = Animation:new({488}, 18):with_size(2, 2):at_end_goto_last_frame():to_sprite(),
        long_horizontal_attack = Animation:new({380}, 18):with_size(2, 1):at_end_goto_last_frame():to_sprite(),

        downward_attack = Animation:new({444}, 18):with_size(2, 2):at_end_goto_last_frame():to_sprite(),
        upward_attack = Animation:new({176}, 18):with_size(2, 2):at_end_goto_last_frame():to_sprite(),
    },

    panda = {
        [PANDA_TYPE.basic] = {
            walk = Animation:new({256, 257}, 22):to_sprite(),
            chase = Animation:new({259, 260}, 10):to_sprite(),
            rest = Animation:new({256, 272}, 20):to_sprite(),
            dashing = Animation:new({267, 268, 269, 270}, 3):with_size(1, 2):at_end_goto_last_frame():to_sprite(),
            charging_basic_attack = Animation:new({267, 267, 267, 267, 268, 269, 270}, 5):with_size(1, 2):at_end_goto_last_frame():to_sprite(),
            charging_dash = Animation:new({282}, 1):to_sprite(),
            dash = Animation:new({263}, 1):to_sprite(),
            sleeping = Animation:new({264}, 1):with_size(2, 1):to_sprite(),
        },
        [PANDA_TYPE.stickless] = {
            walk = Animation:new({240, 241}, 22):to_sprite(),
            chase = Animation:new({242, 243}, 10):to_sprite(),
            rest = Animation:new({240, 244}, 20):to_sprite(),
            dashing = Animation:new({249}, 3):at_end_goto_last_frame():to_sprite(),
            -- Панда без палки не может атаковать.
            --charging_basic_attack = Sprite:new_complex({
            --    Animation:new({330}, 4),
            --    Animation:new({328,329}, 3):with_size(1, 1):at_end_goto_last_frame()
            --}),
            charging_dash = Animation:new({245}, 1):to_sprite(),
            dash = Animation:new({246}, 1):to_sprite(),
            sleeping = Animation:new({264}, 1):with_size(2, 1):to_sprite(),
        },
        -- [PANDA_TYPE.chilling] и т.д. смотреть снизу
    },

    panda_stun_effect = Animation:new({8, 9, 10, 11}, 8):to_sprite(),

    cutscene = {
        start_player = Animation:new({480, 481}, 6):at_end_goto_last_frame():to_sprite(),
        run_player = Animation:new({482, 483, 482, 484, 482, 483, 485, 482, 483, 482, 485}, 8):to_sprite(),
        --finish_player_win = Animation:new({208},2):to_sprite(),

        start_panda = Animation:new({268, 269},6):with_size(1, 2):at_end_goto_last_frame():to_sprite(),
        run_panda = Animation:new({271, 281, 314, 316, 314, 281, 317, 314, 281, 314, 317},8):to_sprite(),
        --finish_panda_win = Animation:new({271, 256},1):at_end_goto_last_frame():to_sprite(),
    },
}
-- Специальные переделки для чилящей панды.
-- Жаль что это всё нельзя сделать внутри одной таблицы.
SPRITES.panda[PANDA_TYPE.orange_eyes] = table.copy(SPRITES.panda[PANDA_TYPE.basic])
SPRITES.panda[PANDA_TYPE.chilling] = table.copy(SPRITES.panda[PANDA_TYPE.basic])
SPRITES.panda[PANDA_TYPE.chilling].charging_basic_attack = Sprite:new_complex({
    Animation:new({282}, 20),
    Animation:new({267, 268, 269, 270}, 6):with_size(1, 2):at_end_goto_last_frame(),
})

SPRITES.panda[PANDA_TYPE.no_stick_no_dash] = table.copy(SPRITES.panda[PANDA_TYPE.stickless])
SPRITES.panda[PANDA_TYPE.no_stick_dash] = table.copy(SPRITES.panda[PANDA_TYPE.stickless])
SPRITES.panda[PANDA_TYPE.stick_no_dash] = table.copy(SPRITES.panda[PANDA_TYPE.basic])
SPRITES.panda[PANDA_TYPE.stick_and_dash] = table.copy(SPRITES.panda[PANDA_TYPE.basic])

SPRITES.panda[PANDA_TYPE.house_maid] = table.copy(SPRITES.panda[PANDA_TYPE.no_stick_no_dash])
-- SPRITES.panda[PANDA_TYPE.guard] = table.copy(SPRITES.panda[PANDA_TYPE.basic])
SPRITES.panda[PANDA_TYPE.guard] = {
            walk = Animation:new({348, 350}, 22):to_sprite(),
            chase = Animation:new({348, 350}, 10):to_sprite(),
            rest = Animation:new({348, 350}, 20):to_sprite(),
            -- dashing = Animation:new({267, 268, 269, 270}, 3):with_size(1, 2):at_end_goto_last_frame():to_sprite(),
            charging_basic_attack = Animation:new({112, 112, 113, 114, 115}, 2):with_size(1, 2):at_end_goto_last_frame():to_sprite(),
            charging_dash = Animation:new({282}, 1):to_sprite(),
            dash = Animation:new({263}, 1):to_sprite(),
            sleeping = Animation:new({318}, 1):with_size(2, 1):to_sprite(),
        }



PLAYER_ATTACK_SPRITES = {
    SPRITES.player.attack,
    SPRITES.player.attack_upwards,
    SPRITES.player.attack_air_forward,
    SPRITES.player.attack_air_downward,
}

ANIMATED_TILES = {
    Animation:new({32, 48}, 24):to_sprite(),
    Animation:new({33, 34}, 24):to_sprite(),
}

--
-- Звуки (sfx🤪)! 🔊
-- 
SOUNDS = {
    MUTE_CHANNEL_ZERO = {id = -1, note = -1, channel = 0},
    MUTE_CHANNEL_ONE = {id = -1, note = -1, channel = 1},
    MUTE_CHANNEL_TWO = {id = -1, note = -1, channel = 2},

    PLAYER_ATTACK = {id = 5, note = 'C-6', duration = 10, channel = 2},
    PLAYER_JUMP = {id = 4, note = 'A#4'},
    PLAYER_SLIDE = {id = 8, note = 'D-1', channel = 1},
    PLAYER_DEAD = {id = 5, note = 'C-5', duration = 30, channel = 2},
    PLAYER_PARRY = {id = 4, note = 'C-5', duration = 10, channel = 2},

    PANDA_DASH_CHARGE = {id = 11, note = 'G-3', duration = 20, channel = 2},
    PANDA_DASH = {id = 11, note = 'C-5', duration = 20, channel = 2},
    PANDA_BASIC_ATTACK_CHARGE = {id = 11, note = 'G-4', duration = 20, channel = 2},
    PANDA_BASIC_ATTACK = {id = 11, note = 'C-4', duration = 20, channel = 2},
    PANDA_JUMP = {id = 4, note = 'A#5'},
    PANDA_HIT = {id = 11, note = 'G-5', duration = 20, channel = 2},
    PANDA_DEAD = {id = 11, note = 'G-6', duration = 60, channel = 2},
}

--
-- Реплики! 💬
--
TEXT = {
    CHOOSE_YOUR_LANGUAGE = {
        ['ru'] = 'ВЫБЕРИ ЯЗЫК',
        ['en'] = 'CHOOSE YOUR LANGUAGE',
    },
    PRESS_Z_TO_START = {
        ['ru'] = 'НАЖМИ Z ЧТОБЫ НАЧАТЬ',
        ['en'] = 'PRESS Z TO START',
    },
    PRESS_RIGHTLEFT_TO_SELECT = {
        ['ru'] = 'НАЖИМАЙ СТРЕЛКИ ЧТОБЫ ПОМЕНЯТЬ ЯЗЫК',
        ['en'] = 'PRESS RIGHT/LEFT TO SELECT LANGUAGE',
    },
    PRESS_ANY_BUTTON_TO_RESPAWN_LINE1 = {
        ['ru'] = 'НАЖМИ ЛЮБУЮ КНОПКУ',
        ['en'] = '\n\n\n\n\n\n  PRESS ANY BUTTON\n   TO RESPAWN',
    },
    PRESS_ANY_BUTTON_TO_RESPAWN_LINE2 = {
        ['ru'] = 'ЧТОБЫ ВОЗРОДИТЬСЯ',
        ['en'] = '\n\n\n\n\n\n  PRESS ANY BUTTON\n   TO RESPAWN',
    },
    GO = {
        ['ru'] = 'ВПЕРЕД)',
        ['en'] = 'GO)',
    },
    -- как тьма зол
    -- не щадит любезность
    -- запретил каомодзи
    -- kawaii-code 😈
    MENU_TITLE = {
        ['ru'] = 'менюшка', -- 'менюшка ~^w^~'
        ['en'] = 'menuwu', -- 'menuwu ~^w^~'
    },
    MENU_OPTION_CONTINUE = {
        ['ru'] = 'ПРОДОЛЖИТБ', -- 'продолжитб~'
        ['en'] = 'CONTIMEOW',
    },
    MENU_OPTION_SETTINGS = {
        ['ru'] = 'НАСТРОИЧКИ', -- 'настроички >_<'
        ['en'] = 'SETTINGS', -- 'settings {{{(>_<)}}}'
    },
    MENU_OPTION_MAIN_MENU = {
        ['ru'] = 'НЕ УХОДИ', -- 'не уходи ￣へ￣'
        ['en'] = 'DONT LEAVE ME', -- 'dont leave me ￣へ￣'
    },

}

--
-- Бинды на клавиши ⌨️
--
CONTROLS = {
    left      = { keys = { KEY_A },     buttons = { BUTTON_LEFT }, },
    right     = { keys = { KEY_D },     buttons = { BUTTON_RIGHT }, },
    look_up   = { keys = { KEY_W },     buttons = { BUTTON_UP }, },
    look_down = { keys = { KEY_S },     buttons = { BUTTON_DOWN }, },
    jump      = { keys = { KEY_SPACE }, buttons = { BUTTON_Z }, },
    attack    = { keys = { KEY_E, KEY_F, KEY_J },           buttons = { BUTTON_X,  }, },
    escape    = { keys = { KEY_Q },     buttons = {  }, },
}

function was_just_pressed(control)
    for _, keyboard_key in ipairs(control.keys) do
        if keyp(keyboard_key) then
            return true
        end
    end
    for _, button in ipairs(control.buttons) do
        if btnp(button) then
            return true
        end
    end
    return false
end

function is_held_down(control)
    for _, keyboard_key in ipairs(control.keys) do
        if key(keyboard_key) then
            return true
        end
    end
    for _, button in ipairs(control.buttons) do
        if btn(button) then
            return true
        end
    end
    return false
end

-- Это всё нужно убрать в какие-нибудь файлы, но эта задача
-- для clean coder-ов 🧹
function is_bad_tile(tile_id)
    for _, bad_tile in ipairs(data.bad_tile) do
        if tile_id == bad_tile then
            return true
        end
    end
    return false
end

data.STANDART_SCALE = 1

data.bad_tile = {}
data.panda = {}
data.run = {}
data.jump = {}
data.idle = {}
data.attack = {}
data.attack_in_jump_forward = {}
data.attack_in_jump_down = {}
data.attack_up = {}
data.slide = {}
data.coffee_bush = {}
data.bush = {}
data.stump = {}
data.cactus = {}


-- Это тайлы для анимаций

-- 1 - тайл 8X8
-- 2 - тайл 16X16
-- Второе значение Scale

data.bike = {}
data.bike.sprite = {
    horny = Sprite:new({178}, 1, 2, 2),
    saddled = Sprite:new({180}, 1, 2, 2),
}

data.idle = {
    --idle_title1 = {382,1}
    -- Мы добавим еще😎
    --idle_title2 = {208,2}
    -- Мы это сделали 😎
}

data.cactus = {
    --cactus_tile1 ={116,2}
    --cactus_tile1 ={118,2}
    --cactus_tile1 ={120,2}
    --cactus_tile1 ={122,1}
    --cactus_tile1 ={123,1}
    --cactus_tile1 ={138,1}
    --cactus_tile1 ={140,1}
    --cactus_tile1 ={124,1}
    --cactus_tile1 ={139,1}
}

data.stump = {
    --stump_tile = {114,2}
}

data.bush = {
    --bush_tile1 = {156,2}
    --bush_tile2 = {158,2}

    --bush_tile1 = {112,2} --сухой куст
}

data.coffee_bush = {
    --coffe_bush_tile1 = {144,2}
    --coffe_bush_tile2 = {146,2}
    --coffe_bush_tile3 = {148,2}
    --coffe_bush_tile4 = {150,2}
    --coffe_bush_tile5 = {152,2}
    --coffe_bush_tile6 = {154,2}
}

data.slide = {
    --slide_tile1 = {448,2}
    --slide_tile2 = {450,2}
    --slide_tile3 = {452,2}
    --slide_tile4 = {454,2}
}

data.attack = {
    --attack_tile1 = {416,2}
    --attack_tile2 = {418,2}
    --attack_tile3 = {420,2}
    --attack_tile4 = {422,2}
    --dust_tile = {488,2} -- 😎
}

data.attack_in_jump_forward = {
    --tile1 = {424,2}
    --tile2 = {456,2}
    --tile3 = {458,2}
    --dust_tile = {488,2} 
}

data.attack_in_jump_down = {
    --tile1 = {490,2}
    --tile2 = {492,2}
    --tile3 = {494,2}
    --dust_tile = {444,2} 
}

data.attack_up = {
    --tile1 = {208,2}
    --tile2 = {210,2}
    --tile3 = {212,2}
    --tile4 = {214,2}
    --dust_tile = {176,2} 
}

data.jump = {
    --jump_tile1 = {380,2}
    --jump_tile2 = {398,1}
    --jump_tile3 = {399,1}
    --jump_tile4 = {383,1}
    --jump_tile5 = {412,2}
    --jump_tile6 = {414,2}
    --jump_tile7 = {412,2}
    --jump_tile8 = {446,2}
    --jump_tile9 = {426,2}
}

data.run = {
    --run_tile1 = {384,2}
    --run_tile2 = {386,2}
    --run_tile3 = {388,2}
    --run_tile4 = {390,2}
    --run_tile5 = {392,2}
    --run_tile6 = {394,2}
}

data.bad_tile = { 32, 33, 34, 48 }

-- 🛖
HOUSE_REVEAL_SPEED = 12
-- Если некоторые тайлы не успевают поменяться, то нужно увеличить эту задержку.
HOUSE_HIDE_DELAY = 0.4

HOUSE_INSIDE_TILES = {}
for x = 8, 15 do
    for y = 2, 5 do
        table.insert(HOUSE_INSIDE_TILES, y*16 + x)
    end
end
HOUSE_OUTSIDE_TILES = {}
for x = 8, 15 do
    for y = 11, 14 do
        table.insert(HOUSE_OUTSIDE_TILES, y*16 + x)
    end
end
HOUSE_DOORS_INSIDE = {72, 88, 79, 95}
HOUSE_DOORS_OUTSIDE = {216, 232, 223, 239}

function is_tile_solid(tile_id)
    -- 2024-09-??
    -- XD Это кому-то исправлять 😆😂😂
    --
    -- 2024-10-20
    -- ... Это пришлось исправлять мне 💀
    --
    -- 2032-32-23
    -- Славный был парень, покойся смело👍
    return
        108 <= tile_id and tile_id <= 110 or
         1 <= tile_id and tile_id <= 4 or
        16 <= tile_id and tile_id <= 19 or
        35 <= tile_id and tile_id <= 35 or
        48 < tile_id and tile_id <= 52 or
              tile_id == 80 or
              tile_id == 81 or
        (table.contains(HOUSE_OUTSIDE_TILES, tile_id) and not table.contains(HOUSE_DOORS_OUTSIDE, tile_id)) or
        tile_id == 40 or tile_id == 56 or tile_id == 47 or tile_id == 63 or -- Внутренние стенки в доме
        24 <= tile_id and tile_id <= 31 -- Тайлы крыши дома
        or 33 <= tile_id and tile_id <= 34
end

-- function is_tile_water(tile_id)
--     return 32 <= tile_id and tile_id <= 34 or tile_id == 48
-- end

function is_tile_water(tile_id)
    return 33 <= tile_id and tile_id <= 34 
end

-- Далее документация у cat-сцене😸

--[[
    
    Тайлы для панды:
        1) 268, 281 (8,16) 
        2) 269, 282 (8,16)
        - Эти два спрайта надо отзеркалить
        -С 3 по 13 (кроме 9,13) нужно дорисовать палку
        3) 271 (8,8) 
        4) 281 (8,8)
        5) 314 (8,8)
        6) 316 (8,8)
        7) 314 (8,8)
        8) 281 (8,8)
        9) 317 (8,8)
        10) 314 (8,8)
        11) 281 (8,8)
        12) 314 (8,8)
        13) 317 (8,8)
        - Далее уже панда отбирает палку или умирает и палка у игрока
        14) 271 (8,8) (дорисовать палку)
        15) 287 (8,8) (отзеркалить) (дорисовать палку)
    
    Тайлы для игрока:
        1) 480 (8,8) 
        2) 481 (8,8)
        - Эти два спрайта (1,2) без палки, дальше борьба
        3) 482 (8,8) 
        4) 483 (8,8)
        5) 482 (8,8)
        6) 484 (8,8) (сместить на 1 пиксель влево)
        7) 482 (8,8)
        8) 483 (8,8) (сместить на 1 пиксель вправо)
        9) 485 (8,8) (сместить на 2 пикселя влево)
        10) 482 (8,8)
        11) 483 (8,8) (сместить на 1 пиксель вправо)
        12) 482 (8,8)
        13) 485 (8,8) (сместить на 2 пикселя влево)
        - Далее уже панда отбирает палку или умирает и палка у игрока
        14) 208 (16,16) (с палкой)
        15) 208 (16,16)
--]]


--[[

    📔 📖

    Архив старых паст, которые утратили актуальность,
    но слишком жалко их удалять

    📔 📖



    kawaii-Code в 2024, про диагональную атаку:
        --
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

    Дебаг от Linux Torbolts (2025): 
        trace('Hello Baka! I\'m Bake for you😤')
        ...
        trace(tostring(self.button_pressed)..' '..'AAAAAAAAAAAAAAAAAAAAAHh💦💦💦')
        ...
        trace(self.x..' 👉👈 '..self.y)

    Обмен любезностями в панде (2024-2025):
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
        --
        --
        -- Как хорошо, что я не читал россказни каваи-монолита до сегодняшнего дня😁
        -- Мозговыжигающее зрелище, скажу вам.
        --
--]]
