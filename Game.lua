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

    local camera_rect = Rect:new(player.x - 16, player.y - 8, CAMERA_WINDOW_WIDTH, CAMERA_WINDOW_HEIGHT)
    game.camera_window = CameraWindow:new(camera_rect, player, 8, 8)
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
    local camera_window = game.camera_window
    local pandas = game.pandas

    --entities:update(pandas)
    dialog_window:update()
    player:update()
    camera_window:update()
    Pandas.update()

    update_psystems()

    map(camera_window.gm.x, camera_window.gm.y, 31, 18, camera_window.gm.sx, camera_window.gm.sy)
    Pandas.draw()
    Effects.draw()
    --entities:draw(pandas)
    player:draw()
    dialog_window:draw()
    local bx, by = camera_window:transform_coordinates(player.x, player.y)
    draw_blood(bx,by,-1)
    draw_psystems()

    -- Обязательно должно выполняться последним
    Time.update()
end
