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
    cur_level = {},
    current_level_index = 1,
    levels = {
        {tile_x1 = 0, tile_y1 = 0, tile_x2 = 119, tile_y2 = 16, player_x = PLAYER_SPAWNPOINT_X, player_y = PLAYER_SPAWNPOINT_Y},
        {tile_x1 = 0, tile_y1 = 17, tile_x2 = 99, tile_y2 = 32, player_x = 0, player_y = 30*8}, 
        {tile_x1 = 0, tile_y1 = 34, tile_x2 = 62, tile_y2 = 49, player_x = 3*8, player_y = 42*8},
        {tile_x1 = 0, tile_y1 = 51, tile_x2 = 89, tile_y2 = 89, player_x = 10*8, player_y = (51+11)*8},
        {tile_x1 = 90, tile_y1 = 51, tile_x2 = 119, tile_y2 = 89, player_x = 94*8, player_y = 75*8},
        {tile_x1 = 120, tile_y1 = 51, tile_x2 = 179, tile_y2 = 51+16, player_x = 120*8, player_y = (51+3)*8},
        {tile_x1 = 180, tile_y1 = 51, tile_x2 = 209, tile_y2 = 51+16, player_x = 180*8, player_y = (51+7)*8},
    },
}

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
                --
                -- 
                -- Я не чёрт, но тоже тут ногу сломал. Долой дизайнеров и манагеров. Анон

                mset(col, row, 0)

                if this_tile_info.type == PANDA_TYPE.house_maid then
                    mset(col, row, 74)
                end
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
        min_x = tile_x1,
        min_y = tile_y1,
        max_x = tile_x2,
        max_y = tile_y2,
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
        table.insert(game.current_level.pandas, Panda:new(tile_info.x, tile_info.y, tile_info.type))
    else
        error('Invalid tile info type: ' .. tile_info.type)
    end
end

function game.all_pandas_dead()
    if not NEED_TO_KILL_ALL_PANDAS_ON_LEVEL then
        return true
    end
    if not game.cur_level or not game.current_level.pandas then
        return false 
    end

    for _, panda in ipairs(game.current_level.pandas) do
        if panda.health > 0 then
            return false
        end
    end
    return true
end

function game.load_current_level()
    game.cur_level = game.levels[game.current_level_index]
    local level = game.levels[game.current_level_index]
    game.restart_in_area(level.tile_x1, level.tile_y1, level.tile_x2, level.tile_y2)
    game.player.x = level.player_x
    game.player.y = level.player_y
    game.camera:set_position(game.player.x, game.player.y)
end

function game.restart()
    game.player = Player:new()
    game.camera = Camera:new(game.player)
    game.parallaxscrolling = ParallaxScrolling:new()

    -- game.current_level_index = 1
    -- спасибо хорошему дизайну кода за мой самый короткий фикс во всем проекте
    game.load_current_level()

    --for _, tile_info in ipairs(game.tile_info) do
    --    game.spawn_object_by_tile_info(tile_info)
    --end

    -- TODO: Это работает с рестартом?
    -- TriggerTiles.add(TriggerTile:new(24,88,8,8, TriggerActions.dialogue))
    game.bike = Bike:new(190*8, 12*8)
    table.insert(game.triggers, game.bike)

    if SKIP_CUTSCENE then
        game.state = GAME_STATE_GAMEPLAY
    else
        cutscene:init()
    end
    game.state = GAME_STATE_CUTSCENE
end

slow_time = false
microslow_time = false
microslow_time_counter = 0
slow_time_counter = 0

