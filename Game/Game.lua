-- В game есть ещё много полей, они создаются в game.init, game.restart, т.д.
game = {
    state = GAME_STATE_LANGUAGE_SELECTION,
    language = 'ru',
    CRUTCH_dialog_window = {},
    animated_tiles = {},
    houses = {},
    triggers = {},
    scale = 1,

    tile_info = {},
    coordinates_to_tile_info = {},
}

if DEV_MODE_ENABLED then
    game.state = GAME_STATE_GAMEPLAY
end

function game.init()
    -- А что использовать как сид 🤔? `os.time()` в тике недоступен
    -- math.randomseed(69420)
    --
    -- Ответ: в тике каждый раз при запуске картриджа задается новый
    -- случайный сид от текущего времени. Я это нашёл в исходном коде
    -- тика. 🤓

    game.dialog_window = DialogWindow:new(100,50,"dcs")

    game.save_special_tile_information()

    game.restart()
end

function game.save_special_tile_information()
    for row = 0, WORLD_TILEMAP_HEIGHT do
        for col = 0, WORLD_TILEMAP_WIDTH do
            local x, y = Basic.tile_to_world(col, row) -- Кто проходит мимо, обратите внимание, сначала col, потом row! ☝️

            local tile_id = mget(col, row)

            for _, tile_sprite in ipairs(ANIMATED_TILES) do
                local animation = tile_sprite.animation_sequence[1]
                if table.contains(animation.frames, tile_id) then
                    table.insert(game.animated_tiles, {x = col, y = row, animation_controller = AnimationController:new(tile_sprite) })
                    goto skip_loop
                end
            end

            if is_tile_a_house(col, row) then
                local already_saved_this_house = false
                for _, house in ipairs(game.houses) do
                    if house.tiles[col] ~= nil and house.tiles[col][row] then
                        already_saved_this_house = true
                        break
                    end
                end
                if already_saved_this_house then
                    -- 2025 still no continue 😭
                    -- Короче, очень интересная история, это называлось continue, но, видимо,
                    -- в новых версиях lua действительно появилось continue, поскольку парсер
                    -- сломался на этом.
                    goto skip_loop
                end

                local new_house = create_a_house_by_bfs_from(col, row)
                table.insert(game.houses, new_house)
                goto skip_loop
            end

            local this_tile_info = nil

            for _, special_tile in ipairs(SPECIAL_TILES) do
                if special_tile.id == tile_id then
                    this_tile_info = {type = special_tile.type, x = x, y = y}
                end
            end

            if this_tile_info ~= nil then
                table.insert(game.tile_info, this_tile_info)

                if game.coordinates_to_tile_info[col] == nil then
                    game.coordinates_to_tile_info[col] = {}
                end
                game.coordinates_to_tile_info[col][row] = #game.tile_info

                -- Вот с этим конечно всё грустно. Нужно убрать этот тайл, иначе
                -- он торчит некрасиво на карте, это не дело. Но если мы его уберем,
                -- мы потеряем информацию, о том, что тут должна спавнится панда.
                -- Поэтому нужно сохранить эту инфу в game.tile_info. Удобно для
                -- дизайнера, неудобно для программиста! Какой выбор сделать?
                --
                -- 🤔 Оставляйте свои мысли в этом комментарии!
                mset(col, row, 0)
            end

            ::skip_loop::
        end
    end
end

-- Превращает спавн-тайлы в игровые объекты в указанной области,
-- (x1, y1) - левый верхний угол, (x2, y2) - правый нижний угол
-- Оба угла включительно.
function game.restart_in_area(tile_x1, tile_y1, tile_x2, tile_y2)
    -- Зачистим предыдущий уровень
    game.current_level = {
        pandas = {},
    }

    spawned_things = {}

    for col = tile_x1, tile_x2 do
        for row = tile_y1, tile_y2 do
            if game.coordinates_to_tile_info[col] ~= nil then
                local idx = game.coordinates_to_tile_info[col][row]
                if idx ~= nil then
                    game.spawn_object_by_tile_info(game.tile_info[idx])
                end
            end
        end
    end

    return spawned_things
end

