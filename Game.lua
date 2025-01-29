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
    game.pandas = {}
    game.dialog_window = DialogWindow:new(100,50,"dcs")

    --Pandas.add(Panda:new(130,95))
    Pandas.add(Panda:new(60,95))
    --Pandas.add(Panda:new(150,48))
    game.pandas = Pandas.alive_pandas

    local camera_rect = Rect:new(player.x - 16, player.y - 8, CAMERA_WIDTH, CAMERA_HEIGHT)
    game.camera = Camera:new(camera_rect, player, 8, 8)
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

    local player = game.player
    local dialog_window = game.dialog_window
    local camera = game.camera
    local pandas = game.pandas

    dialog_window:update()
    player:update()
    camera:update()
    Pandas.update()

    update_psystems()

    map(camera.gm.x, camera.gm.y, 31, 18, camera.gm.sx, camera.gm.sy)
    Pandas.draw()
    Effects.draw()
    player:draw()
    dialog_window:draw()
    local bx, by = camera:transform_coordinates(player.x, player.y)
    draw_blood(bx,by,-1)
    draw_psystems()

    -- Обязательно должно выполняться последним
    Time.update()
end
