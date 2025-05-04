local minlife_leaves = 1000
local maxlife_leaves = 2000

local minstartsize = 1
local maxstartsize = 2

local minendsize = 0.5
local maxendsize = 0.5

local minstartvx = 1
local maxstartvx = 3
local minstartvy = -3
local maxstartvy = -2

local default_leaves_amount = 1

local fx = 0
local fy = 0.15

local leaves_color_1 = {5}
local leaves_color_2 = {11}

function affect_leaves_collision(particle, params)
    if particle.vx == 0 and particle.vy == 0 then return end

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

local function create_particles(x, y, orientation, minlife_leaves, maxlife_leaves, amount, colors)
    local ps = make_psystem(minlife_leaves, maxlife_leaves, minstartsize, maxstartsize, minendsize, maxendsize)

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
        params = {}
    })
    
    return ps
end

function create_leaves(x, y, orientation, amount_of_leaves)
    amount_of_leaves = amount_of_leaves or default_leaves_amount
    
    create_particles(x, y, orientation, minlife_leaves, maxlife_leaves, amount_of_leaves, leaves_color_1)
    
    create_particles(x, y, orientation, minlife_leaves, maxlife_leaves, amount_of_leaves, leaves_color_2)
end

function leaves_spread(hit_x, hit_y, x, y)
    local px = x * 8 + 4
    local py = y * 8 + 4
    if hit_x < 0 then
        create_leaves(px, py, -1)
    elseif hit_x > 0 then
        create_leaves(px, py, 1)
    else
        create_leaves(px, py, -1)
        create_leaves(px, py, 1)
    end
end
