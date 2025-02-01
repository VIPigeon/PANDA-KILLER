--[[

Давайте поясню за физику ⚽

У нас есть Hitbox-ы, Rect-ы и Rigidbody.

Отдельно никакого класса Rigidbody нету, это скорее "интерфейс".
Rigidbody - это таблица, в которой есть поля x, y, velocity и hitbox.
Также можно добавить таблицу physics_settings, которая используется
в Physics.update().

Например, игрок это Rigidbody:

player = {
    x = 0,
    y = 0,
    velocity = { x = 0, y = 0 },
    hitbox = Hitbox:new(0, 0, 8, 8),
    physics_settings = {
        gravity = ...,
        friction = ...,
        min_horizontal_velocity = ...,
    },

    -- Ещё какие-то поля...
    -- ...
}

Про хитбоксы и прямоугольники можно почитать в `Hitbox.lua`

Основные функции: `move_x`, `move_y` Они двигают rigidbody в соответствие с
его velocity, а также следят за тем, чтобы у нас не было коллизий. Если же
коллизия была, то `move_x` и `move_y` вернут её (rigidbody все равно будет
корректно отпозиционирован (какое крутое слово)).

Также я добавил `update`, которая делает всё и сразу.

Для более низкоуровневых штук можно использовать другие функции. Основной
пример использования физики в игроке - заходите туда и копипастите код! 😁

Внимание: обрабатываются коллизии только с тайлами. Если мы хотим, например,
проверить столкновение двух панд между собой (то есть два динамических объекта),
то тут уж разбирайтесь сами. Низкоуровневые `check_collision_rect_rect` вам в
помощь.

--]]

Physics = {}

-- Проверяет, что прямо под хитбоксом что-то есть
function Physics.is_on_ground(rigidbody)
    local collision = Physics.check_collision_rect_tilemap(
        rigidbody.hitbox:to_rect(rigidbody.x, rigidbody.y + 1)
    )
    return collision ~= nil
end

function Physics.update(rigidbody)
    local is_on_ground = Physics.is_on_ground(rigidbody)

    local horizontal_collision = Physics.move_x(rigidbody)
    if horizontal_collision ~= nil then
        rigidbody.velocity.x = -1 * WORLD_HORIZONTAL_COEFFICIENT_OF_RESTITUTION * rigidbody.velocity.x
    end

    local vertical_collision = Physics.move_y(rigidbody)
    if vertical_collision ~= nil then
        rigidbody.velocity.y = 0
    end

    if not is_on_ground then
        rigidbody.velocity.y = rigidbody.velocity.y - rigidbody.physics_settings.gravity * Time.dt()
    end

    rigidbody.velocity.x = rigidbody.velocity.x - (rigidbody.velocity.x * rigidbody.physics_settings.friction * Time.dt())
    if math.abs(rigidbody.velocity.x) < rigidbody.physics_settings.min_horizontal_velocity then
        rigidbody.velocity.x = 0
    end
end

function Physics.move_x(rigidbody)
    local next_x = rigidbody.x + rigidbody.velocity.x * Time.dt()

    local rect_after_x_move = Rect.combine(
        Hitbox.to_rect(rigidbody.hitbox, rigidbody.x, rigidbody.y),
        Hitbox.to_rect(rigidbody.hitbox, next_x, rigidbody.y)
    )
    local tilemap_collision = Physics.check_collision_rect_tilemap(rect_after_x_move)
    if tilemap_collision ~= nil then
        local moving_right = rigidbody.velocity.x > 0
        if moving_right then
            next_x = tilemap_collision.x - rigidbody.hitbox.width - rigidbody.hitbox.offset_x
        else
            next_x = tilemap_collision.x + 8 - rigidbody.hitbox.offset_x
        end
    end

    next_x = math.clamp(next_x, -rigidbody.hitbox.offset_x, WORLD_WIDTH + rigidbody.hitbox.width)
    rigidbody.x = next_x

    return tilemap_collision
end

function Physics.move_y(rigidbody)
    -- Обращаю внимание 🤓, что отрицательная velocity - полет вниз, в то время
    -- как ось y в TIC-80 перевернута, т.е. если мы хотим сдвинуть что-то
    -- **вниз** на 5, то мы делаем y = y + 5.
    --
    -- Отсюда минус в этой формуле (В move_x такого нет)
    local next_y = rigidbody.y - rigidbody.velocity.y * Time.dt()

    local rect_after_y_move = Rect.combine(
        Hitbox.to_rect(rigidbody.hitbox, rigidbody.x, rigidbody.y),
        Hitbox.to_rect(rigidbody.hitbox, rigidbody.x, next_y)
    )
    local tilemap_collision = Physics.check_collision_rect_tilemap(rect_after_y_move)
    if tilemap_collision ~= nil then
        local flying_down = rigidbody.velocity.y < 0
        if flying_down then
            next_y = tilemap_collision.y - rigidbody.hitbox.height - rigidbody.hitbox.offset_y
        else
            next_y = tilemap_collision.y + rigidbody.hitbox.height + rigidbody.hitbox.offset_y
        end
    end

    next_y = math.clamp(next_y, 0, WORLD_HEIGHT)
    rigidbody.y = next_y

    return tilemap_collision
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

function Physics.check_collision_shape_rect(shape, rect)
    for _, shape_rect in ipairs(shape.rects) do
        if Physics.check_collision_rect_rect(shape_rect, rect) then
            return true
        end
    end
    return false
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

            if is_tile_solid(tile_id) then
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

    if is_tile_solid(mget(tile_x2, tile_y1)) then
        return { x = 8 * tile_x2, y = 8 * tile_y1 }
    end

    if is_tile_solid(mget(tile_x1, tile_y2)) then
        return { x = 8 * tile_x1, y = 8 * tile_y2 }
    end

    if is_tile_solid(mget(tile_x2, tile_y2)) then
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
