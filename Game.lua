game = {
    status = true
}

function game.debug_features_init()

end

function game.init()
    -- А что использовать как сид 🤔? `os.time()` в тике недоступен
    -- math.randomseed(69420)

    game.player = player
    game.dialog_window = DialogWindow:new(100,50,"defeat\nato😲")

    TriggerTiles.add(TriggerTile:new(24,88,8,8, TriggerActions.dialogue))
    game.lol = Bike:new(180, 88)
    TriggerTiles.add(game.lol)
    Pandas.add(Panda:new(130,95, true))
    --Pandas.add(Panda:new(60,95))
    --Pandas.add(Panda:new(150,48))
    game.pandas = Pandas.alive_pandas
    game.triggers = TriggerTiles.Tiles

    local camera_rect = Rect:new(player.x - 16, player.y - 8, CAMERA_WINDOW_WIDTH, CAMERA_WINDOW_HEIGHT)
    game.camera_window = CameraWindow:new(camera_rect, player, 8, 8)

    if GAMEMODE == GAMEMODE_DEBUG then
       game.debug_features_init() 
    end
end

function game.update()
    local player = game.player
    local dialog_window = game.dialog_window
    local camera_window = game.camera_window
    local pandas = game.pandas
    local triggers = game.triggers

    if not game.status then
        game.dialog_window:update()
        map(camera_window.gm.x, camera_window.gm.y, 31, 18, camera_window.gm.sx, camera_window.gm.sy)
        game.dialog_window:draw()
        Time.update()
        trace('hahaha')
        return
    end

    dialog_window:update()
    player:update()
    camera_window:update()
    Pandas.update()
    TriggerTiles.update()

    update_psystems()

    map(camera_window.gm.x, camera_window.gm.y, 31, 18, camera_window.gm.sx, camera_window.gm.sy)
    Pandas.draw()
    TriggerTiles.draw()
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

function game.drawSprite(object, x, y, sprite)
    if object.x == nil or object.y == nil then
        error('drawing an illegal object: ' .. tostring(object))
    end

    if object.sprite == nil then
    end
end
