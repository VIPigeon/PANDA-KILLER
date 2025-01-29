--[[

Спрайт состоит из нескольких анимаций 🎞️
Анимация -- набор кадров, у которых одинаковый размер и длительность.
Кадр -- это айдишник спрайта из тика, типа 380.
Эффекты -- спрайты на какой-то позиции, которые проигрывают один раз свою анимацию и останавливаются

Анимация также может указывать куда переходить после того как она закончится:
На какой-то из своих кадров или на какую-то другую анимацию. Примеры можно
посмотреть, как всегда, в игроке.

Сама анимация сделано с помощью паттерна Builder 🤮. Простите, как главный
хейтер ООП, у меня всё же не получилось удержаться. Это ведь так красиво
выглядит при использовании (посмотрите на эти цепочки методов, ух...).
Моя вина... Простите...

]]--


Sprite = {}

function Sprite:new(frames, single_frame_duration, width, height)
    single_frame_duration = single_frame_duration or 1
    width = width or 1
    height = height or 1
    local animation_sequence = Animation:new(frames, single_frame_duration):with_size(width, height)
    return Sprite:new_complex({animation_sequence})
end

function Sprite:new_complex(animation_sequence)
    local object = {
        animation_sequence = animation_sequence,
        animation_index = 1,
        frame_index = 1,
        current_frame_duration = 1,
    }

    setmetatable(object, self)
    return object
end

function Sprite:current_animation()
    return self.animation_sequence[self.animation_index]
end

function Sprite:current_frame()
    return self:current_animation().frames[self.frame_index]
end

function Sprite:animation_ended()
    return self.animation_index == #self.animation_sequence and
           self.frame_index == #self:current_animation().frames and
           self.current_frame_duration == self:current_animation().single_frame_duration
end

function Sprite:reset()
    self.frame_index = 1
    self.animation_index = 1
    self.current_frame_duration = 1
end

function Sprite:next_frame()
    local animation = self:current_animation()
    if self.current_frame_duration >= animation.single_frame_duration then
        self.current_frame_duration = 1
        if self.frame_index >= #animation.frames then
            self.frame_index = 1
            if animation.next_animation_index ~= nil then
                self.animation_index = animation.next_animation_index
            elseif animation.next_frame_index ~= nil then
                self.frame_index = animation.next_frame_index
            else
                self.animation_index = self.animation_index % #self.animation_sequence + 1
            end
        else
            self.frame_index = self.frame_index + 1
        end
    else
        self.current_frame_duration = self.current_frame_duration + 1
    end
end

function Sprite:draw(x, y, flip, rotate)
    local animation = self:current_animation()
    spr(self:current_frame(), x, y, C0, 1, flip, rotate, animation.width, animation.height)
end

function Sprite:copy()
    return Sprite:new_complex(self.animation_sequence)
end

Sprite.__index = Sprite
