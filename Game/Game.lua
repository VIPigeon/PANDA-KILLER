game = {
    state = GAME_STATE_LANGUAGE_SELECTION,
    language = 'en',
    CRUTCH_dialog_window = {},
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
    game.restart()
end

function game.restart()
    game.player = Player:new(PLAYER_SPAWNPOINT_X, PLAYER_SPAWNPOINT_Y)

    game.pandas = {
        Panda:new(60, 95, true),
        Panda:new(130, 95, false),
        Panda:new(150, 48, false),
    }

    -- TODO: Это работает с рестартом?
    -- TriggerTiles.add(TriggerTile:new(24,88,8,8, TriggerActions.dialogue))
    --game.bike = Bike:new(60-8, 95-8)
    -- TriggerTiles.add(game.bike)
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
        trace('bikeini')
        game.draw_map()
        for _, dialog_window in ipairs(game.CRUTCH_dialog_window) do
            dialog_window:update()
        end
        for _, dialog_window in ipairs(game.CRUTCH_dialog_window) do
            dialog_window:draw()
        end
    elseif game.state == GAME_STATE_TRIGGERED then
        trace('triggered')
        game.draw_map()
        for _, dialog_window in ipairs(game.CRUTCH_dialog_window) do
            dialog_window:update()
        end
        for _, dialog_window in ipairs(game.CRUTCH_dialog_window) do
            dialog_window:draw()
        end
    elseif game.state == GAME_STATE_CLICKERMINIGAME then
        trace('clickerd')
        ClickerMinigame:update()
        ClickerMinigame:draw()
    elseif game.state == GAME_STATE_GAMEPLAY then
        game.dialog_window:update()
        --game.bike:update()
        game.player:update()
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
        TriggerTiles.draw()
        game.dialog_window:draw()
        local bx, by = game.camera:transform_coordinates(game.player.x, game.player.y)
        draw_blood(bx, by, -1)
        draw_psystems()
        Debug.draw()
    else
        error('Invalid game state!')
    end

    Time.update()
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
    map(gmx, gmy, 31, 18, gmsx, gmsy)
end
