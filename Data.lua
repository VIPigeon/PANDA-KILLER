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



GAME_STATE_LANGUAGE_SELECTION = 'language-selection'
GAME_STATE_PAUSED = 'paused'
GAME_STATE_GAMEPLAY = 'gameplay'

CAMERA_WINDOW_WIDTH  = 60
CAMERA_WINDOW_HEIGHT = 80
CAMERA_VERTICAL_OFFSET = 26
CAMERA_SPEED = 1

-- Это то, что в тике на F3
WORLD_TILEMAP_WIDTH  = 240 -- тайлов
WORLD_TILEMAP_HEIGHT = 136 -- тайлов

-- Размеры экрана игры, камеры, если угодно
SCREEN_WIDTH  = 240 -- пикселей
SCREEN_HEIGHT = 136 -- пикселей

WORLD_WIDTH  = 1920 -- пикселей (= 240 * 8)
WORLD_HEIGHT = 1088 -- пикселей (= 136 * 8)

TRANSPARENT_SPRITE = Sprite:new({0})



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
PLAYER_AIR_FRICTION = 0.52 * PLAYER_FRICTION                 -- тоже не знаю
-- http://www.thealmightyguru.com/Wiki/index.php?title=Coyote_time
PLAYER_COYOTE_TIME = 0.23                                    -- секунды
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

--
-- Боёвка 🤺
--
-- Сколько по времени занимает одна атака.
-- Это никак не зависит от анимации атаки,
-- она просто зависнет на последнем кадре.
PLAYER_ATTACK_DURATION = 0.4                   -- секунды
-- Это не совсем тоже самое, что и 
PLAYER_ATTACK_BUFFER_TIME = 0.2                -- секунды

--
-- Спрайты и анимации 🎞️
--
PLAYER_SPRITE_IDLE    = Sprite:new({380}, 1, 2, 2)
PLAYER_SPRITE_RUNNING = Sprite:new({384, 386, 388, 390, 392, 394}, 6, 2, 2)
PLAYER_SPRITE_ATTACK  = Animation:new({416, 418, 420, 422}, 4):with_size(2, 2):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_ATTACK_AIR_FORWARD  = Animation:new({424, 456, 458}, 4):with_size(2, 2):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_ATTACK_AIR_DOWNWARD = Animation:new({490, 492, 494}, 6):with_size(2, 2):at_end_goto_last_frame():to_sprite()
PLAYER_ATTACK_FRAME_WHEN_TO_APPLY_ATTACK = 5 -- CRINGE CODE
PLAYER_SPRITE_JUMP = Animation:new({412, 414, 412}, 3):with_size(2, 2):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_FALLING = Animation:new({426}, 1):with_size(2, 2):to_sprite()
PLAYER_SPRITE_SLIDE = Sprite:new_complex({
    Animation:new({448, 450}, 8):with_size(2, 2),
    Animation:new({452, 454}, 12):with_size(2, 2):at_end_goto_animation(2),
})
PLAYER_SPRITE_DEAD = Sprite:new({274})
PLAYER_SPRITE_JUMP_PARTICLE_EFFECT = Animation:new({496, 498, 500, 502}, 6):with_size(2, 1):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_LAND_PARTICLE_EFFECT = Animation:new({500, 502}, 8):with_size(2, 1):at_end_goto_last_frame():to_sprite()
PLAYER_SPRITE_ATTACK_PARTICLE_EFFECT_HORIZONTAL = Animation:new({488}, 18):with_size(2, 2):at_end_goto_last_frame():to_sprite();
PLAYER_SPRITE_ATTACK_PARTICLE_EFFECT_DOWNWARD = Animation:new({444}, 18):with_size(2, 1):at_end_goto_last_frame():to_sprite();

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
PANDA_STAGGER_TIME = 1.0
PANDA_STUNNED_TIME = 2.5

