-- Времена полотен документации прошли, время - деньги, а тут и так всё просто
-- Плюс, ии-агент и так пишет неплохие комментарии

GameMenu = {}

-- Может это в game уже и есть, я не смотрел
GameMenu.last_game_state = GAME_STATE_PAUSED

-- trace(GameMenu.last_game_state)

-- настройки/константы меню
GameMenu.w = 240
GameMenu.h = 136

GameMenu.selected = 1
GameMenu.current_screen = "root"

GameMenu.rebinding = false
GameMenu.rebinding_action = nil

GameMenu.bg_changed = false -- костыль для взлома tic на бесконечный фон


GameMenu.screens = {
    root = {
        type = "list",
        items = {
            { id = "resume",   label = TEXT.MENU_OPTION_CONTINUE, action = "resume_game" },
            { id = "settings", label = TEXT.MENU_OPTION_SETTINGS, action = "goto_settings" },
            { id = "mainmenu", label = TEXT.MENU_OPTION_MAIN_MENU, action = "go_mainmenu" },
        }
    },

    settings = {
        type = "list",
        items = {
            { id = "bindings", label = TEXT.SETTINGS_CONTROLS,          action = "goto_bindings" },
            { id = "reset",    label = TEXT.SETTINGS_RESET_DEFAULTS,    action = "reset_defaults" },
            { id = "back",     label = TEXT.SETTINGS_BACK,              action = "back_to_root" },
        }
    },

    bindings = {
        type = "bindings"
    }
}


-- геометрия/верстка (потом подогнать)
GameMenu.title_y = 0
GameMenu.first_option_y = 16
GameMenu.option_step_y = 16
GameMenu.left_x_pad = 8
GameMenu.action_col_x = 96
GameMenu.key_col_x = 8

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

-- для списков
GameMenu.scroll = 0
GameMenu.visible_count = 7 -- сколько строк помещается на экран

GameMenu.draw_titles = False

-- TODO актуализировать
GameMenu.binding_items = {
    { id = "look_up",   label = localize(TEXT.CONTROL_LABELS.look_up) },
    { id = "look_down", label = localize(TEXT.CONTROL_LABELS.look_down) },
    { id = "left",      label = localize(TEXT.CONTROL_LABELS.left) },
    { id = "right",     label = localize(TEXT.CONTROL_LABELS.right) },
    { id = "jump",      label = localize(TEXT.CONTROL_LABELS.jump) },
    { id = "attack",    label = localize(TEXT.CONTROL_LABELS.attack) },
    { id = "escape",    label = localize(TEXT.CONTROL_LABELS.escape) },
    --
    -- { id = "look_up",   label = localize(TEXT.CONTROL_LABELS.look_up) },
    -- { id = "look_down", label = localize(TEXT.CONTROL_LABELS.look_down) },
    -- { id = "left",      label = localize(TEXT.CONTROL_LABELS.left) },
    -- { id = "right",     label = localize(TEXT.CONTROL_LABELS.right) },
    -- { id = "jump",      label = localize(TEXT.CONTROL_LABELS.jump) },
    -- { id = "attack",    label = localize(TEXT.CONTROL_LABELS.attack) },
    -- { id = "escape",    label = localize(TEXT.CONTROL_LABELS.escape) },
}

function GameMenu:is_active()
    -- trace('last state '..GameMenu.last_game_state..' '..GAME_STATE_PAUSED)
    return GameMenu.last_game_state ~= GAME_STATE_PAUSED
end

function GameMenu:get_screen()
    return GameMenu.screens[GameMenu.current_screen]
end

function GameMenu:set_screen(screen_id)
    GameMenu.current_screen = screen_id
    GameMenu.selected = 1
    GameMenu.scroll = 0
    GameMenu.rebinding = false
    GameMenu.rebinding_action = nil
end

function GameMenu:get_item_count()
    local screen = GameMenu:get_screen()

    if screen.type == "list" then
        return #screen.items
    elseif screen.type == "bindings" then
        -- список биндов + Reset + Back
        return #GameMenu.binding_items + 2
    end

    return 0
end

function GameMenu:option_y(index)
    return GameMenu.first_option_y + (index - 1) * GameMenu.option_step_y
end

