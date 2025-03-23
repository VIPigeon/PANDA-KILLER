House = {}

function House:new(min_x, min_y, max_x, max_y, tiles)
    local object = {
        min_x = min_x,
        max_x = max_x,
        min_y = min_y,
        max_y = max_y,
        tiles = tiles,
        revealed = false,
    }

    setmetatable(object, self)
    return object
end

function House:hide()
    self.revealed = false
end

function House:reveal()
    self.revealed = true
end

function House:draw()
    if not self.revealed then
        for x = self.min_x, self.max_x do
            for y = self.min_y, self.max_y do
                local inside_tile = mget(x, y)
                local outside_tile = house_inside_tile_to_outside_tile(inside_tile)
                local tx, ty = game.camera:transform_coordinates(x*8, y*8)
                spr(outside_tile, tx, ty)
            end
        end
    end
end

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

    return House:new(new_house.min_x, new_house.min_y, new_house.max_x, new_house.max_y, new_house.tiles)
end

function is_tile_a_house(tile_x, tile_y)
    return table.contains(HOUSE_INSIDE_TILES, mget(tile_x, tile_y))
end

function hide_all_houses()
    for _, house in ipairs(game.houses) do
        house:hide()
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

function house_inside_tile_to_outside_tile(tile_id)
    return tile_id + 9 * 16
end

function house_outside_tile_to_inside_tile(tile_id)
    return tile_id - 9 * 16
end

House.__index = House
