--[[

Функции, которые я не знаю куда запихнуть

--]]

Basic = {}

-- В игре есть 3 разные координатные системы, о которых нужно помнить.
-- 1. Мировая -- измеряется в пикселях, x от 0 до 1920, y от 0 до 1088
-- 2. Тайловая -- каждый тайл 8x8 пикселей, соответственно перевод из
--    мировой в тайловую и обратно - это умножение / деление на 8.
--    В тайловой координатной системе x от 0 до 240, y от 0 до 136
-- 3. Локальная -- её ещё нету, но она связана с камерой и положением
--    игровых объектов относительно неё.
function Basic.world_to_tile(x, y)
    local tile_x = x // 8
    local tile_y = y // 8
    return tile_x, tile_y
end

function Basic.tile_to_world(x, y)
    local world_x = x * 8
    local world_y = y * 8
    return world_x, world_y
end

-- Таймер - это просто число с плавающей точкой (обозначим его t). Если t =
-- 0, значит таймер остановился. Если же t > 0, то таймер идет, и осталось
-- t секунд до конца. Делать с этим можно что угодно, примеры можно
-- посмотреть здесь, в игроке.
function Basic.tick_timer(timer)
    return math.max(timer - Time.dt(), 0.0)
end

-- Звук выглядит например так:
--  panda_hit = {id = 11, note = 'G-6', duration = 60, channel = 2}
function Basic.play_sound(sound)
    local duration = sound.duration or -1
    local channel = sound.channel or 0
    local volume = sound.volume or 15
    local speed = sound.speed or 0
    sfx(sound.id, sound.note, duration, channel, volume, speed)
end