function GameMenu:update_scroll()
    local sel = GameMenu.selected
    local top = GameMenu.scroll
    local bottom = top + GameMenu.visible_count - 1

    if sel < top + 1 then
        GameMenu.scroll = sel - 1
    elseif sel > bottom then
        GameMenu.scroll = sel - GameMenu.visible_count
    end

    -- защита
    if GameMenu.scroll < 0 then GameMenu.scroll = 0 end
end

function GameMenu:move_selection(delta)
    local n = GameMenu:get_item_count()
    GameMenu.selected = math.clamp(GameMenu.selected + delta, 1, n)
    
    GameMenu:update_scroll()
end

function GameMenu:activate_selected()
    local screen = GameMenu:get_screen()
    if not screen then return end

    if screen.type == "list" then
        local item = screen.items[GameMenu.selected]
        if item and item.action then
            GameMenu:run_action(item.action)
        end
        return
    end

    if screen.type == "bindings" then
        local bindings_count = #GameMenu.binding_items

        if GameMenu.selected <= bindings_count then
            -- начали перебинд нужного действия
            local bind_item = GameMenu.binding_items[GameMenu.selected]
            GameMenu.rebinding = true
            GameMenu.rebinding_action = bind_item.id
            return
        end

        if GameMenu.selected == bindings_count + 1 then
            GameMenu:reset_controls_to_default()
            return
        end

        if GameMenu.selected == bindings_count + 2 then
            GameMenu:set_screen("settings")
            return
        end
    end
end

-- как бы нельзя будет делать и кнопки и ключи, но если кто-то зарепортит, тогда будем фиксить
function GameMenu:update_rebinding()
    local input = get_just_pressed_key_name()
    if not input then
        return
    end

    local control = CONTROLS[GameMenu.rebinding_action]

    if input.type == "key" then
        control.keys = { input.code }
        control.buttons = {}
    else
        control.buttons = { input.code }
        control.keys = {}
    end

    GameMenu.rebinding = false
    GameMenu.rebinding_action = nil
end

-- TODO contorls default
function GameMenu:reset_controls_to_default()
    for action, key in pairs(DEFAULT_CONTROLS) do
        CONTROLS[action] = key
    end
end

function get_control_name(control)
    if #control.keys > 0 then
        return KEY_NAMES[control.keys[1]] or "KEY"
    end

    if #control.buttons > 0 then
        return BUTTON_NAMES[control.buttons[1]] or "BTN"
    end

    return "-"
end

function GameMenu:run_action(action)
    if action == "resume_game" then
        GameMenu:resume_game()
    elseif action == "goto_settings" then
        GameMenu:set_screen("settings")

    elseif action == "goto_bindings" then
        GameMenu:set_screen("bindings")

    elseif action == "back_to_root" then
        GameMenu:set_screen("root")

    elseif action == "reset_defaults" then
        GameMenu:reset_controls_to_default()

    elseif action == "go_mainmenu" then
        -- заглушка
    end
end

function get_just_pressed_key_name()
    for _, k in ipairs(ALL_BINDABLE_KEYS) do
        if keyp(k) then
            return { type = "key", code = k }
        end
    end

    for _, b in ipairs(ALL_BINDABLE_BUTTONS) do
        if btnp(b) then
            return { type = "button", code = b }
        end
    end

    return nil
end

function GameMenu:resume_game()
    -- у нас нет функции swap, как сделаем, заменим
    temp = game.state
    game.state = GameMenu.last_game_state
    GameMenu.last_game_state = temp
    GameMenu:on_close()
end

function GameMenu:update()
    local escape_pressed = was_just_pressed(CONTROLS.escape)

    -- trace('HI THERE!'..GameMenu.last_game_state)

    if escape_pressed and not GameMenu.rebinding then
        GameMenu:resume_game()
    end

    -- trace('LOL THERE! '..GameMenu.last_game_state)

    if not GameMenu:is_active() then
        return
    end

    if GameMenu.rebinding then
        GameMenu:update_rebinding()
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

function GameMenu:on_close()
    GameMenu:set_screen("root")
    if GameMenu.bg_changed then
        palette.colorChange(
            0, 
            GameMenu.default_bg_color.r, 
            GameMenu.default_bg_color.g, 
            GameMenu.default_bg_color.b
        )
        GameMenu.bg_changed = false
        -- trace('bg default')
    end
end

