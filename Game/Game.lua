game = {
    state = GAME_STATE_LANGUAGE_SELECTION,
    language = 'ru',
    CRUTCH_dialog_window = {},
    animated_tiles = {},
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
    game.collect_entity_spawn_information_from_tiles()
    game.restart()
end

function game.collect_entity_spawn_information_from_tiles()
    game.entity_spawn_info = {}

    for row = 0, WORLD_TILEMAP_HEIGHT do
        for col = 0, WORLD_TILEMAP_WIDTH do
            local x, y = Basic.tile_to_world(col, row)

            local tile_id = mget(col, row)
            if tile_id == SPECIAL_TILES.panda_spawn then
                table.insert(game.entity_spawn_info, {type = PANDA_TYPE.basic, x = x, y = y})
                mset(col, row, 0)
            elseif tile_id == SPECIAL_TILES.chilling_panda_spawn then
                table.insert(game.entity_spawn_info, {type = PANDA_TYPE.chilling, x = x, y = y})
                mset(col, row, 0)
            elseif tile_id == SPECIAL_TILES.agro_panda_spawn then
                trace('nonono!')
                table.insert(game.entity_spawn_info, {type = PANDA_TYPE.agro, x = x, y = y})
                mset(col, row, 0)
            else
                for _, tile_sprite in ipairs(ANIMATED_TILES) do
                    local animation = tile_sprite.animation_sequence[1]
                    if table.contains(animation.frames, tile_id) then
                        table.insert(game.animated_tiles, {x = col, y = row, animation_controller = AnimationController:new(tile_sprite) })
                    end
                end
            end
        end
    end
end

function game.restart()
    game.player = Player:new()

    game.pandas = {}
    for _, entity_info in ipairs(game.entity_spawn_info) do
        if entity_info.type == PANDA_TYPE.basic then
            table.insert(game.pandas, Panda:new(entity_info.x, entity_info.y, PANDA_TYPE.basic, false))
        elseif entity_info.type == PANDA_TYPE.chilling then
            table.insert(game.pandas, Panda:new(entity_info.x, entity_info.y, PANDA_TYPE.chilling, false))
        elseif entity_info.type == PANDA_TYPE.agro then
            table.insert(game.pandas, Panda:new(entity_info.x, entity_info.y, PANDA_TYPE.agro, false))
        else
            error('Invalid entity type: ' .. entity_info.type)
        end
    end

    -- TODO: Это работает с рестартом?
    -- TriggerTiles.add(TriggerTile:new(24,88,8,8, TriggerActions.dialogue))
    game.bike = Bike:new(193*8, 113*8)
    TriggerTiles.add(game.bike)
    game.triggers = TriggerTiles.Tiles

    game.camera = Camera:new(game.player)
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
        --for _, dialog_window in ipairs(game.CRUTCH_dialog_window) do
        --    dialog_window:update()
        --end
        for _, dialog_window in ipairs(game.CRUTCH_dialog_window) do
            dialog_window:draw()
        end
        game.bike:update()
        game.bike:draw()
    elseif game.state == GAME_STATE_GAMEPLAY then
        game.dialog_window:update()
        game.player:update()
        game.bike:update()
        TriggerTiles.update()
        game.camera:update()
        for _, panda in ipairs(game.pandas) do
            panda:update()
        end
        update_psystems()

        game.draw_map()
        for _, panda in ipairs(game.pandas) do
            panda:draw()
        end
        Effects.draw()
        --game.bike:draw()
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
    local cx = game.camera.x
    local cy = game.camera.y
    local tx = math.floor(cx/8)
    local ty = math.floor(cy/8)

    local gmx = tx - math.floor(SCREEN_WIDTH / 16)
    local gmsx = 8 * tx - cx
    local gmy = ty - math.floor(SCREEN_HEIGHT / 16)
    local gmsy = math.floor(8 * ty - cy)
    -- cls(13)
    map(gmx, gmy, 31, 18, gmsx, gmsy)
end