function game.spawn_object_by_tile_info(tile_info)
    if table.contains(PANDA_TYPE, tile_info.type) then
        table.insert(game.current_level.pandas, Panda:new(tile_info.x, tile_info.y, tile_info.type, false))
    else
        error('Invalid tile info type: ' .. tile_info.type)
    end
end

function game.restart()
    game.player = Player:new()

    -- Вся карта: 240 x 136
    game.restart_in_area(0, 0, 240, 136)

    --for _, tile_info in ipairs(game.tile_info) do
    --    game.spawn_object_by_tile_info(tile_info)
    --end

    -- TODO: Это работает с рестартом?
    -- TriggerTiles.add(TriggerTile:new(24,88,8,8, TriggerActions.dialogue))
    game.bike = Bike:new(190*8, 12*8)
    table.insert(game.triggers, game.bike)

    game.camera = Camera:new(game.player)
    game.parallaxscrolling = ParallaxScrolling:new()
end

function game.update()
    if game.state == GAME_STATE_LANGUAGE_SELECTION then
        if btnp(BUTTON_Z) then
            game.state = GAME_STATE_GAMEPLAY
        end
        if btnp(BUTTON_RIGHT) or btnp(BUTTON_LEFT) then
            if game.language == 'ru' then
                game.language = 'en'
            else
                game.language = 'ru'
            end
        end
        draw_language_selection_boxes()
    elseif game.state == GAME_STATE_PAUSED then
        game.dialog_window:update()
        game.dialog_window:draw()
    elseif game.state == GAME_STATE_RIDING_BIKE then
        game.draw_map()
        game.bike:init_go_away()
        game.bike:go_away()
        game.bike:draw()
    elseif game.state == GAME_STATE_TRIGGERED then
        game.draw_map()
        --for _, dialog_window in ipairs(game.CRUTCH_dialog_window) do
        --    dialog_window:update()
        --end
        for _, dialog_window in ipairs(game.CRUTCH_dialog_window) do
            dialog_window:draw()
        end
    elseif game.state == GAME_STATE_CLICKERMINIGAME then
        game.draw_map()
        game.camera:update()
        -- если хотим чтобы игрок и все остальные не зависали, надо сделать для них особых update
        ClickerMinigame:update()
        ClickerMinigame:draw()
    elseif game.state == GAME_STATE_GAMEPLAY then
        game.dialog_window:update()
        game.player:update()
        game.bike:update()
        TriggerTiles.update()
        game.camera:update()
        for _, panda in ipairs(game.current_level.pandas) do
            panda:update()
        end
        game.parallaxscrolling:update()
        update_psystems()

        game.draw_map()
        for _, panda in ipairs(game.current_level.pandas) do
            panda:draw()
        end
        Effects.draw()
        --game.bike:draw()
        for _, house in ipairs(game.houses) do
            house:draw()
        end
        game.player:draw()
        game.bike:draw()
        TriggerTiles.draw()
        game.dialog_window:draw()
        draw_psystems()
        game.animate_tiles()
        Debug.draw()
    else
        error('Invalid game state!')
    end

    Time.update()
end

function game.animate_tiles()
    for _, animated_tile in ipairs(game.animated_tiles) do
        local animation = animated_tile.animation_controller
        animation:next_frame()
        mset(animated_tile.x, animated_tile.y, animation:current_frame())
    end
end

function game.draw_map()
    -- Это последний кусочек легаси, помимо Body, что остался
    -- из бумеранга. Я его не очень понимаю и не слишком хочу
    -- трогать. Это будет памятник нашему труду над бумерангом 🪃

    
    -- а потрогать реликвию видимо придётся...


    local cx = game.camera.x
    local cy = game.camera.y
    local tx = math.floor(cx/8)
    local ty = math.floor(cy/8)

    local gmx = tx - math.floor(SCREEN_WIDTH / 16)
    local gmsx = 8 * tx - cx
    local gmy = ty - math.floor(SCREEN_HEIGHT / 16)
    local gmsy = math.floor(8 * ty - cy)
    cls(0)
    game.parallaxscrolling:draw()
    map(gmx, gmy, 31, 18, gmsx, gmsy,0)
end
