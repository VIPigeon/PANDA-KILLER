
local minlife = 1000
local maxlife = 3000

local minstartsize = 1
local maxstartsize = 2

local minendsize = 0.5
local maxendsize = 0.5

local num = 5

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

function draw_blood(x,y,orientation) -- orientation (1 вправо) (-1 влево)
    -- ДАНЯ 🤬!! Используй константы.
    if btn(BUTTON_A) then --Использовать на кнопку X
        create_blood(x, y, orientation)
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
        params = { colors = {6} }
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
end
