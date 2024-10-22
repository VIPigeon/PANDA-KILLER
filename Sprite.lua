Sprite = {}

function Sprite.generate_animation(t, n)
    res = {}
    for _, e in ipairs(t) do
        for i = 1, n do
            table.insert(res, e)
        end
    end
    return res
end

-- Супер легаси 🧟
function Sprite.gen60(t)
    -- #t -- делитель 60
    res = {}
    for _, pict in ipairs(t) do
        for i=1, 60 // (#t) do
            table.insert(res, pict)
        end
    end
    return res
end

function Sprite:new(animation, width, height, donotloop)
    local w = width or 1
    local h = height or w
    local dontloop = false
    if donotloop ~= nil then
        dontloop = donotloop
    end

    local obj = {
        animation = animation,
        frame = 1,  -- номер кадра
        w = w,
        h = h,
        dontloop = dontloop,
    }

    setmetatable(obj, self)
    return obj
end

function Sprite:current(x, y, flip, rotate)
    return self.animation[self.frame]
end

function Sprite:getFrame()
    return self.frame
end

function Sprite:setFrame(frame)
    self.frame = math.round(frame)
end

function Sprite:nextFrame()
    if self.dontloop then
        if self.frame == #self.animation then
            return
        end
    end
    self.frame = self.frame % #self.animation + 1
end

function Sprite:draw(x, y, flip, rotate)
    spr(self.animation[self.frame], x, y, C0, 1, flip, rotate, self.w, self.h)
end

function Sprite:animationEnd()
    return self.frame == #self.animation
end

function Sprite:copy()
    return Sprite:new(self.animation, self.size)
end

Sprite.__index = Sprite
