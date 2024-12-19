--[[

Рисуйте текст через draw_text_centered_at(...)
Все реплики оборачивайте в localize(...)

Пример использования внизу файла. Больше документации
писать не буду, лень 🐒

]]--

-- Ссылка на святую святых 👼
-- https://www.unicode.org/charts/PDF/U0400.pdf
RUSSIAN_TO_ENGLISH_OBSCURE_TABLE = {
    [0x401] = 't', -- Ё КАК Е
    [0x410] = 'f', -- А
    [0x411] = ',', -- Б
    [0x412] = 'd', -- В
    [0x413] = 'u', -- Г
    [0x414] = 'l', -- Д
    [0x415] = 't', -- Е
    [0x416] = ';', -- Ж
    [0x417] = 'p', -- З
    [0x418] = 'b', -- И
    [0x419] = 'q', -- Й
    [0x41a] = 'r', -- К
    [0x41b] = 'k', -- Л
    [0x41c] = 'v', -- М
    [0x41d] = 'y', -- Н
    [0x41e] = 'j', -- О
    [0x41f] = 'g', -- П
    [0x420] = 'h', -- Р
    [0x421] = 'c', -- С
    [0x422] = 'n', -- Т
    [0x423] = 'e', -- У
    [0x424] = 'a', -- Ф
    [0x425] = '[', -- Х
    [0x426] = 'w', -- Ц
    [0x427] = 'x', -- Ч
    [0x428] = 'i', -- Ш
    [0x429] = 'o', -- Щ
    [0x42a] = ']', -- Ъ
    [0x42b] = 's', -- Ы
    [0x42c] = 'm', -- Ь
    [0x42d] = '\'', -- Э
    [0x42e] = '.', -- Ю
    [0x42f] = 'z', -- Я

    -- Я ИДУ В ЗАД
    -- lt`;pbqrkvyjghcne[wxio]sm'.z
    -- a,duдеёжзийклмнопрсту
}

function russian_to_translit(s)
    result = {}
    for i = 1, string.len(s) do
        local byte = string.byte(s, i)
        if (byte & 0xd0) == 0xd0 then
            --
            -- +---------------+
            -- | GOOGLE PLAY ▶ |
            -- +---------------+
            --
            -- В 21:36, 24.09.2024, kawaii-Code оставил отзыв о продукте *lua*:
            --
            --             **ПОЛНЫЙ ОТСТОЙ**      1 ⭐ /  5 ⭐⭐⭐⭐⭐
            --
            --
            -- Обычно я думаю хорошо о Бразилии 🥭🍹⚽☕, но сегодня...
            --
            -- Я ПИСАЛ ЭТОТ КОД 1 ЧАС 🤬, НЕТ, БЕЗ ШУТОК, ЭТИ
            -- 6 СТРОЧЕК ЗАНЯЛИ 1 ЧАС 🤬, НЕТ, ДАЖЕ БОЛЬШЕ, О
            -- ГОСПОДИ!!!!!!!!! 🤬 🤬 🤬 💀
            --
            -- А всё из-за того, что в lua, помимо итак отвратительного 
            -- индексирования с 1, бразильцы даже не додумались, что, ВНИМАНИЕ,
            -- кому-то в их языке понадобится возможность запись
            -- число в -> ДВОИЧНОМ ВИДЕ <- 1️⃣ 0️⃣. То есть есть ШЕСТНАДЦАТЕРИЧНАЯ 🕓
            -- запись, а вот двоичную добавить -> ПОЛЕНИЛИСЬ <-
            --
            -- А мне теперь страдать, когда нужно парсить utf8 😊, ведь ТИК80 😐
            -- не дает мне UTF8 ИЗ СТАНДАРТНОЙ БИБЛИОТЕКИ https://www.lua.org/manual/5.3/manual.html#6.5
            -- То есть `string` из стандартной библиотеки есть 😠, а utf8 видите-ли нету!
            -- А мне что делать, спрашивается 🤬? Ответ снизу.
            --

            local next_byte = string.byte(s, i + 1)
            local x = next_byte & 0xf
            local y = ((byte & 0x3) << 2) | (next_byte & 0x30) >> 4
            local z = (byte & 0x1c) >> 2
            local final = x | (y << 4) | (z << 8)

            local translation = RUSSIAN_TO_ENGLISH_OBSCURE_TABLE[final]
            if translation ~= nil then
                table.insert(result, translation)
            else
                error(string.format('bad char %x. Obratites k kawaii-Code, tolko on znaet kak rabotaet eta meshanina 💀', final))
            end
        elseif byte & 0x80 == 0 then
            table.insert(result, string.char(byte))
        end
    end
    local translitted = table.concat(result)
    return translitted
end

-- Используется в начале игры
function draw_language_selection_boxes()
    local padding = 10
    local box_width = 30
    local box_height = 20

    local char_width = 8
    local char_height = 6

    local x = SCREEN_WIDTH / 2 - box_width - padding / 2
    local y = SCREEN_HEIGHT / 2 - box_height / 2
    local x2 = x + box_width + padding

    local color_ru = 7
    local color_en = 7
    if game.language == 'en' then
        color_en = 14
    else
        color_ru = 14
    end

    cls(0)

    draw_text_centered_at_x('PANDA_KILLER', SCREEN_WIDTH/2 + 12, 10, char_width, char_height, true, 2)
    draw_text_centered_at_x(localize(TEXT__CHOOSE_YOUR_LANGUAGE), SCREEN_WIDTH/2, y - box_height)

    rect(x, y, box_width, box_height, color_en)
    font('EN', x + box_width/2 - char_width/2, y + box_height/2 - char_height/2)

    rect(x2, y, box_width, box_height, color_ru)
    font('RU', x2 + box_width/2 - char_width/2, y + box_height/ 2 - char_height/2)

    draw_text_centered_at_x(localize(TEXT__PRESS_Z_TO_START), SCREEN_WIDTH/2, y + 2 * box_height)
    draw_text_centered_at_x(localize(TEXT__PRESS_RIGHTLEFT_TO_SELECT), SCREEN_WIDTH/2, y + 2.75 * box_height)
end

function localize(text_entry_in_data)
    if game.language == 'en' then
        return text_entry_in_data['en']
    else
        return russian_to_translit(text_entry_in_data['ru'])
    end
end

function draw_text_centered_at_x(text, x, y, char_width, char_height, fixed, scale)
    local width = measure_text_width(text, char_width, char_height, fixed, scale)
    if char_width == nil then
        font(text, x - width / 2, y)
    else
        font(text, x - width / 2, y, 0, char_width, char_height, fixed, scale)
    end
end

function measure_text_width(text, char_width, char_height, fixed, scale)
    if char_width == nil then
        return font(text, 10000, 10000)
    end
    return font(text, 10000, 10000, 0, char_width, char_height, fixed, scale)
end
