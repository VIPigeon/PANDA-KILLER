data = {}

-- 🏮 Перед релизом поставить в false!!! 🏮
DEV_MODE_ENABLED = true

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
GAME_STATE_PAUSED = 3


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

TRANSPARENT_SPRITE = Sprite:new({0})


--
-- Настройки камеры 🎥
--
-- Чтобы понять, что меняют эти параметры, включите дебаг в Camera.update()
CAMERA_LINES_DISTANCE_FROM_CENTER = 35
CAMERA_PAN_OFFSET = 6
CAMERA_SMOOTH_TIME = 0.18
CAMERA_DIRECTION_CHANGE_TIME = 0.3



--[[

      ТРЕВОГА ⚠

      НАЧИНАЮТСЯ НАСТРОЙКИ ИГРОКА ☢

      БЕЗ ЗАЩИТНОГО КОСТЮМА НЕ ВХОДИТЬ

--]]

PLAYER_SPAWNPOINT_X = 0                                      -- пиксели
PLAYER_SPAWNPOINT_Y = 40                                     -- пиксели

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
PLAYER_JUMP_HEIGHT = 20                                      -- пиксели
-- Поменяйте это, чтобы изменить время, за которое
-- игрок достигнет высшей точки прыжка (APEX).
PLAYER_TIME_TO_APEX = 0.33                                   -- секунды

-- Считается автоматически! Вручную не менять.
PLAYER_GRAVITY = (2 * PLAYER_JUMP_HEIGHT) / (PLAYER_TIME_TO_APEX * PLAYER_TIME_TO_APEX)
PLAYER_GRAVITY_AFTER_WALL_JUMP = 0.75 * PLAYER_GRAVITY
PLAYER_JUMP_STRENGTH = math.sqrt(2 * PLAYER_GRAVITY * PLAYER_JUMP_HEIGHT)
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
PLAYER_ATTACK_DURATION = 0.15                   -- секунды
PLAYER_ATTACK_BUFFER_TIME = 0.2                -- секунды
PLAYER_ATTACK_EFFECT_DURATION = PLAYER_ATTACK_BUFFER_TIME

PLAYER_ATTACK_SHAKE_MAGNITUDE = 0.5
PLAYER_ATTACK_SHAKE_DURATION = 0.05

PLAYER_TIME_BEFORE_SHOWING_DEATH_SCREEN_AFTER_DEATH = 1.5

PLAYER_DEATH_KNOCKBACK_HORIZONTAL = 80
PLAYER_DEATH_KNOCKBACK_VERTICAL = 80

PLAYER_JUMP_BY_HIT = PLAYER_JUMP_STRENGTH * 1.

--
-- Спрайты и анимации 🎞️
--
PLAYER_SPRITE_IDLE    = Sprite:new({380}, 1, 2, 2)
PLAYER_SPRITE_RUNNING = Sprite:new({384, 386, 388, 390, 392, 394}, 6, 2, 2)
PLAYER_SPRITE_ATTACK  = Animation:new({416, 418, 420, 422}, 2):with_size(2, 2):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_ATTACK_AIR_FORWARD  = Animation:new({424, 456, 458}, 2):with_size(2, 2):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_ATTACK_AIR_DOWNWARD = Animation:new({490, 492, 494}, 3):with_size(2, 2):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_ATTACK_UPWARDS = Animation:new({208, 210, 212, 214}, 2):with_size(2, 2):at_end_goto_last_frame():to_sprite()
PLAYER_ATTACK_SPRITES = {PLAYER_SPRITE_ATTACK, PLAYER_SPRITE_ATTACK_AIR_FORWARD, PLAYER_SPRITE_ATTACK_AIR_DOWNWARD, PLAYER_SPRITE_ATTACK_UPWARDS}
PLAYER_SPRITE_JUMP = Animation:new({412, 414, 412}, 3):with_size(2, 2):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_FALLING = Animation:new({426}, 1):with_size(2, 2):to_sprite()
PLAYER_SPRITE_SLIDE = Sprite:new_complex({
    Animation:new({448, 450}, 8):with_size(2, 2),
    Animation:new({452, 454}, 12):with_size(2, 2):at_end_goto_animation(2),
})
PLAYER_SPRITE_DEAD = Sprite:new({479})
PLAYER_SPRITE_JUMP_PARTICLE_EFFECT = Animation:new({496, 498, 500, 502}, 6):with_size(2, 1):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_LAND_PARTICLE_EFFECT = Animation:new({500, 502}, 8):with_size(2, 1):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_ATTACK_PARTICLE_EFFECT_HORIZONTAL = Animation:new({488}, 18):with_size(2, 2):at_end_goto_last_frame():to_sprite();
PLAYER_SPRITE_ATTACK_PARTICLE_EFFECT_DOWNWARD = Animation:new({444}, 18):with_size(2, 1):at_end_goto_last_frame():to_sprite();
PLAYER_SPRITE_ATTACK_PARTICLE_EFFECT_UPWARD = Animation:new({176}, 18):with_size(2, 2):at_end_goto_last_frame():to_sprite();

HAT_SPRITE = Sprite:new({478})

--[[

      Настройки игрока закончены

      Снимайте защитный костюм 🥼🕶



      🐼 🐼 🐼 🐼 🐼

      И НАЛИВАЙТЕ КОФЕ ☕!

      НАЧИНАЮТСЯ НАСТРОЙКИ ПАНДЫ

      🐼 🐼 🐼 🐼 🐼

--]]

