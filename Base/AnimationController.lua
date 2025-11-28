--[[

Читайте документацию в Sprite.lua

-- MakiaTrevozhin@sysithus.jam
Не читал документацию, все фичи, что добавил работают🥰

--]]


AnimationController = {}

function AnimationController:new(first_sprite, need_custom_scale, scale)
    need_custom_scale = need_custom_scale or false

    -- idk how game inits game.scale must be below
    scale = scale or data.STANDART_SCALE
    local custom_scale = nil

    if need_custom_scale then
        custom_scale = scale
    end

    local object =  {
        sprite = first_sprite,
        current_animation_index = 1,
        current_frame_index = 1,
        current_frame_duration = 1,
        custom_scale = custom_scale,
    }

    setmetatable(object, self)
    return object
end

function AnimationController:next_frame()
    local animation = self:current_animation()
    if self.current_frame_duration >= animation.single_frame_duration then
        self.current_frame_duration = 1
        if self.current_frame_index >= #animation.frames then
            self.current_frame_index = 1
            if animation.next_animation_index ~= nil then
                self.current_animation_index = animation.next_animation_index
            elseif animation.next_frame_index ~= nil then
                self.current_frame_index = animation.next_frame_index
            else
                self.current_animation_index = self.current_animation_index % #self.sprite.animation_sequence + 1
            end
        else
            self.current_frame_index = self.current_frame_index + 1
        end
    else
        self.current_frame_duration = self.current_frame_duration + 1
    end
end

function AnimationController:current_animation()
    return self.sprite.animation_sequence[self.current_animation_index]
end

function AnimationController:current_frame()
    return self:current_animation().frames[self.current_frame_index]
end

function AnimationController:is_at_last_frame()
    return self.current_animation_index == #self.sprite.animation_sequence and
           self.current_frame_index == #self:current_animation().frames
end

function AnimationController:animation_ended()
    return self.current_animation_index == #self.sprite.animation_sequence and
           self.current_frame_index == #self:current_animation().frames and
           self.current_frame_duration == self:current_animation().single_frame_duration
end

function AnimationController:reset_animation()
    self.current_animation_index = 1
    self.current_frame_index = 1
    self.current_frame_duration = 1
end

function AnimationController:set_sprite(new_sprite)
    if self.sprite ~= new_sprite then
        self:reset_animation()
        self.sprite = new_sprite
    end
end

function AnimationController:draw(x, y, flip, rotate)
    local animation = self:current_animation()
    local current_scale = self.custom_scale or game.scale

    -- Вот здесь безумные костыли, которые созданы ТОЛЬКО для катсцены.
    -- То есть был попорчен обычный код каким-то специальным случаем.
    -- Поэтому я говорил, что лучше уж продублировать часть кода, чем
    -- портить существующую штуку. Вообще в данной ситуации надо было
    -- бы сделать draw_with_scale какой-нибудь и было бы ок. 😇
    x = x - (current_scale - 1) * 48
    y = y + 24 * (current_scale - 1) - 8 * current_scale * (self:current_animation().height - 1)

    spr(self:current_frame(), x, y, C0, current_scale, flip, rotate, animation.width, animation.height)
end

function AnimationController:draw_at_screen_coordinates(x, y, flip, rotate)
    local animation = self:current_animation()

    local scale = 2
    local y = y - 8 * game.scale * (animation.height - 1)
    spr(self:current_frame(), x, y, C0, scale, flip, rotate, animation.width, animation.height)
end

AnimationController.__index = AnimationController
