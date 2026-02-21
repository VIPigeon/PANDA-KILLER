-- Времена полотен документации прошли, время - деньги, а тут и так всё просто
-- Плюс, ии-агент и так пишет неплохие комментарии

GameMenu = {}

-- Может это в game уже и есть, я не смотрел
GameMenu.last_game_state = GAME_STATE_PAUSED

trace(GameMenu.last_game_state)

-- настройки/константы меню
GameMenu.w = 240
GameMenu.h = 136

GameMenu.options = {
    { id = "resume",   label = TEXT.MENU_OPTION_CONTINUE },
    { id = "settings", label = TEXT.MENU_OPTION_SETTINGS },
    { id = "mainmenu", label = TEXT.MENU_OPTION_MAIN_MENU },
}

GameMenu.selected = 1

-- геометрия/верстка (потом подогнать)
GameMenu.title_y = 0
GameMenu.first_option_y = 16
GameMenu.option_step_y = 16
GameMenu.left_x_pad = 8

GameMenu.cursor_pad_y = 3         -- отступ курсора сверху/снизу вокруг текста
GameMenu.cursor_h = 12            -- высота полосы курсора (можно вычислять, но так проще)
GameMenu.cursor_x = 0
GameMenu.cursor_w = GameMenu.w

-- локальные цвета (потом заменить)
GameMenu.col_bg = 10
GameMenu.col_title = 12
GameMenu.col_text = 15
GameMenu.col_cursor = 5
GameMenu.col_cursor_text = 0

function GameMenu:is_active()
    return GameMenu.last_game_state ~= GAME_STATE_PAUSED
end

function GameMenu:option_y(index)
    return GameMenu.first_option_y + (index - 1) * GameMenu.option_step_y
end

function GameMenu:move_selection(delta)
    local n = #GameMenu.options
    GameMenu.selected = math.clamp(GameMenu.selected + delta, 1, n)
end

function GameMenu:activate_selected()
    local opt = GameMenu.options[GameMenu.selected]
    if not opt then return end

    if opt.id == "resume" then
        -- Закрыть меню (вернуться в то состояние, которое было до паузы)
        -- Здесь game.state должен стать last_game_state, а last_game_state -> GAME_STATE_PAUSED
        game.state = GameMenu.last_game_state
        GameMenu.last_game_state = GAME_STATE_PAUSED

    elseif opt.id == "settings" then
        -- Заглушка, сидим не рыпаемся

    elseif opt.id == "mainmenu" then
        -- Заглушка, сидим не рыпаемся
        
    end
end

function GameMenu:update()
    local escape_pressed = was_just_pressed(CONTROLS.escape)
    
    -- trace('HI THERE!'..GameMenu.last_game_state)

    if escape_pressed then
        -- у нас нет функции swap, как сделаем, заменим
        temp = game.state
        game.state = GameMenu.last_game_state
        GameMenu.last_game_state = temp
    end

    -- trace('LOL THERE! '..GameMenu.last_game_state)

    if not GameMenu:is_active() then
        return
    end

    -- надо обрабатывать перемещения курсора как горизонтальную область (прямоугольник, растянутый на весь экран по горизонтали),
    -- которая перемещается только в пределах указанных в меню опций.

    local up_pressed = was_just_pressed(CONTROLS.look_up)
    local down_pressed = was_just_pressed(CONTROLS.look_down)

    if up_pressed then
        GameMenu:move_selection(-1)
    elseif down_pressed then
        GameMenu:move_selection(1)
    end

    local confirm_pressed = was_just_pressed(CONTROLS.jump) or was_just_pressed(CONTROLS.attack)

    if confirm_pressed then
        GameMenu:activate_selected()
    end

end

function GameMenu:draw()
    --trace(GameMenu:is_active())
    if not GameMenu:is_active() then
        return
    end

    -- показываем меню:
    -- залить весь фон каким-то цветом, есть три опции: продолжить, настройка (заглушка), главное меню (заглушка)

    -- фон
    -- cls(GameMenu.col_bg)
    rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, GameMenu.col_bg)

    -- заголовок - не нужен -_-
    -- local txt = localize(TEXT.MENU_TITLE)
    -- draw_text_centered_at_x(txt, (GameMenu.w // 2) - 18, GameMenu.title_y, GameMenu.col_title, true, 2)

    -- курсор: горизонтальная полоса на всю ширину, двигается по Y только по опциям
    local cy = GameMenu:option_y(GameMenu.selected) - GameMenu.cursor_pad_y
    rect(GameMenu.cursor_x, cy, GameMenu.cursor_w, GameMenu.cursor_h, GameMenu.col_cursor)

    -- опции
    for i, opt in ipairs(GameMenu.options) do
        local y = GameMenu:option_y(i)
        local is_sel = (i == GameMenu.selected)

        local col = is_sel and GameMenu.col_cursor_text or GameMenu.col_text
        -- выравнивание по центру (примерно)
        -- (в TIC-80 нет прямого measure текста, так что чуть грубо)
        local x = GameMenu.left_x_pad

        local txt = localize(opt.label)
        -- trace(txt)
        print(txt, x, y, col, false, 1)
        -- я не понимаю, почему это не работает, оставил плохой отзыв kawaiiQA
        draw_text_centered_at_x(txt, x, y, col, false, 1)
    end
end