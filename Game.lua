game = {}
local dialog_window = DialogWindow:new(100,50,"dhslj\naio")

function game.debug_features_init()

end

function game.init()
    if GAMEMODE == GAMEMODE_DEBUG then
       game.debug_features_init() 
    end
end

local replic = 'СЪЕШЬ ЕЩЁ ЭТИХ МЯГКИХ ФРАНЦУЗСКИХ\nБУЛОК ДА ВЫПЕЙ ЧАЯ'
local translation = russian_to_translit(replic)

function game.update()
    local player = game.player
    local pandas = game.pandas
    
    player:update()
    entities:update(pandas)

    dialog_window:update()

    update_psystems()
    
    map()
    local width = font(translation, 0, 40, 0, 4, 7, false, 1)
    player:draw()
    entities:draw(pandas)

    dialog_window:draw()

    draw_blood(80,80,-1)

    draw_psystems()

    -- Обязательно должно выполняться последним
    Time.update()
end
