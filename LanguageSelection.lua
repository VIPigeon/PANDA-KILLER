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
