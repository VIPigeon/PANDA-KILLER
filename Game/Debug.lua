Debug = {}

Debug.debug_drawing_queue = {}

function Debug.add(draw_func, frames)
    frames = frames or 1
    table.insert(Debug.debug_drawing_queue, { draw = draw_func, frames = frames })
end

function Debug.draw()
    new_drawing_queue = {}
    for _, debug in ipairs(Debug.debug_drawing_queue) do
        debug.draw()
        if debug.frames > 0 then
            table.insert(new_drawing_queue { draw = debug.draw, frames = debug.frames - 1 })
        end
    end
    Debug.debug_drawing_queue = new_drawing_queue
end