-- Стаггер - небольшое время стана после одного удара от игрока
-- Если игрок бъет панду много раз и быстро, то она входит в стан

-- Короче ну вас, не могу придумать название 🤬
-- Если непонятно что это, то спросите. Не хочу
-- даже в этом комментарии объяснять, что это такое!
PANDA_TIME_INTERVAL_BETWEEN_HITS_FROM_PLAYER = 1.0
PANDA_HITS_NEEDED_TO_GET_STUNNED = 3
PANDA_STAGGER_DURATION = 1.0
PANDA_STUN_DURATION = 2.5

-- Отбрасывание панды от игрока при обычном стаггере
PANDA_KNOCKBACK_HORIZONTAL = 20.0
PANDA_KNOCKBACK_VERTICAL = 10.0
-- При стане
PANDA_STUN_KNOCKBACK_HORIZONTAL = 75.0
PANDA_STUN_KNOCKBACK_VERTICAL = 60.0

PANDA_PHYSICS_SETTINGS = {
    gravity = 139.7,
    friction = 3.5,
    min_horizontal_velocity = 2.0,
}

PANDA_LOOK_DIRECTION_LEFT  = -1
PANDA_LOOK_DIRECTION_RIGHT = 1
-- константная функция 📛
PANDA_REST_TIME_BEFORE_DIRECTION_CHANGE = function()
    return 1 + 1.0 * math.random()
end

PANDA_VIEW_CONE_WIDTH = 64
PANDA_VIEW_CONE_HEIGHT = 32
PANDA_PATROL_SPEED = 8
PANDA_PATROL_PIXELS_UNTIL_STOP = 6

PANDA_X_DISTANCE_TO_PLAYER_UNTIL_ATTACK = 16
PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_ATTACK = 16
PANDA_CHASE_JUMP_STRENGTH = 80
PANDA_CHASE_PIXELS_UNTIL_JUMP = 16
PANDA_CHASE_SPEED = 2.5 * PANDA_PATROL_SPEED

PANDA_CHASE_DURATION = 4.0
PANDA_ATTACK_CHARGE_DURATION = 0.8  -- 1.5
PANDA_POUNCE_DURATION = 0.5  -- 1.0

PANDA_SPRITES = {
    walk  = Animation:new({256, 257}, 30):to_sprite(),
    chase = Animation:new({259, 260}, 10):to_sprite(),
    rest  = Sprite:new_complex({
        Animation:new({276}, 8),
        Animation:new({277-16}, 8):with_size(2, 2)
    }),
    charging_attack = Animation:new({282}, 1):to_sprite(),
    pounce = Animation:new({263}, 1):to_sprite(),
}

--[[

      Настройки панды завершены.

      Спасибо за посещение. 🧑💼

--]]

--
-- 💬 💬 💬
-- Реплики!
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
        ['en'] = 'PRESS RIGHT/LEFT TO SELECT',
    },
    PRESS_ANY_BUTTON_TO_RESPAWN = {
        ['ru'] = '\n\n\n\n\n\n  ДЛЯ ВОЗРОЖДЕНИЯ НАЖМИТЕ\n   НА ОДНУ ЛЮБУЮ КНОПКУ',
        ['en'] = '\n\n\n\n\n\n  PRESS ANY BUTTON\n   TO RESPAWN',
    }
}

--
-- Звуки (sfx🤪) 🔊
-- 
SOUNDS = {
    MUTE_CHANNEL_ZERO = {id = -1, note = -1, channel = 0},
    MUTE_CHANNEL_ONE = {id = -1, note = -1, channel = 1},
    MUTE_CHANNEL_TWO = {id = -1, note = -1, channel = 2},

    PLAYER_ATTACK = {id = 5, note = 'C-6', duration = 10, channel = 2},
    PLAYER_JUMP = {id = 4, note = 'A#4'},
    PLAYER_SLIDE = {id = 8, note = 'D-1', channel = 1},
    PLAYER_DEAD = {id = 5, note = 'C-5', duration = 30, channel = 2},

    PANDA_ATTACK_CHARGE = {id = 11, note = 'G-3', duration = 20, channel = 2},
    PANDA_POUNCE = {id = 11, note = 'C-5', duration = 20, channel = 2},
    PANDA_JUMP = {id = 4, note = 'A#5'},
    PANDA_HIT = {id = 11, note = 'G-5', duration = 20, channel = 2},
    PANDA_DEAD = {id = 11, note = 'G-6', duration = 60, channel = 2},
}



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

data.bad_tile = {
	bad_tile1 = 32
}

data.panda.sprite = {

	stay_boring = Animation:new({267}, 1):to_sprite(),

}

function is_tile_solid(tile_id)
    -- 2024-09-??
    -- XD Это кому-то исправлять 😆😂😂
    --
    -- 2024-10-20
    -- ... Это пришлось исправлять мне 💀
    return
         1 <= tile_id and tile_id <= 4 or
        16 <= tile_id and tile_id <= 19 or
        33 <= tile_id and tile_id <= 35 or
        48 <= tile_id and tile_id <= 52 or
              tile_id == 80 or
              tile_id == 81
end


--[[

    Архив старых паст, которые утратили актуальность,
    но слишком жалко их удалять 📚

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

--]]
