game = {}

Time = require 'Time'
require 'Constants'
game.player = require 'Player'

function game.update()
    local player = game.player
    player:update()

    map()
    player:draw()

    -- Обязательно должно выполняться последним
    Time.update()
end
