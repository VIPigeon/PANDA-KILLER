Debug = {}

Debug.debug_drawing_queue = {}

function Debug.add(draw_func)
    table.insert(Debug.debug_drawing_queue, draw_func)
end

function Debug.draw()
    for _, draw_func in ipairs(Debug.debug_drawing_queue) do
        draw_func()
    end
    Debug.debug_drawing_queue = {}
end
