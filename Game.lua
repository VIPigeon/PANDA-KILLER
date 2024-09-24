game = {}

function game.debug_features_init()

end

function game.init()
    if GAMEMODE == GAMEMODE_DEBUG then
       game.debug_features_init() 
    end
end

function game.update()
    local player = game.player
    local pandas = game.pandas
    
    player:update()
    entities:update(pandas)

    map()
    player:draw()
    entities:draw(pandas)

    -- Обязательно должно выполняться последним
    Time.update()
end
