data = {}

GAMEMODE = GAMEMODE_DEBUG -- developer only

PLAYER_START_X = 0
PLAYER_START_Y = 40

CAMERA_WINDOW_WIDTH  = 60
CAMERA_WINDOW_HEIGHT = 80
CAMERA_VERTICAL_OFFSET = 26
CAMERA_SPEED = 1

TILEMAP_WIDTH  = 240 -- тайлов
TILEMAP_HEIGHT = 136 -- тайлов

-- Размеры экрана игры, камеры, если угодно
SCREEN_WIDTH  = 240 -- пикселей
SCREEN_HEIGHT = 136 -- пикселей

WORLD_WIDTH  = 1920 -- пикселей (= 240 * 8)
WORLD_HEIGHT = 1088 -- пикселей (= 136 * 8)

TRANSPARENT_SPRITE = Sprite:new({0})

data.bad_tile = {}
data.panda = {}
data.run = {}
data.jump = {}
data.idle = {}
data.attack1 = {}
data.attack2 = {}
data.slide = {}

-- Это тайлы для анимаций

-- 1 - тайл 8X8
-- 2 - тайл 16X16
-- Второе значение Scale

data.idle = {
    --idle_title1 = {382,1}
    -- Мы добавим еще😎
}

data.slide = {
    --slide_tile1 = {448,2}
    --slide_tile2 = {450,2}
    --slide_tile3 = {452,2}
    --slide_tile4 = {454,2}
}

data.attack1 = {
    --attack1_tile1 = {416,2}
    --attack1_tile2 = {418,2}
    --attack1_tile3 = {420,2}
    --attack1_tile4 = {422,2}
    --attack1_tile4 = {478,2} -- 😎
}

data.attack2 = {
    --attack2_tile1 = {416,2}
    --attack2_tile2 = {458,2}
    --attack2_tile3 = {476,2}
    --attack2_tile4 = {478,2}
}

data.jump = {
    --jump_tile1 = {380,2}
    --jump_tile2 = {398,1}
    --jump_tile3 = {399,1}
    --jump_tile4 = {383,1}
    --jump_tile5 = {412,2}
    --jump_tile6 = {414,2}
    --jump_tile7 = {444,2}
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
