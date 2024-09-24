game = {}
local dialog_window = DialogWindow:new()

function game.update()
    local player = game.player
    player:update()

    dialog_window:update(100,50,"dhslj\naio")
    
    map()
    player:draw()

    dialog_window:draw()
    dialog_window:close()

    -- Обязательно должно выполняться последним
    Time.update()
end