-- Пока что используются для отлета панды (когда её застанило)
PANDA_FLY_AWAY_SPEED = 75.0
PANDA_FLY_UP_SPEED = 60.0
PANDA_GRAVITY = 139.7
PANDA_FRICTION = 3.5
PANDA_MIN_HORIZONTAL_VELOCITY = 4.0

PANDA_LOOK_DIRECTION_LEFT  = -1
PANDA_LOOK_DIRECTION_RIGHT = 1
-- константная функция 📛
PANDA_REST_TIME_BEFORE_DIRECTION_CHANGE = function()
    return 1 + 1.0 * math.random()
end

PANDA_VIEW_CONE_WIDTH = 64
PANDA_VIEW_CONE_HEIGHT = 32
PANDA_PATROL_SPEED = 8
PANDA_SLOWDOWN_FOR_REST = 0.5
PANDA_DECELERATION = 48
PANDA_PATROL_PIXELS_UNTIL_STOP = 6

PANDA_X_DISTANCE_TO_PLAYER_UNTIL_ATTACK = 16 -- pixels
PANDA_Y_DISTANCE_TO_PLAYER_UNTIL_ATTACK = 16 -- pixels
PANDA_CHASE_JUMP_STRENGTH = 80
PANDA_CHASE_PIXELS_UNTIL_JUMP = 12
PANDA_CHASE_SPEED = 2.5 * PANDA_PATROL_SPEED
PANDA_CHASE_TIME = 3.0
PANDA_ATTACK_TIME = 1.5

PANDA_DEFAULT_SPRITE = Animation:new({256, 257}, 1):to_sprite()
PANDA_CHASE_SPRITE = Animation:new({259, 260}, 10):to_sprite()
PANDA_REST_SPRITE = Sprite:new_complex({
    Animation:new({276}, 8),
    Animation:new({277}, 8):with_size(2, 1)
})
PANDA_PANIC_SPRITE = Animation:new({263, 256}, 7):to_sprite()

--[[

      Настройки панды завершены.

      Спасибо за посещение. 🧑💼

--]]

--[[

      💬 💬 💬 💬 💬 💬 💬

      Реплики!

--]]

TEXT__CHOOSE_YOUR_LANGUAGE = {
    ['ru'] = 'ВЫБЕРИ ЯЗЫК',
    ['en'] = 'CHOOSE YOUR LANGUAGE',
}
TEXT__PRESS_Z_TO_START = {
    ['ru'] = 'НАЖМИ Z ЧТОБЫ НАЧАТЬ',
    ['en'] = 'PRESS Z TO START',
}
TEXT__PRESS_RIGHTLEFT_TO_SELECT = {
    ['ru'] = 'НАЖИМАЙ СТРЕЛКИ ЧТОБЫ ПОМЕНЯТЬ ЯЗЫК',
    ['en'] = 'PRESS RIGHT/LEFT TO SELECT',
}

--[[

      Реплики кончились 🤐

--]]



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

-- В игре есть 3 разные координатные системы, о которых нужно помнить.
-- 1. Мировая -- измеряется в пикселях, x от 0 до 1920, y от 0 до 1088
-- 2. Тайловая -- каждый тайл 8x8 пикселей, соответственно перевод из
--    мировой в тайловую и обратно - это умножение / деление на 8.
--    В тайловой координатной системе x от 0 до 240, y от 0 до 136
-- 3. Локальная -- её ещё нету, но она связана с камерой и положением
--    игровых объектов относительно неё.
function world_to_tile(x, y)
    local tile_x = x // 8
    local tile_y = y // 8
    return tile_x, tile_y
end

function tile_to_world(x, y)
    local world_x = x * 8
    local world_y = y * 8
    return world_x, world_y
end

-- Таймер - это просто число с плавающей точкой (обозначим его t). Если t =
-- 0, значит таймер остановился. Если же t > 0, то таймер идет, и осталось
-- t секунд до конца. Делать с этим можно что угодно, примеры можно
-- посмотреть здесь, в игроке.
function tick_timer(timer)
    return math.max(timer - Time.dt(), 0.0)
end
