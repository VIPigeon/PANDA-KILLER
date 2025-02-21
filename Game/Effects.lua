--[[

Эффекты -- спрайты, которые проигрывают один раз свою анимацию и исчезают

--]]

Effects = {
    effects = {},
    insert_index = 1,
}

-- Одновременно могут проигрываться 64 эффекта.
-- Число взято с потолка, просто вот мне так захотелось.
for i = 1, 64 do
    Effects.effects[i] = {x=-100,y=-100, animation_controller=AnimationController:new(SPRITES.transparent), flip=false}
end

function Effects.add(x, y, sprite, flip)
    local effect = Effects.effects[Effects.insert_index]
    effect.x = x
    effect.y = y
    effect.animation_controller:set_sprite(sprite)
    effect.flip = flip
    Effects.insert_index = Effects.insert_index % #Effects.effects + 1
    return effect
end

function Effects.draw()
    for _, effect in ipairs(Effects.effects) do
        local animation_controller = effect.animation_controller
        if not animation_controller:animation_ended() then
            local tx, ty = game.camera:transform_coordinates(effect.x, effect.y)
            animation_controller:draw(tx, ty, effect.flip)
            animation_controller:next_frame()
        end
    end
end
