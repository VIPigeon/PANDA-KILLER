
-- local minlife_blood = 5000
local minlife_blood = 1000  -- censore
-- local maxlife_blood = 40000
local maxlife_blood = 4000  -- censore

local minlife_fur = 1000
local maxlife_fur = 3000

local minstartsize = 1
local maxstartsize = 2

local minendsize = 0.5
local maxendsize = 0.5

local minstartvx = 1
local maxstartvx = 3
local minstartvy = -3
local maxstartvy = -2

-- local default_blood_amount = 100
local default_blood_amount = 5  -- censore

-- local default_fur_amount = 20
local default_fur_amount = 5  -- censore

local fx = 0
local fy = 0.15

local zoneminx = 0
local zonemaxx = 240
local zoneminy = 100
local zonemaxy = 127

--local blood_colors = {6, 8, 2, 9}
--local blood_colors = {6, 4, 8, 12}
local blood_colors = {6, 4, 8}
local white_colors = {15}
local black_colors = {13}

-- Проверка коллизий + растекание крови
function affect_blood_collision(particle, params)
    if particle.vx == 0 and particle.vy == 0 then return end

    if params.color_type == "blood" then
        local next_y = particle.y + particle.vy
        local tile_x, tile_y = math.floor(particle.x / 8), math.floor(particle.y / 8)
        local tile_id = mget(tile_x, tile_y)
        if is_tile_solid(tile_id) then
            particle.vx = particle.vx * 0.2
            particle.vy = 0  
            particle.fy = 0  
            particle.vy = 0.001 --Это для стекания. Очень сильно зависит от времени жизни (меняешь время, поменяй и данное значение😊)
        end
    else
        -- Это для меха(он просто падает на землю, никуда не впитывается)
        local next_x = particle.x + particle.vx
        local tile_x, tile_y = math.floor(next_x / 8), math.floor(particle.y / 8)
        local tile_id = mget(tile_x, tile_y)
        if is_tile_solid(tile_id) then
            particle.vx = -0.1 * particle.vx
            particle.fx = 0
        end  

        local next_y = particle.y + particle.vy
        local tile_x, tile_y = math.floor(particle.x / 8), math.floor(next_y / 8)
        local tile_id = mget(tile_x, tile_y)
        if is_tile_solid(tile_id) then
            particle.vx = particle.vx * 0.6
            particle.vy = 0  
            particle.fy = 0  
        end
    end
end

-- function affect_blood_water(particle, params)
--     if particle.vx == 0 and particle.vy == 0 then return end
--     if not params.color_type == "blood" then return end

--     local next_y = particle.y + particle.vy
--     local tile_x, tile_y = math.floor(particle.x / 8), math.floor(particle.y / 8)
--     local tile_id = mget(tile_x, tile_y)

--     if is_tile_water(tile_id) then
            
--     end
-- end

function create_particles(x, y, orientation, minlife, maxlife, amount, colors, color_type)
    local ps = make_psystem(minlife, maxlife, minstartsize, maxstartsize, minendsize, maxendsize)

    table.insert(ps.emittimers, {
        timerfunc = emittimer_burst,
        params = { num = amount }
    })
    
    if orientation == 1 then
        table.insert(ps.emitters, {
            emitfunc = emitter_point,
            params = { x = x, y = y, minstartvx = minstartvx, maxstartvx = maxstartvx, minstartvy = minstartvy, maxstartvy = maxstartvy }
        })
    else
        table.insert(ps.emitters, {
            emitfunc = emitter_point,
            params = { x = x, y = y, minstartvx = -1*minstartvx, maxstartvx = -1*maxstartvx, minstartvy = minstartvy, maxstartvy = maxstartvy }
        })
    end
    
    table.insert(ps.drawfuncs, {
        drawfunc = draw_ps_pixel,
        params = { colors = colors }
    })
    
    table.insert(ps.affectors, {
        affectfunc = affect_force,
        params = { fx = fx, fy = fy}
    })
    
    table.insert(ps.affectors, {
        affectfunc = affect_blood_collision,
        params = {color_type = color_type}
    })

    -- table.insert(ps.affectors, {
    --     affectfunc = affect_blood_water,
    --     params = {color_type = color_type}
    -- })
    
    return ps
end

function create_blood(x, y, orientation, amount_of_blood, amount_of_fur)
    amount_of_blood = amount_of_blood or default_blood_amount
    amount_of_fur = amount_of_fur or default_fur_amount
    
    create_particles(x, y, orientation, minlife_blood, maxlife_blood, amount_of_blood, blood_colors, "blood")
    
    create_particles(x, y, orientation, minlife_fur, maxlife_fur, amount_of_fur, white_colors, "white")
    
    create_particles(x, y, orientation, minlife_fur, maxlife_fur, amount_of_fur, black_colors, "black")
end

