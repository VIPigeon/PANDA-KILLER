game = {
    state = GAME_STATE_LANGUAGE_SELECTION,
    language = 'en',
}

if DEV_MODE_ENABLED then
    game.state = GAME_STATE_GAMEPLAY
end

function game.init()
    -- А что использовать как сид 🤔? `os.time()` в тике недоступен
    -- math.randomseed(69420)

    game.player = player
    game.dialog_window = DialogWindow:new(100,50,"dcs")

    game.pandas = {}
    table.insert(game.pandas, Panda:new(60, 95))
    table.insert(game.pandas, Panda:new(130, 95))
    table.insert(game.pandas, Panda:new(150, 48))

    game.camera = Camera:new(player)
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
        return
    end

    if game.state == GAME_STATE_PAUSED then
        game.dialog_window:update()
        game.dialog_window:draw()
        Time.update()
        return
    end

    game.dialog_window:update()
    game.player:update()
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
    game.player:draw()
    game.dialog_window:draw()
    local bx, by = game.camera:transform_coordinates(game.player.x, game.player.y)
    draw_blood(bx, by, -1)
    draw_psystems()
    Debug.draw()

    -- Обязательно должно выполняться последним
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
