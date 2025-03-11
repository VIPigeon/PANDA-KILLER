game = {
    state = GAME_STATE_LANGUAGE_SELECTION,
    language = 'ru',
    CRUTCH_dialog_window = {},
    animated_tiles = {},
    triggers = {},
    scale = 1,
}

if DEV_MODE_ENABLED then
    game.state = GAME_STATE_CUTSCENE
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
            table.insert(game.pandas, Panda:new(entity_info.x, entity_info.y, PANDA_TYPE.basic, true))
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
    game.bike = Bike:new(190*8, 12*8)
    table.insert(game.triggers, game.bike)

    game.camera = Camera:new(game.player)
end

function game.update()
    if game.state == GAME_STATE_LANGUAGE_SELECTION then
        if btnp(BUTTON_Z) then
            game.state = GAME_STATE_CUTSCENE
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
    elseif game.state == GAME_STATE_CUTSCENE then
        trace('cutscene')
        -- панда сама набрасывается на игрока
        -- ...
        -- начинается миниигра.
    elseif game.state == GAME_STATE_CLICKERMINIGAME then
        --trace('clickerd')
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

    
    -- а потрогать реликвию видимо придётся...

    local cx = game.camera.x
    local cy = game.camera.y

    -- Да, в целом, это можно унести обратно в миниигру и выиграть 1 if of iffectiveness
    if game.scale == 1 then
        local tx = math.floor(cx / 8)
        local ty = math.floor(cy / 8)
        local gmx = tx - math.floor(SCREEN_WIDTH / 16)
        local gmsx = 8 * tx - cx
        
        local gmy = ty - math.floor(SCREEN_HEIGHT / 16)
        local gmsy = math.floor(8 * ty - cy)
        
        -- cls(13)
        
        map(gmx, gmy, 31, 18, gmsx, gmsy)
        return
    end

    -- Меньше тайлов - меньше fps!
    -- Да, при движении это работать не будет, надо будет масштабировать и координаты камеры
    -- но для статичной картинки всё работает нормально. Так что сидите и не возмущайтесь
    local tx = math.floor(cx / (8))
    local ty = math.floor(cy / (8))

    local gmx = tx - math.floor((SCREEN_WIDTH / (16 * game.scale) ))
    local gmsx = 0 --math.floor((8 * tx - cx * game.scale) )

    local gmy = ty - math.floor((SCREEN_HEIGHT / (16 * game.scale) ))
    local gmsy = 0 --math.floor((8 * ty - cy * game.scale) )
    
    map(gmx, gmy, math.floor(30 / game.scale) + 1, math.floor(17 / game.scale) + 1, gmsx, gmsy, -1, game.scale)

    -- for x = gmx, gmx + math.floor(30 / game.scale) + 1 do
    --     for y = gmy, gmy + math.floor(17 / game.scale) + 1 do
    --         local tile_id = mget(x, y)
    --         -- trace(tile_id)

    --         local screen_x = (x * 8 - cx) * game.scale + SCREEN_WIDTH / 2
    --         local screen_y = (y * 8 - cy) * game.scale + SCREEN_HEIGHT / 2
    --         --cls()

    --         -- Отрисовка тайла с масштабом
    --         spr(tile_id, screen_x, screen_y, 0, game.scale)
    --     end
    -- end
end
