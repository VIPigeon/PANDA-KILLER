
local minlife = 5000
local maxlife = 10000

local minstartsize = 1
local maxstartsize = 2

local minendsize = 0.5
local maxendsize = 0.5

local num = 100

local minstartvx = 1
local maxstartvx = 3
local minstartvy = -3
local maxstartvy = -2

local fx = 0
local fy = 0.15

local zoneminx = 0
local zonemaxx = 240
local zoneminy = 100
local zonemaxy = 127

local blood_colors = {6, 8, 2, 9}

function leave_blood_stain(x, y)
    pix(x, y, blood_colors[math.random(#blood_colors)])
end

-- Проверка коллизий + растекание крови
function affect_blood_collision(particle, params)
    if particle.vx == 0 and particle.vy == 0 then return end

    local next_x, next_y = particle.x + particle.vx, particle.y + particle.vy
    local tile_x, tile_y = math.floor(next_x / 8), math.floor(next_y / 8)
    local tile_id = mget(tile_x, tile_y)

    if is_tile_solid(tile_id) then
        particle.vx, particle.vy = 0, 0  
        particle.fx, particle.fy = 0, 0  
        if math.random() < 0.3 then
            leave_blood_stain(particle.x, particle.y)
        end
        
        if particle.life then
            particle.life = particle.life * 0.7
        end
    end
end

function create_blood(x, y, orientation)
    local ps =  make_psystem(minlife, maxlife, minstartsize, maxstartsize, minendsize, maxendsize)

    table.insert(ps.emittimers,
    {
        timerfunc = emittimer_burst,
        params = { num = num}
    }
    )
    if orientation == 1 then
        table.insert(ps.emitters,
        {
            emitfunc = emitter_point,
            params = { x = x, y = y, minstartvx = minstartvx, maxstartvx = maxstartvx, minstartvy = minstartvy, maxstartvy = maxstartvy }
        }
        )
    else
        table.insert(ps.emitters,
        {
            emitfunc = emitter_point,
            params = { x = x, y = y, minstartvx = -1*minstartvx, maxstartvx = -1*maxstartvx, minstartvy = minstartvy, maxstartvy = maxstartvy }
        }
        )
    end
    table.insert(ps.drawfuncs,
    {
        drawfunc = draw_ps_pixel,
        params = { colors = blood_colors }
    }
    )
    table.insert(ps.affectors,
    {
        affectfunc = affect_force,
        params = { fx = fx, fy = fy}
    }
    )
    table.insert(ps.affectors,
    {
        affectfunc = affect_stopzone,
        params = { zoneminx = zoneminx, zonemaxx = zonemaxx, zoneminy = zoneminy, zonemaxy = zonemaxy }
    }
    )
     table.insert(ps.affectors, {
        affectfunc = affect_blood_collision,
        params = {}
    }
    )
end
