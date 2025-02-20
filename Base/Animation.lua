--[[

Почитать документацию про анимации можно в Sprite.lua

Пример:

PLAYER_SPRITE_SLIDE = Sprite:new_complex({
    Animation:new({448, 450}, 8):with_size(2, 2),
    Animation:new({452, 454}, 12):with_size(2, 2):at_end_goto_animation(2),
})

--]]

Animation = {}

function Animation:new(frames, single_frame_duration)
    local object = {
        frames = frames,
        single_frame_duration = single_frame_duration,
        width = 1,
        height = 1,
        next_frame_index = nil,
        next_animation_index = nil,
    }

    setmetatable(object, self)
    return object
end

function Animation:with_size(width, height)
    self.width = width
    self.height = height
    return self
end

function Animation:at_end_goto_frame(frame_index)
    assert(self.next_animation_index == nil)
    self.next_frame_index = frame_index
    return self
end

function Animation:at_end_goto_last_frame()
    assert(self.next_animation_index == nil)
    self.next_frame_index = #self.frames
    return self
end

function Animation:at_end_goto_animation(animation_index)
    assert(self.next_frame_index == nil)
    self.next_animation_index = animation_index
    return self
end

function Animation:to_sprite()
    return Sprite:new_complex({self})
end

Animation.__index = Animation
