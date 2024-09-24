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

function russian_to_translit(string)
    result = {}
    for i = 1, string.len(string) do
        local byte = string.byte(string, i)
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
            -- число в -> ДВОИЧНОМ ВИДЕ <- 1️⃣ 0️⃣. То есть есть ШЕСТНАДЦАТЕРИЧНАЯ ⏱
            -- запись, а вот двоичную добавить -> ПОЛЕНИЛИСЬ <-
            --
            -- А мне теперь страдать, когда нужно парсить utf8 😊, ведь ТИК80 😐
            -- не дает мне UTF8 ИЗ СТАНДАРТНОЙ БИБЛИОТЕКИ https://www.lua.org/manual/5.3/manual.html#6.5
            -- То есть `string` из стандартной библиотеки есть ☹, а utf8 видите-ли нету!
            -- А мне что делать, спрашивается 🤬? Ответ снизу.
            --
            -- Отстой.
            --

            local next_byte = string.byte(string, i + 1)
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
    local string = table.concat(result)
    return string
end