function GameMenu:draw_list_screen(screen)
    local total = #screen.items

    local start_i = GameMenu.scroll + 1
    local end_i = math.min(start_i + GameMenu.visible_count - 1, total)

    -- курсор с учётом scroll
    local cursor_screen_index = GameMenu.selected - GameMenu.scroll
    local cy = GameMenu:option_y(cursor_screen_index) - GameMenu.cursor_pad_y
    rect(GameMenu.cursor_x, cy, GameMenu.cursor_w, GameMenu.cursor_h, GameMenu.col_cursor)

    for i = start_i, end_i do
        local item = screen.items[i]

        local draw_i = i - GameMenu.scroll
        local y = GameMenu:option_y(draw_i)

        local is_sel = (i == GameMenu.selected)
        local col = is_sel and GameMenu.col_cursor_text or GameMenu.col_text

        local txt = type(item.label) == "string" and item.label or localize(item.label)
        font(txt, GameMenu.left_x_pad, y, col, false, 1)
    end

end

function GameMenu:draw_bindings_screen()
    local total = GameMenu:get_item_count()
    local bindings_count = #GameMenu.binding_items

    local start_i = GameMenu.scroll + 1
    local end_i = math.min(start_i + GameMenu.visible_count - 1, total)

    local cursor_screen_index = GameMenu.selected - GameMenu.scroll
    local cy = GameMenu:option_y(cursor_screen_index) - GameMenu.cursor_pad_y
    rect(GameMenu.cursor_x, cy, GameMenu.cursor_w, GameMenu.cursor_h, GameMenu.col_cursor)

    -- заголовки колонок, если нужны, скорее кринж
    if GameMenu.draw_titles then
        font(localize(TEXT.CONTROL_LABELS.action_col_label), GameMenu.action_col_x, 4, GameMenu.col_title, false, 1)
        font(localize(TEXT.CONTROL_LABELS.key_col_label), GameMenu.key_col_x, 4, GameMenu.col_title, false, 1)
    end

    for i = start_i, end_i do
        local draw_i = i - GameMenu.scroll
        local y = GameMenu:option_y(draw_i)

        local is_sel = (i == GameMenu.selected)
        local col = is_sel and GameMenu.col_cursor_text or GameMenu.col_text

        if i <= bindings_count then
            local item = GameMenu.binding_items[i]

            local action_name = item.label
            local key_name = get_control_name(CONTROLS[item.id])

            if GameMenu.rebinding and GameMenu.rebinding_action == item.id then
                key_name = localize(TEXT.CONTROL_LABELS.key_rebinding_label)
            end

            font(action_name, GameMenu.action_col_x, y, col, false, 1)
            font(key_name, GameMenu.key_col_x, y, col, false, 1)

        -- Reset Defaults
        elseif i == bindings_count + 1 then
            font(localize(TEXT.SETTINGS_RESET_DEFAULTS), GameMenu.action_col_x, y, col, false, 1)

        -- Back
        elseif i == bindings_count + 2 then
            font(localize(TEXT.SETTINGS_BACK), GameMenu.action_col_x, y, col, false, 1)
        end
        
    end
end

function GameMenu:draw()
    if not GameMenu:is_active() then
        -- trace('not active')
        return
    end

    if not GameMenu.bg_changed then
        GameMenu.default_bg_color = palette.getColor(0)
        GameMenu.menu_bg_color = palette.getColor(GameMenu.col_bg)

        palette.colorChange(
            0, 
            GameMenu.menu_bg_color.r, 
            GameMenu.menu_bg_color.g, 
            GameMenu.menu_bg_color.b
        )

        GameMenu.bg_changed = true
        -- trace('bg menued')
    end

    rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, GameMenu.col_bg)

    local screen = GameMenu:get_screen()
    if not screen then return end

    if screen.type == "list" then
        GameMenu:draw_list_screen(screen)
    elseif screen.type == "bindings" then
        GameMenu:draw_bindings_screen()
    end

    -- overlay всегда рисуется последним
    if GameMenu.rebinding then
        local text = localize(TEXT.SETTINGS_PRESS_KEY_TO_REBIND)

        local w = #text * 6
        local h = 10

        local x = (SCREEN_WIDTH - w) // 2
        local y = SCREEN_HEIGHT // 2 - 5

        -- затемнение (опционально, но сильно улучшает UX)
        rect(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT, 0)

        -- окно
        rect(x - 4, y - 2, w + 8, h, GameMenu.col_bg)

        font(text, x, y, GameMenu.col_text, false, 1)
    end

    
end