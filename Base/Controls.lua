BUTTON_UP    = 0
BUTTON_DOWN  = 1
BUTTON_LEFT  = 2
BUTTON_RIGHT = 3

BUTTON_Z = 4
BUTTON_X = 5
BUTTON_A = 6
BUTTON_S = 7

ALL_BINDABLE_BUTTONS = {
    BUTTON_UP,
    BUTTON_DOWN,
    BUTTON_LEFT,
    BUTTON_RIGHT,
    BUTTON_Z,
    BUTTON_X,
    BUTTON_A,
    BUTTON_S,
}

KEY_W = 23
KEY_A = 01
KEY_S = 19
KEY_D = 04
KEY_N = 14
KEY_SPACE = 48

KEY_E = 5
KEY_F = 6
KEY_J = 10

KEY_P = 16
KEY_Q = 17

ALL_BINDABLE_KEYS = {
    KEY_W,
    KEY_A,
    KEY_S,
    KEY_D,
    KEY_N,
    KEY_SPACE,
    KEY_E,
    KEY_F,
    KEY_J,
    KEY_P,
    KEY_Q,
}

KEY_NAMES = {
    [KEY_W] = "W",
    [KEY_A] = "A",
    [KEY_S] = "S",
    [KEY_D] = "D",
    [KEY_SPACE] = "SPACE",
    [KEY_N] = "N",
    [KEY_J] = "J",
    [KEY_P] = "P",
    [KEY_Q] = "Q",
    [KEY_F] = "F",
    [KEY_E] = "E",
}

BUTTON_NAMES = {
    [BUTTON_UP] = "DPAD UP",
    [BUTTON_DOWN] = "DPAD DOWN",
    [BUTTON_LEFT] = "DPAD LEFT",
    [BUTTON_RIGHT] = "DPAD RIGHT",
    [BUTTON_Z] = "BTN Z",
    [BUTTON_X] = "BTN X",
    [BUTTON_A] = "BTN A",
    [BUTTON_S] = "BT S",
}

--[[

Таблица переводов кнопок контроллеров.
Кто-то же должен это делать 🤓

+------+-----------+----------+-----------+
| XBOX |    PS4    | Keyboard | Direction |
+------+-----------+----------+-----------+
|  A   |  cross    |    z     |   south   |
|  B   |  circle   |    x     |   east    |
|  X   |  square   |    a     |   west    |
|  Y   |  triangle |    s     |   north   |
+------+-----------+----------+-----------+

]]--

--
-- Бинды на клавиши ⌨️
--
CONTROLS = {
    left      = { keys = { KEY_A },     buttons = { BUTTON_LEFT }, },
    right     = { keys = { KEY_D },     buttons = { BUTTON_RIGHT }, },
    look_up   = { keys = { KEY_W },     buttons = { BUTTON_UP }, },
    look_down = { keys = { KEY_S },     buttons = { BUTTON_DOWN }, },
    jump      = { keys = { KEY_SPACE }, buttons = { BUTTON_Z }, },
    attack    = { keys = { KEY_E, KEY_F, KEY_J },           buttons = { BUTTON_X,  }, },
    escape    = { keys = { KEY_Q },     buttons = {  }, },
}

DEFAULT_CONTROLS = {
    left      = { keys = { KEY_A },     buttons = { BUTTON_LEFT }, },
    right     = { keys = { KEY_D },     buttons = { BUTTON_RIGHT }, },
    look_up   = { keys = { KEY_W },     buttons = { BUTTON_UP }, },
    look_down = { keys = { KEY_S },     buttons = { BUTTON_DOWN }, },
    jump      = { keys = { KEY_SPACE }, buttons = { BUTTON_Z }, },
    attack    = { keys = { KEY_E, KEY_F, KEY_J },           buttons = { BUTTON_X,  }, },
    escape    = { keys = { KEY_Q },     buttons = {  }, },
}


function was_just_pressed(control)
    for _, keyboard_key in ipairs(control.keys) do
        if keyp(keyboard_key) then
            return true
        end
    end
    for _, button in ipairs(control.buttons) do
        if btnp(button) then
            return true
        end
    end
    return false
end

function is_held_down(control)
    for _, keyboard_key in ipairs(control.keys) do
        if key(keyboard_key) then
            return true
        end
    end
    for _, button in ipairs(control.buttons) do
        if btn(button) then
            return true
        end
    end
    return false
end
