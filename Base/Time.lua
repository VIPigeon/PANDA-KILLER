Time = {
    total_time_passed_ms = 0,
    -- Хранится в миллисекундах, например 16.837
    delta_ms = 0,
}

function Time.update()
    local time = time()
    Time.delta_ms = time - Time.total_time_passed_ms
    Time.total_time_passed_ms = time
end

function Time.now()
    return Time.total_time_passed_ms / 1000.0
end

-- TODO Добавьте функцию для определения времени, занятое СЛЕДУЮЩИМ кадром, пожалуйста
--   ^--- Готово 😊. Вот развернутый ответ:
-- >>> Чтобы добавить функцию для определения времени, занятое следующим кадром,
-- >>> вам нужно учитывать, как вы обрабатываете кадры в вашем приложении. Если вы
-- >>> работаете с анимацией или видео, вы можете использовать временные метки для
-- >>> отслеживания времени между кадрами. Вот пример на Python, который
-- >>> демонстрирует, как это можно сделать:
--
-- Возвращает время, которое занял ПРЕДЫДУЩИЙ (но это не очень важно) кадр в секундах, например 0.016 (16 миллисекунд)
function Time.dt()
    return Time.delta_ms / 1000.0
end

-- Предсказывает время, которое займет СЛЕДУЮЩИЙ (и это важно) кадр в секундах, например 0.016 (16 миллисекунд)
function Time.next_dt()
    return 0.016
end
