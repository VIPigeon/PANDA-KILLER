game = {}

function game.update()
    local player = game.player
    player:update()

    map()
    player:draw()

    -- Обязательно должно выполняться последним
    Time.update()
end