function game.update()
    if DISCLAIMER then
        cls(0)
        font("DISCLAIMER", 35, 10, 15, 0, nil, nil, 2)
        local step = 10
        local cur_y = 40
        local cur_x = 25
        font("NO ANIMALS WERE HARMED", cur_x, cur_y, 15, 0, nil)
        cur_y = cur_y + step
        font("DURING THE DEVELOPMENT", cur_x, cur_y, 15, 0, nil)
        cur_y = cur_y + step
        font("OF THIS GAME", cur_x, cur_y, 15, 0, nil)
        cur_y = cur_y + step
        font("THE DEVELOPERS CONDEMN", cur_x, cur_y, 15, 0, nil)
        cur_y = cur_y + step
        font("VIOLENCE AGAINST ANIMALS", cur_x, cur_y, 15, 0, nil)
        cur_y = cur_y + step
        font("AND ENCOURAGE EVERYONE", cur_x, cur_y, 15, 0, nil)
        cur_y = cur_y + step
        font("TO TREAT THEM WITH", cur_x, cur_y, 15, 0, nil)
        cur_y = cur_y + step
        font("RESPECT AND CARE", cur_x, cur_y, 15, 0, nil)
        return
    end

    -- гордо возвышается над игрой
    -- выбрать путь предлагает
    -- меню 🗻
    -- и дерзкий draw_map - не мешает
    GameMenu:update()

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
        GameMenu:draw()
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
        if SKIP_CUTSCENE then
           game.state = GAME_STATE_GAMEPLAY
        else
            game.camera:update()
            cutscene:update()
            cutscene:draw()
            -- панда сама набрасывается на игрока
            -- ...
            -- начинается миниигра.
        end
    elseif game.state == GAME_STATE_CLICKERMINIGAME then
        -- game.draw_map()
        game.camera:update()
        -- если хотим чтобы игрок и все остальные не зависали, надо сделать для них особых update
        ClickerMinigame:update()
        ClickerMinigame:draw()
    elseif game.state == GAME_STATE_GAMEPLAY then
        local level = game.levels[game.current_level_index]
        update_psystems()  -- перенес наверх для slow_time
        if slow_time then
            slow_time_counter = slow_time_counter + 1
            if slow_time_counter >= 16 then
                slow_time_counter = 0
                slow_time = false
            end
            if slow_time_counter % 10 ~= 0 then
                goto draw
            end
        end
        --if microslow_time then
        --    microslow_time_counter = microslow_time_counter + 1
        --    if microslow_time_counter >= 2 then
        --        microslow_time_counter = 0
        --        microslow_time = false
        --    end
        --    if microslow_time_counter % 10 ~= 0 then
        --        goto end_of_loop
        --    end
        --end
        game.dialog_window:update()
        game.player:update()
        game.bike:update()
        TriggerTiles.update()
        game.camera:update()
        for _, panda in ipairs(game.current_level.pandas) do
            panda:update()
        end
        game.parallaxscrolling:update()

        if game.player.x >= game.cur_level.tile_x2 * 8 and not game.all_pandas_dead() then
            game.player.x = game.cur_level.tile_x2 * 8 - 1
        end

        if game.cur_level and game.all_pandas_dead() and game.player.x >= game.cur_level.tile_x2 * 8 or keyp(KEY_P) then
            game.current_level_index = game.current_level_index + 1
            if game.current_level_index <= #game.levels then
                game.load_current_level()
            else
                -- error('ALARM! NO LEVELS LEFT!')
                error('You WIN the game! Congragulations <3 <3 <3')
            end
        end

        ::draw::
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

        if game.all_pandas_dead() then
            local char_width = 8
            local char_height = 5
            local text_len = string.len(localize(TEXT.GO))
            draw_text_centered_at_x(localize(TEXT.GO), SCREEN_WIDTH - text_len * char_width, 0, char_width, char_height, true, 2)
        end
    else
        error('Invalid game state!')
    end

::end_of_loop::
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
    --
    -- Что гораздо важнее, это нужно унести, чтобы не было такого грязнокода прямо в Game.
    -- То есть с чего это основная логика отрисовки карты, которая работает 99% времени игры
    -- оказалась под каким-то if-ом? Так не должно быть 😡
    if game.scale == 1 then
        local tx = math.floor(cx / 8)
        local ty = math.floor(cy / 8)
        local gmx = tx - math.floor(SCREEN_WIDTH / 16)
        local gmsx = 8 * tx - cx

        local gmy = ty - math.floor(SCREEN_HEIGHT / 16)
        local gmsy = math.floor(8 * ty - cy)

        cls(0)
        game.parallaxscrolling:draw()
        map(gmx, gmy, 31, 18, gmsx, gmsy, 0)
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

    cls(0)
    map(gmx, gmy, math.floor(30 / game.scale) , math.floor(17 / game.scale) + 1, gmsx, gmsy, -1, game.scale)
    game.parallaxscrolling:draw()
end
