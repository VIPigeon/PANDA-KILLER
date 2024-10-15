game = {
    status = true
}

function game.debug_features_init()

end

function game.init()
    game.player = player
    game.pandas = {Panda:new(156,104), Panda:new(10,10), Panda:new(20,10)}
    game.triggers = {TriggerTile:new(20,90,10,10)}
    game.dialog_window = DialogWindow:new(100,50,"defeat\nato😲")

    local camera_rect = Rect:new(player.x - 16, player.y - 8, CAMERA_WINDOW_WIDTH, CAMERA_WINDOW_HEIGHT)
    game.camera_window = CameraWindow:new(camera_rect, player, 8, 8)

    if GAMEMODE == GAMEMODE_DEBUG then
       game.debug_features_init() 
    end
end

function game.update()
    if not game.status then
        game.dialog_window:update()
        game.dialog_window:draw()
        return
    end
    local player = game.player
    local dialog_window = game.dialog_window
    local camera_window = game.camera_window
    local pandas = game.pandas
    local triggers = game.triggers

    entities:update(pandas)
    entities:update(triggers)
    dialog_window:update()
    player:update()
    camera_window:update()

    update_psystems()

    map(camera_window.gm.x, camera_window.gm.y, 31, 18, camera_window.gm.sx, camera_window.gm.sy)
    entities:draw(pandas)
    entities:draw(triggers)
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
