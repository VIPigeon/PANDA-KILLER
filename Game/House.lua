-- Здесь пока что нету класса, ведь зачем?

function create_a_house_by_bfs_from(tile_x, tile_y)
    local new_house = {
        min_x = 240,
        min_y = 240,
        max_x = -1,
        max_y = -1,
        tiles = {},
        revealed = false,
    }

    local queue = Queue:new()
    queue:enqueue({tile_x, tile_y})
    while not queue:empty() do
        tile_x, tile_y = table.unpack(queue:dequeue())
        if new_house.tiles[tile_x] == nil then
            new_house.tiles[tile_x] = {}
        end
        if new_house.tiles[tile_x][tile_y] then
            goto bfs_continue
        end

        new_house.tiles[tile_x][tile_y] = true
        new_house.min_x = math.min(new_house.min_x, tile_x)
        new_house.max_x = math.max(new_house.max_x, tile_x)
        new_house.min_y = math.min(new_house.min_y, tile_y)
        new_house.max_y = math.max(new_house.max_y, tile_y)

        if is_tile_a_house(tile_x + 1, tile_y) then
            queue:enqueue({tile_x + 1, tile_y})
        end
        if is_tile_a_house(tile_x, tile_y + 1) then
            queue:enqueue({tile_x, tile_y + 1})
        end
        if is_tile_a_house(tile_x - 1, tile_y) then
            queue:enqueue({tile_x - 1, tile_y})
        end
        if is_tile_a_house(tile_x, tile_y - 1) then
            queue:enqueue({tile_x, tile_y - 1})
        end

        ::bfs_continue::
    end

    return new_house
end

function is_tile_a_house(tile_x, tile_y)
    return table.contains(HOUSE_OUTSIDE_TILES, mget(tile_x, tile_y))
end

function hide_all_houses()
    for _, house in ipairs(game.houses) do
        hide_house(house)
    end
end

function get_house_at(tile_x, tile_y)
    for _, house in ipairs(game.houses) do
        if house.tiles[tile_x] ~= nil and house.tiles[tile_x][tile_y] then
            return house
        end
    end
    return nil
end

function hide_house(house)
    if not house.revealed then
        return
    end
    house.revealed = false
    for x = house.min_x, house.max_x do
        for y = house.min_y, house.max_y do
            local inside_tile_id = mget(x, y)
            local outside_tile_id = house_inside_tile_to_outside_tile(inside_tile_id)
            mset(x, y, outside_tile_id)
        end
    end
end

function reveal_house_insides(house)
    if house.revealed then
        return
    end
    house.revealed = true
    for x = house.min_x, house.max_x do
        for y = house.min_y, house.max_y do
            local outside_tile_id = mget(x, y)
            local inside_tile_id = house_outside_tile_to_inside_tile(outside_tile_id)
            mset(x, y, inside_tile_id)
        end
    end
end

function house_inside_tile_to_outside_tile(tile_id)
    return tile_id + 9 * 16
end

function house_outside_tile_to_inside_tile(tile_id)
    return tile_id - 9 * 16
end
