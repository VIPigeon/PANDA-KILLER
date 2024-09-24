local Time = {
    total_time_passed_ms = 0,
    -- Хранится в миллисекундах, например 16.837
    delta_ms = 0,
}

function Time.update()
    local time = time()
    Time.delta_ms = time - Time.total_time_passed_ms
    Time.total_time_passed_ms = time
end

-- Возвращает время, которое занял ПРЕДЫДУЩИЙ (но это не очень важно) кадр в секундах, например 0.016 (16 миллисекунд)
-- TODO Добавьте функцию для определения времени, занятое СЛЕДУЮЩИМ кадром, пожалуйста
function Time.dt()
    return Time.delta_ms / 1000.0
end

return Time
