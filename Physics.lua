Physics = {}

-- Наверное эта функция должна быть не здесь
function Physics.is_tile_solid(tile_id)
    -- XD Это кому-то исправлять 😆😂😂
    return tile_id == 1
end

function Physics.check_collision_rect_rect(r1, r2)
    if r1:left() > r2:right() or
       r2:left() > r1:right() or
       r1:top() > r2:bottom() or
       r2:top() > r1:bottom() then
        return false
    end
    return true
end

-- TODO: Уверен, в будущем нужно будет возвращать не только самое первое
-- столкновение, но вообще все столкновения, которые случились.
function Physics.check_collision_rect_tilemap(rect)
    assert(rect.w ~= 0)
    assert(rect.h ~= 0)

    local x = rect.x
    local y = rect.y
    local x2 = rect.x + rect.w - 1
    local y2 = rect.y + rect.h - 1

    local tile_x = x // 8
    local tile_y = y // 8

    local tile_x1 = x // 8
    local tile_y1 = y // 8
    local tile_x2 = x2 // 8
    local tile_y2 = y2 // 8

    while y <= y2 do
        while x <= x2 do
            local tile_id = mget(tile_x, tile_y)

            if Physics.is_tile_solid(tile_id) then
                return {
                    x = 8 * tile_x,
                    y = 8 * tile_y,
                }
            end

            tile_x = tile_x + 1
            x = x + 8
        end

        y = y + 8
        tile_y = tile_y + 1
        x = rect.x
        tile_x = x // 8
    end

    if Physics.is_tile_solid(mget(tile_x2, tile_y1)) then
        return { x = 8 * tile_x2, y = 8 * tile_y1 }
    end

    if Physics.is_tile_solid(mget(tile_x1, tile_y2)) then
        return { x = 8 * tile_x1, y = 8 * tile_y2 }
    end

    if Physics.is_tile_solid(mget(tile_x2, tile_y2)) then
        return { x = 8 * tile_x2, y = 8 * tile_y2 }
    end

    return nil
end

-- TODO: Принимаются предложения по улучшению API
-- Чтобы API не было PAI(N) 🥁🔊
function Physics.tile_ids_that_intersect_with_rect(rect)
    assert(rect.w ~= 0)
    assert(rect.h ~= 0)

    local x = rect.x
    local y = rect.y
    local x2 = rect.x + rect.w - 1
    local y2 = rect.y + rect.h - 1

    local tile_x = x // 8
    local tile_y = y // 8

    local tile_x1 = x // 8
    local tile_y1 = y // 8
    local tile_x2 = x2 // 8
    local tile_y2 = y2 // 8

    collisions = {}

    while y <= y2 do
        while x <= x2 do
            local tile_id = mget(tile_x, tile_y)
            table.insert(collisions, {x = tile_x, y = tile_y, id = tile_id})

            tile_x = tile_x + 1
            x = x + 8
        end

        y = y + 8
        tile_y = tile_y + 1
        x = rect.x
        tile_x = x // 8
    end

    local id_left_top = mget(tile_x2, tile_y1)
    table.insert(collisions, {x = tile_x2, y = tile_y1, id = id_left_top})

    local id_left_bottom = mget(tile_x1, tile_y2)
    table.insert(collisions, {x = tile_x1, y = tile_y2, id = id_left_bottom})

    local id_right_bottom = mget(tile_x2, tile_y2)
    table.insert(collisions, {x = tile_x2, y = tile_y2, id = id_right_bottom})

    return collisions
end
