--[[


AnimationController, что неудивительно, управляет анимации. У него
есть один текущий спрайт, у которого он проигрывает анимацию с
помощью next_frame()

Также можно менять спрайты с помощью set_sprite()

Спрайт:   несколько анимаций (зачастую только одна) 🎞️
Анимация: последовательность кадров, у которых одинаковый размер и длительность.
Кадр:     id спрайта, и больше ничего.

Анимация также может указывать куда переходить после того как она закончится:
На какой-то из своих кадров (по умолчанию на самый первый, то есть по умолчанию
анимация циклится) или на какую-то другую анимацию из тех, что есть
в спрайте. Примеры можно посмотреть в Data.lua, особенно рекомендую посмотреть
на анимацию скольжения по стене и осознать как она работает.

Сама анимация сделано с помощью паттерна Builder. No comments.


Если честно, у меня очень плохо получается дизайнить эту систему с анимациями.
Пока что она такая себе. А особенно сложно придумывать имена. В общем, принимаются
комментарии.


Давайте объясню как я пришел к AnimationController ️🏛️

Проблема: вот как выглядел кусок из Panda:new() до рефакторинга:

    sprites = {
            rest = PANDA_SPRITES.rest:copy(),
            patrol = PANDA_SPRITES.walk:copy(),
            chase = PANDA_SPRITES.chase:copy(),
            charging_dash = PANDA_SPRITES.charging_dash:copy(),
            charging_basic_attack = PANDA_SPRITES.charging_basic_attack:copy(),
            dash = PANDA_SPRITES.dash:copy(),
    },

Прошу обратить особое внимание на copy(). Это означает, что для каждой новой панды
создавалась вот такая большая таблица спрайтов. Во первых, это лишний код, поскольку
все спрайты уже объявлены в PANDA_SPRITES, зачем дублировать здесь эту информацию?
Во вторых, это неэффективно.

Я решил эту проблему отделив данные неизменяемые (кадры в анимации, её длительность,
размер, переходы) от данных изменяемых (текущий кадр, текущая анимация).
Изменяемые данные я вынес в AnimationController, и он теперь заправляет всем этим делом.

]]--


Sprite = {}

function Sprite:new(frames, single_frame_duration, width, height)
    single_frame_duration = single_frame_duration or 1
    width = width or 1
    height = height or 1
    return Animation:new(frames, single_frame_duration):with_size(width, height):to_sprite()
end

function Sprite:new_complex(animation_sequence)
    local object = {
        animation_sequence = animation_sequence,
    }

    setmetatable(object, self)
    return object
end

function Sprite:draw(x, y, flip, rotate, width, height)
    -- TODO:
    -- Это не дело, если что. Так нельзя.
    -- ОЧЕНЬ ПЛОХО ‼️
    local animation = self.animation_sequence[1]
    spr(animation.frames[1], x, y, C0, 1, flip, rotate, animation.width, animation.height)
end

Sprite.__index = Sprite
