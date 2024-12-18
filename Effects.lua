-- Эффекты - спрайты на какой-то позиции, которые проигрывают один раз свою анимацию и останавливаются

Effects = {
    effects = {},
    insert_index = 1,
}

-- Одновременно могут проигрываться 64 эффекта.
-- Число взято с потолка, просто вот мне так захотелось.
for i = 1, 64 do
    Effects.effects[i] = {x=-100,y=-100, sprite=TRANSPARENT_SPRITE, flip=false}
end

function Effects.add(x, y, sprite, flip)
    local effect = Effects.effects[Effects.insert_index]
    effect.x = x
    effect.y = y
    effect.sprite = sprite:copy()
    effect.flip = flip
    Effects.insert_index = Effects.insert_index % #Effects.effects + 1
end

function Effects.draw()
    for _, effect in ipairs(Effects.effects) do
        local sprite = effect.sprite
        if not sprite:animation_ended() then
            local tx, ty = game.camera_window:transform_coordinates(effect.x, effect.y)
            sprite:draw(tx, ty, effect.flip)
            sprite:next_frame()
        end
    end
end
