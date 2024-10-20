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

data.bad_tile = {}
data.panda = {}

data.bad_tile = {
	bad_tile1 = 32
}

data.panda.sprite = {

	stay_boring = Sprite:new({267}, 1),

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
