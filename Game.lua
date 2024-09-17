game = {}

function game.update()
    local player = game.player
    player:update()

    local dialog_window = game.dialog_window
    dialog_window.text = "SKNKnklsn\n idan"
    
    map()
    player:draw()

    dialog_window:draw(100,100)

    -- Обязательно должно выполняться последним
    Time.update()
end
