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

function Effects.spawn_epic_parry_particles(x, y, orientation)
    local minlife = 3000
    local maxlife = 5000
    local minstartsize = 1
    local maxstartsize = 2
    local minendsize = 0.5
    local maxendsize = 0.5
    local ps = make_psystem(minlife, maxlife, minstartsize, maxstartsize, minendsize, maxendsize)

    local amount = 10
    table.insert(ps.emittimers, {
        timerfunc = emittimer_burst,
        params = { num = amount }
    })
    

    local minstartvx = 0.1
    local maxstartvx = 1
    local minstartvy = -2
    local maxstartvy = -1
    if orientation == 1 then
        table.insert(ps.emitters, {
            emitfunc = emitter_point,
            params = {
                x = x, y = y, minstartvx = minstartvx, maxstartvx = maxstartvx, minstartvy = minstartvy, maxstartvy = maxstartvy
            }
        })
    else
        table.insert(ps.emitters, {
            emitfunc = emitter_point,
            params = {
                x = x, y = y, minstartvx = -1*minstartvx, maxstartvx = -1*maxstartvx, minstartvy = minstartvy, maxstartvy = maxstartvy
            }
        })
    end

    local colors = {15}
    table.insert(ps.drawfuncs, {
        drawfunc = draw_ps_pixel,
        params = { colors = colors }
    })

    local gravity = 0.15
    table.insert(ps.affectors, {
        affectfunc = affect_force,
        params = { fx = 0, fy = gravity}
    })
    
    return ps
end
