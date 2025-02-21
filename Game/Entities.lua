-- Линукс Торбольтс никогда не ошибается! 🐧😎
-- Clean Code (tm) 🧼

Entities = {}

function Entities.update()
    for _, entity in ipairs(game.entities) do
        entity:update()
    end
end

function Entities.draw()
    for _, entity in ipairs(game.entities) do
        entity:draw()
    end
end
